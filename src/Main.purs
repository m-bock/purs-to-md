module Main where

import Prelude

import Control.Monad.Error.Class (catchError)
import Data.Either (Either(..))
import Data.Foldable (for_)
import Effect (Effect)
import Effect.Aff (Aff, Error, launchAff_, message)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import Effect.Exception (stack)
import Node.Process as Process
import PursToMd (app)
import PursToMd.Config (AppConfig(..), getConfig)
import PursToMd.Impl.AppM (runAppM)
import PursToMd.Types (printAppError)

main :: Effect Unit
main = launchAff_ do
  config <- getConfig
  result <- runAppM config app
    `catchError` handleJsError config

  case result of
    Left err -> do
      error $ printAppError config err
      exit 1
    Right _ -> do
      exit 0

handleJsError :: forall a. AppConfig -> Error -> Aff a
handleJsError (AppConfig { debug }) jsError = do
  error "An unexpected error occurred!"
  if debug then do
    error "\n"
    error (message jsError)
    for_ (stack jsError) error
  else error "Run with --debug for more information"
  exit 1

exit :: forall a. Int -> Aff a
exit = liftEffect <<< Process.exit