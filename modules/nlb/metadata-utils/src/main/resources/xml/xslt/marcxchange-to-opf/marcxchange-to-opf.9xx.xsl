<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 9XX HENVISNINGER -->

    <!-- TODO: 911c and 911d (TIGAR project) -->

    <xsl:template match="marcxchange:datafield[@tag='996']">
        <xsl:variable name="websok-id" select="concat('websok-',1+count(preceding-sibling::marcxchange:datafield[@tag='996']))"/>

        <xsl:if test="marcxchange:subfield[@code='u']">
            <meta property="websok.url" id="{$websok-id}">
                <xsl:value-of select="marcxchange:subfield[@code='u']/text()"/>
            </meta>

            <xsl:for-each select="marcxchange:subfield[@code='t']">
                <meta property="websok.type" refines="{$websok-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
