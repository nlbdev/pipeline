<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 4XX SERIEANGIVELSER -->

    <xsl:template match="marcxchange:datafield[@tag='440']">
        <xsl:variable name="title-id" select="concat('series-title-',1+count(preceding-sibling::marcxchange:datafield[@tag='440' or @tag='490']))"/>

        <xsl:variable name="series-title" as="element()?">
            <xsl:if test="marcxchange:subfield[@code='a']">
                <meta property="dc:title.series" id="{$title-id}">
                    <xsl:value-of select="marcxchange:subfield[@code='a'][1]/text()"/>
                </meta>
            </xsl:if>
        </xsl:variable>
        <xsl:copy-of select="$series-title"/>
        <xsl:for-each select="marcxchange:subfield[@code='p']">
            <meta property="dc:title.subSeries">
                <xsl:if test="$series-title">
                    <xsl:attribute name="refines" select="concat('#',$title-id)"/>
                </xsl:if>
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='x']">
            <meta property="series.issn">
                <xsl:if test="$series-title">
                    <xsl:attribute name="refines" select="concat('#',$title-id)"/>
                </xsl:if>
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='v']">
            <meta property="series.partNumber">
                <xsl:if test="$series-title">
                    <xsl:attribute name="refines" select="concat('#',$title-id)"/>
                </xsl:if>
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='449']">
        <xsl:variable name="fields">
            <xsl:apply-templates select="../marcxchange:datafield[@tag='300']"/>
        </xsl:variable>
        <xsl:for-each select="marcxchange:subfield[@code='n']">
            <xsl:choose>
                <xsl:when test="$fields/meta[@property='dc:format.extent']">
                    <meta property="dc:format.extent.other">
                        <xsl:value-of select="concat(text(),' CDs')"/>
                    </meta>
                </xsl:when>
                <xsl:otherwise>
                    <meta property="dc:format.extent">
                        <xsl:value-of select="concat(text(),' CDs')"/>
                    </meta>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='490']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 490 SERIEANGIVELSE UTEN BIINNFØRSEL'"/>-->
    </xsl:template>

</xsl:stylesheet>
