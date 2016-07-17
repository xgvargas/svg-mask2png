# SVG-mask2PNG

It's a node package to extract to PNG every object inside a SVG file when their ID match a mask.

**Important** This is not a real extractor! Is more like a helper. You **MUST** have [inkscape](https://inkscape.org) in your path to execute the real extraction of images.

## Install

```bash
npm install [-g] svg-mask2png
```

## Usage

You can require it on your code:

```js
var svgMask2png = require('svg-mask2png');

svgMask2png('input.svg', {
    // default values
    mask: 'xx',
    color: null,
    outpath: './',
    n: 3,
    verbose: false
})
.then(function(result){
    console.log('extracted objects: ', result[0]);
    console.log('all objects: ', result[1]);
})
.catch(function(err){
    console.log(err);
});
```

Or, if installed as global, you can execute:

```bash

$ svg-m2png --help

#example

$ svg-m2png -o images input.svg
```

## Options

- `mask` - mask to match the start if ID name
- `color` - color to be converted to transparent, must be in form: `#123abc`
- `outpath` - path to PNG destination
- `n` - number of concurrent processes
- `verbose` - if you want to print out the name of files while being extracted.

## Workflow

I like to create all my image assets inside a single SVG file, then name all of them to its final png's name (plus the stating mask).

When creating fixed size images with transparent background I usually use a known color since it is easier to manipulate and define its size. Then group that background with the draw over it, name the group and instruct this helper to convert that color to transparent prior extraction.

```bash
$ svg-m2png -o images input.svg --transparent "#f2f2f2"
```
