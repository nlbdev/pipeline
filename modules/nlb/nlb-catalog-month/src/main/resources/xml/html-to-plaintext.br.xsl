<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml" version="2.0">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="line">
        <xsl:for-each-group select="node()" group-starting-with="br">
            <line>
                <xsl:apply-templates select="current-group()[not(self::br)]"/>
            </line>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
