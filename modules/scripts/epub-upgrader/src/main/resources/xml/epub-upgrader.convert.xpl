<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xpath-version="2.0"
                type="px:epub-upgrader.convert"
                name="main"
                version="1.0">
    
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true">
        <p:empty/>
    </p:input>
    <p:input port="report.in" sequence="true">
        <p:empty/>
    </p:input>
    <p:input port="status.in">
        <p:inline>
            <d:validation-status result="ok"/>
        </p:inline>
    </p:input>
    
    <p:output port="fileset.out" primary="true">
        <p:pipe port="fileset.out" step="choose"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="in-memory.out" step="choose"/>
    </p:output>
    <p:output port="report.out" sequence="true">
        <p:pipe port="report.in" step="main"/>
        <p:pipe port="report.out" step="choose"/>
    </p:output>
    <p:output port="status.out">
        <p:pipe port="result" step="status"/>
    </p:output>
    
    <p:option name="fail-on-error" select="'true'"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/validation-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-nav-utils/library.xpl"/>
    
    <p:choose name="choose">
        <p:xpath-context>
            <p:pipe port="status.in" step="main"/>
        </p:xpath-context>
        <p:when test="/*/@result='ok' or $fail-on-error = 'false'">
            <p:output port="fileset.out" primary="true">
                <p:pipe port="result" step="fileset"/>
            </p:output>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe port="result" step="all-content"/>
                <p:pipe port="result" step="nav"/>
                <p:pipe port="result" step="smil"/>
                <p:pipe port="result" step="opf"/>
            </p:output>
            <p:output port="report.out" sequence="true">
                <p:empty/>
            </p:output>
            
            <p:variable name="fileset-base" select="base-uri(/*)"/>
            
            <p:identity>
                <p:input port="source">
                    <p:pipe port="fileset.in" step="main"/>
                </p:input>
            </p:identity>
            <px:message message="[progress px:epub-upgrader.convert 5 px:epub-load-opf] Loading package document"/>
            <px:epub-load-opf>
                <p:input port="in-memory">
                    <p:pipe port="in-memory.in" step="main"/>
                </p:input>
            </px:epub-load-opf>
            <p:add-attribute match="/*" attribute-name="xml:base">
                <p:with-option name="attribute-value" select="base-uri(/*)"/>
            </p:add-attribute>
            <px:assert message="There must be exactly 1 OPF in the fileset" test-count-min="1" test-count-max="1"/>
            <p:delete match="/opf:package/opf:manifest/opf:item[@id = /opf:package/opf:spine/@toc] | /opf:package/opf:spine/@toc"/>
            <p:identity name="opf-before-href-fix"/>
            
            <p:identity>
                <p:input port="source">
                    <p:pipe port="fileset.in" step="main"/>
                </p:input>
            </p:identity>
            <px:message message="Loading content documents"/>
            <px:fileset-load media-types="application/xhtml+xml text/html application/x-dtbook+xml">
                <p:input port="in-memory">
                    <p:pipe port="in-memory.in" step="main"/>
                </p:input>
            </px:fileset-load>
            
            <px:message message="[progress px:epub-upgrader.convert 70 px:epub-upgrader.convert.for-each.spine] Processing content"/>
            <p:for-each>
                <p:variable name="document-base" select="(/*/@xml:base, /*/base-uri())[1]"/>
                
                <p:add-attribute attribute-name="xml:base" match="/*">
                    <p:with-option name="attribute-value" select="$document-base"/>
                </p:add-attribute>
                
                <p:choose>
                    <p:when test="base-uri(/*) = 'http://www.daisy.org/z3986/2005/dtbook/'">
                        <px:message>
                            <p:with-option name="message" select="concat('Converting &quot;',replace($document-base,'.*/',''),'&quot; from DTBook to HTML 5 (not implemented!)')"/>
                        </px:message>
                        <p:identity/>
                        
                    </p:when>
                    <p:otherwise>
                        <px:message>
                            <p:with-option name="message" select="concat('Upgrading &quot;',replace($document-base,'.*/',''),'&quot; to HTML 5')"/>
                        </px:message>
                        <p:xslt>
                            <p:input port="parameters">
                                <p:empty/>
                            </p:input>
                            <p:input port="stylesheet">
                                <p:document href="http://www.daisy.org/pipeline/modules/html-utils/html5-upgrade.xsl"/>
                            </p:input>
                        </p:xslt>
                    </p:otherwise>
                </p:choose>
                
                <p:add-attribute attribute-name="xml:base" match="/*">
                    <p:with-option name="attribute-value" select="concat(replace($document-base, '\.[^/\.]+$',''),'.xhtml')"/>
                </p:add-attribute>
                
                <px:message>
                    <p:with-option name="message" select="concat('Upgrading hrefs in &quot;',replace($document-base,'.*/',''),'&quot; to the xhtml file extension')"/>
                </px:message>
                <p:identity name="content-before-href-fix"/>
                <p:wrap-sequence wrapper="c:result">
                    <p:input port="source">
                        <p:pipe port="result" step="content-before-href-fix"/>
                        <p:pipe port="result" step="opf-before-href-fix"/>
                    </p:input>
                </p:wrap-sequence>
                <p:xslt>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="fix-hrefs.xsl"/>
                    </p:input>
                </p:xslt>
                
            </p:for-each>
            <p:identity name="all-content"/>
            
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="opf-before-href-fix"/>
                </p:input>
            </p:identity>
            <px:message message="[progress px:epub-upgrader.convert 5 px:epub-load-opf] Loading spine"/>
            <px:epub-load-spine>
                <p:input port="in-memory">
                    <p:pipe port="result" step="all-content"/>
                </p:input>
            </px:epub-load-spine>
            <p:identity name="spine"/>
            
            <p:wrap-sequence wrapper="c:result">
                <p:input port="source">
                    <p:pipe port="result" step="opf-before-href-fix"/>
                    <p:pipe port="result" step="opf-before-href-fix"/>
                </p:input>
            </p:wrap-sequence>
            <px:message message="Upgrading references from package document to content document to the xhtml file extension"/>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="fix-hrefs.xsl"/>
                </p:input>
            </p:xslt>
            <p:identity name="original-opf-with-fixed-hrefs"/>
            <px:message message="Creating fileset based on the input package document (with fixed hrefs)"/>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/opf-manifest-to-fileset.xsl"/>
                </p:input>
            </p:xslt>
            <p:identity name="original-opf-fileset-with-fixed-hrefs"/>
            <px:message message="Loading Media Overlay (if present)"/>
            <px:fileset-load media-types="application/smil+xml"/>
            <p:for-each>
                <p:add-attribute attribute-name="xml:base" match="/*">
                    <p:with-option name="attribute-value" select="base-uri(/*)"/>
                </p:add-attribute>
                <px:message>
                    <p:with-option name="message" select="concat('Upgrading hrefs in &quot;',replace(base-uri(/*),'.*/',''),'&quot; to the xhtml file extension')"/>
                </px:message>
                <p:identity name="current-smil"/>
                <p:wrap-sequence wrapper="c:result">
                    <p:input port="source">
                        <p:pipe port="result" step="current-smil"/>
                        <p:pipe port="result" step="opf-before-href-fix"/>
                    </p:input>
                </p:wrap-sequence>
                <p:xslt>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="fix-hrefs.xsl"/>
                    </p:input>
                </p:xslt>
            </p:for-each>
            <p:identity name="smil"/>
            
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="original-opf-with-fixed-hrefs"/>
                </p:input>
            </p:identity>
            <px:message message="[progress px:epub-upgrader.convert 10] Creating navigation document"/>
            <p:choose>
                <p:when test="/*/opf:manifest/opf:item[tokenize(@properties,'\s+')='nav']">
                    <px:message message="Using pre-existing navigation document"/>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                    
                </p:when>
                <p:otherwise>
                    <p:identity>
                        <p:input port="source">
                            <p:pipe port="result" step="spine"/>
                        </p:input>
                    </p:identity>
                    <px:message message="Creating navigation document table of contents"/>
                    <px:epub3-nav-create-toc name="nav-toc">
                        <p:with-option name="base-dir" select="replace(base-uri(),'[^/]+$','')">
                            <p:pipe port="result" step="original-opf-with-fixed-hrefs"/>
                        </p:with-option>
                    </px:epub3-nav-create-toc>
                    
                    <p:identity>
                        <p:input port="source">
                            <p:pipe port="result" step="spine"/>
                        </p:input>
                    </p:identity>
                    <px:message message="Creating navigation document page list"/>
                    <px:epub3-nav-create-page-list name="nav-page-list">
                        <p:with-option name="base-dir" select="replace(base-uri(),'[^/]+$','')">
                            <p:pipe port="result" step="original-opf-with-fixed-hrefs"/>
                        </p:with-option>
                    </px:epub3-nav-create-page-list>
                    
                    <p:identity>
                        <p:input port="source">
                            <p:pipe port="result" step="nav-toc"/>
                            <p:pipe port="result" step="nav-page-list"/>
                        </p:input>
                    </p:identity>
                    <px:message message="Combining navigation document table of contents and page list"/>
                    <px:epub3-nav-aggregate>
                        <p:with-option name="language" select="(/*/opf:metadata/dc:language[not(@refines)])[1]/text()">
                            <p:pipe port="result" step="original-opf-with-fixed-hrefs"/>
                        </p:with-option>
                    </px:epub3-nav-aggregate>
                    <p:identity name="nav-before-xml-base"/>
                    <p:xslt name="unique-nav-href">
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:inline>
                                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:opf="http://www.idpf.org/2007/opf" version="2.0">
                                    <xsl:template match="/*">
                                        <c:result>
                                            <xsl:variable name="href" select="(for $href in ('nav.xhtml',
                                                                                               'navigation.xhtml',
                                                                                               for $i in (0 to 99, //*/generate-id()) return (
                                                                                                   concat('nav-',$i,'.xhtml'),
                                                                                                   concat('navigation-',$i,'.xhtml'),
                                                                                                   concat('nav',$i,'.xhtml'),
                                                                                                   concat('navigation',$i,'.xhtml')))
                                                                                 return if (/*/opf:manifest/opf:item/@href = $href) then () else $href
                                                                                 )[1]"/>
                                            <xsl:value-of select="if ($href) then resolve-uri($href, base-uri(/*)) else ''"/>
                                        </c:result>
                                    </xsl:template>
                                </xsl:stylesheet>
                            </p:inline>
                        </p:input>
                    </p:xslt>
                    <p:add-attribute attribute-name="xml:base" match="/*">
                        <p:input port="source">
                            <p:pipe port="result" step="nav-before-xml-base"/>
                        </p:input>
                        <p:with-option name="attribute-value" select="/*/text()">
                            <p:pipe port="result" step="unique-nav-href"/>
                        </p:with-option>
                    </p:add-attribute>
                    
                </p:otherwise>
            </p:choose>
            <p:identity name="nav"/>
            
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="original-opf-with-fixed-hrefs"/>
                </p:input>
            </p:identity>
            <px:message message="Creating fileset of the spine documents based on the input package document (with fixed hrefs)"/>
            <p:xslt>
                <p:with-param name="spine-only" select="'true'"/>
                <p:input port="stylesheet">
                    <p:document href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/opf-manifest-to-fileset.xsl"/>
                </p:input>
            </p:xslt>
            <p:identity name="original-opf-spine-fileset">
                <p:log port="result"/>
            </p:identity>
            
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="opf-before-href-fix"/>
                </p:input>
            </p:identity>
            <px:message message="Listing files not referenced from the OPF"/>
            <p:xslt name="original-opf-fileset">
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/opf-manifest-to-fileset.xsl"/>
                </p:input>
            </p:xslt>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="fileset.in" step="main"/>
                    <p:pipe port="result" step="original-opf-fileset"/>
                </p:input>
            </p:identity>
            <px:fileset-exclusive/>
            <px:fileset-filter not-media-types="application/x-dtbncx+xml"/>
            <p:identity name="fileset-resources"/>
            
            <px:epub3-pub-create-package-doc compatibility-mode="false">
                <p:input port="spine-filesets">
                    <p:pipe port="result" step="original-opf-spine-fileset"/>
                </p:input>
                <p:input port="publication-resources">
                    <p:pipe port="result" step="original-opf-fileset-with-fixed-hrefs"/>
                </p:input>
                <p:input port="metadata" select="/*/opf:metadata">
                    <p:pipe port="result" step="original-opf-with-fixed-hrefs"/>
                </p:input>
                <p:input port="bindings">
                    <p:empty/>
                </p:input>
                <p:input port="content-docs">
                    <p:pipe port="result" step="all-content"/>
                    <p:pipe port="result" step="nav"/>
                </p:input>
                <p:input port="mediaoverlays">
                    <p:pipe port="result" step="smil"/>
                </p:input>
                <p:with-option name="nav-uri" select="base-uri(/*)">
                    <p:pipe port="result" step="nav"/>
                </p:with-option>
                <p:with-option name="cover-image" select="/*/opf:manifest/opf:item[tokenize(@properties,'\s+')='cover-image']/resolve-uri(@href,base-uri(.))">
                    <p:pipe port="result" step="original-opf-with-fixed-hrefs"/>
                </p:with-option>
                <p:with-option name="result-uri" select="base-uri(/*)">
                    <p:pipe port="result" step="original-opf-with-fixed-hrefs"/>
                </p:with-option>
            </px:epub3-pub-create-package-doc>
            <p:add-attribute match="/*" attribute-name="xml:base">
                <p:with-option name="attribute-value" select="base-uri(/*)">
                    <p:pipe port="result" step="original-opf-with-fixed-hrefs"/>
                </p:with-option>
            </p:add-attribute>
            <p:identity name="opf">
                <p:log port="result"/>
            </p:identity>
            
            <p:xslt name="opf-fileset">
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="source">
                    <p:pipe port="result" step="opf"/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/opf-manifest-to-fileset.xsl"/>
                </p:input>
            </p:xslt>
            <px:fileset-join>
                <p:input port="source">
                    <p:pipe port="result" step="opf-fileset"/>
                    <p:pipe port="result" step="fileset-resources"/>
                </p:input>
            </px:fileset-join>
            <p:identity name="fileset"/>
            
        </p:when>
        <p:otherwise>
            <p:output port="fileset.out" primary="true"/>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe port="in-memory.in" step="main"/>
            </p:output>
            <p:output port="report.out" sequence="true">
                <p:empty/>
            </p:output>
            
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
    <p:choose name="status">
        <p:xpath-context>
            <p:pipe port="status.in" step="main"/>
        </p:xpath-context>
        <p:when test="/*/@result='ok'">
            <p:output port="result"/>
            <px:validation-status>
                <p:input port="source">
                    <p:pipe port="report.out" step="choose"/>
                </p:input>
            </px:validation-status>
        </p:when>
        <p:otherwise>
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="status.in" step="main"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
