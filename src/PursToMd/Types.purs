module PursToMd.Types where

import Prelude

import Pathy (AbsFile)
import PursToMd.Config (AppConfig(..))
import PursToMd.Util (printMaybeRel)

data AppError
  = ErrReadFile AbsFile
  | ErrWriteFile AbsFile

printAppError :: AppConfig -> AppError -> String
printAppError (AppConfig { cwd }) = case _ of
  ErrReadFile path -> "Error reading file: " <> printMaybeRel { cwd, path }
  ErrWriteFile path -> "Error writing file: " <> printMaybeRel { cwd, path }
