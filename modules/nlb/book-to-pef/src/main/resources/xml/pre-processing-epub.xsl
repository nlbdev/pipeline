<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
                xmlns:epub="http://www.idpf.org/2007/ops"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="node()" mode="#all" priority="-5">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="a[f:types(.)='noteref'][normalize-space(.) eq '*']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="1 + count(preceding::a[f:types(.)='noteref'])"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="aside[f:types(.)='note']/p[1]/text()[1][starts-with(normalize-space(.), '*')] | li[f:types(.)=('rearnote','footnote')]/p[1]/text()[1][starts-with(normalize-space(.), '*')]">
        <xsl:value-of select="1 + count(preceding::aside[f:types(.)='note'] | preceding::li[f:types(.)=('rearnote','footnote')])"/>
        <xsl:value-of select="substring-after(., '*')"/>
    </xsl:template>
    
    <xsl:function name="f:types" as="xs:string*">
        <xsl:param name="element" as="element()"/>
        <xsl:sequence select="tokenize($element/@epub:type,'\s+')"/>
    </xsl:function>
    
</xsl:stylesheet>
