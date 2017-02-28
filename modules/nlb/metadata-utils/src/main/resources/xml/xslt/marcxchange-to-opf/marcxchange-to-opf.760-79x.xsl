<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 760 - 79X LENKER / RELASJONER -->

    <xsl:template match="marcxchange:datafield[@tag='780']">
        <xsl:variable name="series-preceding-id" select="concat('series-preceding-',1+count(preceding-sibling::marcxchange:datafield[@tag='780']))"/>

        <xsl:if test="marcxchange:subfield[@code='t']">
            <meta property="dc:title.series.preceding" id="{$series-preceding-id}">
                <xsl:value-of select="marcxchange:subfield[@code='t']/text()"/>
            </meta>
        </xsl:if>
        <xsl:for-each select="marcxchange:subfield[@code='w']">
            <meta property="dc:identifier.series.preceding.uri" refines="#{$series-preceding-id}">
                <xsl:value-of select="concat('urn:NBN:no-nb_nlb_',text())"/>
            </meta>
            <meta property="dc:identifier.series.preceding">
                <xsl:choose>
                    <xsl:when test="parent::*/marcxchange:subfield[@code='t']">
                        <xsl:attribute name="refines" select="concat('#',$series-preceding-id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="id" select="$series-preceding-id"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:title.series.preceding.alternative" refines="#{$series-preceding-id}">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='785']">
        <xsl:variable name="series-sequel-id" select="concat('series-sequel-',1+count(preceding-sibling::marcxchange:datafield[@tag='785']))"/>

        <xsl:for-each select="marcxchange:subfield[@code='t']">
            <meta property="dc:title.series.sequel" id="{$series-sequel-id}">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='w']">
            <meta property="dc:identifier.series.sequel.uri" refines="#{$series-sequel-id}">
                <xsl:value-of select="concat('urn:NBN:no-nb_nlb_',text())"/>
            </meta>
            <meta property="dc:identifier.series.sequel">
                <xsl:choose>
                    <xsl:when test="parent::*/marcxchange:subfield[@code='t']">
                        <xsl:attribute name="refines" select="concat('#',$series-sequel-id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="id" select="$series-sequel-id"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:title.series.sequel.alternative" refines="#{$series-sequel-id}">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
