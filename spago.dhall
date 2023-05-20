{ name = "purs-to-md"
, dependencies =
  [ "aff"
  , "console"
  , "control"
  , "effect"
  , "either"
  , "exceptions"
  , "foldable-traversable"
  , "heterogeneous"
  , "maybe"
  , "newtype"
  , "node-buffer"
  , "node-fs-aff"
  , "node-process"
  , "optparse"
  , "partial"
  , "pathy"
  , "prelude"
  , "record"
  , "strings"
  , "transformers"
  , "tuples"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
