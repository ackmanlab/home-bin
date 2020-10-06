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

#Setup defaults
styleSheet=${pubmedStyleSheet:-$HOME/bin/pubmed2bibtex.xsl}
bibdFileOut=${bibdFileOut:-$HOME/projects/bibd/OMEGA.bib}
pdfPathOut=${pdfPathOut:-$HOME/projects/bibd/papers}
relPath=$(basename $pdfPathOut)
fn=$1

set -e #exit if an error

echo "using $pdfPathOut"
echo "using $bibdFileOut"

#try to extract doi from pdf and retrieve a pubmed id
#for 'DOI:' syntax
doi=$(pdftotext -q -f 1 -l 1 $fn - | grep -i doi: --max-count=1 | tr [:upper:] [:lower:] | sed -E "s#doi:(.+)#\1#")

#for 'https://doi.org' syntax
if [ -z "$doi" ]; then
  doi=$(pdftotext -q -f 1 -l 1 $fn - | grep -i "doi.org/" --max-count=1 | tr [:upper:] [:lower:] | sed -E "s#.+doi\.org\/(.+)#\1#")
fi

if [ -z "$doi" ]; then
  echo "doi not found"
  exit 1
fi


## TODO: dedupe this with sdoi.sh
uid=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=$doi&field=doi&retmode=xml" | grep -E "<Id>[0-9]+</Id>" | sed -E "s#<Id>([0-9]+)</Id>#\1#")

if [ -z "$uid" ]; then
  echo "pubmed id not found"
  exit 1
fi

#request pubmed xml and transform into bibtex
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$uid&retmode=xml" > $uid.xml
xsltproc --novalid $styleSheet $uid.xml > $uid.bib

#extract some strings to make a nice filename for the pdf
key="LastName"; 
author=$(grep $key --max-count=1 $uid.xml | sed -E "s#\W*<$key>(.+)</$key>\W*#\1#" | tr -d " ")

key="MedlineTA"; 
journal=$(grep $key --max-count=1 $uid.xml | sed -E "s#\W*<$key>(.+)</$key>\W*#\1#" | tr -d " ")

key1="PubDate"; 
key2="Year"; year=$(awk "/<$key1>/,/<\/$key1>/" $uid.xml | grep $key2 | sed -E "s#\W*<$key2>(.+)</$key2>\W*#\1#")

fn2=${author}_${journal}$year-$uid.pdf

#move pdf file to papers repository, add file name to bibtex file field
mv $fn $pdfPathOut/$fn2
echo "moved to $pdfPathOut/$fn2"
sed -i -E "s|(\W*file = \{).*(\}.*)|\1$relPath/$fn2\2|" $uid.bib

if [[ -z $(rg $uid $bibdFileOut) ]]; then
  #import bibtex
  echo "importing $uid.bib"
  cat $uid.bib >> $bibdFileOut
else
  echo "$uid already found in $bibdFileOut, exiting"
fi

#clean up
rm $uid.xml $uid.bib
