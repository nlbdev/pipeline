<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 050 - 099 KLASSIFIKASJONSKODER -->

    <xsl:template match="marcxchange:datafield[@tag='082']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.dewey">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='b']">
            <meta property="dc:subject.dewey">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[matches(@tag,'09\d')]">
        <!--<xsl:message select="'NORMARC-felt ignorert: 09X LOKALT FELT'"/>-->
    </xsl:template>
    
</xsl:stylesheet>
