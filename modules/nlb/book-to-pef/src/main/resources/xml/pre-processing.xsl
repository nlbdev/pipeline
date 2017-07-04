<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns="http://www.daisy.org/z3986/2005/dtbook/"
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
    
</xsl:stylesheet>
