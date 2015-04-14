#!/usr/bin/env python3

# Transform a corpus of ELAN transcripts to the PAULA format.

# Usage: elan2paula.py in_dir

import os
import sys
import glob
import subprocess
import tempfile

import re

SCRIPTDIR = os.path.dirname(os.path.realpath(__file__))
BASEDIR = os.path.normpath(os.path.join(SCRIPTDIR, ".."))
TEMPLDIR = os.path.join(BASEDIR, "src", "templates")
LIBDIR = os.path.join(BASEDIR, "src", "lib")
TEMPFILE = tempfile.NamedTemporaryFile()
IN_DIR = sys.argv[1]
OUT_DIR = "elan-corpus"
ACCEPTED_FILE_GLOB = "*.eaf"
XSLTPROC = ["saxonb-xslt", "-ext:on"]
# XSLTPROC = ["saxon", "-ext:on"]
PREPROC = (XSLTPROC +
           ["-xsl:{}".format(os.path.join(LIBDIR, "preprocess.xsl")),
            "-o:{}".format(TEMPFILE.name)])
XMLLINT = ["xmllint", "--valid", "--noout"]

for f in glob.iglob(os.path.join(IN_DIR, ACCEPTED_FILE_GLOB)):
    # abort if an input file contains whitespace in basename
    basename = os.path.basename(f)
    if re.search(r"\s", basename):
        sys.stderr.write("Filename {} contains whitespace. Please remove it "
                         "before proceeding.\n".format(basename))
        sys.exit(1)

    # preprocess ELAN file (= deduplicate TIME_ORDER and rewire TIME_SLOT_REFs)
    command = PREPROC + [f]
    sys.stderr.write("Preprocessing file {} with: {}\n".
                     format(basename, " ".join(command)))
    subprocess.call(command)

    for template in glob.iglob(os.path.join(TEMPLDIR, "*.xsl")):
        command = XSLTPROC + [TEMPFILE.name, template]
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
                sys.stderr.write(" ERROR\n")
                sys.exit(1)

TEMPFILE.close()
