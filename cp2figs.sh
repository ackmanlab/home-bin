#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
          cp2figs.sh - copy and convert image to figure assets folder and put html figure string containing relative link to the asset on system clipboard
               - converts to a smaller asset size for html presentation
               - default figure assets set as HOME/figures
    
              Usage: cp2figs.sh img.jpg 
                     cp2figs.sh img.jpg ~/myproject/assets
    "
    exit 0
fi

set -e

# fn=$(basename $1)
fn=$1
#default image location
# blobFolder=$HOME/figures
blobFolder=${2:-$HOME/figures}

#TODO: add xorg-x11 vs wayland logic here
# wayland: use "wl-copy"
#xorg-x11: use "xclip -selection clipboard"

origHash=$(md5sum $fn | cut -d ' ' -f 1 | cut -c -7)

newName=$blobFolder/$(basename -s .jpg $fn)_$origHash.jpg
cp $fn $newName 
convert -resize 1280x1280 -quality 90 $newName $newName

echo "<figure><img src=\""$(basename $blobFolder)/$(basename $newName)"\" width=\"500px\"><figcaption></figcaption></figure>" | wl-copy 
