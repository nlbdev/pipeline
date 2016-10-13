<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:html="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all">

    <xsl:template match="@id">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="dtbook:dtbook">
        <html>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </html>
    </xsl:template>

    <xsl:template match="dtbook:head">
        <head>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </head>
    </xsl:template>

    <xsl:template match="dtbook:meta">
        <meta>
            <xsl:copy-of select="@id|@name"/>
            <xsl:attribute name="value" select="@content"/>
            <xsl:apply-templates/>
        </meta>
    </xsl:template>

    <xsl:template match="dtbook:book">
        <body>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </body>
    </xsl:template>

    <xsl:template match="dtbook:frontmatter"/>

    <xsl:template match="dtbook:doctitle">
        <h1>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>

    <xsl:template match="dtbook:docauthor">
        <h2>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="dtbook:img">
        <img>
            <xsl:copy-of select="@src|@alt"/>
        </img>
    </xsl:template>

    <xsl:template match="dtbook:*[matches(local-name(),'level\d')]">
        <div>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </div>
        <xsl:if test="starts-with(@id,'urn_NBN')">
            <hr/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dtbook:*[matches(local-name(), 'h\d')]">
        <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:choose>
                <!--<xsl:when test="starts-with(parent::*/@id,'urn_NBN') and .//@class='author' and parent::*//*/@class='title'">
                    <xsl:copy-of select="@id"/>
                    <a target="_blank" href="http://websok.nlb.no/cgi-bin/websok?tnr={(parent::*//*[@class='identifier']/text())[1]}"><xsl:value-of select="."/></a>
                </xsl:when>-->
                <xsl:when test="matches(normalize-space(.), '^Del \d: ')">
                    <xsl:copy-of select="@id"/>
                    <xsl:value-of select="replace(normalize-space(.), '^Del \d: ', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@id"/>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dtbook:p">
        <p>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="dtbook:em">
        <em>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

    <xsl:template match="dtbook:linegroup">
        <p>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="dtbook:line">
        <span>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </span>
        <br/>
    </xsl:template>

    <xsl:template match="dtbook:a">
        <xsl:choose>
            <xsl:when test="starts-with(@href,'mailto:')">
                <a href="{@href}">
                    <xsl:copy-of select="@id"/>
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:when test="@external='true'">
                <a target="_blank" href="{@href}">
                    <xsl:copy-of select="@id"/>
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:copy-of select="@id"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dtbook:bodymatter">
        <div>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="dtbook:list">
        <ul>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="dtbook:li">
        <li>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="dtbook:lic">
        <xsl:copy-of select="@id"/>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="dtbook:table">
        <table datatable="0" role="presentation">
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <xsl:template match="dtbook:tr">
        <xsl:choose>
            <xsl:when test=".//@class=('author','authors','title','subTitle','extent','duration','narrator','narrators','description','age-group')">
                <tr>
                    <xsl:copy-of select="@id"/>
                    <td style="white-space:nowrap;">
                        <xsl:value-of select="normalize-space(dtbook:td[1])"/>
                    </td>
                    <td>
                        <xsl:value-of select="normalize-space(dtbook:td[2])"/>
                    </td>
                </tr>
            </xsl:when>
            <xsl:when test=".//@class='identifier'">
                <tr>
                    <xsl:copy-of select="@id"/>
                    <td style="white-space:nowrap;">NLB-nummer:</td>
                    <td>
                        <a target="_blank" href="http://websok.nlb.no/cgi-bin/websok?tnr={normalize-space(dtbook:td[2])}">
                            <xsl:value-of select="normalize-space(dtbook:td[2])"/>
                        </a>
                    </td>
                </tr>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dtbook:td">
        <td>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="dtbook:span">
        <span>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="dtbook:br">
        <br>
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </br>
    </xsl:template>

</xsl:stylesheet>
