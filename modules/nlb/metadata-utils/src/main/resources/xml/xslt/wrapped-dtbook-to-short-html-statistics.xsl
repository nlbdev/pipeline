<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml">

    <xsl:template match="/*">
        <xsl:variable name="doc" select="."/>
        <html>
            <head/>
            <body>
                <h4>Format</h4>
                <ul>
                    <xsl:for-each select="distinct-values(*/@format)">
                        <xsl:variable name="format" select="."/>
                        <xsl:variable name="format-norsk" select="if ($format='Braille') then 'Punktskrift' else $format"/>
                        <li>
                            <xsl:value-of select="concat($format-norsk,': ',count($doc/*[@format=$format]),' stk.')"/>
                        </li>
                    </xsl:for-each>
                </ul>

                <h4>Målgruppe</h4>
                <ul>
                    <xsl:for-each select="distinct-values(*/@audience)">
                        <xsl:variable name="audience" select="."/>
                        <xsl:variable name="audience-norsk" select="if ($audience='Adult') then 'Voksen' else if ($audience='Juvenile') then 'Barn og ungdom' else $audience"/>
                        <li>
                            <xsl:value-of select="concat($audience-norsk,': ',count($doc/*[@audience=$audience]),' stk.')"/>
                        </li>
                    </xsl:for-each>
                </ul>

                <h4>Sjanger</h4>
                <ul>
                    <xsl:for-each select="distinct-values(*/@mainGenre)">
                        <xsl:variable name="mainGenre" select="."/>
                        <xsl:variable name="mainGenre-norsk" select="if ($mainGenre='Non-fiction') then 'Sakprosa' else if ($mainGenre='Fiction') then 'Skjønnlitteratur' else $mainGenre"/>
                        <li>
                            <xsl:value-of select="concat($mainGenre-norsk,': ',count($doc/*[@mainGenre=$mainGenre]),' stk.')"/>
                        </li>
                    </xsl:for-each>
                </ul>

                <h4>Fordelt på måneder</h4>
                <ul>
                    <li>Januar: <xsl:value-of select="count(*[contains(@production-available,'-01-')])"/> titler</li>
                    <li>Februar: <xsl:value-of select="count(*[contains(@production-available,'-02-')])"/> titler</li>
                    <li>Mars: <xsl:value-of select="count(*[contains(@production-available,'-03-')])"/> titler</li>
                    <li>April: <xsl:value-of select="count(*[contains(@production-available,'-04-')])"/> titler</li>
                    <li>Mai: <xsl:value-of select="count(*[contains(@production-available,'-05-')])"/> titler</li>
                    <li>Juni: <xsl:value-of select="count(*[contains(@production-available,'-06-')])"/> titler</li>
                    <li>Juli: <xsl:value-of select="count(*[contains(@production-available,'-07-')])"/> titler</li>
                    <li>August: <xsl:value-of select="count(*[contains(@production-available,'-08-')])"/> titler</li>
                    <li>September: <xsl:value-of select="count(*[contains(@production-available,'-09-')])"/> titler</li>
                    <li>Oktober: <xsl:value-of select="count(*[contains(@production-available,'-10-')])"/> titler</li>
                    <li>November: <xsl:value-of select="count(*[contains(@production-available,'-11-')])"/> titler</li>
                    <li>Desember: <xsl:value-of select="count(*[contains(@production-available,'-12-')])"/> titler</li>
                </ul>
                <p>Totalt <xsl:value-of select="count(*)"/> titler ble gjort tilgjengelig for utlån i <xsl:value-of select="*[1]/substring-before(@production-available,'-')"/>.</p>

            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
