#!/bin/bash
#installation: place in home directory and make this file executable `chmod u=rwX,go= reveal.sh`
#usage example: `./reveal.sh neuroanatomy1.md`

appPath="$HOME/projects/dev/reveal.js"

if [[ ! -d $appPath ]]; then
    echo "reveal.js not found"
    exit 1
else
    cd $appPath
fi

fn=$1 #markdown document to render e.g. neuroanatomy1.md
if [[ ! -e $fn ]]; then
    ln -s $fn $(basename $fn)
fi

#add markdown filename to reveal placeholder start file
sed -i -E "s|(<section data-markdown=\")[A-Za-z0-9\.-]*(\" )|\1$fn\2|" index.html
npm start

