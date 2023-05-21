module PursToMd.Class.MonadApp where

import Prelude

import Control.Monad.Error.Class (class MonadThrow)
import Pathy (AbsFile)
import PursToMd.Config (AppConfig)
import PursToMd.Types (AppError, AppStdout)

class MonadAppConfig m where
  getConfig :: m AppConfig

class MonadAppStdOut m where
  stdout :: AppStdout -> m Unit

class
  ( Monad m
  , MonadAppConfig m
  , MonadThrow AppError m
  , MonadAppStdOut m
  ) <=
  MonadApp m where
  readFile :: AbsFile -> m String
  writeFile :: AbsFile -> String -> m Unit

