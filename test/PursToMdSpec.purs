module Test.PursToMdSpec where

import Prelude

import PursToMd as ME
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

spec :: Spec Unit
spec = do
  describe "pursToMd" $ do
    it "should convert a purs file to a markdown file" do
      ME.pursToMd pursFile `shouldEqual` mdFile

-- spec :: Spec Unit
-- spec =
--   describeOnly "isBelow" do
--     it "" do
--       printMaybeRel { cwd: absDir "/foo/bar/", path: absDir "/foo/bar/baz/" } `shouldEqual` "./baz/"
--       printMaybeRel { cwd: absDir "/foo/bar/baz/", path: absDir "/foo/bar/baz/" } `shouldEqual` "./"
--       printMaybeRel { cwd: absDir "/foo/bar/baz/x/", path: absDir "/foo/bar/baz/" } `shouldEqual` "/foo/bar/baz/"
--       printMaybeRel { cwd: absDir "/foo/bar/x/", path: absDir "/foo/bar/baz/" } `shouldEqual` "/foo/bar/baz/"

-- absFile :: String -> AbsFile
-- absFile s = P.parseAbsFile P.posixParser s
--   # fromMaybe' (\_ -> unsafeCrashWith ("absFile:" <> s))

-- absDir :: String -> AbsDir
-- absDir s = P.parseAbsDir P.posixParser s
--   # fromMaybe' (\_ -> unsafeCrashWith ("absDir:" <> s))

-- relDir :: String -> RelDir
-- relDir s = P.parseRelDir P.posixParser s
--   # fromMaybe' (\_ -> unsafeCrashWith ("relDir:" <> s))
