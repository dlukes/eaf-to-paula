<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lib="lib:lib"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="lib">
  <xsl:import href="../lib/lib.xsl"/>
  <xsl:output method="xml" version="1.0" standalone="no" indent="yes"
              encoding="UTF-8"/>

  <xsl:param name="corpus-name"/>

  <xsl:template match="/">
    <xsl:variable name="file-no-ext" select="lib:file-no-ext(base-uri())"/>

    <!-- map participant names to shorter ASCII-only names -->

    <xsl:variable name="speakers">
      <xsl:for-each select="distinct-values(//@PARTICIPANT)">
        <entry key="{.}" value="spk{position()}"/>
      </xsl:for-each>
    </xsl:variable>

    <!-- create markables / features for tiers -->

    <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER">
      <xsl:variable name="full-tier-type" select="@LINGUISTIC_TYPE_REF"/>
      <xsl:variable name="tier-type" select="lib:normalize-ling-type($full-tier-type)"/>

      <!-- tiers with participants should be namespaced by those participants -->

      <xsl:variable name="speaker-id">
        <xsl:if test="@PARTICIPANT">
          <xsl:value-of select="concat($speakers/entry[@key = current()/@PARTICIPANT]/@value, '.')"/>
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

      <!-- create a markable file only for alignable annotation tiers (ref
           annotation tiers will be anchored to their parent alignable
           annotation tiers) -->

      <xsl:if test="not(@PARENT_REF)">
        <xsl:result-document
            href="{$corpus-name}/{$file-no-ext}/{$speaker-id}{$corpus-name}.{$file-no-ext}.{$tier-type}_seg.xml"
            doctype-system="paula_mark.dtd">
          <paula version="1.1">
            <header paula_id="{$speaker-id}{$corpus-name}.{$file-no-ext}.{$tier-type}_seg"/>
            <markList type="{$tier-type}" xml:base="{$corpus-name}.{$file-no-ext}.tok.xml">
              <xsl:apply-templates select="ANNOTATION/*" mode="markable"/>
            </markList>
          </paula>
        </xsl:result-document>
      </xsl:if>

      <!-- create a feature file both for alignable and ref annotation tiers
      -->

      <xsl:result-document
          href="{$corpus-name}/{$file-no-ext}/{$speaker-id}{$corpus-name}.{$file-no-ext}.{$base-type}_seg_{$tier-type}.xml"
          doctype-system="paula_feat.dtd">
        <paula version="1.1">
          <header paula_id="{$speaker-id}{$corpus-name}.{$file-no-ext}.{$base-type}_seg_{$tier-type}"/>
          <featList type="{$tier-type}" xml:base="{$speaker-id}{$corpus-name}.{$file-no-ext}.{$base-type}_seg.xml">
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
    <feat id="{$id}" xlink:href="#{$ref}" value="{ANNOTATION_VALUE}"/>
  </xsl:template>

  <xsl:template match="ANNOTATION/REF_ANNOTATION" mode="feature">
    <xsl:param name="tier-type"/>
    <xsl:variable name="id" select="concat($tier-type, '_', position())"/>
    <xsl:variable name="ref" select="@ANNOTATION_REF"/>
    <feat id="{$id}" xlink:href="#{$ref}" value="{ANNOTATION_VALUE}"/>
  </xsl:template>

</xsl:stylesheet>
