<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 700 - 75X BIINNFØRSLER -->

    <xsl:template match="marcxchange:datafield[@tag='700']">
        <xsl:variable name="contributor-id" select="concat('contributor-700-',1+count(preceding-sibling::marcxchange:datafield[@tag='700']))"/>
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

        <xsl:variable name="role" select="nlb:parseRole(concat('',(marcxchange:subfield[@code='e'], marcxchange:subfield[@code='r'], marcxchange:subfield[@code='x'])[1]/text()))"/>
        <xsl:variable name="role" select="if ($role='dc:creator') then 'dc:contributor' else $role">
            <!-- because 700 never is the main author -->
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="matches($role,'^dc:\w+$')">
                <xsl:element name="{$role}">
                    <xsl:attribute name="id" select="$contributor-id"/>
                    <xsl:value-of select="$name"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <meta property="{$role}" id="{$contributor-id}">
                    <xsl:value-of select="$name"/>
                </meta>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:for-each select="marcxchange:subfield[@code='b']">
            <meta property="suffixName" refines="#{$contributor-id}">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='c']">
            <xsl:choose>
                <xsl:when test="matches(text(), $PSEUDONYM)">
                    <xsl:variable name="pseudonym" select="replace(text(), $PSEUDONYM_REPLACE, '$1')"/>
                    <xsl:variable name="pseudonym" select="if (not(contains($pseudonym,','))) then replace($pseudonym, $FIRST_LAST_NAME, '$2, $1') else $pseudonym"/>
                    <meta property="pseudonym" refines="#{$contributor-id}">
                        <xsl:value-of select="$pseudonym"/>
                    </meta>
                </xsl:when>
                <xsl:otherwise>
                    <meta property="title" refines="#{$contributor-id}">
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
                    <meta property="birth" refines="#{$contributor-id}">
                        <xsl:value-of select="concat($sign,$value)"/>
                    </meta>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="years" select="tokenize(text(),'-')"/>
                    <xsl:if test="count($years) &gt; 0">
                        <meta property="birth" refines="#{$contributor-id}">
                            <xsl:value-of select="$years[1]"/>
                        </meta>
                    </xsl:if>
                    <xsl:if test="count($years) &gt; 1 and string-length($years[2]) &gt; 0">
                        <meta property="death" refines="#{$contributor-id}">
                            <xsl:value-of select="$years[2]"/>
                        </meta>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='j']/tokenize(replace(text(),'[\.,? ]',''), '-')">
            <xsl:variable name="nationality" select="nlb:parseNationality(.)"/>
            <meta property="nationality" refines="#{$contributor-id}">
                <xsl:value-of select="$nationality"/>
            </meta>
        </xsl:for-each>

        <xsl:for-each select="marcxchange:subfield[@code='3']">
            <meta property="bibliofil-id" refines="#{$contributor-id}">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='710']">
        <xsl:for-each select="marcxchange:subfield[@code='1']">
            <meta property="dc:subject.dewey">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <xsl:variable name="contributor-id" select="concat('contributor-700-',1+count(preceding-sibling::marcxchange:datafield[@tag='700']))"/>
            
            <dc:contributor id="{$contributor-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a'][1]/text()"/>
            </dc:contributor>
            
            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$contributor-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='730']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:title.alternative">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='740']">
        <xsl:if test="marcxchange:subfield[@code='a']">
            <xsl:variable name="title-id" select="concat('title-740-',1+count(preceding-sibling::marcxchange:datafield[@tag='740']))"/>
            <xsl:for-each select="marcxchange:subfield[@code='a']">
                <meta property="dc:title.part" id="{$title-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='b']">
                <meta property="dc:title.part.subTitle" refines="#{$title-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='n']">
                <meta property="partNumber" refines="#{$title-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='p']">
                <meta property="dc:title.part.alternative" refines="#{$title-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='w']">
                <meta property="dc:title.part.sortingKey" refines="#{$title-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
