<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="pef:meta">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <nlb:sheet-count value="{
                sum(
                    for $volume in //pef:volume return
                    for $section in $volume/pef:section return
                    for $duplex in ($section/@duplex,$volume/@duplex)[1]='true' return
                    if ($duplex)
                    then ceiling(count($section/pef:page) div 2)
                    else count($section/pef:page)
                )
            }"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
