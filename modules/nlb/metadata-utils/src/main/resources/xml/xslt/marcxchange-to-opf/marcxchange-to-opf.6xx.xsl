<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 6XX EMNEINNFØRSLER -->

    <xsl:template match="marcxchange:datafield[@tag='600']">
        <xsl:for-each select="marcxchange:subfield[@code='0']">
            <meta property="dc:subject.keyword">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='x']">
            <meta property="dc:subject.keyword">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='1']">
            <meta property="dc:subject.dewey">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>

        <xsl:variable name="subject-id" select="concat('subject-600-',1+count(preceding-sibling::marcxchange:datafield[@tag='600']))"/>
        <xsl:variable name="name" select="(marcxchange:subfield[@code='q'], marcxchange:subfield[@code='a'], marcxchange:subfield[@code='w'])[1]"/>
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="not($name/text())">
                    <xsl:value-of select="$name/text()"/>
                </xsl:when>
                <xsl:when test="$name/@code='w'">
                    <xsl:value-of select="$name/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="if (not(contains($name/text(),','))) then replace($name/text(), $FIRST_LAST_NAME, '$2, $1') else $name/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="not($name='')">

            <dc:subject id="{$subject-id}">
                <xsl:value-of select="$name"/>
            </dc:subject>

            <xsl:for-each select="marcxchange:subfield[@code='b']">
                <meta property="suffixName" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='c']">
                <xsl:choose>
                    <xsl:when test="matches(text(), $PSEUDONYM)">
                        <xsl:variable name="pseudonym" select="replace(text(), $PSEUDONYM_REPLACE, '$1')"/>
                        <xsl:variable name="pseudonym" select="if (not(contains($pseudonym,','))) then replace($pseudonym, $FIRST_LAST_NAME, '$2, $1') else $pseudonym"/>
                        <meta property="pseudonym" refines="#{$subject-id}">
                            <xsl:value-of select="$pseudonym"/>
                        </meta>
                    </xsl:when>
                    <xsl:otherwise>
                        <meta property="title" refines="#{$subject-id}">
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
                        <meta property="birth" refines="#{$subject-id}">
                            <xsl:value-of select="concat($sign,$value)"/>
                        </meta>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="years" select="tokenize(text(),'-')"/>
                        <xsl:if test="count($years) &gt; 0">
                            <meta property="birth" refines="#{$subject-id}">
                                <xsl:value-of select="$years[1]"/>
                            </meta>
                        </xsl:if>
                        <xsl:if test="count($years) &gt; 1 and string-length($years[2]) &gt; 0">
                            <meta property="death" refines="#{$subject-id}">
                                <xsl:value-of select="$years[2]"/>
                            </meta>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='j']/tokenize(replace(text(),'[\.,? ]',''), '-')">
                <xsl:variable name="nationality" select="nlb:parseNationality(.)"/>
                <meta property="nationality" refines="#{$subject-id}">
                    <xsl:value-of select="$nationality"/>
                </meta>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='610']">
        <xsl:variable name="subject-id" select="concat('subject-610-',1+count(preceding-sibling::marcxchange:datafield[@tag='610']))"/>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.keyword" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>

            <xsl:for-each select="marcxchange:subfield[@code='1']">
                <meta property="dc:subject.dewey" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='b']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='q']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='611']">
        <xsl:variable name="subject-id" select="concat('subject-611-',1+count(preceding-sibling::marcxchange:datafield[@tag='611']))"/>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.keyword" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='650']">
        <xsl:variable name="subject-id" select="concat('subject-650-',1+count(preceding-sibling::marcxchange:datafield[@tag='650']))"/>

        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.keyword" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>
            
            <xsl:if test="marcxchange:subfield[@code='a']/text()=('Tidsskrifter','Avis')">
                <meta property="periodical">true</meta>
            </xsl:if>
            <xsl:if test="marcxchange:subfield[@code='a']/text()='Tidsskrifter'">
                <meta property="magazine">true</meta>
            </xsl:if>
            <xsl:if test="marcxchange:subfield[@code='a']/text()='Avis'">
                <meta property="newspaper">true</meta>
            </xsl:if>

            <xsl:for-each select="marcxchange:subfield[@code='0']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='1']">
                <meta property="dc:subject.dewey" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='c']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='d']">
                <meta property="dc:subject.time" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='q']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='w']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='x']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='z']">
                <meta property="dc:subject.location" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='651']">
        <xsl:variable name="subject-id" select="concat('subject-651-',1+count(preceding-sibling::marcxchange:datafield[@tag='651']))"/>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.location" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>

            <xsl:for-each select="marcxchange:subfield[@code='1']">
                <meta property="dc:subject.dewey" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='q']">
                <meta property="dc:subject.location" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='x']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='z']">
                <meta property="dc:subject.location" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='653']">
        <xsl:variable name="subject-id" select="concat('subject-653-',1+count(preceding-sibling::marcxchange:datafield[@tag='653']))"/>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.keyword" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>
            
            <xsl:for-each select="marcxchange:subfield[@code='1']">
                <meta property="dc:subject.dewey" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='c']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='q']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='x']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='655']">
        <xsl:variable name="subject-id" select="concat('subject-655-',1+count(preceding-sibling::marcxchange:datafield[@tag='655']))"/>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:type.genre" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>
            <meta property="dc:type.genre.no" refines="#{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>

            <xsl:for-each select="marcxchange:subfield[@code='1']">
                <meta property="dc:subject.dewey" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='691']">
        <xsl:variable name="subject-id" select="concat('subject-691-',1+count(preceding-sibling::marcxchange:datafield[@tag='691']))"/>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.keyword" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>

            <xsl:for-each select="marcxchange:subfield[@code='1']">
                <meta property="dc:subject.dewey" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='x']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='692']">
        <xsl:variable name="subject-id" select="concat('subject-692-',1+count(preceding-sibling::marcxchange:datafield[@tag='692']))"/>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.keyword" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='693']">
        <xsl:variable name="subject-id" select="concat('subject-693-',1+count(preceding-sibling::marcxchange:datafield[@tag='693']))"/>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.keyword" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='699']">
        <xsl:variable name="subject-id" select="concat('subject-699-',1+count(preceding-sibling::marcxchange:datafield[@tag='699']))"/>
        
        <xsl:if test="marcxchange:subfield[@code='a']">
            <meta property="dc:subject.keyword" id="{$subject-id}">
                <xsl:value-of select="marcxchange:subfield[@code='a']/text()"/>
            </meta>
            
            <xsl:for-each select="marcxchange:subfield[@code='1']">
                <meta property="dc:subject.dewey" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='c']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='d']">
                <meta property="dc:subject.time" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='q']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='x']">
                <meta property="dc:subject.keyword" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="marcxchange:subfield[@code='z']">
                <meta property="location" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>

            <xsl:for-each select="marcxchange:subfield[@code='3']">
                <meta property="bibliofil-id" refines="#{$subject-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
