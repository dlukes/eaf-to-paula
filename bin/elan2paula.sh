#!/usr/bin/env bash

# Transform a corpus of ELAN transcripts to the PAULA format.

# Usage: elan2paula.sh in_dir

SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
BASEDIR="$SCRIPTDIR/.."
XSLTPROC="saxonb-xslt -ext:on"

# can't use for loop here as I don't control the whitespace in the path to the
# corpus
find "$1" -iname "*.eaf" -print0 | while IFS= read -r -d '' file; do
    # for loop acceptable -- $BASEDIR is quoted and there's no whitespace in
    # the directories I myself control
    for template in "$BASEDIR"/src/templates/*.xsl; do
        echo "Running: $XSLTPROC '$file' $template"
        $XSLTPROC "$file" $template
    done
done
