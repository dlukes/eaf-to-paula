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
    <xsl:result-document href="elan-corpus/{$file-no-ext}/annis.elan-corpus.{$file-no-ext}.tok_time.xml">
      <paula version="1.1">
        <header paula_id="annis.elan-corpus.{$file-no-ext}.tok_time"/>
        <featList type="time" xml:base="elan-corpus.{$file-no-ext}.tok.xml">

          <!-- put ALIGNABLE_ANNOTATIONs into groups where both TIME_SLOT_REFs
               are the same -->

          <xsl:for-each-group
              select="ANNOTATION_DOCUMENT/TIER/ANNOTATION/ALIGNABLE_ANNOTATION"
              group-by="concat(@TIME_SLOT_REF1, '+', @TIME_SLOT_REF2)">

            <!-- output a time annotation only for the first match in each such
                 group, otherwise SaltNPepper complains that annotations with
                 the same QName are being repeatedly added to the same span -->

            <xsl:variable name="first-match" select="current-group()[1]"/>
            <xsl:variable name="start-tok" select="$first-match/@TIME_SLOT_REF1"/>
            <xsl:variable name="end-tok" select="$first-match/@TIME_SLOT_REF2"/>
            <xsl:variable name="id" select="$first-match/@ANNOTATION_ID"/>
            <xsl:variable name="start-time"
                          select="//TIME_SLOT[@TIME_SLOT_ID = $start-tok]/@TIME_VALUE
                                  div 1000"/>
            <xsl:variable name="end-time"
                          select="//TIME_SLOT[@TIME_SLOT_ID = $end-tok]/@TIME_VALUE div
                                  1000"/>
            <xsl:variable name="time-order" select="/ANNOTATION_DOCUMENT/TIME_ORDER"/>

            <!-- the xpointer range-to operator returns an inclusive range, but we
                 actually need the markable span to stop just short of TIME_SLOT_REF2 -->

            <feat id="{$id}"
                  xlink:href="#xpointer(id('{$start-tok}')/range-to(id('{lib:preceding-ts($end-tok,
                              $time-order)}')))"
                  value="{$start-time}-{$end-time}"/>

          </xsl:for-each-group>

        </featList>
      </paula>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
