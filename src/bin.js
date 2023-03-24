#!/usr/bin/env node
import * as lib from "./.";
import * as fs from "fs";

const [, , ...args] = process.argv;

const inPath = args[0];
const outPath = args[1];

const main = () => {
  const lines = fs
    .readFileSync(inPath)
    .toString();
  const str = lib.convert(lines);
  fs.writeFileSync(outPath, str);
};

main();
