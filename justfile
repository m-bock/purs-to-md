purs_args := "--stash --censor-lib --censor-codes=ImplicitQualifiedImport"
cfg_test := "--config test.dhall"

build-strict:
    spago build --purs-args "--strict {{purs_args}}"

build:
    spago build --purs-args "{{purs_args}}"

test-strict:
    spago {{cfg_test}} test --purs-args "--strict {{purs_args}}"

test:
    spago {{cfg_test}} test --purs-args "{{purs_args}}"

clean:
    rm -rf .spago output .psa-stash

ide:
    spago {{cfg_test}} test --purs-args "{{purs_args}} --json-errors"

ci: check-format clean build-strict test-strict

format:
    purs-tidy format-in-place "src/**/*.purs"
    purs-tidy format-in-place "test/**/*.purs"

check-format:
    purs-tidy check "src/**/*.purs"
    purs-tidy check "test/**/*.purs"

dist:
    spago bundle-app --to dist/index.js

set positional-arguments := true
run *a:
    spago run --purs-args "{{purs_args}}" -a "$@"
    
run-sample:
    spago run --purs-args "{{purs_args}}" -a \
      '--debug --input-purs assets/Sample.purs --output-md assets/Sample.md'