module PursToMd.Config
  ( AppConfig(..)
  , AppConfigMandatory
  , AppConfigOptionalF
  , It
  , getConfig
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Error.Class (throwError)
import Data.Either (Either, note)
import Data.Foldable (fold)
import Data.Maybe (Maybe(..), optional)
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import MergeConfigs (mergeConfigs)
import Node.Process as Process
import Options.Applicative as O
import Pathy (AbsDir, AbsFile, (</>))
import Pathy as P
import Record as Record

------------------------------------------------------------------------------
-- Types
------------------------------------------------------------------------------

type AppConfigOptionalF :: (Type -> Type) -> Row Type
type AppConfigOptionalF f =
  ( debug :: f Boolean
  )

type AppConfigMandatory r =
  { inputPurs :: AbsFile
  , outputMd :: AbsFile
  , cwd :: AbsDir
  | r
  }

newtype AppConfig = AppConfig
  (AppConfigMandatory (AppConfigOptionalF It))

type It :: Type -> Type
type It a = a

------------------------------------------------------------------------------
-- Defaults
------------------------------------------------------------------------------

defaults :: { | AppConfigOptionalF It }
defaults =
  { debug: false
  }

------------------------------------------------------------------------------
-- CLI
------------------------------------------------------------------------------

parseCLI :: AbsDir -> O.ParserInfo ({ | AppConfigOptionalF Maybe } /\ AppConfigMandatory ())
parseCLI cwd = O.info (O.helper <*> parseArgs) $ fold
  [ O.fullDesc
  , O.progDesc "Convert PureScript files with comments to Markdown"
  , O.header "purs-to-md - Convert PureScript files with comments to Markdown"
  ]
  where
  parseArgs = ado
    inputPurs <- absFileOption cwd $ fold
      [ O.long "input-purs"
      , O.help "PureScript file to read from"
      ]

    outputMd <- absFileOption cwd $ fold
      [ O.long "output-md"
      , O.help "Markdown file to write to"
      ]

    debug <- optional $ O.switch $ fold
      [ O.long "debug"
      , O.help "Print debug information"
      ]

    in { debug } /\ { inputPurs, outputMd, cwd }

absFileOption :: AbsDir -> O.Mod O.OptionFields AbsFile -> O.Parser AbsFile
absFileOption cwd = O.option (O.eitherReader $ readAbsFile cwd)

readAbsFile :: AbsDir -> String -> Either String AbsFile
readAbsFile cwd str =
  let
    parseAbs = P.parseAbsFile P.posixParser str
    parseRel = P.parseRelFile P.posixParser str
    parseAbsFromRel = ado
      rel <- parseRel
      in cwd </> rel
  in
    (parseAbs <|> parseAbsFromRel)
      # note ("Could not parse file: " <> str)

------------------------------------------------------------------------------
-- Config
------------------------------------------------------------------------------

getConfig :: Aff AppConfig
getConfig = do
  cwd <- getCwd
  cliConfigOptional /\ configMandatory <- liftEffect $ O.execParser $ parseCLI cwd
  let config = mergeConfigs [ cliConfigOptional ] defaults
  pure $ AppConfig (config `Record.merge` configMandatory)

getCwd :: Aff AbsDir
getCwd = do
  cwdStr <- liftEffect $ Process.cwd
  case P.parseAbsDir P.posixParser (cwdStr <> "/") of
    Nothing -> throwError $ error ("Could not parse current working directory: " <> cwdStr)
    Just cwd -> pure cwd