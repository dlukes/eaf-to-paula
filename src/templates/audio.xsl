<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="lib">
  <xsl:import href="../lib/lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              doctype-system="paula_feat.dtd" encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>
    <xsl:result-document href="elan-corpus/{$file-no-ext}/elan-corpus.{$file-no-ext}.tok_audio.xml">
      <paula version="1.1">
        <header paula_id="elan-corpus.{$file-no-ext}.tok_audio"/>
        <featList type="audio" xml:base="elan-corpus.{$file-no-ext}.tok.xml">
          <feat id="audio_1" xlink:href="#tok_1" value="[ExtFile]{$file-no-ext}/{$file-no-ext}.wav"/>
        </featList>
      </paula>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
