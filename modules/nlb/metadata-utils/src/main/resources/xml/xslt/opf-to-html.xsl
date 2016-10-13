<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dc="http://purl.org/dc/elements/1.1/">
    
    <xsl:template match="/*">
        <xsl:variable name="identifier" select="dc:identifier/text()"/>
        <html xml:lang="en">
            <head>
                <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
                <title>
                    <xsl:value-of select="if ($identifier) then concat($identifier,': metadata') else 'metadata'"/>
                </title>
                <meta name="dc:title">
                    <xsl:attribute name="content" select="if ($identifier) then concat($identifier,': metadata') else 'metadata'"/>
                </meta>
                <meta name="dc:date" content="{replace(xs:string(current-dateTime()),'T.*','')}"/>
                <meta name="dc:language" content="no"/>
            </head>
            <body>
                <h2>
                    <xsl:value-of select="if ($identifier) then concat('Metadata for ',$identifier) else 'Metadata'"/>
                </h2>
                <xsl:choose>
                    <xsl:when test="count((dc:* | opf:meta))=0">
                        <xsl:text>Ingen metadata.</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <table style="width: 100%;">
                            <thead>
                                <tr>
                                    <th>Navn</th>
                                    <th>Verdi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="*">
                                    <tr>
                                        <td style="padding: 0px 10px 0px 0px;">
                                            <xsl:if test="@refines">
                                                <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                                            </xsl:if>
                                            <xsl:value-of select="if (self::dc:*) then name() else @property"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="text()"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
