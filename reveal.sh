#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
              reveal - helper app for opening reveal.js markdown presentations 
              Useful for serving markdown text files locally with reveal.js
              
              Usage: reveal.sh neuroanatomy1.md
                     reveal.sh neuroanatomy1.md 8001
    "
    echo "$(tput setaf 6)$EDITOR $(tput setaf 7)is currently set as editor"
    exit 0
fi

set -e

appPath="$HOME/projects/dev/reveal.js"
portNumber=${2:-8000}

if [[ ! -d $appPath ]]; then
    echo "reveal.js not found"
    exit 1
else
    cd $appPath
fi

fn=$1 #markdown document to render e.g. neuroanatomy1.md
basefn=$(basename $fn)
if [[ ! -e $basefn ]]; then
    ln -s $fn $basefn
fi

#add markdown filename to reveal placeholder start file
sed -i -E "s|(<section data-markdown=\")[A-Za-z0-9\.-]*(\" )|\1$basefn\2|" index.html
npm start -- --port=$portNumber
# npm start 
