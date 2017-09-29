<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:param name="braille-standard" select="'(dots:6)(grade:0)'"/>
    <xsl:param name="notes-placement" select="''"/>
    <xsl:variable name="contraction-grade" select="replace($braille-standard, '.*\(grade:(.*)\).*', '$1')"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="book[not(frontmatter)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <frontmatter>
                <xsl:call-template name="add-information-based-from-metadata"/>
            </frontmatter>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="frontmatter">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node() except level1[1]/(. | following-sibling::node())"/>
            <xsl:call-template name="add-information-based-from-metadata"/>
            <xsl:apply-templates select="level1[1]/(. | following-sibling::node())"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="add-information-based-from-metadata">
        <level1 class="first-page">
            <xsl:variable name="author" select="//meta[@name eq 'dc:Creator']/@content"/>
            <xsl:for-each select="$author[position() &lt;= 3]">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <p class="author-1">
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:when>
                    <xsl:when test="position() = 3 and count($author) > 3">
                        <p class="author-2">
                            <xsl:value-of select="count($author) - 2"/>
                            <xsl:text> flere</xsl:text>
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <p class="author-3">
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <p class="title-pef">
                <xsl:value-of select="//meta[@name eq 'dc:Title']/@content"/>
            </p>


            <xsl:variable name="contributor" select="//meta[@name eq 'dc:Contributor']/@content"/>
            <p class="translator">Oversatt av</p>
            <xsl:for-each select="$contributor[position() &lt;= 3]">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <p class="translator-1">
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:when>
                    <xsl:when test="position() = 3 and count($contributor) > 3">
                        <p class="translator-2">
                            <xsl:value-of select="count($contributor) - 2"/>
                            <xsl:text> flere</xsl:text>
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <p class="translator-3">
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <p class="nlb">NLB</p>
            <p class="year">
                <xsl:value-of select="concat('Norge ', format-dateTime(current-dateTime(), '[Y]'))"
                />
            </p>
            <p class="bind"> av </p>
        </level1>
        <xsl:choose>
            <xsl:when test="exists(//frontmatter/level1[@class eq 'colophon'])">
                <level1 class="second-page">
                    <h1>Colophon</h1>
                    <xsl:copy-of select="//frontmatter/level1[@class eq 'colophon']/descendant::p"/>
                </level1>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>No colophon!</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
        <level1 class="third-page">
            <h1>Om boka</h1>
            <p class="contraction-level">
                <xsl:choose>
                    <xsl:when test="$contraction-grade = '0'">Fullskrift</xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$contraction-grade = '1'">Kortskrift nivå 1</xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$contraction-grade = '2'">Kortskrift nivå 2</xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$contraction-grade = '3'">Kortskrift nivå 3</xsl:when>
                </xsl:choose>
            </p>
            <p class="pages">Antall Sider: </p>
            <xsl:if test="//note">
                <!-- TODO: handle fallback mechanism for footnotes (bottom-of-page = end-of-volume) -->
                <p class="notes-placement">
                    <xsl:choose>
                        <xsl:when test="$notes-placement = 'bottom-of-page'">
                            <xsl:text>Noter er plassert nederst på hver side.</xsl:text>
                        </xsl:when>
                        <xsl:when test="$notes-placement = 'end-of-volume'">
                            <xsl:text>Noter er plassert i slutten av hvert hefte.</xsl:text>
                        </xsl:when>
                        <xsl:when test="$notes-placement = 'end-of-book'">
                            <xsl:text>Noter er plassert bakerst i boken.</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </p>
            </xsl:if>
            <p class="return">Boka skal ikke returneres.</p>
            <p class="contact">Feil eller mangler kan meldes til punkt@nlb.no.</p>
        </level1>
    </xsl:template>



</xsl:stylesheet>
