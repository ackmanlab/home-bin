#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
        sdoi - search for doi guid on pubmed and append bibtex entry to bibtex db. Optionally import a downloaded pdf.

         usage:
          sdoi.sh 'doi'
          sdoi.sh 'doi' download.pdf

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
doi=$1
fn=$2

set -e #exit if an error
# set -v -x -e #debugging

function import_bib {
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

function fetchBib_pubmed {
  #request pubmed xml and transform into bibtex
  curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$uid&retmode=xml" > $tmpBib.xml
  xsltproc --novalid $styleSheet $tmpBib.xml > $tmpBib
}

function fetchBib_doiDotOrg {
  echo "pubmed id not found, trying doi.org.."
  curl -LH 'Accept: application/x-bibtex' "http//dx.doi.org/"$doi >> $tmpBib
  echo -e "\n" >> $tmpBib
}

function extract_name {
  #extract some strings to make a nice filename for the pdf
  key="LastName"; 
  author=$(grep $key --max-count=1 $tmpBib.xml | sed -E "s|\W*<$key>(.+)</$key>\W*|\1|" | tr -d " ")

  key="MedlineTA"; 
  journal=$(grep $key --max-count=1 $tmpBib.xml | sed -E "s|\W*<$key>(.+)</$key>\W*|\1|" | tr -d " ")

  key1="PubDate"; 
  key2="Year"; year=$(awk "/<$key1>/,/<\/$key1>/" $tmpBib.xml | grep $key2 | sed -E "s|\W*<$key2>(.+)</$key2>\W*|\1|")

}

function append_bibfile {
  #import bibtex
  #first grep for a uid (doi) in case its already in db
  if [[ -z $(rg $doi $bibdFileOut) ]]; then
    echo "importing $tmpBib"
    cat $tmpBib >> $bibdFileOut
  else
    echo "$doi already found in $bibdFileOut, exiting"
  fi
}


function append_pdf {
  fn2=${author}_${journal}$year-$uid.pdf
  #move pdf file to papers repository, add file name to bibtex file field
  mv $fn $pdfPathOut/$fn2
  echo "moved to $pdfPathOut/$fn2"
  sed -i -E "s|(\W*file = \{).*(\}.*)|\1$relPath/$fn2\2|" $tmpBib
}


function clean_up {
  #clean up
  rm -f $tmpBib $tmpBib.xml
  exit 1
}


uid=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=$doi&field=doi&retmode=xml" | grep -E "<Id>[0-9]+</Id>" | sed -E "s|<Id>([0-9]+)</Id>|\1|")

tmpBib=$(mktemp -p ./ --suffix=.bib)

if [ -z "$uid" ]; then
  fetchBib_doiDotOrg
else
  fetchBib_pubmed
fi

if [ -s "$tmpBib" ]; then
  import_bib
else
  echo "sorry, doi not found.."
  clean_up
fi

