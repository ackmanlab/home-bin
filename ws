#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
          ws - quickly setup workspace environment by invoking some terminals
               - intended to be invoked within a window manager environ like i3
               - can use a default workDir variable preference if ~/.bashrc.local exists
    
              Usage: 
              #with an existing terminal:
                     ws  
                     ws ~/projects 
                     
              #with i3wm|sway for example: 
                     1. select workspace e.g. <\$mod+2>
                     2. open dbus quick menu <\$mod+d> and type ws
    "
    echo "$(tput setaf 6)$workDir $(tput setaf 7)was previous working directory"
    exit 0
fi

set -e

myLocalConfig="$HOME/.bashrc.local"
# myTerm=${TERM:-urxvt}
myTerm=${TERM:-alacritty}

if [[ -e $myLocalConfig ]]; then
    source $myLocalConfig
fi

if [[ $1 ]]; then
    workingDirectory=$1
else 
    workingDirectory=${workDir:-~/projects} #e.g. if workDir is defined in .bashrc.local
fi

# echo $workDir
# echo $workingDirectory

if [[ $myTerm == urxvt ]]; then
#urxvt -e "dimr &"
urxvt -cd $workingDirectory -title "$(basename $workingDirectory) woola" -e bash -ic "$HOME/bin/woola" &
urxvt -cd $workingDirectory -title "$(basename $workingDirectory) ranger" -e bash -ic "ranger" &
urxvt -cd $workingDirectory &
fi

if [[ $myTerm == alacritty ]]; then
alacritty --working-directory $workingDirectory --title "$(basename $workingDirectory) woola" -e bash -ic "$HOME/bin/woola" &
alacritty --working-directory $workingDirectory --title "$(basename $workingDirectory) ranger" -e bash -ic "ranger" &
alacritty --working-directory $workingDirectory &
else
  echo "edit script for compatibility with terminal"
fi

if [[ -e $myLocalConfig ]]; then
    sed -i -E "s|(export workDir=).+|\1$workingDirectory|" "$myLocalConfig"
    export workDir=$workingDirectory
fi

