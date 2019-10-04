<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.daisy.org/z3986/2005/dtbook/" xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/" version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:strip-space elements="*" />
    <xsl:preserve-space elements="xsl:text" />
    
    <xsl:template match="/processing-instruction()"/>
    
    <xsl:template match="@*|node()">
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:value-of select="concat(
                                                if (starts-with(.,' ')) then ' ' else '',
                                                normalize-space(.),
                                                if (ends-with(.,' ')) then ' ' else '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[@id='toc']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="class" select="'print_toc'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@class">
        <xsl:if test="not(local-name()='print_toc')">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="h1|h2|h3|h4|h5|h6">
        <xsl:variable name="h" select="."/>
        <xsl:for-each-group select="node()" group-starting-with="br">
            <xsl:choose>
                <xsl:when test="position()=1">
                    <xsl:for-each select="$h">
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <p>
                        <em>
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates select="current-group()[not(self::br)]"/>
                        </em>
                    </p>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="span | linegroup | br">
        <xsl:if test="preceding-sibling::*[not(self::br)]">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="line">
        <p>
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>

    <xsl:template match="a">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="img">
        <xsl:value-of select="normalize-space(@alt)"/>
    </xsl:template>
    
</xsl:stylesheet>
