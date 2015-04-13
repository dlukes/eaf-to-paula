#!/usr/bin/env bash

# Transform a corpus of ELAN transcripts to the PAULA format.

# Usage: elan2paula.sh in_dir

SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
BASEDIR="$SCRIPTDIR/.."
XSLTPROC="saxonb-xslt -ext:on"
XMLLINT="xmllint --valid --noout"

# can't use for loop here as I don't control the whitespace in the path to the
# corpus
find "$1" -iname "*.eaf" -print0 | while IFS= read -r -d '' file; do
    # exit if filename contains spaces
    $space=" "
    if [[ "$file" =~ "$space" ]]; then
        echo "Corpus document file names must not contain spaces. Aborting."
        # this exits only the subshell created by the pipe, dammit!
        exit 1
    fi

    # for loop acceptable -- $BASEDIR is quoted and there's no whitespace in
    # the directories I myself control
    for template in "$BASEDIR"/src/templates/*.xsl; do
        echo "Running: $XSLTPROC '$file' $template"
        $XSLTPROC "$file" $template
    done
done

echo "Verifying generated files according to DTDs..."
find elan-corpus -iname "*.xml" -print0 | while IFS= read -r -d '' file; do
    echo -n "$file..."
    $XMLLINT "$file" && echo " OK"
done
