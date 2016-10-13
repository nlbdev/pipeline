<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 2XX TITTEL-, ANSVARS- OG UTGIVELSESOPPLYSNINGER -->

    <xsl:template match="marcxchange:datafield[@tag='240']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:title.alternative">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='245']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <dc:title>
                <xsl:value-of select="text()"/>
            </dc:title>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='b']">
            <meta property="dc:title.subTitle">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='h']">
            <xsl:choose>
                <xsl:when test="matches(text(),'.*da[i\\ss][si]y[\\.\\s]*.*','i') or matches(text(),'.*2[.\\s]*0?2.*','i')">
                    <dc:format>DAISY 2.02</dc:format>
                </xsl:when>
                <xsl:when test="matches(text(),'.*dtbook.*','i')">
                    <dc:type>Full Text</dc:type>
                    <dc:format>DTBook</dc:format>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='n']">
            <meta property="partNumber">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='p']">
            <meta property="partName">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='w']">
            <meta property="dc:title.part.sortingKey">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='246']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:title.alternative">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='b']">
            <meta property="dc:title.subTitle.alternative">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='250']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="edition">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='260']">
        <xsl:if test="marcxchange:subfield[@code='b']">
            <xsl:variable name="publisher-id" select="concat('publisher-260-',1+count(preceding-sibling::marcxchange:datafield[@tag='260']))"/>
            
            <dc:publisher id="{$publisher-id}">
                <xsl:value-of select="(marcxchange:subfield[@code='b'])[1]/text()"/>
            </dc:publisher>
            
            <xsl:for-each select="marcxchange:subfield[@code='a']">
                <meta property="dc:publisher.location" refines="#{$publisher-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$publisher-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
        
        <xsl:for-each select="marcxchange:subfield[@code='c']">
            <meta property="dc:date.issued">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='9' and text()='n']">
            <meta property="watermark">none</meta>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
