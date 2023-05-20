module PursToMd.Types where

import Prelude

import Pathy (AbsFile)

data AppError
  = ErrReadFile AbsFile
  | ErrWriteFile AbsFile

printAppError :: AppError -> String
printAppError = case _ of
  ErrReadFile file -> "Error reading file: " <> show file
  ErrWriteFile file -> "Error writing file: " <> show file
