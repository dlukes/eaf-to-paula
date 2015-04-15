<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="lib">
  <xsl:import href="../lib/lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              doctype-system="paula_feat.dtd" encoding="UTF-8"/>

  <xsl:param name="corpus-name" select="'elan-corpus'"/>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>
    <xsl:result-document href="{$corpus-name}/{$file-no-ext}/{$corpus-name}.{$file-no-ext}.tok_audio.xml">
      <paula version="1.1">
        <header paula_id="{$corpus-name}.{$file-no-ext}.tok_audio"/>
        <featList type="audio" xml:base="{$corpus-name}.{$file-no-ext}.tok.xml">
          <feat id="audio_1" xlink:href="#ts1" value="[ExtFile]{$file-no-ext}/{$file-no-ext}.wav"/>
        </featList>
      </paula>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
