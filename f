#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
    f - fuzzy preview and open text files or pdfs
         usage:
          f 
          f p

         depends: 
          fzf
          grep, git-grep, or ripgrep
          zathura (or other fast pdf viewer)
          pdf2bib.sh - handles saving to your bib db
    "
    exit 0
fi

#Setup defaults
# cslFile=${2:-$HOME/projects/bibd/bibd-md.csl}
# bibdFile=${3:-$HOME/projects/bibd/OMEGA.bib}
# cd $(dirname $bibdFile)
set -e #exit if an error
inFlag=${1:-"-i --files"}


if [ "$1" == "p" ]; then

    ls *.pdf | fzf --preview 'pdftotext -l 2 -nopgbrk -q {1} -' \
        --preview-window=up:70% --bind "enter:execute-silent(zathura {} &)" \
        --bind "ctrl-s:execute(pdf2bib.sh {})+reload(ls *.pdf)"
    exit 1
fi

if [ -z "$1" ]; then
    #FZF_DEFAULT_COMMAND=rg -i --files --glob "!.git/*"
    # fzf --delimiter : --preview 'less {1}' \
    fzf --delimiter : --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
        --preview-window=up:70% --bind "enter:execute-silent(gvim {1} &)" 

else
    # rg $1 | fzf --delimiter : --preview 'less {1}' \
    rg $1 | fzf --delimiter : --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
        --preview-window=up:70% --bind "enter:execute-silent(gvim {1} &)" 
fi
