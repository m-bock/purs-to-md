module Test.PursToMdSpec (spec) where

import Prelude

import Data.Maybe (fromMaybe')
import Partial.Unsafe (unsafeCrashWith)
import Pathy (AbsDir)
import Pathy as P
import PursToMd as ME
import PursToMd.Util as ME.Util
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

pursFile :: String
pursFile =
  """
module Main where

-- Let's define some variables:

a :: Int
a = 3

b :: Int
b = 3

-- And do some fancy calculattion:

c :: Int
c = a + b
"""

mdFile :: String
mdFile =
  """
```hs
module Main where
```

Let's define some variables:

```hs
a :: Int
a = 3

b :: Int
b = 3
```

And do some fancy calculattion:

```hs
c :: Int
c = a + b
```
"""

--------------------------------------------------------------------------------
--- Spec
--------------------------------------------------------------------------------

spec :: Spec Unit
spec = do
  describe "PursToMd" do
    describe "pursToMd" $ do
      it "should convert a purs file to a markdown file" do
        ME.pursToMd pursFile `shouldEqual` mdFile
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
