<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:f="#"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="/*">
        <xsl:variable name="clean" as="element()">
            <xsl:apply-templates mode="clean" select="."/>
        </xsl:variable>
        <xsl:variable name="leaf-sections" as="element()">
            <xsl:apply-templates select="$clean" mode="leaf-sections"/>
        </xsl:variable>
        <xsl:apply-templates select="$leaf-sections" mode="keep-with-next-section"/>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="#all" priority="-5">
        <xsl:copy>
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
        <xsl:copy>
            <xsl:call-template name="attributes"/>
            <xsl:value-of select="1 + count(preceding::dtbook:noteref | preceding::html:*[f:types(.)='noteref'])"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dtbook:note/dtbook:p[1]/text()[1][starts-with(normalize-space(.), '*')] | html:*[f:types(.)=('note','footnote','endnote','rearnote')]/html:p[1]/text()[1][starts-with(normalize-space(.), '*')]" mode="clean">
        <xsl:value-of select="1 + count(preceding::dtbook:note | preceding::html:*[f:types(.)=('note','footnote','endnote','rearnote')])"/>
        <xsl:value-of select="substring-after(., '*')"/>
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
    <xsl:template match="dtbook:level1[tokenize(@class,'\s+') = 'titlepage']" mode="clean"/>
    <xsl:template match="html:body[tokenize(@epub:type,'\s+') = 'titlepage']" mode="clean"/>
    <xsl:template match="html:body/html:section[tokenize(@epub:type,'\s+') = 'titlepage']" mode="clean"/>
    
    <!-- remove print toc if present -->
    <xsl:template match="dtbook:level1[tokenize(@class,'\s+') = ('toc','print_toc')]" mode="clean"/>
    <xsl:template match="html:body[tokenize(@epub:type,'\s+') = ('toc','toc-brief')]" mode="clean"/>
    <xsl:template match="html:body/html:section[tokenize(@epub:type,'\s+') = ('toc','toc-brief')]" mode="clean"/>
    
    <!-- move colophon to the end of the book -->
    <xsl:template match="html:*[tokenize(@epub:type,'\s+') = 'colophon'] | dtbook:level1[tokenize(@class,'\s+') = 'colophon']" mode="clean"/>
    <xsl:template match="html:body[count(../html:body) = 1]" mode="clean">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
            <xsl:for-each select="*[tokenize(@epub:type,'\s+') = 'colophon']">
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:attribute name="epub:type" select="string-join(distinct-values((tokenize(@epub:type,'\s+')[not(.=('cover','frontmatter','bodymatter'))], 'backmatter')),' ')"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:body[preceding-sibling::html:body and not(following-sibling::html:body)]" mode="clean">
        <xsl:next-match/>
        <xsl:for-each select="preceding-sibling::html:body[tokenize(@epub:type,'\s+') = 'colophon']">
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="#current"/>
                <xsl:attribute name="epub:type" select="string-join(distinct-values((tokenize(@epub:type,'\s+')[not(.=('cover','frontmatter','bodymatter'))], 'backmatter')),' ')"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="dtbook:rearmatter" mode="clean">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
            <xsl:copy-of select="../*/dtbook:level1[tokenize(@class,'\s+') = 'colophon']"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dtbook:bodymatter[not(../dtbook:rearmatter)]" mode="clean">
        <xsl:next-match/>
        <rearmatter xmlns="http://www.daisy.org/z3986/2005/dtbook/">
            <xsl:copy-of select="../*/dtbook:level1[tokenize(@class,'\s+') = 'colophon']"/>
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
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:variable name="pages-estimate" select="string-length(normalize-space(string-join(.//text(),' '))) div 650" as="xs:double"/>
            <xsl:if test="$pages-estimate le 3">
                <xsl:attribute name="class" select="string-join((f:classes(.), 'keep-with-next-section'),' ')"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="html:section | dtbook:level2 | dtbook:level3 | dtbook:level4 | dtbook:level5 | dtbook:level6">
                    <xsl:for-each-group select="*" group-adjacent="local-name() = ('section','level2','level3','level4','level5','level6')">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key()">
                                <xsl:apply-templates select="current-group()" mode="#current"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="div" namespace="{current-group()[1]/namespace-uri()}">
                                    <xsl:variable name="pages-estimate" select="string-length(normalize-space(string-join(current-group()//text(),' '))) div 650" as="xs:double"/>
                                    <xsl:choose>
                                        <xsl:when test="$pages-estimate le 3">
                                            <xsl:attribute name="class" select="'leaf-section keep-with-next-section'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="class" select="'leaf-section'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:apply-templates select="current-group()" mode="#current"/>
                                </xsl:element>
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
    
    <xsl:template match="html:body | html:section | dtbook:level1 | dtbook:level2 | dtbook:level3 | dtbook:level4 | dtbook:level5 | dtbook:level6 | *[local-name() = 'div' and f:classes(.) = 'leaf-section']" mode="keep-with-next-section">
        <xsl:choose>
            <xsl:when test="not(f:classes(.) = 'keep-with-next-section')">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy exclude-result-prefixes="#all">
                    <xsl:variable name="result-classes" select="if (local-name() = ('body','section','level1','level2','level3','level4','level5','level6')) then f:classes(.)[not(. = 'leaf-section')] else f:classes(.)"/>
                    <xsl:choose>
                        <xsl:when test="exists((* | ancestor-or-self::*/following-sibling::*)[(local-name() = ('body','section','level1','level2','level3','level4','level5','level6')
                                                                                                                            or local-name() = 'div' and f:classes(.) = 'leaf-section')
                                                                                              and not(f:classes(.) = 'keep-with-next-section')])">
                            <xsl:apply-templates select="@* except @class" mode="#current"/>
                            <xsl:if test="count($result-classes)">
                                <xsl:attribute name="class" select="string-join($result-classes, ' ')"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="@* except @class" mode="#current"/>
                            <xsl:variable name="result-classes" select="$result-classes[not(. = 'keep-with-next-section')]"/>
                            <xsl:if test="count($result-classes)">
                                <xsl:attribute name="class" select="string-join($result-classes, ' ')"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
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
    
</xsl:stylesheet>
