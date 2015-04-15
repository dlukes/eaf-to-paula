<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                exclude-result-prefixes="lib">
  <xsl:import href="../lib/lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              doctype-system="paula_text.dtd" encoding="UTF-8"/>

  <xsl:param name="corpus-name" select="'elan-corpus'"/>
  <xsl:param name="out-dir" select="'./'"/>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>
    <xsl:variable name="doc-dir"
                  select="concat($out-dir, '/', $corpus-name, '/',
                          $file-no-ext)"/>
    <xsl:variable name="paula-id"
                  select="concat($corpus-name, '.', $file-no-ext, '.text')"/>
    <xsl:result-document href="{$doc-dir}/{$paula-id}.xml">
      <paula version="1.1">
        <header paula_id="{$paula-id}"/>
        <body>
          <xsl:for-each select="ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT">
            <xsl:text>.</xsl:text>
          </xsl:for-each>
        </body>
      </paula>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
