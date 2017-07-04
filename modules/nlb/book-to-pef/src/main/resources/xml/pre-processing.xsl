<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="node()" mode="#all" priority="-5">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="noteref[normalize-space(.) eq '*']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="1 + count(preceding::noteref)"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="note/p[1]/text()[1][starts-with(normalize-space(.), '*')]">
        <xsl:value-of select="1 + count(preceding::note)"/>
        <xsl:value-of select="substring-after(., '*')"/>
    </xsl:template>

    <!-- Rename article and main elements to section, to simplify CSS styling -->
    <xsl:template match="html:article | html:main">
        <xsl:element name="section" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="epub:type" select="string-join(distinct-values(tokenize(@epub:type,'\s+'),local-name()),' ')"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
