<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:smil="http://www.w3.org/ns/SMIL"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/c:*">
        <xsl:apply-templates select="*[1]"/>
    </xsl:template>
    
    <xsl:template match="opf:item[@media-type=('application/xhtml+xml','text/html','application/x-dtbook+xml')]">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@href, @media-type)"/>
            <xsl:attribute name="href" select="concat(replace(@href, '\.[^/\.]+$',''), '.xhtml')"/>
            <xsl:attribute name="media-type" select="'application/xhtml+xml'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:*/@action | html:*/@background | html:*/@cite | html:*/@classid
                        | html:*/@codebase | html:*/@data | html:*/@formaction | html:*/@href
                        | html:*/@icon | html:*/@longdesc | html:*/@manifest | html:*/@poster
                        | html:*/@profile | html:*/@src | html:*/@usemap
                        | svg:*/@href
                        | smil:*/@src">
        
        <xsl:choose>
            <xsl:when test="pf:is-relative(.)">
                <xsl:variable name="uri" as="xs:string">
                    <xsl:call-template name="fix-content-file-extension">
                        <xsl:with-param name="uri" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="{name()}" select="$uri"/>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="html:meta[@http-equiv='refresh' and matches(@content, '^\d+\s*;\s*[^\s].*$')]">
        <xsl:variable name="uri" as="xs:string">
            <xsl:call-template name="fix-content-file-extension">
                <xsl:with-param name="uri" select="replace(@content,'^\d+\s*;\s*','')"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@* except @content"/>
            <xsl:attribute name="content" select="concat(replace(@content,'(\d+\s*;\s*).*?$','$1'), $uri)"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="fix-content-file-extension">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:variable name="tokenized-uri" select="pf:tokenize-uri($uri)"/>
        <xsl:variable name="resolved-uri" select="resolve-uri(pf:recompose-uri(($tokenized-uri[1],$tokenized-uri[2],$tokenized-uri[3])),base-uri(.))"/>
        <xsl:choose>
            <xsl:when test="$resolved-uri = /*/*[2]/opf:manifest/opf:item[@media-type=('application/xhtml+xml','text/html','application/x-dtbook+xml')]/resolve-uri(@href,base-uri(.))">
                <xsl:value-of select="pf:recompose-uri(($tokenized-uri[1], $tokenized-uri[2], concat(replace($tokenized-uri[3], '\.[^/\.]+$',''), '.xhtml'), $tokenized-uri[4], $tokenized-uri[5]))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$tokenized-uri"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
