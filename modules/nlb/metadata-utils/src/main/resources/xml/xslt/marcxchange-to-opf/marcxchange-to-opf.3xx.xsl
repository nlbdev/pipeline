<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 3XX FYSISK BESKRIVELSE -->

    <xsl:template match="marcxchange:datafield[@tag='300']">
        <xsl:variable name="fields" as="element()*">
            <xsl:apply-templates select="../marcxchange:datafield[@tag='245']"/>
        </xsl:variable>
        <xsl:variable name="fields" as="element()*">
            <xsl:choose>
                <xsl:when test="$fields[self::dc:format]">
                    <xsl:copy-of select="$fields"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="../marcxchange:datafield[@tag='019']"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <xsl:choose>
                <xsl:when test="$fields[self::dc:format]='DAISY 2.02'">
                    <meta property="dc:format.extent.duration">
                        <xsl:choose>
                            <xsl:when test="matches(text(),'^.*?\d+ *t+\.? *\d+ *min\.?.*?$')">
                                <xsl:value-of select="replace(text(),'^.*?(\d+) *t+\.? *(\d+) *min\.?.*?$','$1 t. $2 min.')"/>
                            </xsl:when>
                            <xsl:when test="matches(text(),'^.*?\d+ *min\.?.*?$')">
                                <xsl:value-of select="replace(text(),'^.*?(\d+) *min\.?.*?$','0 t. $1 min.')"/>
                            </xsl:when>
                            <xsl:when test="matches(text(),'^.*?\d+ *t\.?.*?$')">
                                <xsl:value-of select="replace(text(),'^.*?(\d+) *t\.?.*?$','$1 t. 0 min.')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="text()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </meta>
                </xsl:when>
                <xsl:otherwise>
                    <meta property="dc:format.extent">
                        <xsl:value-of select="text()"/>
                    </meta>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='310']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="periodicity">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
