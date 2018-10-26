<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@style">
        <xsl:variable name="style" as="element()*" select="css:parse-stylesheet(.)"/> <!-- css:rule*-->
        <xsl:if test="exists($style/self::css:rule[not(@selector[not(contains(.,'('))])])">
            <xsl:sequence select="css:style-attribute(
                                    css:serialize-stylesheet(
                                      $style/self::css:rule[not(@selector[not(contains(.,'('))])]))"/>
        </xsl:if>
        <xsl:apply-templates select="$style/self::css:rule[@selector[not(contains(.,'('))]]"/>
    </xsl:template>
    
    <xsl:template match="css:rule">
        <xsl:attribute name="css:{replace(replace(replace(@selector, '^(@|::|:)' , ''  ),
                                                                     '^-'        , '_' ),
                                                                     ' +'        , '-' )}"
                       select="@style"/>
    </xsl:template>
    
    <!--
        Suppress warning messages "The source document is in no namespace, but the template rules
        all expect elements in a namespace" (see https://github.com/daisy/pipeline-mod-braille/issues/38)
    -->
    <xsl:template match="/phony">
        <xsl:next-match/>
    </xsl:template>
    
</xsl:stylesheet>
