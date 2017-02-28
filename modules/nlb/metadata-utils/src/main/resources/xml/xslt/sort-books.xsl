<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[starts-with(local-name(),'level') and ancestor::*/@id=('audio','braille')]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="*[starts-with(local-name(),'level') and starts-with(@id,'b_')]">
                    <xsl:copy-of select="*[not(starts-with(local-name(),'level'))]"/>
                    <xsl:apply-templates select="*[starts-with(local-name(),'level') and starts-with(@id,'b_')]">
                        <xsl:sort select="lower-case(normalize-space(string-join(*[matches(local-name(),'^h\d$')]//text(),'')))"/>
                        <xsl:sort select="lower-case(normalize-space(string-join((*//*[@class='author'])[1]//text(),'')))"/>
                        <xsl:sort select="lower-case(normalize-space(string-join((*//*[@class='title'])[1]//text(),'')))"/>
                        <xsl:sort select="normalize-space(string-join((*//*[@class='publisherYear'])[1],''))"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="*[starts-with(local-name(),'level') and not(starts-with(@id,'b_'))]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="dtbook:list[@id=('periodical-audio-list','periodical-braille-list')]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*">
                <xsl:sort select="string-join(text(),'')"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
