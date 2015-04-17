<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="lib">
  <xsl:import href="lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              encoding="UTF-8"/>

  <xsl:param name="corpus-name" select="'elan-corpus'"/>
  <xsl:param name="prepend" select="'doc'"/>
  <xsl:param name="smoothing" select="20"/>
  <xsl:param name="out-dir" select="'./'"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>
    <xsl:variable name="doc-name" select="concat($prepend, $file-no-ext)"/>
    <xsl:variable name="doc-dir"
                  select="concat($out-dir, '/', $corpus-name, '/', $doc-name)"/>
    <xsl:result-document href="{$doc-dir}/{$doc-name}.temp">
      <xsl:copy>
        <xsl:apply-templates select="node()"/>
      </xsl:copy>
    </xsl:result-document>
  </xsl:template>

  <!-- collapse adjacent TIME_SLOTs with the same TIME_VALUE -->

  <xsl:template match="TIME_ORDER">
    <xsl:copy>
      <!-- copy any attributes the TIME_ORDER tier might have as well -->
      <xsl:copy-of select="@*"/>
      <!-- TIME_SLOTs should already be sorted by ELAN, so let's not worry
           about that -->
      <xsl:for-each-group select="TIME_SLOT" group-by="@TIME_VALUE">
        <xsl:copy-of select="current-group()[1]"/>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <!-- rewire TIME_SLOT_REFs -->

  <xsl:template match="ALIGNABLE_ANNOTATION/@TIME_SLOT_REF1 |
                       ALIGNABLE_ANNOTATION/@TIME_SLOT_REF2">
    <xsl:variable name="time-ref" select="."/>
    <xsl:variable name="initial-ts" select="//TIME_SLOT[@TIME_SLOT_ID = $time-ref]"/>
    <xsl:variable name="time-val" select="$initial-ts/@TIME_VALUE"/>

    <!-- if this is a @TIME_SLOT_REF2, then we shouldn't go further than the
         @TIME_VALUE corresponding to @TIME_SLOT_REF1 when searching for the
         first-ts-with-same-val(). -->

    <xsl:variable name="min-time-val">
      <xsl:choose>
        <xsl:when  test="name(.) = 'TIME_SLOT_REF2'">
          <xsl:variable name="time-ref1" select="../@TIME_SLOT_REF1"/>
          <xsl:value-of select="//TIME_SLOT[@TIME_SLOT_ID = $time-ref1]/@TIME_VALUE"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:attribute name="{name(.)}"
                   select="lib:first-ts-with-same-val($initial-ts, $time-val,
                           $min-time-val, $smoothing)/@TIME_SLOT_ID"/>
  </xsl:template>

</xsl:stylesheet>
