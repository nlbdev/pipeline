<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://www.example.org/" xpath-default-namespace="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">

    <xsl:output indent="yes"/>

    <xsl:template match="/">
        <plain-text>
            <xsl:apply-templates select="/*"/>
        </plain-text>
    </xsl:template>


    <xsl:template match="*[local-name()='html']">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="*[local-name()='head']"/>
    <xsl:template match="*[local-name()='body']">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="*[local-name()='h1']">
        <line/>
        <line>* <xsl:apply-templates select="node()"/></line>
        <line>------------------------------------------------------------</line>
    </xsl:template>

    <xsl:template match="*[local-name()='h2']">
        <line/>
        <line>** <xsl:apply-templates select="node()"/></line>
        <line>------------------------------------------------------------</line>
    </xsl:template>

    <xsl:template match="*[local-name()='h3']">
        <line/>
        <line>*** <xsl:apply-templates select="node()"/></line>
        <line>------------------------------------------------------------</line>
    </xsl:template>

    <xsl:template match="*[local-name()='h4']">
        <line/>
        <line>**** <xsl:apply-templates select="node()"/></line>
        <line>------------------------------------------------------------</line>
    </xsl:template>

    <xsl:template match="*[local-name()='h5']">
        <line/>
        <line>***** <xsl:apply-templates select="node()"/></line>
        <line>------------------------------------------------------------</line>
    </xsl:template>

    <xsl:template match="*[local-name()='h6']">
        <line/>
        <line>****** <xsl:apply-templates select="node()"/></line>
        <line>------------------------------------------------------------</line>
    </xsl:template>

    <xsl:template match="*[local-name()='span']">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="*[local-name()='div']">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="*[local-name()='p']">
        <line/>
        <line>
            <xsl:apply-templates select="node()"/>
        </line>
        <line/>
    </xsl:template>

    <xsl:template match="*[local-name()='br']">
        <br/>
    </xsl:template>

    <xsl:template match="*[local-name()='hr']">
        <line/>
        <line>------------------------------------------------------------</line>
        <line/>
    </xsl:template>

    <xsl:template match="*[local-name()='a']">
        <xsl:apply-templates select="node()"/>
        <xsl:if test="@href and not(starts-with(@href,'#'))">
            <xsl:if test="not(*)">
                <xsl:value-of select="' '"/>
            </xsl:if>
            <xsl:value-of select="concat('(',@href,') ')"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:choose>
            <xsl:when test="normalize-space()='' and preceding-sibling::*">
                <xsl:value-of select="' '"/>
            </xsl:when>
            <xsl:when test="not(normalize-space()='')">
                <text>
                    <xsl:value-of select="normalize-space()"/>
                </text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[local-name()='img']">
        <xsl:if test="@alt">
            <xsl:value-of select="@alt"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[local-name()=('i','em')]">
        <xsl:text>/</xsl:text>
        <xsl:apply-templates select="node()"/>
        <xsl:text>/</xsl:text>
    </xsl:template>

    <xsl:template match="*[local-name()=('b','strong')]">
        <xsl:text>*</xsl:text>
        <xsl:apply-templates select="node()"/>
        <xsl:text>*</xsl:text>
    </xsl:template>

    <xsl:template match="*[local-name()='center']">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="*[local-name()='table']">
        <xsl:choose>
            <xsl:when test="contains(@role,'presentation')">
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:otherwise>
                <line>------------------------------</line>
                <xsl:apply-templates select="node()"/>
                <line>------------------------------</line>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[local-name()='tr']">
        <line>
            <xsl:apply-templates select="node()"/>
        </line>
    </xsl:template>

    <xsl:template match="*[local-name()='td']">
        <xsl:choose>
            <xsl:when test="contains((ancestor::table)[1]/@role,'presentation')">
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
                <xsl:if test="following-sibling::td">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[local-name()='ul']">
        <xsl:param name="indent" select="1" tunnel="yes"/>
        <xsl:for-each select="node()">
            <xsl:choose>
                <xsl:when test="li">
                    <line>
                        <xsl:apply-templates select="node()">
                            <xsl:with-param name="indent" select="$indent+1"/>
                        </xsl:apply-templates>
                    </line>
                </xsl:when>
                <xsl:when test="not(self::text() and normalize-space(.)='')">
                    <line>
                        <xsl:value-of select="concat( string-join(for $i in 1 to $indent return ' ','') , '* ' )"/>
                        <xsl:apply-templates select="node()"/>
                    </line>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*[local-name()='li']">
        <xsl:param name="indent" select="1" tunnel="yes"/>
        <xsl:text>
</xsl:text>
        <xsl:value-of select="concat( string-join(for $i in 1 to ($indent+1) return ' ','') , '* ' )"/>
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="*">
        <xsl:comment select="concat('unmatched element: ',name())"/>
        <xsl:apply-templates select="node()"/>
    </xsl:template>

</xsl:stylesheet>
