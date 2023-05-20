module PursToMd.Util where

import Prelude

import Data.Maybe (Maybe(..))
import Data.String (Pattern(..))
import Data.String as Str
import Pathy (class IsDirOrFile, Abs, AbsDir, Path)
import Pathy as P

printMaybeRel :: forall b. IsDirOrFile b => { cwd :: AbsDir, path :: Path Abs b } -> String
printMaybeRel { cwd, path } =
  let
    cwdStr = printAbsPath cwd
    pathStr = printAbsPath path
  in
    case Str.stripPrefix (Pattern cwdStr) pathStr of
      Nothing -> pathStr
      Just pathStr' -> "./" <> pathStr'

printAbsPath :: forall b. IsDirOrFile b => Path Abs b -> String
printAbsPath = (P.unsafePrintPath P.posixPrinter <<< P.sandboxAny)