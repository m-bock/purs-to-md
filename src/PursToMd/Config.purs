module PursToMd.Config
  ( AppConfig(..)
  , AppConfigMandatory
  , AppConfigOptionalF
  , It
  , OutputMd(..)
  , getConfig
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Error.Class (throwError)
import Data.Either (Either(..), note)
import Data.Foldable (fold)
import Data.Maybe (Maybe(..), optional)
import Data.String as Str
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import MergeConfigs (mergeConfigs)
import Node.Process as Process
import Options.Applicative (ReadM)
import Options.Applicative as O
import Pathy (AbsDir, AbsFile, (</>))
import Pathy as P
import Record as Record
import Text.PrettyPrint.Leijen as PP

------------------------------------------------------------------------------
-- Types
------------------------------------------------------------------------------

type AppConfigOptionalF :: (Type -> Type) -> Row Type
type AppConfigOptionalF f =
  ( debug :: f Boolean
  , outputMd :: f OutputMd
  )

data OutputMd = Stdout | OutFile AbsFile

type AppConfigMandatory r =
  { inputPurs :: AbsFile
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
  , outputMd: Stdout
  }

------------------------------------------------------------------------------
-- CLI
------------------------------------------------------------------------------

parseCLI :: AbsDir -> O.ParserInfo ({ | AppConfigOptionalF Maybe } /\ AppConfigMandatory ())
parseCLI cwd =
  O.info (O.helper <*> parseArgs) $ fold
    [ O.fullDesc
    , O.progDesc "Convert PureScript files with comments to Markdown"
    , O.header "purs-to-md - Convert PureScript files with comments to Markdown"
    ]
  where
  parseArgs = ado
    inputPurs <- O.option (readAbsFile cwd) $ fold
      [ O.long "input-purs"
      , O.help "PureScript file to read from"
      ]

    outputMd <- optional $ O.option (readOutputMd cwd) $ fold
      [ O.long "output-md"
      , O.helpDoc $ pure $ PP.string $ Str.joinWith "\n"
          [ "Markdown file to write to"
          , "(File path or '-' for stdout, defaults to '-')"
          ]
      ]

    debug <- optional $ O.switch $ fold
      [ O.long "debug"
      , O.help "Print debug information"
      ]

    in { debug, outputMd } /\ { inputPurs, cwd }

readOutputMd :: AbsDir -> ReadM OutputMd
readOutputMd cwd =
  let
    readOutFile = map OutFile $ readAbsFile cwd
    readStdout = O.eitherReader case _ of
      "-" -> Right Stdout
      _ -> Left "Output file must be '-' for stdout"
  in
    readStdout <|> readOutFile

readAbsFile :: AbsDir -> ReadM AbsFile
readAbsFile cwd = O.eitherReader \str ->
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