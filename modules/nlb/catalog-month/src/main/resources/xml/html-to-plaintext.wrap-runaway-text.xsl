<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    <xsl:template match="@*|node()">
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:if test="string-length(normalize-space(.))&gt;0">
                    <xsl:value-of select="concat(normalize-space(.),' ')"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:for-each-group select="node()" group-starting-with="line">
                <xsl:apply-templates select="current-group()[1]"/>
                <xsl:for-each select="current-group()[position()&gt;1]">
                    <line>
                        <xsl:apply-templates select="."/>
                    </line>
                </xsl:for-each>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text">
        <xsl:apply-templates select="node()"/>
        <xsl:text> </xsl:text>
    </xsl:template>
</xsl:stylesheet>