<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:lib="lib:lib">

  <!-- Given a path, return base file name without extension. -->

  <xsl:function name="lib:file-no-ext" as="xs:string">
    <xsl:param name="base-uri" as="xs:string"/>
    <xsl:variable name="basename" select="replace($base-uri, '.*/', '')"/>
    <xsl:sequence select="replace($basename, '\.[^\.]+$', '')"/>
  </xsl:function>

  <!-- Given a TIME_SLOT element and a TIME_VALUE, return the first TIME_SLOT
       in the TIME_ORDER with the same TIME_VALUE. -->

  <xsl:function name="lib:first-ts-with-same-val" as="xs:string">
    <xsl:param name="current-ts"/>
    <xsl:param name="time-val" as="xs:string"/>
    <xsl:variable name="preceding-sibling"
                  select="$current-ts/preceding-sibling::TIME_SLOT[1]"/>
    <xsl:choose>
      <xsl:when test="$preceding-sibling/@TIME_VALUE = $time-val">
        <xsl:sequence
            select="lib:first-ts-with-same-val($preceding-sibling, $time-val)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$current-ts/@TIME_SLOT_ID"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>