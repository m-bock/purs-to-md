module PursToMd where

import Prelude

import PursToMd.Class.MonadApp (class MonadApp, getConfig, readFile, writeFile)
import PursToMd.Config (AppConfig(..))

-------------------------------------------------------------------------------

pursToMd :: String -> String
pursToMd _ = "x"

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

app :: forall m. MonadApp m => m Unit
app = do
  AppConfig config <- getConfig
  purs <- readFile config.inputPurs
  writeFile config.outputMd (pursToMd purs)