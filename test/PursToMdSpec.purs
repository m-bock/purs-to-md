module Test.PursToMdSpec (spec) where

import Prelude

import Data.Either (Either(..), isLeft)
import Data.Maybe (fromMaybe')
import Parsing as PA
import Partial.Unsafe (unsafeCrashWith)
import Pathy (AbsDir)
import Pathy as P
import PursToMd (MdCodeBlock(..), PursCodeBlock(..))
import PursToMd as ME
import PursToMd.Util as ME.Util
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual, shouldSatisfy)

--------------------------------------------------------------------------------
--- Spec
--------------------------------------------------------------------------------

spec :: Spec Unit
spec = do
  describe "PursToMd" do
    describe "parserMdCodeBlock" do
      let
        parse str = PA.runParser str ME.parserMdCodeBlock

      it "should fail with wrong input" do
        parse "" `shouldSatisfy` isLeft
        parse "{-\nfooo" `shouldSatisfy` isLeft

      it "should succeed with correct input" do
        parse "{-\nfoo-}\n" `shouldEqual` (Right (MdCodeBlock "foo"))

    describe "parserPursCodeBlock" do
      let
        parse str = PA.runParser str ME.parserPursCodeBlock

      it "should fail with wrong input" do
        parse "{-\nabc" `shouldSatisfy` isLeft
      it "should succeed with correct input" do
        parse "{abc" `shouldEqual` (Right (PursCodeBlock "{abc"))
        parse "foo" `shouldEqual` (Right (PursCodeBlock "foo"))
        parse "foo{-\n" `shouldEqual` (Right (PursCodeBlock "foo"))

  describe "PursToMd.Util" do
    describe "printMaybeRel" $ do
      it "should print a relative path" do
        ME.Util.printMaybeRel { cwd: absDir "/foo/bar/", path: absDir "/foo/bar/baz/" }
          `shouldEqual` "./baz/"
        ME.Util.printMaybeRel { cwd: absDir "/foo/bar/baz/", path: absDir "/foo/bar/baz/" }
          `shouldEqual` "./"
        ME.Util.printMaybeRel { cwd: absDir "/foo/bar/baz/x/", path: absDir "/foo/bar/baz/" }
          `shouldEqual` "/foo/bar/baz/"
        ME.Util.printMaybeRel { cwd: absDir "/foo/bar/x/", path: absDir "/foo/bar/baz/" }
          `shouldEqual` "/foo/bar/baz/"

--------------------------------------------------------------------------------
--- Util
--------------------------------------------------------------------------------

absDir :: String -> AbsDir
absDir s = P.parseAbsDir P.posixParser s
  # fromMaybe' (\_ -> unsafeCrashWith ("absDir:" <> s))
