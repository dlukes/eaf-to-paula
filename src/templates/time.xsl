<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="lib">
  <xsl:import href="../lib/lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              doctype-system="paula_feat.dtd" encoding="UTF-8"/>

  <xsl:param name="corpus-name"/>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>
    <xsl:result-document href="{$corpus-name}/{$file-no-ext}/annis.{$corpus-name}.{$file-no-ext}.tok_time.xml">
      <paula version="1.1">
        <header paula_id="annis.{$corpus-name}.{$file-no-ext}.tok_time"/>
        <featList type="time" xml:base="{$corpus-name}.{$file-no-ext}.tok.xml">

          <!-- for each TIME_SLOT, create a time annotation starting at its
               TIME_VALUE and ending at its following sibling's TIME_VALUE -->

          <xsl:apply-templates select="ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT"/>

        </featList>
      </paula>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="TIME_SLOT">
    <xsl:variable name="following-sibling"
                  select="following-sibling::TIME_SLOT[1]"/>

    <!-- ignore the last TIME_SLOT (it has no following sibling) -->

    <xsl:if test="$following-sibling">
      <xsl:variable name="id" select="@TIME_SLOT_ID"/>
      <xsl:variable name="start-time"
                    select="@TIME_VALUE div 1000"/>
      <xsl:variable name="end-time"
                    select="$following-sibling/@TIME_VALUE div 1000"/>
      <feat id="{$id}"
            xlink:href="#{$id}"
            value="{$start-time}-{$end-time}"/>
    </xsl:if>

  </xsl:template>

</xsl:stylesheet>
