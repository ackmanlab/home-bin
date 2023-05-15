#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
        spdf - search for a doi within a pdf. If found, print the doi and then use sdoi.sh to query pubmed and append a bibtex entry with the pdf to your local bib database file

         usage:
          spdf.sh file.pdf

         depends:
          pdftotext - from ghostscript or poppler or texlive ?

         defaults:
          See sdoi.sh
          "
    exit 0
fi

set -e #exit if an error
# set -v -x -e #debugging

#Setup defaults
fn=$1


#try to extract doi from pdf and retrieve a pubmed id
#for 'DOI:' syntax
# search for doi string between first page last page 10
doi=$(pdftotext -q -f 1 -l 10 $fn - | grep -iE "doi:? ?/?10\." --max-count=1 | tr [:upper:] [:lower:] | sed -E "s|.*doi:? ?/?(10.+)|\1|")

#for 'https://doi.org' syntax
if [ -z "$doi" ]; then
  doi=$(pdftotext -q -f 1 -l 1 $fn - | grep -iE "doi\.org/10\." --max-count=1 | tr [:upper:] [:lower:] | sed -E "s|.+doi\.org/(10.+)|\1|")
fi

if [ -z "$doi" ]; then
  echo "doi not found"
  exit 1
else
  echo $doi
fi

sdoi.sh $doi $fn

