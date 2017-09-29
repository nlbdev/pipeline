<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"  xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
    xmlns:epub="http://www.idpf.org/2007/ops" >
    
    <xsl:output indent="yes"/>

    <xsl:param name="braille-standard" select="'(dots:6)(grade:0)'"/>
    <xsl:param name="notes-placement" select="''"/>
    <xsl:variable name="contraction-grade"
        select="replace($braille-standard, '.*\(grade:(.*)\).*', '$1')"/>


    <xsl:template match="body[not(preceding::body)]">
        <xsl:call-template name="add-information-based-from-metadata"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
        
    </xsl:template>

    <xsl:template match="node()" mode="#all" priority="-5">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="add-information-based-from-metadata">
        <section class="first-page">
            <xsl:variable name="author" select="//meta[@name eq 'dc:creator']/@content"/>
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
                <xsl:value-of select="//meta[@name eq 'dc:title']/@content"/>
            </p>


            <xsl:variable name="contributor" select="//meta[@name eq 'dc:contributor']/@content"/>
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
        </section>
        <xsl:choose>
            <xsl:when test="exists(//frontmatter/level1[@class eq 'colophon'])">
                <section class="second-page">
                    <h1>Colophon</h1>
                    <xsl:copy-of select="//frontmatter/level1[@class eq 'colophon']/descendant::p"/>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>No colophon!</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
        <section class="third-page">
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
            <xsl:if test="//a[tokenize(@epub:type,'\s+') = 'noteref']">
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

        </section>
    </xsl:template>
    
    
    
    <xsl:function name="f:types" as="xs:string*">
        <xsl:param name="element" as="element()"/>
        <xsl:sequence select="tokenize($element/@epub:type,'\s+')"/>
    </xsl:function>
    
    <xsl:function name="f:classes" as="xs:string*">
        <xsl:param name="element" as="element()"/>
        <xsl:sequence select="tokenize($element/@class,'\s+')"/>
    </xsl:function>

</xsl:stylesheet>
