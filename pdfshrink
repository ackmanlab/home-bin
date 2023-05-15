#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
        shrinkpdf - resize pdf to smaller size. Warning: if no second file name is provided, the default behavior is to overwrite the original pdf
         usage:
          shrinkpdf.sh large.pdf
          shrinkpdf.sh large.pdf small.pdf
         dependencies:
          ps2pdf from Ghostscript
          mktemp from GNU Coreutils
   
              Usage: shrinkpdf.sh infile.pdf
                     shrinkpdf.sh infile outfile.pdf 
    "
    exit 0
fi

set -e

#Setup defaults
fn=$1
fn2=$2

set -e #exit if an error

#decide whether to use a provided new file name or too write over the original filename
if [ -z "$fn2" ]; then
  #clean up
  tmpName=$(mktemp $fn.XXXXXXX)
  ps2pdf $fn $tmpName
  #echo $tmpName
  rm $fn
  mv $tmpName $fn
  chmod u=rw,go=r $fn
else
  ps2pdf $fn $fn2
fi
