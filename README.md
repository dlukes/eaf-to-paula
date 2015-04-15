# Introduction

This repository provides a set of XSLT templates to transform linguistic
transcription files in the
[ELAN Annotation Format](https://tla.mpi.nl/tools/tla-tools/elan/) to
[PAULA](https://www.sfb632.uni-potsdam.de/paula.html) standoff
annotation. These can be further converted to the relANNIS format used by the
[ANNIS corpus manager](http://annis-tools.org/) using the
[SaltNPepper](https://github.com/korpling/pepper) conversion framework.

# Pre-requisites

- environment: this software was tested to work on Ubuntu 14.04 and OS X 10.10;
  getting it to work in other environments may require some creative tweaking
- an XSLT 2.0 compliant processor --
  [Saxon / Saxon B](http://saxon.sourceforge.net/) is expected by the bundled
  wrapper script
  - install on Ubuntu with `apt-get install libsaxonb-java`
- an XML validator, such as `xmllint`
  - install on Ubuntu with `apt-get install libxml2`
- Python 3.x if (to run the bundled wrapper script)

# Usage

Verify that the string `XSLTPROC` in `bin/elan2paula.py` is a correct path to
Saxon / Saxon B (XSLT 2.0 compliant) on your system (or change it accordingly).
Similarly with the XML validator command stored in `XMLLINT`. Then, run:

```sh
$ bin/elan2paula.py path/to/input/eaf/files/
```

The PAULA output will appear in your current working directory in a directory
called `elan-corpus`.

A default smoothing of 20ms is applied to the `TIME_VALUE`s in the `TIME_ORDER`,
i.e. events on the timeline which are less than 20ms apart are considered to
occur at the same time. This can be changed by setting the `-s` option on the
command line. List all available options by running:

```sh
$ bin/elan2paula.py -h
```

# Assumptions

The PAULA feat file `type` attribute is derived from the `LINGUISTIC_TYPE_REF`
attribute of the relevant tier by:

- removing accents
- stripping any character which is NOT an ASCII letter (`[^a-zA-Z]`) by this
  point, including whitespace
- keeping only the first three characters

Please make sure that your `LINGUISTIC_TYPE_REF`s are such that they remain
distinct after the conversion. The following different `LINGUISTIC_TYPE_REF`s
would be problematic if occurring in the same file, because they would be
normalized to the same `type`:

- `orthographic 1` and `orthographic 2` (both normalize to `ort`)
- `abc` and `äbc` (both normalize to `abc`)
- `...` and `---` (both normalize to an empty value, because they do not
  contain enough characters which can be converted to ASCII)

Annotation layers which have a `PARTICIPANT` attribute are namespaced by an id
derived from it (`spk1` ... `spkN`) on the assumption that each speaker has
his/her own set of layers of the given `LINGUISTIC_TYPE`.

# Limitations

No metadata files (at the corpus or document level) are currently being
generated, nor are `annoSet` and `annoFeat` files. Some of these are required
by the PAULA specification, but as they're not needed for the conversion from
PAULA to relANNIS by SaltNPepper (which is my primary goal here), they're not a
priority.

# License

Copyright © 2015 David Lukeš, except for files located in `src/dtds`, which are
part of the PAULA specification.

Distributed under the GNU General Public License v3.
