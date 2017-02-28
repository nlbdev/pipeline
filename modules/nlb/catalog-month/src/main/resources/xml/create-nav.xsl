<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml">

    <xsl:output indent="yes"/>

    <xsl:template match="/*">
        <div>
            <h2>I dette nummeret</h2>
            <ul style="margin:0;">
                <xsl:variable name="headlines" select="//*[local-name()=('h1','h2','h3','h4','h5','h6')]"/>
                <xsl:call-template name="recursion">
                    <xsl:with-param name="level" select="1"/>
                    <xsl:with-param name="context" select="$headlines"/>
                </xsl:call-template>
            </ul>
        </div>
    </xsl:template>

    <xsl:template name="recursion">
        <xsl:param name="level" required="yes"/>
        <xsl:param name="context" required="yes"/>
        <xsl:choose>
            <xsl:when test="$level&gt;6"/>
            <xsl:when test="$context/local-name()=concat('h',$level)">
                <xsl:for-each-group select="$context" group-starting-with="*[local-name()=concat('h',$level)]">
                    <xsl:choose>
                        <xsl:when test="position()=1 and not(current-group()[1]/local-name()=concat('h',$level))">
                            <xsl:call-template name="recursion">
                                <xsl:with-param name="level" select="$level+1"/>
                                <xsl:with-param name="context" select="current-group()"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <li>
                                <xsl:copy-of select="@data-catalog"/>
                                <a href="#{current-group()[1]/@id}">
                                    <span>
                                        <!-- span needed for GMail internal links -->
                                        <xsl:value-of select="normalize-space(current-group()[1])"/>
                                    </span>
                                </a>
                                <xsl:if test="count(current-group())&gt;1">
                                    <ul style="margin:0;">
                                        <xsl:call-template name="recursion">
                                            <xsl:with-param name="level" select="$level+1"/>
                                            <xsl:with-param name="context" select="current-group()"/>
                                        </xsl:call-template>
                                    </ul>
                                </xsl:if>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="recursion">
                    <xsl:with-param name="level" select="$level+1"/>
                    <xsl:with-param name="context" select="$context"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
