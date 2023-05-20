#!/usr/bin/env node
import * as lib from "./lib.js";
import * as fs from "fs";

// const [, , ...args] = process.argv;

// const inPath = args[0];
// const outPath = args[1];

// const main = () => {
//   const lines = fs
//     .readFileSync(inPath)
//     .toString();
//   const str = lib.convert(lines);
//   fs.writeFileSync(outPath, str);
// };

// main();


import yargs from "yargs";


// Parse command line arguments with yargs
const parseArgs = () => {
  return yargs.argv
    .option("input", {
      alias: "i",
      describe: "Input PureScript file",
      type: "string",
      demandOption: true,
    })
    .option("output", {
      alias: "o",
      describe: "Output file",
      type: "string",
      demandOption: true,
    });
};

const main = () => {
    console.log("Hello, world!")
    const args = parseArgs().argv;
    console.log(args);
}

main()
