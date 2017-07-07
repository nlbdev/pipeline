<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:f="#"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@* | node()" mode="#all" priority="-5">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="dtbook:noteref[normalize-space(.) eq '*'] | html:*[f:types(.)='noteref'][normalize-space(.) eq '*']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="1 + count(preceding::dtbook:noteref | preceding::html:*[f:types(.)='noteref'])"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dtbook:note/dtbook:p[1]/text()[1][starts-with(normalize-space(.), '*')] | html:*[f:types(.)=('note','footnote','endnote','rearnote')]/html:p[1]/text()[1][starts-with(normalize-space(.), '*')]">
        <xsl:value-of select="1 + count(preceding::dtbook:note | preceding::html:*[f:types(.)=('note','footnote','endnote','rearnote')])"/>
        <xsl:value-of select="substring-after(., '*')"/>
    </xsl:template>

    <!-- Rename article and main elements to section, to simplify CSS styling -->
    <xsl:template match="html:article | html:main">
        <xsl:element name="section" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="epub:type" select="string-join(distinct-values((f:types(.),local-name())),' ')"/>
            <xsl:apply-templates select="@* except @epub:type"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="f:types" as="xs:string*">
        <xsl:param name="element" as="element()"/>
        <xsl:sequence select="tokenize($element/@epub:type,'\s+')"/>
    </xsl:function>
    
</xsl:stylesheet>
