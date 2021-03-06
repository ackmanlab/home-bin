#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
        spmid - search for pubmed guid and append bibtex entry to bibtex db. Optionally import an associated pdf.
         usage:
          spmid.sh '12345678'
          spmid.sh '12345678' download.pdf

         depends: 
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
uid=$1
fn=$2

set -e #exit if an error

#request pubmed xml and transform into bibtex
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$uid&retmode=xml" > $uid.xml
xsltproc --novalid $styleSheet $uid.xml > $uid.bib

#decide whether to process and move an associated pdf or just exit
if [ -z "$fn" ]; then
  #clean up
  rm $uid.xml $uid.bib
  exit 1
else
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
fi
