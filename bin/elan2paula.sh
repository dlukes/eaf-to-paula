#!/usr/bin/env bash

# Transform a corpus of ELAN transcripts to the PAULA format.

# Usage: elan2paula.sh in_dir

SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
BASEDIR="$SCRIPTDIR/.."
XSLTPROC="saxonb-xslt -ext:on"

for file in $1/*.eaf; do
    for template in "$BASEDIR"/src/templates/*.xsl; do
        comm="$XSLTPROC ""$file ""$template"
        echo "Running: $comm"
        $comm
    done
done
