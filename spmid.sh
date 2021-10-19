#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
        spmid - search for pubmed guid and append bibtex entry to bibtex db. Optionally import an associated pdf.
         usage:
          spmid.sh '12345678'
          spmid.sh '12345678' download.pdf

    "
    exit 0
fi

#TODO: deprecate this function, add pmid logic into sdoi

set -e #exit if an error
# set -v -x -e #debugging

#Setup defaults
uid=$1
fn=$2
styleSheet=${pubmedStyleSheet:-$HOME/bin/pubmed2bibtex.xsl}
bibdFileOut=${bibdFileOut:-$HOME/projects/bibd/OMEGA.bib}
pdfPathOut=${pdfPathOut:-$HOME/projects/bibd/papers}
relPath=$(basename $pdfPathOut)

#define functions
import_bib() {
  #decide whether to process and move an associated pdf or just exit
  if [ -z "$fn" ]; then
    append_bibfile
    clean_up
  else
    extract_name
    append_pdf
    append_bibfile
    clean_up
  fi
}

fetchBib_pubmed() {
  #request pubmed xml and transform into bibtex
  curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$uid&retmode=xml" > $tmpBib.xml
  xsltproc --novalid $styleSheet $tmpBib.xml > $tmpBib
}

fetchBib_doiDotOrg() {
  echo "pubmed id not found, trying doi.org.."
  curl -LH 'Accept: application/x-bibtex' "https//dx.doi.org/"$doi >> $tmpBib
  echo -e "\n" >> $tmpBib
}

extract_name() {
  #extract some strings to make a nice filename for the pdf
  key="LastName"; 
  author=$(xmllint --xpath "string(//$key)" $tmpBib.xml | tr -d ' ')

  key="MedlineTA"; 
  journal=$(xmllint --xpath "string(//$key)" $tmpBib.xml | tr -d ' ')

  key="Year";
  year=$(xmllint --xpath "string(//$key)" $tmpBib.xml)
}

append_bibfile() {
  #import bibtex
  #first grep for a uid (doi) in case its already in db
  if [[ -z $(rg $doi $bibdFileOut) ]]; then
    echo "importing $tmpBib"
    cat $tmpBib >> $bibdFileOut
  else
    echo "$doi already found in $bibdFileOut, exiting"
  fi
}


append_pdf() {
  fn2=${author}_${journal}$year-$uid.pdf
  #move pdf file to papers repository, add file name to bibtex url field
  mv $fn $pdfPathOut/$fn2
  echo "moved to $pdfPathOut/$fn2"
  sed -i -E "s|(\W*url = \{).*(\}.*)|\1$relPath/$fn2\2|" $tmpBib
}


clean_up() {
  #clean up
  rm -f $tmpBib $tmpBib.xml
  exit 1
}


#main
tmpBib=$(mktemp -p ./ --suffix=.bib)

fetchBib_pubmed

if [ -s "$tmpBib" ]; then
  import_bib
else
  echo "sorry, doi not found.."
  clean_up
fi

