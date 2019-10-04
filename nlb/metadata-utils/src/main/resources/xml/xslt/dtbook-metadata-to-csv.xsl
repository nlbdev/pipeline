<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0"
    xmlns="http://www.daisy.org/z3986/2005/dtbook/" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:c="http://www.w3.org/ns/xproc-step"
    xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/">

    <xsl:param name="author-in-columns" select="'true'"/>
    <xsl:param name="narrator-in-columns" select="'true'"/>

    <xsl:template name="main">
        <c:result>
            <xsl:variable name="books">
                <xsl:call-template name="parse-books">
                    <xsl:with-param name="input" select="/*/*"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="books-to-csv">
                <xsl:with-param name="authorInColumns" select="$author-in-columns = 'true'"/>
                <xsl:with-param name="narratorInColumns" select="$narrator-in-columns = 'true'"/>
                <xsl:with-param name="books" select="$books/*"/>
            </xsl:call-template>
        </c:result>
    </xsl:template>


    <!-- ======================================= first pass: ======================================= -->

    <xsl:template name="parse-books" as="element()*">
        <xsl:param name="input" as="element()*"/>
        <xsl:apply-templates select="$input"/>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="level1">
        <book>
            <meta name="Format" value="{if (@format='Braille') then 'Punktskrift' else @format}"/>
            <meta name="Målgruppe" value="{if (@audience='Adult') then 'Voksen' else if (@audience='Juvenile') then 'Barn/Ungdom' else @audience}"/>
            <meta name="Sjanger" value="{if (@mainGenre='Non-fiction') then 'Sakprosa' else if (@mainGenre='Fiction') then 'Skjønnlitteratur' else @mainGenre}"/>
            <meta name="Tidsskrift" value="{if (@magazine='true') then 'Ja' else 'Nei'}"/>
            <meta name="Avis" value="{if (@newspaper='true') then 'Ja' else 'Nei'}"/>
            <xsl:if test="string(@external-production)!=''">
                <meta name="Produsert eksternt" value="{@external-production}"/>
            </xsl:if>
            <meta name="Klar for utlån" value="{@production-available}"/>
            <xsl:for-each select=".//span[tokenize(@class,'\s+') = 'author']">
                <meta name="Forfatter {position()}" value="{.}">
                    <xsl:variable name="bibliofil-id" select="for $class in (tokenize(@class,'\s+')[starts-with(.,'bibliofil-id-')]) return substring-after($class,'bibliofil-id-')"/>
                    <xsl:if test="count($bibliofil-id)">
                        <xsl:attribute name="bibliofil-id" select="$bibliofil-id"/>
                    </xsl:if>
                </meta>
            </xsl:for-each>
            <xsl:apply-templates/>
        </book>
    </xsl:template>

    <xsl:template match="h1">
        <meta name="Tittel">
            <xsl:attribute name="value" select="normalize-space(string-join(.//text() except .//span[tokenize(@class,'\s+')='author']//text(),''))"/>
        </meta>
    </xsl:template>

    <xsl:template match="line">
        <xsl:choose>
            <xsl:when test="span/tokenize(@class,'\s+') = 'narrators'">
                <xsl:for-each select=".//span[tokenize(@class,'\s+') = 'narrator']">
                    <meta name="Innleser {position()}" value="{.}">
                        <xsl:variable name="bibliofil-id" select="for $class in (tokenize(@class,'\s+')[starts-with(.,'bibliofil-id-')]) return substring-after($class,'bibliofil-id-')"/>
                        <xsl:if test="count($bibliofil-id)">
                            <xsl:attribute name="bibliofil-id" select="$bibliofil-id"/>
                        </xsl:if>
                    </meta>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="span/tokenize(@class,'\s+') = 'authors'"/>
            <xsl:otherwise>
                <meta>
                    <xsl:variable name="name" select="(replace(normalize-space(string-join(*[@class='fieldName']//text(),'')),':$',''), tokenize(@class,'\s+'))[normalize-space()][1]"/>
                    <xsl:variable name="name" select="if ($name = 'Hefter') then 'Hefter (bind)' else $name"/>
                    <xsl:variable name="name"
                        select="if ($name='duration') then 'Varighet'
                        else if ($name='extent') then 'Hefter og sider'
                        else if ($name='description') then 'Bokomtale'
                        else $name"/>
                    <xsl:variable name="value" select="normalize-space(string-join(.//text() except *[@class='fieldName']//text(),''))"/>
                    <xsl:variable name="value"
                        select="if ($name='Varighet' and matches($value,'\d+ *t\.? *\d+ *min\.?')) then replace($value,'^.*?(\d+) *t\.? *(\d+) *min\.?.*?$','$1:0$2') else $value"/>
                    <xsl:variable name="value" select="if ($name='Varighet' and matches($value,'\d+ *min\.?')) then replace($value,'^.*?(\d+) *min\.?.*?$','0:0$1') else $value"/>
                    <xsl:variable name="value" select="if ($name='Varighet' and matches($value,'\d+:\d+')) then replace($value,'0(\d\d)','$1') else $value"/>
                    
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="value" select="$value"/>
                    
                    <xsl:variable name="bibliofil-id" select="(for $class in (descendant-or-self::*/tokenize(@class,'\s+')[starts-with(.,'bibliofil-id-')]) return substring-after($class,'bibliofil-id-'))[1]"/>
                    <xsl:if test="count($bibliofil-id)">
                        <xsl:attribute name="bibliofil-id" select="$bibliofil-id"/>
                    </xsl:if>
                </meta>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- ======================================= second pass: ======================================= -->

    <xsl:template name="books-to-csv" as="xs:string">
        <xsl:param name="books" as="element()*"/>
        <xsl:param name="authorInColumns" as="xs:boolean"/>
        <xsl:param name="narratorInColumns" as="xs:boolean"/>

        <xsl:variable name="headlines"
            select="('Boknummer','Format','Målgruppe','Sjanger','Tidsskrift','Klar for utlån','Tittel','Varighet','Varighet (desimal)','Forlag','Originalforlag','Sjanger/Emner','Originaltittel','Avis','Produsert eksternt','Hefter og sider','Hefter (bind)','Dewey','Oversatt av')"/>
        <xsl:variable name="headlines" select="($headlines, $books/*/string(@name)[not(.='Bokomtale' or starts-with(.,'Innleser ') or starts-with(.,'Forfatter '))])"/>
        <xsl:variable name="headlines" select="($headlines, 'Antall innlesere', $books/*/string(@name)[starts-with(.,'Innleser ')])"/>
        <xsl:variable name="headlines" select="($headlines, 'Antall forfattere / oversettere', $books/*/string(@name)[starts-with(.,'Forfatter ')])"/>
        <xsl:variable name="headlines" select="($headlines, 'Bokomtale')"/>
        <xsl:variable name="headlines" select="distinct-values($headlines)"/>

        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="not($authorInColumns)">

                    <!-- Forfatter i første kolonne, potensielt flere rader per bok, potensielt flere innleser-kolonner -->

                    <xsl:variable name="headlines" select="$headlines[not(starts-with(.,'Forfatter') or starts-with(.,'Oversatt av'))]"/>

                    <xsl:call-template name="cell">
                        <xsl:with-param name="value" select="'Bibliofil ID for forfatter / oversetter'"/>
                    </xsl:call-template>
                    <xsl:text>,</xsl:text>
                    <xsl:call-template name="cell">
                        <xsl:with-param name="value" select="'Forfatter / Oversetter'"/>
                    </xsl:call-template>
                    <xsl:text>,</xsl:text>
                    <xsl:call-template name="cell">
                        <xsl:with-param name="value" select="'Rolle'"/>
                    </xsl:call-template>
                    <xsl:text>,</xsl:text>

                    <xsl:call-template name="headlines-row">
                        <xsl:with-param name="headlines" select="$headlines"/>
                    </xsl:call-template>

                    <xsl:for-each select="$books">
                        <xsl:variable name="meta" select="meta"/>

                        <xsl:variable name="authorOrTranslator" select="$meta[starts-with(@name,'Forfatter') or starts-with(@name,'Oversatt av')]"/>

                        <xsl:for-each select="if (count($authorOrTranslator) = 0) then 'Ukjent forfatter / oversetter' else $authorOrTranslator">

                            <xsl:text/>
                            <xsl:call-template name="cell">
                                <xsl:with-param name="value" select="if (. instance of node()) then string(@bibliofil-id) else ''"/>
                            </xsl:call-template>
                            <xsl:text>,</xsl:text>
                            <xsl:call-template name="cell">
                                <xsl:with-param name="value" select="if (. instance of node()) then string(@value) else ."/>
                            </xsl:call-template>
                            <xsl:text>,</xsl:text>
                            <xsl:call-template name="cell">
                                <xsl:with-param name="value" select="if (. instance of node()) then (if (starts-with(@name,'Forfatter')) then 'Forfatter' else 'Oversetter') else ''"/>
                            </xsl:call-template>
                            <xsl:text>,</xsl:text>

                            <xsl:call-template name="metadata-row">
                                <xsl:with-param name="headlines" select="$headlines"/>
                                <xsl:with-param name="meta" select="$meta"/>
                            </xsl:call-template>

                        </xsl:for-each>

                    </xsl:for-each>

                </xsl:when>
                <xsl:when test="not($narratorInColumns)">

                    <!-- Innleser i første kolonne, potensielt flere rader per bok, potensielt flere forfatter-kolonner -->

                    <xsl:variable name="headlines" select="$headlines[not(starts-with(.,'Innleser'))]"/>

                    <xsl:call-template name="cell">
                        <xsl:with-param name="value" select="'Bibliofil ID for Innleser'"/>
                    </xsl:call-template>
                    <xsl:text>,</xsl:text>
                    <xsl:call-template name="cell">
                        <xsl:with-param name="value" select="'Innleser'"/>
                    </xsl:call-template>
                    <xsl:text>,</xsl:text>

                    <xsl:call-template name="headlines-row">
                        <xsl:with-param name="headlines" select="$headlines"/>
                    </xsl:call-template>

                    <xsl:for-each select="$books">
                        <xsl:variable name="meta" select="meta"/>
                        
                        <xsl:variable name="narrator" select="$meta[starts-with(@name,'Innleser')]"/>
                        
                        <xsl:for-each select="if (count($narrator) = 0) then 'Ukjent innleser' else $narrator">

                            <xsl:text/>
                            <xsl:call-template name="cell">
                                <xsl:with-param name="value" select="if (. instance of node()) then string(@bibliofil-id) else ''"/>
                            </xsl:call-template>
                            <xsl:text>,</xsl:text>
                            <xsl:call-template name="cell">
                                <xsl:with-param name="value" select="if (. instance of node()) then string(@value) else ."/>
                            </xsl:call-template>
                            <xsl:text>,</xsl:text>

                            <xsl:call-template name="metadata-row">
                                <xsl:with-param name="headlines" select="$headlines"/>
                                <xsl:with-param name="meta" select="$meta"/>
                            </xsl:call-template>

                        </xsl:for-each>

                    </xsl:for-each>

                </xsl:when>
                <xsl:otherwise>

                    <!-- Kun én rad per bok, potensielt flere forfatter-kolonner og innleser-kolonner -->

                    <xsl:call-template name="headlines-row">
                        <xsl:with-param name="headlines" select="$headlines"/>
                    </xsl:call-template>

                    <xsl:for-each select="$books">
                        <xsl:variable name="meta" select="meta"/>
                        <xsl:text/>
                        <xsl:call-template name="metadata-row">
                            <xsl:with-param name="headlines" select="$headlines"/>
                            <xsl:with-param name="meta" select="$meta"/>
                        </xsl:call-template>
                    </xsl:for-each>


                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join($result,'')"/>
    </xsl:template>

    <xsl:template name="cell" as="xs:string">
        <xsl:param name="value" as="xs:string"/>
        <xsl:value-of select="concat('&quot;',replace($value,'&quot;','&quot;&quot;'),'&quot;')"/>
    </xsl:template>

    <xsl:template name="row" as="xs:string">
        <xsl:param name="values" as="xs:string*"/>
        <xsl:variable name="row-string">
            <xsl:for-each select="$values">
                <xsl:call-template name="cell">
                    <xsl:with-param name="value" select="."/>
                </xsl:call-template>
                <xsl:if test="not(position()=last())">
                    <xsl:text>,</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>
</xsl:text>
        </xsl:variable>
        <xsl:value-of select="string-join($row-string,'')"/>
    </xsl:template>
    
    <xsl:template name="headlines-row" as="xs:string">
        <xsl:param name="headlines" as="xs:string*"/>
        
        <xsl:variable name="headlines" as="xs:string*">
            <xsl:for-each select="$headlines">
                <xsl:if test="starts-with(.,'Innleser ') or starts-with(.,'Forfatter ')">
                    <xsl:sequence select="concat('Bibliofil ID for ', .)"/>
                </xsl:if>
                <xsl:sequence select="."/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:call-template name="row">
            <xsl:with-param name="values" select="$headlines"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="metadata-row" as="xs:string">
        <xsl:param name="headlines" as="xs:string*"/>
        <xsl:param name="meta" as="element()*"/>

        <xsl:variable name="values" as="xs:string*">
            <xsl:for-each select="$headlines">
                <xsl:variable name="headline" select="."/>

                <xsl:choose>
                    <xsl:when test="$headline='Antall forfattere / oversettere'">
                        <xsl:copy-of select="string(count($meta[starts-with(@name,'Forfatter') or starts-with(@name,'Oversettere')]))"/>
                    </xsl:when>
                    <xsl:when test="$headline='Antall innlesere'">
                        <xsl:copy-of select="string(count($meta[starts-with(@name,'Innleser')]))"/>
                    </xsl:when>
                    <xsl:when test="$headline='Varighet (desimal)'">
                        <xsl:copy-of
                            select="($meta[@name='Varighet' and matches(@value,'\d+:\d+')]/replace(string(round(100 * (number(substring-before(@value,':')) + number(substring-after(@value,':')) div 60)) div 100),'\.',','), '')[1]"
                        />
                    </xsl:when>
                    <xsl:when test="starts-with($headline,'Innleser ') or starts-with($headline,'Forfatter ')">
                        <xsl:copy-of select="($meta[@name=$headline]/string(@bibliofil-id),'')[1]"/>
                        <xsl:copy-of select="($meta[@name=$headline]/string(@value),'')[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="($meta[@name=$headline]/string(@value),'')[1]"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each>
        </xsl:variable>

        <xsl:call-template name="row">
            <xsl:with-param name="values" select="$values"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
