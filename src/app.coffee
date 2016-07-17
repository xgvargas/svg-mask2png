chalk     = require 'chalk'
commander = new (require('commander').Command)('svg-m2png')
svgM2png  = require './svg-m2png'

cmdok = no

commander
    .version require('../package.json').version
    .option '-o, --out <path>', 'output path (default: `./`)'
    .option '-m, --mask <mask>', 'regex mask selector (default: `xx`)'
    .option '-t, --transparent <color>', 'transparent color'
    .option '--verbose', 'enable verbose mode'
    .arguments '<file.svg...>'
    .on '--help', -> console.log """
        Will extract to PNG every path or group inside the SVG file which name
        starts with mask pattern. Any thing else will be ignored. The mask portion
        is removed out from the final PNG filename.

        Every path with the transparent color will be rendered as #{chalk.gray('(guess what?!)')}, transparent.

        #{chalk.red('This program is just a helper! You MUST have inkscape in your path!')}
        """

    .action (file, options) ->
        cmdok = yes
        svgM2png file,
            outpath : options.out
            mask    : options.mask
            color   : options.transparent
            verbose : options.verbose

        .then (result) ->
            [valid, all] = result
            console.log "\n Found #{chalk.yellow(all)} objects.
                Extracted #{chalk.green(valid.length)} objects matching the mask."

        .catch (err) ->
            console.log err

    .parse process.argv

commander.help() unless cmdok
