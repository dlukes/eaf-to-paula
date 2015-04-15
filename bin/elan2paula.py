#!/usr/bin/env python3

"""Transform a corpus of ELAN transcripts to the PAULA standoff annotation
format.

Basic usage: elan2paula.py input_dir

Consult also elan2paula.py -h for additional parameters.

"""

import os
import sys
import glob
import shutil
import argparse
import subprocess

import re

### INVOCATION OF EXTERNAL PROGRAMS ###

XSLTPROC = "saxonb-xslt"
XMLLINT = "xmllint"

#######################################

def process_command_line(argv):
    """Return args list.  `argv` is a list of arguments, or `None` for
    ``sys.argv[1:]``.

    """
    if argv is None:
        argv = sys.argv[1:]

    # initialize the parser object:
    parser = argparse.ArgumentParser(description="""Transform a corpus of ELAN
                                     transcripts to the PAULA standoff
                                     annotation format.""")

    # define options here:
    parser.add_argument("input_dir", nargs=1, help="""input directory
                        containing .eaf transcriptions""")
    parser.add_argument("-o", "--output-dir", help="""directory to write output to;
                        the last directory in the path will be the
                        name of the corpus""", default="elan-corpus")
    parser.add_argument("-s", "--smoothing", type=int, default=20,
                        help="""smoothing of timeline in ms (see README)""")
    parser.add_argument("-p", "--prepend", default="doc", help="""string to
                        prepend to each document name""")

    args = parser.parse_args(argv)

    return args

def main(argv=None):
    args = process_command_line(argv)

    global XSLTPROC, XMLLINT

    SCRIPTDIR = os.path.dirname(os.path.realpath(__file__))
    BASEDIR = os.path.normpath(os.path.join(SCRIPTDIR, ".."))
    TEMPLDIR = os.path.join(BASEDIR, "src", "templates")
    LIBDIR = os.path.join(BASEDIR, "src", "lib")
    DTDDIR = os.path.join(BASEDIR, "src", "dtds")
    PREPROC = os.path.join(LIBDIR, "preprocess.xsl")
    IN_DIR = args.input_dir[0]
    OUT_DIR = args.output_dir
    ACCEPTED_FILE_GLOB = "*.eaf"
    XSLTPROC = [XSLTPROC, "-ext:on"]
    XSLTPARAMS = ["corpus-name=elan-corpus"]
    # XSLTPROC = ["saxon", "-ext:on"]
    XMLLINT = [XMLLINT, "--valid", "--noout"]

    for f in glob.iglob(os.path.join(IN_DIR, ACCEPTED_FILE_GLOB)):
        # abort if an input file contains whitespace in basename
        basename = os.path.basename(f)
        if re.search(r"\s", basename):
            sys.stderr.write("Filename {} contains whitespace. Please remove it "
                             "before proceeding.\n".format(basename))
            sys.exit(1)

        # create output directory for current document
        file_no_ext = "doc" + os.path.splitext(basename)[0]
        curr_doc_out_dir = os.path.join(OUT_DIR, file_no_ext)
        if not os.path.exists(curr_doc_out_dir):
            os.makedirs(curr_doc_out_dir)

        # preprocess ELAN file (= deduplicate TIME_ORDER and rewire TIME_SLOT_REFs)
        tempfile = os.path.join(OUT_DIR, file_no_ext, file_no_ext + ".temp")
        command = XSLTPROC + ["-xsl:{}".format(PREPROC), f]
        sys.stderr.write("Preprocessing file {} with: {}\n".
                         format(basename, " ".join(command)))
        subprocess.call(command)

        for template in glob.iglob(os.path.join(TEMPLDIR, "*.xsl")):
            command = XSLTPROC + [tempfile, template] + XSLTPARAMS
            sys.stderr.write("Running: {}\n".format(" ".join(command)))
            subprocess.call(command)

        sys.stderr.write("Copying DTD files for {}.\n".format(basename))
        for dtd in glob.iglob(os.path.join(DTDDIR, "*.dtd")):
            dtd_basename = os.path.basename(dtd)
            shutil.copyfile(dtd, os.path.join(curr_doc_out_dir, dtd_basename))

        sys.stderr.write("Removing temporary files for {}.\n".format(basename))
        os.remove(tempfile)

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

    return 0        # success

if __name__ == '__main__':
    status = main()
    sys.exit(status)
