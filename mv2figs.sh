#!/bin/bash
#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
          mv2figs - move image to figure assets folder and put html figure string containing relative link to the asset on system clipboard
               - used by the <ctrl-z> screenshot shortcut set in .config/sway/config and .config/i3/config
               - default figure assets set as HOME/figures
    
              Usage: mv2figs.sh img.jpg 
                     mv2figs.sh img.jpg ~/myproject/assets
    "
    exit 0
fi

set -e

#default image location
# blobFolder=$HOME/figures
blobFolder=${2:-$HOME/figures}

#TODO: add xorg-x11 vs wayland logic here
# wayland: use "wl-copy"
#xorg-x11: use "xclip -selection clipboard"

mv $1 $blobFolder/$1

echo "<figure><img src=\""$(basename $blobFolder)/$1"\" width=\"500px\"><figcaption></figcaption></figure>" | wl-copy 
