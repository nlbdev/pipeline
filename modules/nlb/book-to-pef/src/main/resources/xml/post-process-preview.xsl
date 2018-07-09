<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:output indent="no"/>
    
    <xsl:template match="@* | node()" mode="#all">
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[@class = 'text-page']/div[@class = 'row']">
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:copy-of select="@*" exclude-result-prefixes="#all"/>
            
            <xsl:variable name="text" select="text()"/>
            
            <!-- Correctly translate Æ Ø Å -->
            <xsl:variable name="text" select="translate(., '>[*',
                                                           'ÆØÅ')"/>
            
            <xsl:analyze-string select="$text" regex="(#[^\s]*)">
                
                <!-- Render numbers as numbers -->
                <xsl:matching-substring>
                    <xsl:value-of select="translate(., 'ABCDEFGHIJ1''',
                                                       '1234567890,.')"/>
                </xsl:matching-substring>
                
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="." regex="(,,[^ ]*|,.)">
                        <xsl:matching-substring>
                            
                            <!-- Put stuff in uppercase when preceded by dot 6 -->
                            <xsl:value-of select="upper-case(.)"/>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            
                            <!-- Otherwise put stuff in lowercase -->
                            <xsl:value-of select="lower-case(.)"/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
