#!/bin/bash
#mv2figs: used by the <ctrl-z> screenshot shortcut set in .config/i3/config

#default image location
blobFolder=$HOME/figures

mv $1 $blobFolder/$1

echo "<figure><img src=\""$(basename $blobFolder)/$1"\" width=\"500px\"><figcaption></figcaption></figure>" | xclip -selection clipboard
