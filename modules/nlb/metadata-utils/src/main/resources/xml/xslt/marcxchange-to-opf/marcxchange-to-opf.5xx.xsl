<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 5XX NOTER -->

    <xsl:template match="marcxchange:datafield[@tag='500']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 500 GENERELL NOTE'"/>-->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='501']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 490 &quot;SAMMEN MED&quot;-NOTE'"/>-->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='503']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="edition">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='505']">
        <!-- what's 505$a? prodnote? -->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='511']">
        <xsl:variable name="contributor-id" select="concat('contributor-511-',1+count(preceding-sibling::marcxchange:datafield[@tag='511']))"/>
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:contributor.narrator">
                <xsl:if test="position() = 1">
                    <xsl:attribute name="id" select="$contributor-id"/>
                </xsl:if>
                <xsl:variable name="contributor-name" select="text()"/>
                <xsl:value-of select="if (not(contains($contributor-name,','))) then replace($contributor-name, $FIRST_LAST_NAME, '$2, $1') else $contributor-name"/>
            </meta>

            <xsl:variable name="pos" select="position()"/>
            <xsl:for-each select="../marcxchange:subfield[@code='3'][position() = $pos]">
                <meta property="bibliofil-id" refines="#{$contributor-id}">
                    <xsl:value-of select="text()"/>
                </meta>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='520']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:description.abstract">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='533']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 533 FYSISK BESKRIVELSE'"/>-->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='539']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 539 SERIER'"/>-->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='574']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:title.original">
                <xsl:value-of select="replace(text(),'^\s*Ori?ginaltit\w*\s*:?\s*','')"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='590']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 590 LOKALE NOTER'"/>-->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='592']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <xsl:variable name="available" select="nlb:parseDate(text())"/>
            <xsl:if test="$available">
                <meta property="dc:date.available">
                    <xsl:value-of select="$available"/>
                </meta>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='593']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 593 LOKALE NOTER'"/>-->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='594']">
        <!-- Karakteristikk (fulltekst/lettlest/musikk/...) - se emneordprosjektet -->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='596']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="dc:publisher.original.location">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='b']">
            <meta property="dc:publisher.original">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='c']">
            <meta property="dc:date.issued.original">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='d']">
            <meta property="edition.original">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='e']">
            <xsl:choose>
                <xsl:when test="matches(text(),'^\s*\d+\s*s?[\.\s]*$')">
                    <meta property="dc:format.extent.pages.original">
                        <xsl:value-of select="replace(text(),'[^\d]','')"/>
                    </meta>
                </xsl:when>
                <xsl:otherwise>
                    <meta property="dc:format.extent.original">
                        <xsl:value-of select="text()"/>
                    </meta>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='f']">
            <meta property="isbn.original">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='597']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 597 LOKALE NOTER'"/>-->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='598']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <xsl:choose>
                <xsl:when test="contains(text(),'RNIB')">
                    <meta property="external-production">RNIB</meta>
                </xsl:when>
                <xsl:when test="contains(text(),'TIGAR')">
                    <meta property="external-production">TIGAR</meta>
                </xsl:when>
                <xsl:when test="contains(text(),'INNKJØPT')">
                    <meta property="external-production">WIPS</meta>
                </xsl:when>
            </xsl:choose>
            <xsl:variable name="tag592">
                <xsl:apply-templates select="../../marcxchange:datafield[@tag='592']"/>
            </xsl:variable>
            <xsl:if test="not($tag592/meta[@property='dc:date.available'])">
                <xsl:variable name="available" select="nlb:parseDate(text())"/>
                <xsl:if test="$available">
                    <meta property="dc:date.available">
                        <xsl:value-of select="$available"/>
                    </meta>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
