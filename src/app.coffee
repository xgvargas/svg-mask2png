chalk           = require 'chalk'
commander       = new (require('commander').Command)('svg-m2png')
{writeFileSync} = require 'fs'
svgM2png        = require './svg-m2png'
{join}          = require 'path'

cmdok = no

commander
    .version require('../package.json').version
    .option '-o, --out <path>', 'output path (default: `./`)', './'
    .option '-m, --mask <mask>', 'regex mask selector (default: `xx`)'
    .option '-t, --transparent <color>', 'transparent color'
    .option '-f, --flat', 'force a flat output layout'
    .option '-l, --list [file]', 'save extracted file names to `file`'
    .option '-v, --verbose', 'enable verbose mode'
    .arguments '<file.svg...>'
    .on '--help', -> console.log """
        Will extract to PNG every path or group inside the SVG file which name
        starts with mask pattern. Anything else will be ignored. The mask portion
        is removed out from the final PNG filename.

        Every path with the transparent color will be rendered as #{chalk.gray('(guess what?!)')}, transparent.

        By default every object of file1.svg will be extracted to folder `<out>/file1/`.
        If you set `flat` option then images are saved to `<out>/`.

        If you do not supply a filename to `list` then it will save a file per each input svg
        file, with pattern: `input.svg --> input.svg.extracted`.

        #{chalk.red('This program is just a helper! You MUST have inkscape in your path!')}
        """

    .action (file, options) ->
        cmdok = yes
        svgM2png file,
            outpath : options.out
            mask    : options.mask
            color   : options.transparent
            verbose : options.verbose
            flat    : options.flat

        .then (result) ->
            all   = []
            total = 0
            for k, v of result
                all = [all..., v.images...]
                total += v.total
                if options.list is true
                    fn = join options.out, k + '.extracted'
                    console.log "------- Saving #{fn}" if options.verbose
                    writeFileSync fn, v.images.join '\n'

            if options.list and options.list isnt true
                fn = join options.out, options.list
                console.log "------- Saving #{fn}" if options.verbose
                writeFileSync fn, all.join '\n'

            console.log "\n Found #{chalk.yellow(total)} objects.
                Extracted #{chalk.green(all.length)} objects matching the mask."

        .catch (err) ->
            console.log err

    .parse process.argv

commander.help() unless cmdok
