module PursToMd.Types where

import Prelude

import Pathy (AbsFile)
import PursToMd.Config (AppConfig(..))
import PursToMd.Util (printMaybeRel)
import Parsing (ParseError, parseErrorMessage)

data AppError
  = ErrReadFile AbsFile
  | ErrWriteFile AbsFile
  | ErrParse ParseError

printAppError :: AppConfig -> AppError -> String
printAppError (AppConfig { cwd }) = case _ of
  ErrReadFile path -> "Error reading file: " <> printMaybeRel { cwd, path }
  ErrWriteFile path -> "Error writing file: " <> printMaybeRel { cwd, path }
  ErrParse err -> "Error parsing file: " <> parseErrorMessage err
