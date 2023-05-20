module PursToMd where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Error.Class (class MonadThrow, liftEither)
import Data.Array as Array
import Data.Bifunctor (lmap)
import Data.Foldable (class Foldable, foldMap)
import Data.Generic.Rep (class Generic)
import Data.List (List)
import Data.Show.Generic (genericShow)
import Data.String as Str
import Data.String.CodeUnits as S
import Parsing (Parser)
import Parsing as PA
import Parsing.Combinators (lookAhead, manyTill, notFollowedBy)
import Parsing.String as PS
import PursToMd.Class.MonadApp (class MonadApp, getConfig, readFile, writeFile)
import PursToMd.Config (AppConfig(..))
import PursToMd.Types (AppError(..))

newtype PursCodeBlock = PursCodeBlock String

newtype MdCodeBlock = MdCodeBlock String

data CodeBlock
  = Purs PursCodeBlock
  | Md MdCodeBlock

-------------------------------------------------------------------------------
--- Parse
-------------------------------------------------------------------------------

parseCodeBlocks :: Parser String (List CodeBlock)
parseCodeBlocks = manyTill parseCodeBlock PS.eof

parseCodeBlock :: Parser String CodeBlock
parseCodeBlock = map Md parserMdCodeBlock <|> map Purs parserPursCodeBlock

parseOpen :: Parser String Unit
parseOpen = void $ PS.string "{-\n"

parseClose :: Parser String Unit
parseClose = void $ PS.string "-}\n"

parserPursCodeBlock :: Parser String PursCodeBlock
parserPursCodeBlock =
  do
    _ <- notFollowedBy parseOpen
    let end = (lookAhead parseOpen) <|> PS.eof
    xs :: List Char <- manyTill PS.anyChar end
    pure $ PursCodeBlock (fromChars xs)

parserMdCodeBlock :: Parser String MdCodeBlock
parserMdCodeBlock = do
  let end = parseClose
  _ <- parseOpen
  xs :: List Char <- manyTill PS.anyChar end
  pure $ MdCodeBlock (fromChars xs)

-------------------------------------------------------------------------------
--- Print
-------------------------------------------------------------------------------

printCodeBlocks :: List CodeBlock -> String
printCodeBlocks codeBlocks = codeBlocks
  # map printCodeBlock
  # Array.fromFoldable
  # Str.joinWith "\n\n"

printCodeBlock :: CodeBlock -> String
printCodeBlock = case _ of
  Purs purs -> printPursCodeBlock purs
  Md md -> printMdCodeBlock md

printPursCodeBlock :: PursCodeBlock -> String
printPursCodeBlock (PursCodeBlock purs) = Str.joinWith "\n"
  [ "```hs"
  , Str.trim purs
  , "```"
  ]

printMdCodeBlock :: MdCodeBlock -> String
printMdCodeBlock (MdCodeBlock md) = md

-------------------------------------------------------------------------------

parseSource :: forall m. MonadThrow AppError m => String -> m (List CodeBlock)
parseSource str = PA.runParser str parseCodeBlocks
  # lmap ErrParse
  # liftEither

app :: forall m. MonadApp m => m Unit
app = do
  AppConfig config <- getConfig
  pursSrc <- readFile config.inputPurs
  blocks <- parseSource pursSrc
  let mdSrc = printCodeBlocks blocks
  writeFile config.outputMd mdSrc

-------------------------------------------------------------------------------
--- Utils
-------------------------------------------------------------------------------

fromChars :: forall f. Foldable f => f Char -> String
fromChars = foldMap S.singleton

-------------------------------------------------------------------------------
--- Instances
-------------------------------------------------------------------------------

derive instance Generic PursCodeBlock _
derive instance Generic MdCodeBlock _

derive instance Eq PursCodeBlock
derive instance Eq MdCodeBlock

instance Show PursCodeBlock where
  show = genericShow

instance Show MdCodeBlock where
  show = genericShow
