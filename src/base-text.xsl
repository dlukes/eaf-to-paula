<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib">
  <xsl:import href="lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              doctype-system="paula_mark.dtd" encoding="UTF-8"/>
  <xsl:strip-space elements="TIME_SLOT"/>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>
    <paula version="1.1">
      <header paula_id="elan-corpus.{$file-no-ext}.text"/>
      <body><xsl:apply-templates select="ANNOTATION_DOCUMENT/TIME_ORDER"/></body>
    </paula>
  </xsl:template>

  <xsl:template match="TIME_SLOT"><xsl:text>.</xsl:text></xsl:template>
</xsl:stylesheet>
