sh      = require 'shelljs'
path    = require 'path'
Promise = require 'bluebird'
execAsync = Promise.promisify require('child_process').exec

exports = module.exports = (source, options) ->

    tmp = path.join sh.tempdir(), Math.random().toString(36).substr(7) + '.svg'

    new Promise (resolve, reject) ->

        cfg =
            mask: 'xx'
            color: null
            outpath: './'
            n: 3
            verbose: false

        cfg[k] = v for k, v of options when v?

        throw new Error "Oops! Inkscape must be in your path" unless sh.which 'inkscape'

        throw new Error "Oops! Can't find input file: #{source}" unless sh.test '-f', source

        if cfg.color?
            unless /#[0-9a-f]{6}/.test cfg.color
                throw new Error "Oops! Transparent color should be in the form: `#123456`"

        sh.mkdir '-p', cfg.outpath

        sh.cp source, tmp

        sh.sed '-i', cfg.color, 'none', tmp if cfg.color?

        execAsync 'inkscape -z -S ' + tmp
        .then (output) ->

            exid = /// ^ ([^\n,]+) ///gm
            ids = (m[1] while (m = exid.exec output)?)

            exmask = new RegExp cfg.mask + '(\\w+)'
            valids = (m[1] for id in ids when (m = exmask.exec id)?)

            Promise.map valids, (name) ->
                pngfile = path.join cfg.outpath, name + '.png'
                console.log "Exporting #{pngfile}" if cfg.verbose
                execAsync "inkscape -z -d 90 -e #{pngfile} -j -i #{cfg.mask}#{name} #{tmp}"
            ,
                concurrency: cfg.n
            .then ->
                resolve [valids, ids]

    .finally ->
        sh.rm '-f', tmp
