const cp = require('child_process');

module.exports = {
  transforms: {
    cliHelp() {
      const helpTxt = cp.execSync('./bin/purs-to-md.js --help', { stdio: 'pipe' }).toString();
      
      return "```\n" + helpTxt + "```"
    },
  },
};
