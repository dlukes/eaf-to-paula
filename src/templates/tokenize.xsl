<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="lib">
  <xsl:import href="lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              doctype-system="paula_mark.dtd" encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>
    <xsl:result-document href="elan-corpus/{$file-no-ext}/elan-corpus.{$file-no-ext}.tok.xml">
      <paula version="1.1">
        <header paula_id="elan-corpus.{$file-no-ext}.tok"/>
        <markList type="tok" xml:base="elan-corpus.{$file-no-ext}.text.xml">
          <xsl:apply-templates select="ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT"/>
        </markList>
      </paula>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="TIME_SLOT">
    <xsl:variable name="i" select="position()"/>
    <mark id="tok_{$i}" xlink:href="#xpointer(string-range(//body,'',{$i},0))"/>
  </xsl:template>

</xsl:stylesheet>
