<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <!--
        replace elements in the source with the name 'generate':
        <generate xmlns="{dtbook/html}" generate-name="{QName}" generate-text="{string}" generate-text-length="{integer}" generate-count="{integer}" {other-attributes}>
            {other-content}
        </generate>
        
        - generate-name: name of element to be generated. Default: none (no element created)
        - generate-count: number of repetitions of this generated content. Default: 1
        - generate-text: text to use as template when generating text. Default: 'Lorem ipsum ...'
        - generate-text-length: length of text to generate. If generate-name is also specified, the text will be wrapped in that element. Default: 0 (no text node created)
    -->
    
    <xsl:template match="@* | node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/*">
        <xsl:variable name="generated">
            <xsl:apply-templates select="/*" mode="generate"/>
        </xsl:variable>
        <xsl:apply-templates select="$generated" mode="counters"/>
    </xsl:template>
    
    <xsl:template match="*[local-name()='generate']" mode="generate">
        <xsl:variable name="this" select="."/>
        <xsl:variable name="count" select="if (@generate-count) then xs:integer(number(@generate-count)) else 1" as="xs:integer"/>
        <xsl:variable name="text-template" select="if (@generate-text[normalize-space()])
                                                   then string(@generate-text)
                                                   else concat(
                                                        'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod ',
                                                        'tempor incididunt ut labore et dolore magna aliqua. ÆØÅ æøå @ # 123456789. Ut enim ad minim veniam, ',
                                                        'quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo ',
                                                        'consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse ',
                                                        'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non ',
                                                        'proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
                                                       )" as="xs:string"/>
        <xsl:variable name="generate-text-length" select="if (@generate-text-length[matches(.,'^\d+$')]) then xs:integer($this/@generate-text-length) else if (@generate-text) then string-length(@generate-text) else -1" as="xs:integer"/>
        <xsl:variable name="generated-text" select="if ($generate-text-length &gt;= 0 and string-length($text-template) &gt; 0)
                                                    then substring(
                                                            string-join(
                                                                (
                                                                    for $i in (0 to xs:integer($generate-text-length div string-length($text-template)))
                                                                        return $text-template
                                                                ), ' '
                                                            ), 1, $generate-text-length
                                                        )
                                                    else ()" as="xs:string?"/>
        <xsl:for-each select="1 to $count">
            <xsl:choose>
                <xsl:when test="$this/@generate-name[normalize-space()]">
                    <xsl:element name="{string($this/@generate-name)}" namespace="{namespace-uri($this)}">
                        <xsl:copy-of select="$this/(@* except (@generate-count | @generate-name | @generate-text | @generate-text-length))"/>
                        <xsl:if test="$generated-text">
                            <xsl:value-of select="$generated-text"/>
                        </xsl:if>
                        <xsl:apply-templates select="$this/node()" mode="#current"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$generated-text">
                    <xsl:value-of select="$generated-text"/>
                    <xsl:apply-templates select="$this/node()" mode="#current"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$this/node()" mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*[@generate-counter | @generate-id]" mode="counters">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@generate-counter | @generate-id)"/>
            <xsl:if test="@generate-id">
                <xsl:attribute name="id" select="concat(@generate-id,count(preceding::*[@generate-id[.=current()/@generate-id]]) + 1)"/>
            </xsl:if>
            
            <xsl:if test="@generate-counter">
                <xsl:value-of select="count(preceding::*[@generate-counter[.=current()/@generate-counter]]) + 1"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
