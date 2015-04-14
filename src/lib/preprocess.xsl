<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="lib">
  <xsl:import href="lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              encoding="UTF-8"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
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
    <xsl:attribute name="{name(.)}"
                   select="lib:first-ts-with-same-val($initial-ts, $time-val)"/>
  </xsl:template>

</xsl:stylesheet>
