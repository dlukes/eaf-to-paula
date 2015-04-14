<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="lib">
  <xsl:import href="../lib/lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>
    <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER">
      <xsl:variable name="tier-type" select="@LINGUISTIC_TYPE_REF"/>

      <!-- tiers with participants should be namespaced by those participants -->

      <xsl:variable name="speaker-id">
        <xsl:if test="@PARTICIPANT">
          <xsl:value-of select="concat(@PARTICIPANT, '.')"/>
        </xsl:if>
      </xsl:variable>

      <!-- set the annotation type of the base file (the same as the feature
           file for an alignable tier, and the parent's type for a ref tier) -->

      <xsl:variable name="base-type">
        <xsl:choose>
          <xsl:when test="not(@PARENT_REF)">
            <xsl:value-of select="$tier-type"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="parent-ref" select="@PARENT_REF"/>
            <xsl:value-of select="//TIER[@TIER_ID = $parent-ref]/@LINGUISTIC_TYPE_REF"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!-- !!! solution for range of markables: sort the tok_time annotations and
           make the endpoint of the range refer to the node preceding that with
           the end-time id -->

      <!-- !!! solution for unknown tier types: only ASCII + truncate + add a
           positional number in case homonymy arises from the previous two
           steps -->

      <!-- create a markable file only for alignable annotation tiers (ref
           annotation tiers will be anchored to their parent alignable
           annotation tiers) -->

      <xsl:if test="not(@PARENT_REF)">
        <xsl:result-document
            href="elan-corpus/{$file-no-ext}/{$speaker-id}elan-corpus.{$file-no-ext}.{$tier-type}_seg.xml"
            doctype-system="paula_mark.dtd">
          <paula version="1.1">
            <header paula_id="{$speaker-id}elan-corpus.{$file-no-ext}.{$tier-type}_seg"/>
            <markList type="{$tier-type}" xml:base="elan-corpus.{$file-no-ext}.tok.xml">
              <xsl:apply-templates select="ANNOTATION/*" mode="markable"/>
            </markList>
          </paula>
        </xsl:result-document>
      </xsl:if>

      <!-- create a feature file both for alignable and ref annotation tiers
      -->

      <xsl:result-document
          href="elan-corpus/{$file-no-ext}/{$speaker-id}elan-corpus.{$file-no-ext}.{$base-type}_seg_{$tier-type}.xml"
          doctype-system="paula_feat.dtd">
        <paula version="1.1">
          <header paula_id="{$speaker-id}.elan-corpus.{$file-no-ext}.{$tier-type}_seg"/>
          <featList type="{$tier-type}" xml:base="{$speaker-id}elan-corpus.{$file-no-ext}.{$base-type}_seg_{$tier-type}.xml">
            <xsl:apply-templates select="ANNOTATION/*" mode="feature">
              <xsl:with-param name="tier-type" select="$tier-type"/>
            </xsl:apply-templates>
          </featList>
        </paula>
      </xsl:result-document>

    </xsl:for-each>
  </xsl:template>

  <xsl:template match="ANNOTATION/ALIGNABLE_ANNOTATION" mode="markable">
    <xsl:variable name="start-tok" select="@TIME_SLOT_REF1"/>
    <xsl:variable name="end-tok" select="@TIME_SLOT_REF2"/>
    <xsl:variable name="id" select="@ANNOTATION_ID"/>
    <mark id="{$id}"
          xlink:href="#xpointer(id('{$start-tok}')/range-to(id('{$end-tok}')))"/>
  </xsl:template>

  <xsl:template match="ANNOTATION/ALIGNABLE_ANNOTATION" mode="feature">
    <xsl:param name="tier-type"/>
    <xsl:variable name="id" select="concat($tier-type, '_', position())"/>
    <xsl:variable name="ref" select="@ANNOTATION_ID"/>
    <feat id="{$id}" xlink:href="#{$ref}" value="{ANNOTATION_VALUE}"/>
  </xsl:template>

  <xsl:template match="ANNOTATION/REF_ANNOTATION" mode="feature">
    <xsl:param name="tier-type"/>
    <xsl:variable name="id" select="concat($tier-type, '_', position())"/>
    <xsl:variable name="ref" select="@ANNOTATION_REF"/>
    <feat id="{$id}" xlink:href="#{$ref}" value="{ANNOTATION_VALUE}"/>
  </xsl:template>

</xsl:stylesheet>
