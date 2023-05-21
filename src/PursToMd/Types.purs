module PursToMd.Types where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.List (List)
import Data.Show.Generic (genericShow)
import Parsing (ParseError, parseErrorMessage)
import Pathy (AbsFile)
import PursToMd.Config (AppConfig(..))
import PursToMd.Util (printMaybeRel)

type CodeBlocks = List CodeBlock

newtype PursCodeBlock = PursCodeBlock String

newtype MdCodeBlock = MdCodeBlock String

data CodeBlock
  = Purs PursCodeBlock
  | Md MdCodeBlock

data AppError
  = ErrReadFile AbsFile
  | ErrWriteFile AbsFile
  | ErrParse ParseError

printAppError :: AppConfig -> AppError -> String
printAppError (AppConfig { cwd }) = case _ of
  ErrReadFile path -> "Error reading file: " <> printMaybeRel { cwd, path }
  ErrWriteFile path -> "Error writing file: " <> printMaybeRel { cwd, path }
  ErrParse err -> "Error parsing file: " <> parseErrorMessage err

type AppStdout = CodeBlocks

-------------------------------------------------------------------------------
--- Instances
-------------------------------------------------------------------------------

derive instance Generic PursCodeBlock _
derive instance Generic MdCodeBlock _

derive instance Eq PursCodeBlock
derive instance Eq MdCodeBlock

instance Show PursCodeBlock where
  show = genericShow

instance Show MdCodeBlock where
  show = genericShow
