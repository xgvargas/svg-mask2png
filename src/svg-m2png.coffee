path      = require 'path'
Promise   = require 'bluebird'
sh        = require 'shelljs'
execAsync = Promise.promisify require('child_process').exec

exports = module.exports = (sources, options) ->

    new Promise (resolve, reject) ->

        cfg =
            mask    : 'xx'
            color   : null
            outpath : './'
            n       : 3
            verbose : false
            flat    : false

        cfg[k] = v for k, v of options when v?

        throw new Error "Oops! Inkscape must be in your path" unless sh.which 'inkscape'

        if cfg.color?
            unless /#[0-9a-f]{6}/.test cfg.color
                throw new Error "Oops! Transparent color should be in the form: `#123456`"

        Promise.reduce sources, (total, source) ->

            throw new Error "Oops! Can't find input file: #{source}" unless sh.test '-f', source

            console.log "------- Processing #{source}" if cfg.verbose

            tmp = path.join sh.tempdir(), Math.random().toString(36).substr(7) + '.svg'
            sh.cp source, tmp

            sh.sed '-i', cfg.color, 'none', tmp if cfg.color?

            sh.mkdir '-p', path.join cfg.outpath, path.basename source, '.svg' unless cfg.flat

            execAsync 'inkscape -z -S ' + tmp
            .then (output) ->

                exid = /// ^ ([^\n,]+) ///gm
                ids = (m[1] while (m = exid.exec output)?)

                exmask = new RegExp cfg.mask + '(\\w+)'
                valids = (m[1] for id in ids when (m = exmask.exec id)?)

                Promise.map valids, (name) ->

                    if cfg.flat
                        pngfile = path.join cfg.outpath, name + '.png'
                    else
                        pngfile = path.join cfg.outpath, path.basename(source, '.svg'), name + '.png'

                    console.log "Exporting #{pngfile}" if cfg.verbose
                    execAsync "inkscape -z -d 90 -e #{pngfile} -j -i #{cfg.mask}#{name} #{tmp}"
                ,
                    concurrency: cfg.n

                .then ->
                    total[source] = images: valids, total: ids.length
                    total

            .finally -> sh.rm '-f', tmp
        ,
            {}

        .then (data) -> resolve data

        .catch (err) -> reject  err
