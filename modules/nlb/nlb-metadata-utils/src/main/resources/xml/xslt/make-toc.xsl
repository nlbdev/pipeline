<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns="http://www.daisy.org/z3986/2005/dtbook/" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:output indent="yes"/>
    <xsl:param name="include-adult-nonfiction-dewey" select="false()"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dtbook:list[@class='toc']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="//dtbook:frontmatter//dtbook:h1">
                <xsl:variable name="h1" select="normalize-space(string-join(.//text(),' '))"/>
                <xsl:variable name="id1" select="parent::*/@id"/>
                <li>
                    <lic class="entry">
                        <xsl:choose>
                            <xsl:when test="$id1">
                                <a external="false" href="#{$id1}"><xsl:value-of select="$h1"/></a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$h1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </lic>
                </li>
            </xsl:for-each>
            <xsl:for-each select="//dtbook:bodymatter//dtbook:h1">
                <xsl:variable name="h1" select="normalize-space(string-join(.//text(),' '))"/>
                <xsl:variable name="id1" select="parent::*/@id"/>
                <li>
                    <lic class="entry">
                        <xsl:choose>
                            <xsl:when test="$id1">
                                <a external="false" href="#{$id1}"><xsl:value-of select="$h1"/></a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$h1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </lic>
                    <xsl:if test="$id1=('audio','braille') and parent::*//dtbook:h2">
                        <list class="toc_chapter" type="pl">
                            <xsl:for-each select="parent::*//dtbook:h2">
                                <xsl:variable name="h2" select="normalize-space(string-join(.//text(),' '))"/>
                                <xsl:variable name="id2" select="parent::*/@id"/>
                                <li>
                                    <lic class="entry">
                                        <xsl:choose>
                                            <xsl:when test="$id2">
                                                <a external="false" href="#{$id2}"><xsl:value-of select="$h2"/></a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$h2"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </lic>
                                    <xsl:if test="$include-adult-nonfiction-dewey and $id2=('audio-adult-nonfiction','braille-adult-nonfiction') and parent::*//dtbook:h3">
                                        <list class="toc_chapter" type="pl">
                                            <xsl:for-each select="parent::*//dtbook:h3">
                                                <xsl:variable name="h3" select="normalize-space(string-join(.//text(),' '))"/>
                                                <xsl:variable name="id3" select="parent::*/@id"/>
                                                <li>
                                                    <lic class="entry">
                                                        <xsl:choose>
                                                            <xsl:when test="$id3">
                                                                <a external="false" href="#{$id3}"><xsl:value-of select="$h3"/></a>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="$h3"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </lic>
                                                    <xsl:if test="parent::*//dtbook:h4[not(starts-with(parent::*/@id,'urn_NBN'))]">
                                                        <list class="toc_chapter" type="pl">
                                                            <xsl:for-each select="parent::*//dtbook:h4[not(starts-with(parent::*/@id,'urn_NBN'))]">
                                                                <xsl:variable name="h4" select="normalize-space(string-join(.//text(),' '))"/>
                                                                <xsl:variable name="id4" select="parent::*/@id"/>
                                                                <li>
                                                                    <lic class="entry">
                                                                        <xsl:choose>
                                                                            <xsl:when test="$id4">
                                                                                <a external="false" href="#{$id4}"><xsl:value-of select="$h4"/></a>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <xsl:value-of select="$h4"/>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                    </lic>
                                                                </li>
                                                            </xsl:for-each>
                                                        </list>
                                                    </xsl:if>
                                                </li>
                                            </xsl:for-each>
                                        </list>
                                    </xsl:if>
                                </li>
                            </xsl:for-each>
                        </list>
                    </xsl:if>
                </li>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
