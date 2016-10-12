<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 1XX HOVEDORDNINGSORD -->

    <xsl:template match="marcxchange:datafield[@tag='100']">
        <xsl:variable name="creator-id" select="concat('creator-',1+count(preceding-sibling::marcxchange:datafield[@tag='100' or @tag='110']))"/>
        <xsl:variable name="name" select="(marcxchange:subfield[@code='q'], marcxchange:subfield[@code='a'], marcxchange:subfield[@code='w'])[1]"/>
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="$name/@code='w'">
                    <xsl:value-of select="$name/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="if (not(contains($name/text(),','))) then replace($name/text(), $FIRST_LAST_NAME, '$2, $1') else $name/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <dc:creator id="{$creator-id}">
            <xsl:value-of select="$name"/>
        </dc:creator>

        <xsl:for-each select="marcxchange:subfield[@code='b']">
            <meta property="suffixName" refines="#{$creator-id}">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='c']">
            <xsl:choose>
                <xsl:when test="matches(text(), $PSEUDONYM)">
                    <xsl:variable name="pseudonym" select="replace(text(), $PSEUDONYM_REPLACE, '$1')"/>
                    <xsl:variable name="pseudonym" select="if (not(contains($pseudonym,','))) then replace($pseudonym, $FIRST_LAST_NAME, '$2, $1') else $pseudonym"/>
                    <meta property="pseudonym" refines="#{$creator-id}">
                        <xsl:value-of select="$pseudonym"/>
                    </meta>
                </xsl:when>
                <xsl:otherwise>
                    <meta property="title" refines="#{$creator-id}">
                        <xsl:value-of select="text()"/>
                    </meta>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='d']">
            <xsl:choose>
                <xsl:when test="matches(text(),'.*[^\d-].*')">
                    <xsl:variable name="sign" select="if (matches(text(),$YEAR_NEGATIVE)) then '-' else ''"/>
                    <xsl:variable name="value" select="replace(text(), $YEAR_VALUE, '')"/>
                    <meta property="birth" refines="#{$creator-id}">
                        <xsl:value-of select="concat($sign,$value)"/>
                    </meta>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="years" select="tokenize(text(),'-')"/>
                    <xsl:if test="count($years) &gt; 0">
                        <meta property="birth" refines="#{$creator-id}">
                            <xsl:value-of select="$years[1]"/>
                        </meta>
                    </xsl:if>
                    <xsl:if test="count($years) &gt; 1 and string-length($years[2]) &gt; 0">
                        <meta property="death" refines="#{$creator-id}">
                            <xsl:value-of select="$years[2]"/>
                        </meta>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='j']/tokenize(replace(text(),'[\.,? ]',''), '-')">
            <xsl:variable name="nationality" select="nlb:parseNationality(.)"/>
            <meta property="nationality" refines="#{$creator-id}">
                <xsl:value-of select="$nationality"/>
            </meta>
        </xsl:for-each>
        
        <xsl:for-each select="marcxchange:subfield[@code='3']">
            <meta property="bibliofil-id" refines="#{$creator-id}">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='110']">
        <xsl:variable name="creator-id" select="concat('creator-',1+count(preceding-sibling::marcxchange:datafield[@tag='100' or @tag='110']))"/>
        <xsl:choose>
            <xsl:when test="marcxchange:subfield[@code='a']">
                <dc:creator id="{$creator-id}">
                    <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
                </dc:creator>
                <xsl:if test="marcxchange:subfield[@code='b']">
                    <meta property="department" refines="#{$creator-id}">
                        <xsl:value-of select="marcxchange:subfield[@code='b']/text()"/>
                    </meta>
                </xsl:if>
            </xsl:when>
            <xsl:when test="marcxchange:subfield[@code='b']">
                <dc:creator id="{$creator-id}">
                    <xsl:value-of select="marcxchange:subfield[@code='b']/text()"/>
                </dc:creator>
            </xsl:when>
        </xsl:choose>
        
        <xsl:for-each select="marcxchange:subfield[@code='3']">
            <meta property="bibliofil-id" refines="#{$creator-id}">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
