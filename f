#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
    f - fuzzy preview and open text files or pdfs
         usage:
          f 
          f p #then type <enter> to preview
          f p #then type <ctrl-s> to save pdf with spdf.sh 

         depends: 
          fzf
          bat 
          grep, git-grep, or ripgrep
          zathura (or other fast pdf viewer)
          spdf.sh - handles saving to your bib db
    "
    exit 0
fi

set -e #exit if an error

#todo: simplify.

if [ "$1" == "p" ]; then

    ls *.pdf | fzf --preview 'pdftotext -l 2 -nopgbrk -q {1} -' \
        --preview-window=up:70% --bind "enter:execute-silent(zathura {} &)" \
        --bind "ctrl-s:execute(spdf.sh {})+reload(ls *.pdf)"
    exit 1
fi

if [ -z "$1" ]; then
    #FZF_DEFAULT_COMMAND=rg -i --files --glob "!.git/*"
    fzf --delimiter : --preview 'bat --color always --style=numbers --line-range=:500 {1}' \
        --preview-window=up:70% --bind "enter:execute(xdg-open {1})" 
#        --preview-window=up:70% --bind "enter:execute($VISUAL {1})" 

     # fzf --delimiter : --preview 'bat --color=always --style=numbers --line-range=:500 {}' \

        # --preview-window=up:70% --bind "enter:execute-silent(gvim {1} &)" 

else
    # rg $1 | fzf --delimiter : --preview 'less {1}' \
    # todo: replace this with a series elif blocks mapping selective previews and downstream application bindings to a set of desired filetypes
    #use xdg-mime, filetype info for opening
    ls *$1 | fzf --delimiter : --preview 'bat --color always --style=numbers --line-range=:500 {1}' \
        --preview-window=up:70% --bind "enter:execute(xdg-open {1})" 

        # --preview-window=up:70% --bind "enter:execute-silent(gvim {1} &)" 
fi

