module PursToMd.Core where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, liftEither)
import Data.Bifunctor (lmap)
import Parsing as PA
import PursToMd.Class.MonadApp (class MonadApp, getConfig, readFile, stdout, writeFile)
import PursToMd.Config (AppConfig(..), OutputMd(..))
import PursToMd.Types (AppError(..), CodeBlocks)
import PursToMd.Types.CodeBlocks (parseCodeBlocks, printCodeBlocks)

parseSource :: forall m. MonadThrow AppError m => String -> m CodeBlocks
parseSource str = PA.runParser str parseCodeBlocks
  # lmap ErrParse
  # liftEither

app :: forall m. MonadApp m => m Unit
app = do
  AppConfig config <- getConfig
  pursSrc <- readFile config.inputPurs
  blocks <- parseSource pursSrc
  let mdSrc = printCodeBlocks blocks
  case config.outputMd of
    OutFile path ->
      writeFile path mdSrc
    Stdout ->
      stdout blocks

