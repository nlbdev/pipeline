<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns="http://www.daisy.org/z3986/2005/dtbook/" exclude-result-prefixes="#all" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dtbook:level4">
        <level5>
            <xsl:apply-templates select="@*|node()"/>
        </level5>
    </xsl:template>

    <xsl:template match="dtbook:h4">
        <h5>
            <xsl:apply-templates select="@*|node()"/>
        </h5>
    </xsl:template>

</xsl:stylesheet>
