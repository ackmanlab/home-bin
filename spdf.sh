#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
        pdf2bib - search for a doi within a pdf, query pubmed, and append bibtex entry with pdf to your local bib database file. Last two steps are identical to sdoi.sh

         usage:
          pdf2bib.sh file.pdf

         depends:
          pdftotext - from ghostscript or poppler or texlive ?
          xsltproc - xml processor, from GNOME project
          pubmed2bibtex.xsl - xml processor stylesheet

         defaults:
          Set the three required default file locations (xsl file, bib file, pdf directory)
          "
    exit 0
fi

set -e #exit if an error
# set -v -x -e #debugging

#Setup defaults
fn=$1


#try to extract doi from pdf and retrieve a pubmed id
#for 'DOI:' syntax
# doi=$(pdftotext -q -f 1 -l 1 $fn - | grep -i "doi:" --max-count=1 | tr [:upper:] [:lower:] | sed -E "s|doi:(.+)|\1|")

# search for doi string between first page last page 10
doi=$(pdftotext -q -f 1 -l 10 $fn - | grep -iE "doi:? ?/?10\." --max-count=1 | tr [:upper:] [:lower:] | sed -E "s|.*doi:? ?/?(10.+)|\1|")


#for 'https://doi.org' syntax
if [ -z "$doi" ]; then
  doi=$(pdftotext -q -f 1 -l 1 $fn - | grep -iE "doi\.org/10\." --max-count=1 | tr [:upper:] [:lower:] | sed -E "s|.+doi\.org/(10.+)|\1|")
fi

# for 'https://doi.org' syntax
# if [ -z "$doi" ]; then
  # doi=$(pdftotext -q -f 1 -l 1 $fn - | grep -i "doi.org/" --max-count=1 | tr [:upper:] [:lower:] | sed -E "s|.+doi\.org\/(.+)|\1|")
# fi
# 
# if [ -z "$doi" ]; then
# doi=$(pdftotext -q -f 1 -l 1 $fn - | grep -iE "doi ?" --max-count=1 | tr [:upper:] [:lower:] | sed -E "s|doi ?(.+)|\1|")
# fi

if [ -z "$doi" ]; then
  echo "doi not found"
  exit 1
fi

sdoi.sh $doi $fn

