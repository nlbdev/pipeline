<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:h="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.daisy.org/z3986/2005/dtbook/" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" exclude-result-prefixes="#all" version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:opf="http://www.idpf.org/2007/opf" xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/" xmlns:f="#" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    
    <xsl:output indent="yes"/>
    
    <xsl:param name="split-type" select="'none'"/>
    <xsl:param name="split-student" select="'false'"/>
    
    <xsl:template match="@lang | @langName" mode="#all"/>
    
    <xsl:template match="@* | node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/*" mode="#default">
        <xsl:choose>
            <xsl:when test="$split-type = 'outer-other'">
                <!-- create a completely separate navigation structure ("outer") and split into "norwegian" and "other" -->
                <xsl:apply-templates mode="outer-other" select="/*"/>
            </xsl:when>
            <xsl:when test="$split-type = 'inner-all'">
                <!-- create separate sibling headlinges inside the same navigation structure ("inner") and split into each different language ("all") -->
                <xsl:apply-templates mode="inner-all" select="/*"/>
            </xsl:when>
            <xsl:when test="$split-type = 'none' or $split-type = ''">
                <!-- don't split into separate languages -->
                <xsl:apply-templates mode="none" select="/*"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="concat('$split-type must be either ''outer-other'', ''inner-all'' or ''none'' (was: ''',$split-type,''')')" terminate="yes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[matches(@id,'(audio|braille)-(adult|juvenile)-(fiction|nonfiction)')]" mode="inner-all">
        <xsl:call-template name="inner-all"/>
    </xsl:template>
    
    <xsl:template match="*[matches(@id,'student-(audio|braille)')]" mode="inner-all">
        <xsl:choose>
            <xsl:when test="xs:boolean($split-student)">
                <xsl:call-template name="inner-all"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="inner-all">
        <xsl:variable name="current-level" select="."/>
        <xsl:variable name="current-headline" select="(*[matches(local-name(),'h\d')])[1]"/>
        <xsl:variable name="current-books" select="*[starts-with(@id,'b_')]"/>
        <xsl:if test="$current-books/@langName = ('Norsk', 'Bokmål', 'Nynorsk')">
            <xsl:copy>
                <xsl:apply-templates select="@* except @id" mode="#current"/>
                <xsl:attribute name="id" select="concat(@id,'-nor')"/>
                <xsl:element name="{$current-headline/name()}">
                    <xsl:apply-templates select="$current-headline/(@* except @id)" mode="#current"/>
                    <xsl:value-of select="concat($current-headline/string-join(.//text(),''), ' på norsk')"/>
                </xsl:element>
                <xsl:for-each select="$current-books[@langName=('Norsk', 'Bokmål', 'Nynorsk')]">
                    <xsl:copy>
                        <xsl:apply-templates select="@*" mode="#current"/>
                        <xsl:apply-templates select="node()" mode="#current"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:copy>
        </xsl:if>
        <xsl:for-each-group select="$current-books[not(@langName=('Norsk', 'Bokmål', 'Nynorsk'))]" group-by="@langName">
            <xsl:variable name="langName" select="if (current-grouping-key() = 'Flerspråklig') then 'flere språk' else current-grouping-key()"/>
            <xsl:element name="{$current-level/name()}">
                <xsl:apply-templates select="$current-level/(@* except @id)" mode="#current"/>
                <xsl:attribute name="id" select="concat($current-level/@id,'-',(current-group()/@lang)[1])"/>
                <xsl:element name="{$current-headline/name()}">
                    <xsl:apply-templates select="$current-headline/(@* except @id)" mode="#current"/>
                    <xsl:value-of select="concat($current-headline/string-join(.//text(),''), ' på ', lower-case($langName))"/>
                </xsl:element>
                <xsl:for-each select="current-group()">
                    <xsl:copy>
                        <xsl:apply-templates select="@*" mode="#current"/>
                        <xsl:apply-templates select="node()" mode="#current"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:element>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="bodymatter" mode="outer-other">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current">
                <xsl:with-param name="norwegian" select="true()" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="bodymatter//level1 | bodymatter//level2 | bodymatter//level3 | bodymatter//level4 | bodymatter//level5 | bodymatter//level6" priority="2" mode="outer-other">
        <xsl:param name="norwegian" as="xs:boolean" required="yes" tunnel="yes"/>
        <xsl:next-match>
            <xsl:with-param name="norwegian" select="$norwegian" tunnel="yes"/>
        </xsl:next-match>
        <xsl:if test="$norwegian and @id=('audio','braille','student-audio','student-braille') and not(following::*[@id=('audio','braille','student-audio','student-braille')])">
            <!-- insert other languages after all norwegian language books have been listed -->
            <xsl:apply-templates select="../*[@id=('audio', 'braille', 'student-audio', 'student-braille')]" mode="#current">
                <xsl:with-param name="norwegian" select="false()" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[ancestor::bodymatter and descendant-or-self::*[starts-with(@id,'b_')]]" mode="outer-other">
        <xsl:param name="norwegian" as="xs:boolean" required="yes" tunnel="yes"/>
        <xsl:variable name="langName" as="xs:string*" select="('Norsk', 'Bokmål', 'Nynorsk')"/>
        <xsl:choose>
            <xsl:when test="not(xs:boolean($split-student)) and @id=('student-audio','student-braille')">
                <xsl:if test="$norwegian">
                    <xsl:apply-templates select="." mode="none">
                        <xsl:with-param name="norwegian" select="$norwegian" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when
                test="count(descendant-or-self::*[starts-with(@id,'b_')]) = 0
                or $norwegian and count(descendant-or-self::*[starts-with(@id,'b_') and @langName = $langName]) &gt; 0
                or not($norwegian) and count(descendant-or-self::*[starts-with(@id,'b_') and not(@langName = $langName)]) &gt; 0">
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:if test="@id and not($norwegian) and count(ancestor-or-self::*[starts-with(@id,'b_')]) = 0">
                        <xsl:attribute name="id" select="concat(@id,'-other')"/>
                    </xsl:if>
                    <xsl:apply-templates select="node()" mode="#current">
                        <xsl:with-param name="norwegian" select="$norwegian" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="h1[ancestor::bodymatter] | h2[ancestor::bodymatter] | h3[ancestor::bodymatter] | h4[ancestor::bodymatter] | h5[ancestor::bodymatter] | h6[ancestor::bodymatter]"
        mode="outer-other">
        <xsl:param name="norwegian" as="xs:boolean" required="yes" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current">
                <xsl:with-param name="norwegian" select="$norwegian" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:if test="not($norwegian) and not(ancestor-or-self::*[starts-with(@id,'b_')])">
                <xsl:text> på andre språk</xsl:text>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
