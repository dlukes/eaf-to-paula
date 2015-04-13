<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:lib="lib:lib">
  <xsl:function name="lib:file-no-ext" as="xs:string">
    <xsl:param name="base-uri" as="xs:string"/>
    <xsl:variable name="basename" select="replace($base-uri, '.*/', '')"/>
    <xsl:sequence select="replace($basename, '\.[^\.]+$', '')"/>
  </xsl:function>
</xsl:stylesheet>
