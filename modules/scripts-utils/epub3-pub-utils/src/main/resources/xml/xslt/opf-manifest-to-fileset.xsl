<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="#all" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                                             xmlns:xs="http://www.w3.org/2001/XMLSchema"
                                                             xmlns:d="http://www.daisy.org/ns/pipeline/data"
                                                             xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                                                             xmlns:opf="http://www.idpf.org/2007/opf">
    
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
    
    <xsl:param name="spine-only" select="'false'"/>
    <xsl:param name="include-opf" select="'true'"/>
    
    <xsl:template match="opf:package" name="main">
        <xsl:param name="opf" as="element()" select="/*"/>
        <xsl:param name="fileset" as="element()?" select="collection()[2]/*"/>
        <xsl:for-each select="$opf">
            <d:fileset>
                <xsl:attribute name="xml:base" select="pf:normalize-uri(replace(base-uri(/*),'(.*/)[^/]*','$1'))"/>
                
                <!-- content files first, and in spine order -->
                <xsl:apply-templates select="opf:spine/opf:itemref">
                    <xsl:with-param name="fileset" select="$fileset" tunnel="yes"/>
                </xsl:apply-templates>
                
                <xsl:if test="$spine-only = 'false'">
                    <!-- then the package document -->
                    <xsl:if test="$include-opf = 'true'">
                        <xsl:variable name="opf-href" select="replace(base-uri(/*),'.*/','')"/>
                        <xsl:variable name="resolved-opf-href" select="pf:normalize-uri(resolve-uri($opf-href, base-uri(/*)))"/>
                        <d:file href="{$opf-href}" media-type="application/oebps-package+xml">
                            <xsl:for-each select="$fileset/d:file[pf:normalize-uri(resolve-uri(@href, if (ancestor-or-self::*/@xml:base) then base-uri(.) else $opf/base-uri())) = $resolved-opf-href]">
                                <xsl:copy-of select="@* except (@href | @media-type)"/>
                                <xsl:copy-of select="node()"/>
                            </xsl:for-each>
                        </d:file>
                    </xsl:if>
                    
                    <!-- and finally all other files, sorted alphabetically -->
                    <xsl:for-each select="opf:manifest/opf:item[not(@id=/*/opf:spine/opf:itemref/@idref)]">
                        <xsl:sort select="@href"/>
                        <xsl:apply-templates select=".">
                            <xsl:with-param name="fileset" select="$fileset" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:if>
            </d:fileset>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="opf:itemref">
        <xsl:apply-templates select="/*/opf:manifest/opf:item[@id=current()/@idref]"/>
    </xsl:template>
    
    <xsl:template match="opf:item">
        <xsl:param name="fileset" as="element()?" tunnel="yes"/>
        <xsl:variable name="opf" select="/*"/>
        <d:file>
            <xsl:variable name="href" select="pf:normalize-uri(@href)"/>
            <xsl:variable name="resolved-href" select="pf:normalize-uri(resolve-uri($href, base-uri(.)))"/>
            
            <xsl:attribute name="href" select="$href"/>
            <xsl:copy-of select="$fileset/d:file[pf:normalize-uri(resolve-uri(@href, if (ancestor-or-self::*/@xml:base) then base-uri(.) else $opf/base-uri())) = $resolved-href]/(@* except @href)"/>
            <xsl:copy-of select="@media-type"/>
            <xsl:copy-of select="$fileset/d:file[pf:normalize-uri(resolve-uri(@href, if (ancestor-or-self::*/@xml:base) then base-uri(.) else $opf/base-uri())) = $resolved-href]/node()"/>
        </d:file>
    </xsl:template>

</xsl:stylesheet>
