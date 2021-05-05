#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
        spubmed.sh - search for pubmed for author, journal, year

         usage:
          spubmed.sh 'kaas' 'trends+neurosci' '1995'
          spubmed.sh 'rakic' 'j+comp+neurol' '1972'

         depends: 
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
author=$1
journal=$2
year=$3

#curl's option globoff needed for using brackets in a uri
uid=$(curl -s --globoff "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=$author[au]+AND+$journal[ta]+AND+$year[dp]&retmode=xml" | grep -E "<Id>[0-9]+</Id>" | sed -E "s|<Id>([0-9]+)</Id>|\1|")

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

echo $uid
# echo $uid | xclip -selection clipboard
echo $uid | wl-copy

