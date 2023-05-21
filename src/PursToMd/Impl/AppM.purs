module PursToMd.Impl.AppM where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, catchError)
import Control.Monad.Except (ExceptT(..), lift, runExceptT)
import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Data.Either (Either(..))
import Effect.Aff (Aff, Error)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect)
import Effect.Class.Console as Console
import Node.Encoding (Encoding(..))
import Node.FS.Aff as FSA
import PursToMd.Class.MonadApp (class MonadApp, class MonadAppConfig, class MonadAppStdOut)
import PursToMd.Config (AppConfig)
import PursToMd.Types (AppError(..))
import PursToMd.Types.CodeBlocks (printCodeBlocks)
import PursToMd.Util (printAbsPath)

newtype AppM a = AppM (ReaderT AppConfig (ExceptT AppError Aff) a)

derive newtype instance Monad AppM
derive newtype instance MonadThrow AppError AppM
derive newtype instance Applicative AppM
derive newtype instance Functor AppM
derive newtype instance Bind AppM
derive newtype instance Apply AppM
derive newtype instance MonadAff AppM
derive newtype instance MonadEffect AppM

instance MonadAppConfig AppM where
  getConfig = AppM ask

instance MonadApp AppM where
  readFile path = do
    liftAffWith
      (\_ -> ErrReadFile path)
      (FSA.readTextFile UTF8 (printAbsPath path))

  writeFile path content = do
    liftAffWith
      (\_ -> ErrWriteFile path)
      (FSA.writeTextFile UTF8 (printAbsPath path) content)

instance MonadAppStdOut AppM where
  stdout codeBlocks = liftAff
    $ Console.log
    $ printCodeBlocks codeBlocks

runAppM :: forall a. AppConfig -> AppM a -> Aff (Either AppError a)
runAppM config (AppM ma) = runExceptT (runReaderT ma config)

liftAffWith :: forall a. (Error -> AppError) -> Aff a -> AppM a
liftAffWith mkErr ma1 = do
  let
    ma2 :: Aff (Either AppError a)
    ma2 = catchError (Right <$> ma1) (mkErr >>> Left >>> pure)

    ma3 :: ExceptT AppError Aff a
    ma3 = ExceptT ma2

    ma4 :: ReaderT AppConfig (ExceptT AppError Aff) a
    ma4 = lift ma3

  AppM ma4