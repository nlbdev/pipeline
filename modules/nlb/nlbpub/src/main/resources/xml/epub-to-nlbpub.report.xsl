<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns="http://www.daisy.org/ns/pipeline/data"
                xpath-default-namespace="http://www.daisy.org/ns/pipeline/data"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="/c:wrapper">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="/*/* except /*/d:fileset">
                <xsl:variable name="errors" select="(.//comment()[starts-with(.,'d:error ')] | .//@d:*[starts-with(local-name(),'error-')])/replace(string(.),'^d:error ','')" as="xs:string*"/>
                
                <document-validation-report>
                    <document-info>
                        <document-name>
                            <xsl:value-of select="replace(base-uri(.),'.*/','')"/>
                        </document-name>
                        <document-type>
                            <xsl:choose>
                                <xsl:when test="self::html:*">
                                    <xsl:text>HTML</xsl:text>
                                </xsl:when>
                                <xsl:when test="self::opf:*">
                                    <xsl:text>OPF (EPUB Package Document)</xsl:text>
                                </xsl:when>
                                <xsl:when test="self::ncx:*">
                                    <xsl:text>NCX</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>XML</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </document-type>
                        <document-path>
                            <xsl:value-of select="base-uri(.)"/>
                        </document-path>
                        <error-count>
                            <xsl:value-of select="count($errors)"/>
                        </error-count>
                    </document-info>
                    <reports>
                        <report>
                            <xsl:for-each select="$errors">
                                <xsl:variable name="error" select="tokenize(.,' \| ')"/>
                                
                                <message severity="error">
                                    <desc>
                                        <xsl:value-of select="$error[2]"/>
                                    </desc>
                                    
                                    <location href="{$error[1]}"/>
                                    
                                    <xsl:if test="$error[3]">
                                        <was>
                                            <xsl:value-of select="$error[3]"/>
                                        </was>
                                    </xsl:if>
                                    
                                    <xsl:if test="$error[4]">
                                        <expected>
                                            <xsl:value-of select="$error[4]"/>
                                        </expected>
                                    </xsl:if>
                                    
                                </message>
                            </xsl:for-each>
                        </report>
                    </reports>
                </document-validation-report>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
