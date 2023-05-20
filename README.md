# purs-to-md

Small CLI tool that I use to generate Markdown README files from PureScript files. Comments become plain markdown, and normal code become markdown code blocks, very simple.

```hs
module Main where

-- Let's define some variables:

a :: Int
a = 3

b :: Int
b = 3

-- And do some fancy calculattion:

c :: Int
c = a + b
```


````text
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
````
