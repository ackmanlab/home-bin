#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
    sdoi - search for a unique identifier (doi or pmid) on doi.org and/or pubmed and append bibtex entry to bibtex db. Optionally import a downloaded pdf.

         usage:
          sdoi.sh 'doi'
          sdoi.sh 'doi' download.pdf

         depends: 
          xsltproc, xmllint - xml processing programs from libxml
          pubmed2bibtex.xsl - xml processor stylesheet

         defaults:
          Set the three required default file locations (xsl file, bib file, pdf directory)
          "
    exit 0
fi 

set -e #exit if an error
# set -v -x -e #debugging

#Setup defaults
doi=$1
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
  #request bibtex from doi.org
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
  #move pdf file to papers repository, add file name to bibtex url field
  fn2=${author}_${journal}$year-$uid.pdf
  echo "moving $fn to $pdfPathOut/$fn2"
  mv $fn $pdfPathOut/$fn2
  #insert local path to pdf into the retrieved bibtex url field
  sed -i -E "s|(\W*url = \{).*(\}.*)|\1$relPath/$fn2\2|" $tmpBib
}


clean_up() {
  #clean up
  rm -f $tmpBib.bib $tmpBib.bib.xml
  exit 1
}


#main function
##test whether the given unique identifier (doi) is an actual doi, else assume its a pmid 
if [[ -z $(echo $doi | grep "^10." -) ]]; then
  searchField="pmid"
else
  searchField="doi"
fi

uid=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=$doi&field=$searchField&retmode=xml" | grep -E "<Id>[0-9]+</Id>" | sed -E "s|<Id>([0-9]+)</Id>|\1|")

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
fi

