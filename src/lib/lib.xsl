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
       in the TIME_ORDER with the same TIME_VALUE. The $smoothing parameter
       sets the amount of lenience with which two TIME_VALUEs can still be
       considered the same (= maximum acceptable difference in
       milliseconds). In any case, stop the search before reaching the
       TIME_VALUE specified by $min-time-val. -->

  <xsl:function name="lib:first-ts-with-same-val">
    <xsl:param name="current-ts"/>
    <xsl:param name="time-val" as="xs:integer"/>
    <xsl:param name="min-time-val" as="xs:integer"/>
    <xsl:param name="smoothing" as="xs:integer"/>
    <xsl:variable name="preceding-sibling"
                  select="$current-ts/preceding-sibling::TIME_SLOT[1]"/>

    <xsl:choose>
      <xsl:when test="abs($preceding-sibling/@TIME_VALUE - $time-val) &lt;= $smoothing
                      and
                      not($preceding-sibling/@TIME_VALUE = $min-time-val)">
        <xsl:sequence
            select="lib:first-ts-with-same-val($preceding-sibling, $time-val,
                    $min-time-val, $smoothing)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$current-ts"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- Given a TIME_SLOT in the (ordered) TIME_ORDER, return the preceding
       one. -->

  <xsl:function name="lib:preceding-ts">
    <xsl:param name="ts"/>
    <xsl:param name="time-order"/>
    <xsl:sequence
        select="$time-order/TIME_SLOT[@TIME_SLOT_ID = $ts]/preceding-sibling::TIME_SLOT[1]/@TIME_SLOT_ID"/>
  </xsl:function>

  <!-- Map linguistic types to three-character ASCII-only names without
       spaces. -->

  <xsl:function name="lib:normalize-ling-type" as="xs:string">
    <xsl:param name="ling-type" as="xs:string"/>
    <xsl:variable name="only-ascii-letters"
                  select="replace(normalize-unicode($ling-type,'NFKD'),'[^a-zA-Z]','')"/>
    <xsl:sequence select="substring($only-ascii-letters, 1, 3)"/>
  </xsl:function>

</xsl:stylesheet>
