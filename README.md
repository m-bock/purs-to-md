# purs-to-md

Small CLI tool that I use to generate Markdown README files from PureScript files. 
Multiline comments become plain markdown, and normal code become markdown code blocks, very simple.

## Installation

```
npm install purs-to-md
```

## CLI Options

```
purs-to-md --help
```

<!-- AUTO-GENERATED-CONTENT:START (cliHelp) -->
```
purs-to-md - Convert PureScript files with comments to Markdown

Usage: purs-to-md.js --input-purs ARG [--output-md ARG] [--debug]
  Convert PureScript files with comments to Markdown

Available options:
  -h,--help                Show this help text
  --input-purs ARG         PureScript file to read from
  --output-md ARG          Markdown file to write to
                           (File path or '-' for stdout, defaults to '-')
  --debug                  Print debug information
```
<!-- AUTO-GENERATED-CONTENT:END -->

## Example

Define a PureScript file like this:

`Sample.purs`
```hs
module Sample where

import Prelude

{-
Let's define some variables:
-}

a :: Int
a = 3

b :: Int
b = 3

{-
And do some calculation:
-}

c :: Int
c = a + b
```

Then run the CLI like so:

```
purs-to-md --input-purs Sample.purs --output-md sample.md
```

This will generate the following Markdown file:

`sample.md`
````text
```hs
module Sample where

import Prelude
```

Let's define some variables:


```hs
a :: Int
a = 3

b :: Int
b = 3
```

And do some calculation:


```hs
c :: Int
c = a + b
```
````

## Limitations

Note that the `{-` and `-}` must be written in dedicated lines. This won't work : `{- Some Text .. -}`.
Also don't expect edge cases to be handled, like e.g. PureScript strings that contain `{-` will break the generator.