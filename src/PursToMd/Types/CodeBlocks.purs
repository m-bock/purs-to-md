module PursToMd.Types.CodeBlocks where

import Prelude

import Control.Alt ((<|>))
import Data.Array as Array
import Data.Foldable (class Foldable, foldMap)
import Data.List (List)
import Data.String as Str
import Data.String.CodeUnits as S
import Parsing (Parser)
import Parsing.Combinators (lookAhead, manyTill, notFollowedBy)
import Parsing.String as PS
import PursToMd.Types (CodeBlock(..), CodeBlocks, MdCodeBlock(..), PursCodeBlock(..))

-------------------------------------------------------------------------------
--- Parse
-------------------------------------------------------------------------------

parseCodeBlocks :: Parser String CodeBlocks
parseCodeBlocks = manyTill parseCodeBlock PS.eof

parseCodeBlock :: Parser String CodeBlock
parseCodeBlock = map Md parserMdCodeBlock <|> map Purs parserPursCodeBlock

parseOpen :: Parser String Unit
parseOpen = void $ PS.string "{-\n"

parseClose :: Parser String Unit
parseClose = void $ PS.string "-}"

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
--- Utils
-------------------------------------------------------------------------------

fromChars :: forall f. Foldable f => f Char -> String
fromChars = foldMap S.singleton

