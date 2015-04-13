#!/usr/bin/env python3

# Transform a corpus of ELAN transcripts to the PAULA format.

# Usage: elan2paula.py in_dir

import os
import sys
import glob
import subprocess

import re

SCRIPTDIR = os.path.dirname(os.path.realpath(__file__))
BASEDIR = os.path.normpath(os.path.join(SCRIPTDIR, ".."))
TEMPLDIR = os.path.join(BASEDIR, "src/templates")
IN_DIR = sys.argv[1]
OUT_DIR = "elan-corpus"
ACCEPTED_FILE_GLOB = "*.eaf"
XSLTPROC = ["saxonb-xslt", "-ext:on"]
XMLLINT = ["xmllint", "--valid", "--noout"]

print(TEMPLDIR)
print(BASEDIR)

for f in glob.iglob(os.path.join(IN_DIR, ACCEPTED_FILE_GLOB)):
    # abort if an input file contains whitespace in basename
    basename = os.path.basename(f)
    if re.search(r"\s", basename):
        sys.stderr.write("Filename {} contains whitespace. Please remove it "
                         "before proceeding.\n".format(basename))
        sys.exit(1)

    for template in glob.iglob(os.path.join(TEMPLDIR, "*.xsl")):
        command = XSLTPROC + [f, template]
        sys.stderr.write("Running: {}\n".format(" ".join(command)))
        subprocess.call(command)

sys.stderr.write("Verifying generated files according to DTDs:\n")
for root, dirs, files in os.walk(OUT_DIR):
    for f in files:
        if f.endswith(".xml"):
            sys.stderr.write("  {}... ".format(f))
            fpath = os.path.join(root, f)
            if subprocess.call(XMLLINT + [fpath]) == 0:
                sys.stderr.write(" OK\n")
            else:
                sys.exit(1)
