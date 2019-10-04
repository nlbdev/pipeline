<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns="http://www.daisy.org/z3986/2005/dtbook/" exclude-result-prefixes="#all">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dtbook:linegroup">
        <table>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="dtbook:line">
        <tr>
            <td><xsl:value-of select="*[@class='fieldName']"/></td>
            <td><xsl:apply-templates select="node()[not(@class='fieldName')]"/></td>
        </tr>
    </xsl:template>
</xsl:stylesheet>