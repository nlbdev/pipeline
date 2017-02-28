<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 00X KONTROLLFELT -->

    <xsl:template match="marcxchange:leader"/>

    <xsl:template match="marcxchange:controlfield[@tag='001']">
        <dc:identifier id="pub-id">
            <xsl:value-of select="text()"/>
        </dc:identifier>
    </xsl:template>
    
    <xsl:template match="marcxchange:controlfield[@tag='007']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 007 FYSISK BESKRIVELSE AV DOKUMENTET'"/>-->
    </xsl:template>

    <xsl:template match="marcxchange:controlfield[@tag='008']">
        <xsl:variable name="POS22" select="substring(text(),23,1)"/>
        <xsl:variable name="POS33" select="substring(text(),34,1)"/>
        <xsl:variable name="POS34" select="substring(text(),35,1)"/>
        <xsl:variable name="POS35-37" select="substring(text(),36,3)"/>

        <xsl:choose>
            <xsl:when test="$POS22='a'">
                <meta property="audience">Adult</meta>
            </xsl:when>
            <xsl:when test="$POS22='j'">
                <meta property="audience">Juvenile</meta>
            </xsl:when>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="$POS33='0'">
                <meta property="dc:type.genre">Non-fiction</meta>
            </xsl:when>
            <xsl:when test="$POS33='1'">
                <meta property="dc:type.genre">Fiction</meta>
            </xsl:when>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="$POS34='0'">
                <meta property="dc:type.genre">Non-biography</meta>
            </xsl:when>
            <xsl:when test="$POS34='1'">
                <meta property="dc:type.genre">Biography</meta>
            </xsl:when>
            <xsl:when test="$POS34='a'">
                <meta property="dc:type.genre">Biography</meta>
                <meta property="dc:type.genre">Autobiography</meta>
            </xsl:when>
            <xsl:when test="$POS34='b'">
                <meta property="dc:type.genre">Biography</meta>
                <meta property="dc:type.genre">Individual biography</meta>
            </xsl:when>
            <xsl:when test="$POS34='c'">
                <meta property="dc:type.genre">Biography</meta>
                <meta property="dc:type.genre">Collective biography</meta>
            </xsl:when>
            <xsl:when test="$POS34='d'">
                <meta property="dc:type.genre">Biography</meta>
            </xsl:when>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="normalize-space($POS35-37)">
                <dc:language>
                    <xsl:value-of select="$POS35-37"/>
                </dc:language>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
