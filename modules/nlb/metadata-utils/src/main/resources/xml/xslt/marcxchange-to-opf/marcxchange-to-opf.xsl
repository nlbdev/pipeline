<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <xsl:output indent="yes"/>

    <xsl:param name="nested" select="false()"/>

    <xsl:include href="marcxchange-to-opf.common.xsl"/>
    <xsl:include href="marcxchange-to-opf.00x.xsl"/>
    <xsl:include href="marcxchange-to-opf.010-04x.xsl"/>
    <xsl:include href="marcxchange-to-opf.050-099.xsl"/>
    <xsl:include href="marcxchange-to-opf.1xx.xsl"/>
    <xsl:include href="marcxchange-to-opf.2xx.xsl"/>
    <xsl:include href="marcxchange-to-opf.3xx.xsl"/>
    <xsl:include href="marcxchange-to-opf.4xx.xsl"/>
    <xsl:include href="marcxchange-to-opf.5xx.xsl"/>
    <xsl:include href="marcxchange-to-opf.6xx.xsl"/>
    <xsl:include href="marcxchange-to-opf.700-75x.xsl"/>
    <xsl:include href="marcxchange-to-opf.760-79x.xsl"/>
    <xsl:include href="marcxchange-to-opf.800-830.xsl"/>
    <xsl:include href="marcxchange-to-opf.85x.xsl"/>
    <xsl:include href="marcxchange-to-opf.9xx.xsl"/>

    <xsl:template match="@*|node()">
        <xsl:choose>
            <xsl:when test="self::*[@tag]">
                <xsl:message>
                    <xsl:text>Ingen regel for NORMARC-felt: </xsl:text>
                    <xsl:value-of select="@tag"/>
                    <xsl:text> (boknummer: </xsl:text>
                    <xsl:value-of select="../*[@tag='001']/text()"/>
                    <xsl:text>)</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:when test="self::*[@code]">
                <xsl:message>
                    <xsl:text>Ingen regel for NORMARC-delfelt: </xsl:text>
                    <xsl:value-of select="parent::*/@tag"/>
                    <xsl:text> $</xsl:text>
                    <xsl:value-of select="@code"/>
                    <xsl:text> (boknummer: </xsl:text>
                    <xsl:value-of select="../../*[@tag='001']/text()"/>
                    <xsl:text>)</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:when test="self::*">
                <!--<xsl:message
                    select="concat('marcxchange-to-opf.xsl: no match for element &quot;',concat('/',string-join((ancestor-or-self::*)/concat(name(),'[',count(preceding-sibling::*)+1,']'),'/')),'&quot; with attributes: ',string-join(for $attribute in @* return concat($attribute/name(),'=&quot;',$attribute,'&quot;'),' '))"
                />-->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="SRU:* | /SRU:record">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="marcxchange:record | /marcxchange:record">
        <xsl:variable name="metadata" as="element()">
            <metadata>
                <xsl:namespace name="dc" select="'http://purl.org/dc/elements/1.1/'"/>
                <xsl:variable name="with-duplicates" as="element()*">
                    <xsl:apply-templates select="node()"/>
                </xsl:variable>
                <xsl:variable name="without-duplicates" as="element()*">
                    <xsl:for-each select="$with-duplicates">
                        <xsl:variable name="position" select="position()"/>
                        <xsl:choose>
                            <xsl:when test="self::dc:*">
                                <xsl:if test="not($with-duplicates[position() &lt; $position and name()=current()/name() and text()=current()/text() and string(@refines)=string(current()/@refines)])">
                                    <xsl:copy>
                                        <xsl:copy-of select="$with-duplicates[self::dc:*[name()=current()/name() and text()=current()/text() and string(@refines)=string(current()/@refines)]]/@*"/>
                                        <xsl:copy-of select="node()"/>
                                    </xsl:copy>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="self::meta">
                                <xsl:variable name="this" select="."/>
                                <xsl:if
                                    test="not($with-duplicates[position() &lt; $position and @property=current()/@property and text()=current()/text() and string(@refines)=string(current()/@refines)])">
                                    <xsl:copy>
                                        <xsl:copy-of select="$with-duplicates[self::meta[@property=current()/@property and text()=current()/text() and string(@refines)=string(current()/@refines)]]/@*"/>
                                        <xsl:copy-of select="node()"/>
                                    </xsl:copy>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="sorted" as="element()*">
                    <xsl:for-each select="$without-duplicates[self::dc:*[not(@refines)]]">
                        <xsl:sort
                            select="if (not(contains('dc:identifier dc:title dc:creator dc:format',name()))) then 100 else count(tokenize(substring-before('dc:identifier dc:title dc:creator dc:format',name()),' '))"/>
                        <xsl:copy-of select="."/>
                        <xsl:if test="@id">
                            <xsl:call-template name="copy-meta-refines">
                                <xsl:with-param name="meta-set" select="$with-duplicates"/>
                                <xsl:with-param name="id" select="string(@id)"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="$without-duplicates[self::meta[starts-with(@property,'dc:') and not(@refines)]]">
                        <xsl:sort select="@property"/>
                        <xsl:copy-of select="."/>
                        <xsl:if test="@id">
                            <xsl:call-template name="copy-meta-refines">
                                <xsl:with-param name="meta-set" select="$with-duplicates"/>
                                <xsl:with-param name="id" select="string(@id)"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="$without-duplicates[self::meta[not(starts-with(@property,'dc:')) and contains(@property,':') and not(@refines)]]">
                        <xsl:sort select="@property"/>
                        <xsl:copy-of select="."/>
                        <xsl:if test="@id">
                            <xsl:call-template name="copy-meta-refines">
                                <xsl:with-param name="meta-set" select="$with-duplicates"/>
                                <xsl:with-param name="id" select="string(@id)"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="$without-duplicates[self::meta[not(contains(@property,':')) and not(@refines)]]">
                        <xsl:sort select="@property"/>
                        <xsl:copy-of select="."/>
                        <xsl:if test="@id">
                            <xsl:call-template name="copy-meta-refines">
                                <xsl:with-param name="meta-set" select="$with-duplicates"/>
                                <xsl:with-param name="id" select="string(@id)"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:for-each select="$sorted">
                    <!-- remove unneccessary id's on non-DC elements -->
                    <xsl:copy>
                        <xsl:copy-of select="@* except @id"/>
                        <xsl:if test="self::dc:* or @id and $sorted[@refines = concat('#',current()/@id)]">
                            <xsl:copy-of select="@id"/>
                        </xsl:if>
                        <xsl:copy-of select="node()"/>
                    </xsl:copy>
                </xsl:for-each>
            </metadata>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="string($nested) = 'true'">
                <xsl:for-each select="$metadata">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:for-each select="*[not(@refines)] | comment()">
                            <xsl:choose>
                                <xsl:when test="self::comment()">
                                    <xsl:copy-of select="."/>
                                </xsl:when>
                                <xsl:when test="self::*">
                                    <xsl:apply-templates select="." mode="nesting"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$metadata"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="copy-meta-refines">
        <xsl:param name="meta-set" required="yes" as="element()*"/>
        <xsl:param name="id" required="yes" as="xs:string"/>
        <xsl:variable name="idref" select="concat('#',$id)"/>
        <xsl:for-each select="$meta-set[self::meta[@refines=$idref]]">
            <xsl:sort select="@property"/>
            <xsl:copy-of select="."/>
            <xsl:if test="@id">
                <xsl:call-template name="copy-meta-refines">
                    <xsl:with-param name="meta-set" select="$meta-set"/>
                    <xsl:with-param name="id" select="string(@id)"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*" mode="nesting">
        <xsl:copy>
            <xsl:copy-of select="@* except (@property, @refines)"/>
            <xsl:if test="@property">
                <xsl:attribute name="name" select="@property"/>
            </xsl:if>
            <xsl:attribute name="content" select="text()"/>
            <xsl:if test="@id">
                <xsl:apply-templates select="../*[@refines = concat('#',current()/@id)]" mode="nesting"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
