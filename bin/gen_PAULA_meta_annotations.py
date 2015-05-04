#!/usr/bin/env python3

import os
import sys
import glob

import itertools
from copy import deepcopy
from collections import defaultdict
from pprint import pprint

import re
import lxml.etree as etree

meta = sys.argv[1]
corpus = sys.argv[2].strip("/").strip("\\")

SCRIPTDIR = os.path.dirname(os.path.realpath(__file__))
BASEDIR = os.path.normpath(os.path.join(SCRIPTDIR, ".."))
TEMPLDIR = os.path.join(BASEDIR, "src", "meta")

# parse metadata annotation templates
parser = etree.XMLParser(remove_blank_text=True)
spk_seg = etree.parse(os.path.join(TEMPLDIR, "spk_seg.xml"), parser)
spk_seg_soc = etree.parse(os.path.join(TEMPLDIR, "spk_seg_soc.xml"), parser)
spk_rel = etree.parse(os.path.join(TEMPLDIR, "spk_rel.xml"), parser)

# parse metadata and store them in a dict
soc = defaultdict(dict)
with open(meta, "r") as f:
    for line in f:
        columns = line.strip().split("\t")
        recording, num = columns[:2]
        meta = ";".join(columns[2:])      # = speaker, gender, year, region, # education
        soc["doc" + recording]["spk" + num] = meta

# create the metadata annotations for the individual speakers
for doc_path in glob.iglob(os.path.join(corpus, "*/")):
    sys.stderr.write("Processing: {} ...\n".format(doc_path))

    doc = os.path.split(doc_path[:-1])[1]

    # generate IDs / filename stubs
    ss_id = "{}.{}.spk_seg".format(corpus, doc)
    sss_id = "{}.{}.spk_seg_soc".format(corpus, doc)
    sr_id = "{}.{}.spk_rel".format(corpus, doc)

    # set up templates
    ss = deepcopy(spk_seg)
    ss.xpath("//header")[0].attrib["paula_id"] = ss_id
    ss.xpath("//markList")[0].attrib["{http://www.w3.org/XML/1998/namespace}base"] = "{}.{}.tok.xml".format(corpus, doc)

    sss = deepcopy(spk_seg_soc)
    sss.xpath("//header")[0].attrib["paula_id"] = sss_id
    sss.xpath("//featList")[0].attrib["{http://www.w3.org/XML/1998/namespace}base"] = ss_id + ".xml"

    sr = deepcopy(spk_rel)
    sr.xpath("//header")[0].attrib["paula_id"] = sr_id
    sr.xpath("//relList")[0].attrib["{http://www.w3.org/XML/1998/namespace}base"] = ss_id + ".xml"

    speakers = map(os.path.basename, glob.glob(os.path.join(doc_path, "spk*")))
    speakers = sorted(set([x[:4] for x in speakers]))

    for spk in speakers:
        etree.SubElement(ss.xpath("//markList")[0],
                         "mark",
                         attrib = {
                             "id": spk,
                             "{http://www.w3.org/1999/xlink}href": "#ts1"
                         })
        etree.SubElement(sss.xpath("//featList")[0],
                         "feat",
                         attrib = {
                             "{http://www.w3.org/1999/xlink}href": "#" + spk,
                             "value": soc[os.path.basename(doc)].get(spk, "<empty>")
                         })

    ss.write(os.path.join(doc_path, ss_id + ".xml"),
             pretty_print=True,
              encoding="UTF-8",
             xml_declaration=True)
    sss.write(os.path.join(doc_path, sss_id + ".xml"),
              pretty_print=True,
              xml_declaration=True,
              encoding="UTF-8")

    # link segments spoken by individual speakers to their metadata with pointing
    # relations
    meta_glob = glob.iglob(os.path.join(doc_path, "spk*.met_seg.*"))
    ort_glob = glob.iglob(os.path.join(doc_path, "spk*.ort_seg.*"))
    fon_glob = glob.iglob(os.path.join(doc_path, "spk*.fon_seg.*"))

    rel_list = sr.xpath("//relList")[0]
    rel_count = 1

    for annot in itertools.chain(ort_glob, fon_glob, meta_glob):
        tree = etree.parse(annot)
        annot = os.path.basename(annot)
        spk = re.findall(r"spk.", annot)[0]
        for feat in tree.xpath("//mark"):
            id = feat.attrib.get("id")
            etree.SubElement(rel_list,
                             "rel",
                             attrib = {
                                 "id": "rel" + str(rel_count),
                                 "{http://www.w3.org/1999/xlink}href": "#" + spk,
                                 "target": annot + "#" + id
                             })
            rel_count += 1

    sr.write(os.path.join(doc_path, sr_id + ".xml"),
             pretty_print=True,
             xml_declaration=True,
             encoding="UTF-8")
