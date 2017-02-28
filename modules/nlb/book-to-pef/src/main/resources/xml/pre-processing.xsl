<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns="http://www.daisy.org/z3986/2005/dtbook/">

    <xsl:param name="uncontracted-pre" select="'⠐⠂ '"/>
    <xsl:param name="uncontracted-post" select="' ⠐⠂'"/>
    <xsl:template match="element()[(ancestor-or-self::*/(@xml:lang | @lang))[last()] != 'no']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="@xml:lang | @lang">
                <xsl:attribute name="style" select="concat(@style,'text-transform:uncontracted;')"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="matches(local-name(), '^(h[1-6]|p|li|td|th|bh|caption)$')">
                    <!-- <xsl:value-of select="$uncontracted-pre"/> -->  
                    <xsl:apply-templates mode="#current"/>
                    <!-- <xsl:value-of select="$uncontracted-post"/> --> 
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()" mode="#all" priority="-5">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
