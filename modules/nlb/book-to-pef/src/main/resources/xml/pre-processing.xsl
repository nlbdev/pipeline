<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:f="#"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:param name="maximum-number-of-pages" as="xs:integer" select="86"/>
    
    <xsl:template match="/*">
        <xsl:variable name="clean" as="element()">
            <xsl:apply-templates mode="clean" select="."/>
        </xsl:variable>
        <xsl:apply-templates select="$clean" mode="leaf-sections"/>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="#all" priority="-5">
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:call-template name="attributes"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="attributes">
        <xsl:apply-templates select="@* except (@class | @epub:type)" mode="#current"/>
        <xsl:call-template name="class-attribute"/>
        <xsl:call-template name="type-attribute"/>
    </xsl:template>
    
    <xsl:template name="class-attribute">
        <xsl:if test="@class">
            <xsl:variable name="classes" select="f:classes(.)"/>
            <xsl:variable name="classes" select="for $class in $classes return if ($class = ('precedingseparator','precedingemptyline')) then () else $class"/>
            <xsl:if test="count($classes)">
                <xsl:attribute name="class" select="string-join($classes,' ')"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="type-attribute">
        <xsl:apply-templates select="@epub:type" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="dtbook:noteref[normalize-space(.) eq '*'] | html:*[f:types(.)='noteref'][normalize-space(.) eq '*']" mode="clean">
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:call-template name="attributes"/>
            <xsl:value-of select="1 + count(preceding::dtbook:noteref | preceding::html:*[f:types(.)='noteref'])"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="dtbook:note | html:*[f:types(.)=('note','footnote','endnote','rearnote')]" mode="clean">
        <xsl:variable name="namespace-uri" select="string(namespace-uri())" as="xs:string"/>
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="node()" group-adjacent="f:is-inline(.) or self::text()/normalize-space() = ''">
                <xsl:choose>
                    <xsl:when test="current-grouping-key() and count(current-group()[not(self::text()/normalize-space() = '')]) gt 0">
                        <xsl:apply-templates select="current-group()[1][self::text()/normalize-space() = '']"/>
                        <xsl:element name="p" namespace="{$namespace-uri}">
                            <xsl:apply-templates select="current-group()[not(self::text()/normalize-space() = '') or not(position() = (1, last()))]"/>
                        </xsl:element>
                        <xsl:apply-templates select="current-group()[last()][self::text()/normalize-space() = '']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dtbook:note/dtbook:p[1]/text()[1] | dtbook:note/text()[1] | html:*[f:types(.)=('note','footnote','endnote','rearnote')]/html:p[1]/text()[1] | html:*[f:types(.)=('note','footnote','endnote','rearnote')]/text()[1]">
        <xsl:choose>
            <xsl:when test="starts-with(normalize-space(.), '*') and not(parent::*:p/preceding-sibling::text()[starts-with(normalize-space(.), '*')])">
                <xsl:value-of select="1 + count(preceding::dtbook:note | preceding::html:*[f:types(.)=('note','footnote','endnote','rearnote')])"/>
                <xsl:value-of select="substring-after(., '*')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Rename article and main elements to section, to simplify CSS styling -->
    <xsl:template match="html:article | html:main" mode="clean">
        <xsl:element name="section" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="@* except (@epub:type | @class)" mode="#current"/>
            <xsl:call-template name="class-attribute"/>
            <xsl:attribute name="epub:type" select="string-join(distinct-values((f:types(.),local-name())),' ')"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!-- remove existing titlepage if present -->
    <xsl:template match="dtbook:level1[f:classes(.) = 'titlepage']" mode="clean" priority="2"/>
    <xsl:template match="html:body[f:types(.) = 'titlepage']" mode="clean" priority="2"/>
    <xsl:template match="html:body/html:section[f:types(.) = 'titlepage']" mode="clean" priority="2"/>
    
    <!-- remove print toc if present -->
    <xsl:template match="dtbook:level1[f:classes(.) = ('toc','print_toc')]" mode="clean" priority="2"/>
    <xsl:template match="html:body[f:types(.) = ('toc','toc-brief')]" mode="clean" priority="2"/>
    <xsl:template match="html:body/html:section[f:types(.) = ('toc','toc-brief')]" mode="clean" priority="2"/>
    
    <!-- move colophon to the end of the book -->
    <xsl:template match="html:*[f:types(.) = 'colophon'] | dtbook:level1[f:classes(.) = 'colophon']" mode="clean" priority="2"/>
    <xsl:template match="html:body[count(../html:body) = 1]" mode="clean">
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
            <xsl:for-each select="*[f:types(.) = 'colophon']">
                <xsl:copy exclude-result-prefixes="#all">
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:attribute name="epub:type" select="string-join(distinct-values((f:types(.)[not(.=('cover','frontmatter','bodymatter'))], 'backmatter')),' ')"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:body[preceding-sibling::html:body[not((f:classes(.), f:types(.)) = ('titlepage', 'toc', 'print_toc', 'toc-brief', 'colophon'))]
                           and not(following-sibling::html:body[not((f:classes(.), f:types(.)) = ('titlepage', 'toc', 'print_toc', 'toc-brief', 'colophon'))])]" mode="clean">
        <xsl:next-match/>
        <xsl:for-each select="preceding-sibling::html:body[f:types(.) = 'colophon']">
            <xsl:copy exclude-result-prefixes="#all">
                <xsl:apply-templates select="@*" mode="#current"/>
                <xsl:attribute name="epub:type" select="string-join(distinct-values((f:types(.)[not(.=('cover','frontmatter','bodymatter'))], 'backmatter')),' ')"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="dtbook:rearmatter" mode="clean">
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
            <xsl:copy-of select="../*/dtbook:level1[f:classes(.) = 'colophon']" exclude-result-prefixes="#all"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dtbook:bodymatter[not(../dtbook:rearmatter)]" mode="clean">
        <xsl:next-match/>
        <rearmatter xmlns="http://www.daisy.org/z3986/2005/dtbook/">
            <xsl:copy-of select="../*/dtbook:level1[f:classes(.) = 'colophon']" exclude-result-prefixes="#all"/>
        </rearmatter>
    </xsl:template>
    
    <xsl:template match="*[f:classes(.)=('precedingseparator','precedingemptyline')]" mode="clean">
        <xsl:element name="hr" namespace="{namespace-uri()}">
            <xsl:if test="f:classes(.) = 'precedingemptyline'">
                <xsl:attribute name="class" select="'emptyline'"/>
            </xsl:if>
        </xsl:element>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="html:body | html:section | dtbook:level1 | dtbook:level2 | dtbook:level3 | dtbook:level4 | dtbook:level5 | dtbook:level6" mode="leaf-sections">
        <xsl:variable name="maximum-number-of-leaf-section-pages" select="xs:integer(round($maximum-number-of-pages div 3 + 0.5))" as="xs:integer"/>
        
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:variable name="pages-estimate" select="f:pages-estimate(.)" as="xs:double"/>
            <xsl:choose>
                <xsl:when test="exists(html:section | dtbook:level2 | dtbook:level3 | dtbook:level4 | dtbook:level5 | dtbook:level6) or $pages-estimate gt $maximum-number-of-leaf-section-pages">
                    <xsl:for-each-group select="node()" group-adjacent="local-name() = ('section','level2','level3','level4','level5','level6') or self::text() and not(normalize-space())">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key()">
                                <xsl:apply-templates select="current-group()" mode="#current"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="create-div-leaf-sections">
                                    <xsl:with-param name="content" select="current-group()"/>
                                    <xsl:with-param name="maximum-number-of-leaf-section-pages" select="$maximum-number-of-leaf-section-pages"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="create-div-leaf-sections">
        <xsl:param name="content" as="node()*" required="yes"/>
        <xsl:param name="maximum-number-of-leaf-section-pages" as="xs:integer" required="yes"/>
        
        <xsl:choose>
            <xsl:when test="count($content) = 0"/>
            <xsl:otherwise>
                <xsl:call-template name="create-div-leaf-section">
                    <xsl:with-param name="content" select="$content" as="node()*"/>
                    <xsl:with-param name="pages-estimates" select="for $n in $content return f:pages-estimate($n)" as="xs:double*"/>
                    <xsl:with-param name="maximum-number-of-leaf-section-pages" select="$maximum-number-of-leaf-section-pages" as="xs:integer"/>
                    <xsl:with-param name="namespace" select="($content[self::*], $content[1]/ancestor::*)[1]/namespace-uri()" as="xs:string"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="create-div-leaf-section">
        <xsl:param name="content" as="node()*" required="yes"/>
        <xsl:param name="pages-estimates" as="xs:double*" required="yes"/>
        <xsl:param name="maximum-number-of-leaf-section-pages" as="xs:integer" required="yes"/>
        <xsl:param name="namespace" as="xs:string" required="yes"/>
        
        <xsl:choose>
            <xsl:when test="count($content) = 0"/>
            
            <xsl:when test="sum($pages-estimates) le $maximum-number-of-leaf-section-pages or count($content) = 1">
                
                <xsl:if test="not(sum($pages-estimates) le $maximum-number-of-leaf-section-pages)">
                    <xsl:message select="concat('Could not create leaf sections smaller than ', $maximum-number-of-leaf-section-pages, '. Leaf section is estimated to contain ', sum($pages-estimates), ' pages.')"/>
                </xsl:if>
                
                <xsl:element name="div" namespace="{$namespace}">
                    <xsl:attribute name="class" select="'leaf-section'"/>
                    <xsl:apply-templates select="$content" mode="#current"/>
                </xsl:element>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:message select="'leaf section too big; recursively split it in half until it is small enough'"/>
                
                <xsl:variable name="content-nodes-split-position" as="xs:boolean*">
                    <xsl:for-each select="$pages-estimates">
                        <xsl:variable name="position" select="position()"/>
                        <xsl:value-of select="sum($pages-estimates[position() le $position]) gt sum($pages-estimates) div 2"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="content-nodes-split-position" select="max((1, count($content-nodes-split-position[.=false()])))"/>
                
                <xsl:call-template name="create-div-leaf-section">
                    <xsl:with-param name="content" select="$content[position() le $content-nodes-split-position]" as="node()*"/>
                    <xsl:with-param name="pages-estimates" select="$pages-estimates[position() le $content-nodes-split-position]" as="xs:double*"/>
                    <xsl:with-param name="maximum-number-of-leaf-section-pages" select="$maximum-number-of-leaf-section-pages" as="xs:integer"/>
                    <xsl:with-param name="namespace" select="$namespace"/>
                </xsl:call-template>
                
                <xsl:call-template name="create-div-leaf-section">
                    <xsl:with-param name="content" select="$content[position() gt $content-nodes-split-position]" as="node()*"/>
                    <xsl:with-param name="pages-estimates" select="$pages-estimates[position() gt $content-nodes-split-position]" as="xs:double*"/>
                    <xsl:with-param name="maximum-number-of-leaf-section-pages" select="$maximum-number-of-leaf-section-pages" as="xs:integer"/>
                    <xsl:with-param name="namespace" select="$namespace"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="f:types" as="xs:string*">
        <xsl:param name="element" as="element()"/>
        <xsl:sequence select="tokenize($element/@epub:type,'\s+')"/>
    </xsl:function>
    
    <xsl:function name="f:classes" as="xs:string*">
        <xsl:param name="element" as="element()"/>
        <xsl:sequence select="tokenize($element/@class,'\s+')"/>
    </xsl:function>
    
    <xsl:function name="f:pages-estimate" as="xs:double">
        <xsl:param name="node" as="node()*"/>
        <xsl:value-of select="string-length(normalize-space(string-join($node//text(),' '))) div 650"/>
    </xsl:function>
        
    <xsl:function name="f:is-inline" as="xs:boolean">
        <xsl:param name="element" as="node()"/>
        <xsl:choose>
            <xsl:when test="$element[self::text() and normalize-space()]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$element[self::html:*]">
                <xsl:value-of select="$element/local-name() = ('a','abbr','bdo','br','code','dfn','em','img','kbd','q','samp','span','strong','sub','sup')"/>
            </xsl:when>
            <xsl:when test="$element[self::dtbook:*]">
                <xsl:value-of select="$element/local-name() = ('em','strong','dfn','code','samp','kbd','cite','abbr','acronym','a','img','br','q','sub','sup','span','bdo','sent','w','annoref','noteref','lic')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
