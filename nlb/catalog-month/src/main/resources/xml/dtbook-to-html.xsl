<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:f="#"
                xmlns="http://www.w3.org/1999/xhtml"
                xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:param name="media" select="'email'"/>

    <xsl:template match="text()[preceding-sibling::*[1]/local-name() = 'span']">
        <span>
            <xsl:next-match/>
        </span>
    </xsl:template>

    <xsl:template match="@id">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="dtbook:dtbook">
        <html>
            <xsl:copy-of select="@id"/>
            <xsl:variable name="lang" select="(@xml:lang, dtbook:head/dtbook:meta[lower-case(@name)='dc:language']/@content, 'no')[1]"/>
            <xsl:attribute name="lang" select="$lang"/>
            <xsl:attribute name="xml:lang" select="$lang"/>
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
        <xsl:choose>
            <xsl:when test="@name = 'dtb:uid'"/>
            <xsl:when test="lower-case(@name) = 'dc:title'">
                <title>
                    <xsl:value-of select="@content"/>
                </title>
            </xsl:when>
            <xsl:otherwise>
                <meta>
                    <xsl:copy-of select="@id"/>
                    <xsl:if test="@name">
                        <xsl:attribute name="name" select="if (starts-with(@name,'dc:')) then string-join((lower-case(tokenize(@name,'\.')[1]), if (contains(@name,'.')) then substring-after(@name,'.') else ()), '.') else @name"/>
                    </xsl:if>
                    <xsl:attribute name="content" select="@content"/>
                    <xsl:apply-templates/>
                </meta>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dtbook:book">
        <body>
            <xsl:copy-of select="@id"/>
            <xsl:if test="$media = 'braille'">
                <section id="contact">
                    <p>Her finner du nyheter og lister med bøker NLB har produsert siste måned. For å bestille bøker du finner i listene kan du oppgi boknummeret til oss på telefon, eller søke på boknummeret på nettsiden vår: www.nlb.no</p>
                    <p>Du kan også kontakte oss på e-post: <a href="mailto:utlaan@nlb.no">utlaan@nlb.no</a> eller telefon: <a href="tlf:22068810">22 06 88 10</a>.</p>
                </section>
            </xsl:if>
            <xsl:apply-templates/>
        </body>
    </xsl:template>

    <xsl:template match="dtbook:frontmatter"/>

    <xsl:template match="dtbook:doctitle">
        <xsl:if test="not($media = 'braille')">
            <h1>
                <xsl:copy-of select="@id"/>
                <xsl:apply-templates/>
            </h1>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dtbook:docauthor">
        <xsl:if test="not($media = 'braille')">
            <h2>
                <xsl:copy-of select="@id"/>
                <xsl:apply-templates/>
            </h2>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dtbook:img">
        <img>
            <xsl:copy-of select="@src|@alt"/>
        </img>
    </xsl:template>

    <xsl:template match="dtbook:*[matches(local-name(),'level\d')]">
        <xsl:choose>
            <xsl:when test="not($media = 'braille') or exists((dtbook:h1 | dtbook:h2 | dtbook:h3 | dtbook:h4 | dtbook:h5 | dtbook:h6)//text()[normalize-space()])">
                <xsl:element name="{if ($media = 'braille') then 'section' else 'div'}">
                    <xsl:copy-of select="@id"/>
                    <xsl:apply-templates/>
                </xsl:element>
                <xsl:if test="starts-with(@id,'urn_NBN')">
                    <hr/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dtbook:*[matches(local-name(), 'h\d')]">
        <xsl:if test="normalize-space(string-join(.//text(),''))">
            <xsl:element name="h{f:level(.)}" namespace="http://www.w3.org/1999/xhtml">
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
        </xsl:if>
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
            <xsl:when test="$media = 'braille' and starts-with(@href, 'http://websok.nlb.no/cgi-bin/websok?tnr=')">
                <span>
                    <xsl:copy-of select="@id"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
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
        <xsl:choose>
            <xsl:when test="$media = 'braille'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:copy-of select="@id"/>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
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
    
    <xsl:template match="dtbook:div">
        <xsl:choose>
            <xsl:when test="$media = 'braille' and not(exists(*[not(matches(local-name(), 'level\d'))]))">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="f:level" as="xs:integer">
        <xsl:param name="context" as="element()"/>
        <xsl:variable name="ancestor-levels" select="$context/ancestor-or-self::*[matches(local-name(), 'level\d') and exists((dtbook:h1 | dtbook:h2 | dtbook:h3 | dtbook:h4 | dtbook:h5 | dtbook:h6)//text()[normalize-space()])]"/>
        <xsl:value-of select="count($ancestor-levels)"/>
    </xsl:function>

</xsl:stylesheet>
