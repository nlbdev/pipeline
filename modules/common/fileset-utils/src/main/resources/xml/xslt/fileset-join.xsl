<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
    
    <xsl:param name="method" select="'join'"/>              <!-- join, intersect, diff, left-diff -->
    <xsl:param name="use-first-base" select="'false'"/>     <!-- true, false -->

    <xsl:template name="join">
        <xsl:param name="filesets" select="collection()/*" as="node()*"/>
        <xsl:call-template name="join.common">
            <xsl:with-param name="filesets" select="$filesets"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="join.common">
        <xsl:param name="filesets" required="yes" as="node()*"/>

        <!-- Joint fileset base: longest common URI of all fileset bases -->
        <xsl:param name="base" select="if ($use-first-base = 'true') then $filesets[1]/pf:normalize-uri(@xml:base) else pf:longest-common-uri(distinct-values($filesets[@xml:base]/pf:normalize-uri(@xml:base)))" as="xs:string"/>
        
        <xsl:variable name="fileset-count" select="count($filesets)"/>

        <d:fileset>
            <xsl:if test="$base">
                <xsl:attribute name="xml:base" select="$base"/>
            </xsl:if>
            <xsl:for-each-group select="$filesets/d:file"
                group-by="
                pf:normalize-uri(
                    if      ((ancestor-or-self::*/@xml:base or pf:is-absolute(@href)) and $base) then pf:relativize-uri(resolve-uri(@href,base-uri(.)),$base)
                    else if ( ancestor-or-self::*/@xml:base                                    ) then                   resolve-uri(@href,base-uri(.))
                    else                                                                                                            @href
                )">
                
                <xsl:choose>
                    <xsl:when test="$method = 'intersect'">
                        <xsl:if test="count(current-group()) = $fileset-count">
                            <d:file href="{current-grouping-key()}">
                                <xsl:apply-templates select="current-group()/(@* except @href) | current-group()/*"/>
                            </d:file>
                        </xsl:if>
                        
                    </xsl:when>
                    <xsl:when test="$method = 'diff'">
                        <xsl:if test="count(current-group()) = 1">
                            <d:file href="{current-grouping-key()}">
                                <xsl:apply-templates select="current-group()/(@* except @href) | current-group()/*"/>
                            </d:file>
                        </xsl:if>
                        
                    </xsl:when>
                    <xsl:when test="$method = 'left-diff'">
                        <xsl:if test="count(current-group()) = 1 and count(current-group() intersect $filesets[1]/d:file)">
                            <d:file href="{current-grouping-key()}">
                                <xsl:apply-templates select="current-group()/(@* except @href) | current-group()/*"/>
                            </d:file>
                        </xsl:if>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- join -->
                        <d:file href="{current-grouping-key()}">
                            <xsl:apply-templates select="current-group()/(@* except @href) | current-group()/*"/>
                        </d:file>
                        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </d:fileset>
    </xsl:template>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
