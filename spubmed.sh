#!/bin/bash
#spubmed.sh - search for pubmed for author, journal, year
# usage:
#  spubmed.sh 'kaas' 'trends+neurosci' '1995'
#  spubmed.sh 'rakic' 'j+comp+neurol' '1972'

#Setup defaults
styleSheet="$HOME/bin/pubmed2bibtex.xsl"
bibdFileOut="$HOME/projects/bibd/OMEGA.bib"
pdfPathOut="$HOME/projects/bibd/papers"
relPath=$(basename $pdfPathOut)
author=$1
journal=$2
year=$3

set -e #exit if an error

uid=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=$author[au]+AND+$journal[ta]+AND+$year[dp]&retmode=xml" | grep -E "<Id>[0-9]+</Id>" | sed -E "s#<Id>([0-9]+)</Id>#\1#")

if [ -z "$uid" ]; then
  echo "pubmed id not found"
  exit 1
fi

if [[ $(echo $uid | wc -w) -gt 1 ]]; then
  echo 'more than one pmid found, going to pubmed'
  exturl="https://www.ncbi.nlm.nih.gov/pubmed/?term=$author[au]+AND+$journal[ta]+AND+$year[dp]"
  xdg-open $exturl
  exit 1
fi

echo $uid | xclip -selection clipboard
echo $uid

# #request pubmed xml and transform into bibtex
# curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$uid&retmode=xml" > $uid.xml
# xsltproc --novalid $styleSheet $uid.xml > $uid.bib
# 
# #import bibtex
# echo "importing $uid.bib"
# cat $uid.bib >> $bibdFileOut
# 
# #clean up
# rm $uid.xml $uid.bib
