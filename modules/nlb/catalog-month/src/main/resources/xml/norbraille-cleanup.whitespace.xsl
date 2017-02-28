<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.daisy.org/z3986/2005/dtbook/" xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/" version="2.0">

    <xsl:output indent="no"/>

    <xsl:template match="@*|node()">
        <xsl:param name="no-linebreak" select="false()" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$no-linebreak and self::text()">
                <xsl:value-of select="concat(if (matches(.,'^\s')) then ' ' else '',
                                             normalize-space(.),
                                             if (matches(.,'\s$')) then ' ' else '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="doctitle|docauthor">
        <xsl:copy><![CDATA[]]><xsl:copy-of select="@*"/><![CDATA[]]><xsl:apply-templates select="node()"><![CDATA[]]><xsl:with-param name="no-linebreak" select="true()" tunnel="yes"
        /><![CDATA[]]></xsl:apply-templates><![CDATA[]]></xsl:copy>
    </xsl:template>
    
    <xsl:template match="level1|level2|level3|level4|level5|level6">
        <xsl:variable name="e" select="."/>
        <xsl:variable name="self-indent" select="string-join(for $i in 1 to count(ancestor::*) return '   ' ,'')"/>
        <xsl:variable name="indent" select="concat($self-indent,'   ')"/>
        <xsl:text>
</xsl:text>
        <xsl:value-of select="$self-indent"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>
</xsl:text>
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::text()">
                        <xsl:if test="string-length(normalize-space(.))&gt;0">
                            <xsl:value-of select="$indent"/>
                            <p><![CDATA[]]><xsl:value-of select="normalize-space(.)"/><![CDATA[]]></p>
                            <xsl:text>
</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="self::*">
                        <xsl:value-of select="$indent"/>
                        <xsl:copy><![CDATA[]]><xsl:copy-of select="@*"/><![CDATA[]]><xsl:apply-templates select="node()"><![CDATA[]]><xsl:with-param name="no-linebreak" select="true()" tunnel="yes"
                            /><![CDATA[]]></xsl:apply-templates><![CDATA[]]></xsl:copy>
                        <xsl:text>
</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <xsl:value-of select="$self-indent"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="li">
        <xsl:text>
</xsl:text>
        <xsl:value-of select="string-join(for $i in 1 to count(ancestor::*) return '   ' ,'')"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()">
                <xsl:with-param name="no-linebreak" select="true()" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
