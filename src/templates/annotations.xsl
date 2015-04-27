<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="lib">
  <xsl:import href="../lib/lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              encoding="UTF-8"/>

  <xsl:param name="corpus-name" select="'elan-corpus'"/>
  <xsl:param name="out-dir" select="'./'"/>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>
    <xsl:variable name="doc-dir"
                  select="concat($out-dir, '/', $corpus-name, '/', $file-no-ext)"/>

    <!-- create markables / features for tiers -->

    <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER">
      <xsl:variable name="full-tier-type" select="@LINGUISTIC_TYPE_REF"/>
      <xsl:variable name="tier-type" select="lib:normalize-ling-type($full-tier-type)"/>

      <!-- tiers with participants should be namespaced by those participants -->

      <xsl:variable name="speaker-id">
        <xsl:if test="@PARTICIPANT">
          <xsl:value-of select="concat(current()/@PARTICIPANT, '.')"/>
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
            <xsl:variable name="full-parent-type" select="//TIER[@TIER_ID = $parent-ref]/@LINGUISTIC_TYPE_REF"/>
            <xsl:value-of select="lib:normalize-ling-type($full-parent-type)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="paula-markable-id"
                    select="concat($speaker-id, $corpus-name, '.',
                            $file-no-ext, '.', $base-type, '_seg')"/>
      <!-- create a markable file only for alignable annotation tiers (ref
           annotation tiers will be anchored to their parent alignable
           annotation tiers) -->

      <xsl:if test="not(@PARENT_REF)">

        <xsl:result-document
            href="{$doc-dir}/{$paula-markable-id}.xml"
            doctype-system="paula_mark.dtd">
          <paula version="1.1">
            <header paula_id="{$paula-markable-id}"/>
            <markList type="{$tier-type}" xml:base="{$corpus-name}.{$file-no-ext}.tok.xml">
              <xsl:apply-templates select="ANNOTATION/*" mode="markable"/>
            </markList>
          </paula>
        </xsl:result-document>
      </xsl:if>

      <!-- create a feature file both for alignable and ref annotation tiers
      -->

      <xsl:result-document
          href="{$doc-dir}/{$paula-markable-id}_{$tier-type}.xml"
          doctype-system="paula_feat.dtd">
        <paula version="1.1">
          <header paula_id="{$paula-markable-id}_{$tier-type}"/>
          <featList type="{$tier-type}" xml:base="{$paula-markable-id}.xml">
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
    <xsl:variable name="time-order" select="/ANNOTATION_DOCUMENT/TIME_ORDER"/>
    <xsl:variable name="id" select="@ANNOTATION_ID"/>
    <!-- the xpointer range-to operator returns an inclusive range, but we
         actually need the markable span to stop just short of TIME_SLOT_REF2 -->
    <mark id="{$id}"
          xlink:href="#xpointer(id('{$start-tok}')/range-to(id('{lib:preceding-ts($end-tok,
                      $time-order)}')))"/>
  </xsl:template>

  <xsl:template match="ANNOTATION/ALIGNABLE_ANNOTATION" mode="feature">
    <xsl:param name="tier-type"/>
    <xsl:variable name="id" select="concat($tier-type, '_', position())"/>
    <xsl:variable name="ref" select="@ANNOTATION_ID"/>

    <!-- output only if ANNOTATION_VALUE is non-empty -->

    <xsl:if test="ANNOTATION_VALUE != ''">
      <feat id="{$id}" xlink:href="#{$ref}" value="{ANNOTATION_VALUE}"/>
    </xsl:if>

  </xsl:template>

  <xsl:template match="ANNOTATION/REF_ANNOTATION" mode="feature">
    <xsl:param name="tier-type"/>
    <xsl:variable name="id" select="concat($tier-type, '_', position())"/>
    <xsl:variable name="ref" select="@ANNOTATION_REF"/>

    <!-- output only if ANNOTATION_VALUE is non-empty -->

    <xsl:if test="ANNOTATION_VALUE != ''">
      <feat id="{$id}" xlink:href="#{$ref}" value="{ANNOTATION_VALUE}"/>
    </xsl:if>

  </xsl:template>

</xsl:stylesheet>
