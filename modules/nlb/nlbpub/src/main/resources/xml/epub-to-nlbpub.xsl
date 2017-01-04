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
                exclude-result-prefixes="#all"
                version="2.0">
    
    <!--
        Input-dokumentet er et Pipeline 2 filesett og alle XML-filene i EPUBen. Feks.:
        
        ```
        <c:wrapper>
            <d:fileset xml:base="file:/tmp/epub/">
                <d:file href="META-INF/container.xml" media-type="application/xml"/>
                <d:file href="EPUB/package.opf" media-type="application/oebps-package+xml"/>
                <d:file href="EPUB/nav.xhtml" media-type="application/xhtml+xml"/>
                <d:file href="EPUB/content.xhtml" media-type="application/xhtml+xml"/>
            </d:fileset>
            <container xml:base="file:/tmp/epub/EPUB/package.opf">...</container>
            <package xml:base="file:/tmp/epub/EPUB/package.opf">...</package>
            <html xml:base="file:/tmp/epub/EPUB/nav.xhtml">...</html>
            <html xml:base="file:/tmp/epub/EPUB/content.xhtml">...</html>
        </c:wrapper>
        ```
        
        - Filsettet er tilgjengeling gjennom `/*/d:fileset`
        - Alle XML-filene er tilgjengelig gjennom `$collection`
        - Alle XML-filene ahr en /*/@xml:base attributt som kan brukes for å sammenligne referanse
        - `pf:relativize-uri(uri, base)` er en nyttig funksjon for å sammenligne relative referanser
    -->
    
    <!--<xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>-->
    <xsl:import href="../../../../../../common/file-utils/src/main/resources/xml/xslt/uri-functions.xsl"/>
    
    
    <!-- ############################################################# -->
    <!-- ########## Feilmeldinger for elementer uten regler ########## -->
    <!-- ############################################################# -->
    
    <xsl:template match="@* | node()" mode="#all">
        <xsl:message terminate="yes" select="concat(f:filename(., /*/d:fileset/base-uri()),' (',f:xpath(.),'): Ingen regel for ',f:node-type(.),' her; &quot;',f:node-content(.),'&quot;')"/>
    </xsl:template>
    
    
    <!-- ############################################################################## -->
    <!-- ########## Hoved-template som sjekker filsettet og plukker ut OPFen ########## -->
    <!-- ############################################################################## -->
    
    <xsl:template match="/c:wrapper">
        
        <!-- Finn META-INF/container.xml -->
        <xsl:variable name="ocf" select="/*/*[base-uri() = resolve-uri('META-INF/container.xml',/*/d:fileset/base-uri())]"/>
        <xsl:if test="count($ocf) = 0">
            <xsl:message terminate="yes" select="'Finner ikke META-INF/container.xml'"/>
        </xsl:if>
        <xsl:if test="count($ocf/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml']) &gt; 1">
            <xsl:message terminate="yes" select="'Multiple Rendition EPUB er ikke støttet'"/>
        </xsl:if>
        
        <!-- Finn OPF -->
        <xsl:message select="$ocf/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml']/resolve-uri(concat('../',@full-path),base-uri())"/>
        <xsl:variable name="opf" select="/*/*[base-uri() = $ocf/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml']/resolve-uri(concat('../',@full-path),base-uri())]"/>
        <xsl:if test="count($opf) = 0">
            <xsl:message terminate="yes" select="'Fant ingen OPF'"/>
        </xsl:if>
        
        <!-- Sjekk at alle XML-filene er referert til fra OPFen -->
        <xsl:for-each select="/*/* except /*/d:fileset">
            <xsl:choose>
                <xsl:when test="base-uri() = $opf/base-uri()">
                    <!-- OPFen refererer ikke til seg selv -->
                </xsl:when>
                <xsl:when test="substring-after(base-uri(), /*/d:fileset/base-uri()) = (
                                                                                        'mimetype',
                                                                                        'META-INF/container.xml',
                                                                                        'META-INF/encryption.xml',
                                                                                        'META-INF/manifest.xml',
                                                                                        'META-INF/metadata.xml',
                                                                                        'META-INF/rights.xml',
                                                                                        'META-INF/signatures.xml'
                                                                                        )">
                    <!-- Disse filene er definert i OCF-standarden, og refereres ikke til fra OPFen -->
                </xsl:when>
                <xsl:when test="not(base-uri() = $opf/opf:manifest/opf:item/resolve-uri(@href,base-uri()))">
                    <xsl:message terminate="yes" select="concat(pf:relativize-uri(base-uri(),/*/d:fileset/base-uri()), ' er ikke referert til fra OPFen')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        
        <!-- Behandle XML-filer (OPF, HTML, etc.) -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            
            <xsl:copy-of select="* except (html:* | opf:* | ncx:*)"/>
            
            <xsl:apply-templates select="html:* | opf:* | ncx:*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/*/*/@xml:base">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- ############ -->
    <!-- Behandle OPF -->
    <!-- ############ -->
    
    <xsl:template match="opf:package | opf:metadata | opf:manifest | opf:spine | opf:item | opf:itemref | opf:metadata/dc:* | opf:metadata/opf:meta">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="opf:package/@version | opf:package/@unique-identifier | opf:package/@prefix">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:metadata/dc:*/@id | opf:metadata/dc:*/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:meta/@id | opf:meta/@property | opf:meta[@property]/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:meta[@name]">
        <!-- OPF 2-metadata -->
        <xsl:choose>
            <xsl:when test="../opf:meta[not(@refines) and @property = current()/@name and text() = current()/@content]">
                <!-- Metadataen finnes alleredemed OPF 3-syntaks; ignorer dette elementet -->
            </xsl:when>
            <xsl:otherwise>
                <!-- Skriv om metadataen til OPF 3-syntaks -->
                <xsl:copy>
                    <xsl:attribute name="property" select="@name"/>
                    <xsl:value-of select="@content"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="opf:item/@id | opf:item/@media-type | opf:item/@href | opf:item/@properties">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:item[@media-type = 'application/x-dtbncx+xml']">
        <!-- Fjern NCX fra manifestet -->
    </xsl:template>
    
    <xsl:template match="opf:itemref/@id | opf:itemref/@idref | opf:itemref/@linear">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:spine/@toc">
        <!-- Fjern referanse til NCX -->
    </xsl:template>
    
    
    <!-- ############# -->
    <!-- Behandle HTML -->
    <!-- ############# -->
    
    <xsl:template match="ncx:ncx">
        <!-- Ikke inkluder NCX i resultatet -->
    </xsl:template>
    
    
    <!-- ############# -->
    <!-- Behandle HTML -->
    <!-- ############# -->
    
    <xsl:template match="html:html">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:head">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:head/html:title">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:head/html:meta">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:head/html:style">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:head/html:link">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:head/html:script">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:body">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:h1 | html:h2 | html:h3 | html:h4 | html:h5 | html:h6">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:span | html:pre | html:code | html:abbr">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="html:p">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:ul | html:ol">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:ul/html:li | html:ol/html:li">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:img">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:img/@src | html:img/@alt">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="html:*/@id | html:*/@class">
        <xsl:choose>
            <xsl:when test="parent::*/local-name() = ('body', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'span', 'pre', 'code', 'abbr', 'li', 'img')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="html:*/text()">
        <xsl:choose>
            <xsl:when test="parent::*/local-name() = ('title', 'style', 'script', 'body', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'span', 'pre', 'code', 'abbr', 'li')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ################# -->
    <!-- Hjelpe-funksjoner -->
    <!-- ################# -->
    
    <xsl:function name="f:filename" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="base" as="xs:string"/>
        <xsl:value-of select="pf:relativize-uri($node/base-uri(), $base)"/>
    </xsl:function>
    
    <xsl:function name="f:xpath" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:value-of select="concat(string-join(($node/ancestor-or-self::* except $node/ancestor::*[last()])/name(), '/'), if ($node/self::*) then '' else concat('/', f:node-type($node), '()'))"/>
    </xsl:function>
    
    <xsl:function name="f:node-type" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:choose>
            <xsl:when test="count($node|root($node))=1">
                <xsl:text>document</xsl:text>
            </xsl:when>
            <xsl:when test="$node/self::*">
                <xsl:text>element</xsl:text>
            </xsl:when>
            <xsl:when test="$node/self::text()">
                <xsl:text>text</xsl:text>
            </xsl:when>
            <xsl:when test="$node/self::comment()">
                <xsl:text>comment</xsl:text>
            </xsl:when>
            <xsl:when test="$node/self::processing-instruction()">
                <xsl:text>processing-instruction</xsl:text>
            </xsl:when>
            <xsl:when test="$node/count(.|../@*)=$node/count(../@*)">
                <xsl:text>attribute</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:node-content" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="node-type" select="f:node-type($node)"/>
        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="$node-type = 'document'">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$node-type = 'element'">
                    <xsl:text>&lt;</xsl:text>
                    <xsl:value-of select="$node/name()"/>
                    <xsl:if test="count($node/@*)">
                        <xsl:text> …</xsl:text>
                    </xsl:if>
                    <xsl:if test="count($node/node()) = 0">
                        <xsl:text>/</xsl:text>
                    </xsl:if>
                    <xsl:text>&gt;</xsl:text>
                    <xsl:if test="count($node/node())">
                        <xsl:text>…&lt;/</xsl:text>
                        <xsl:value-of select="$node/name()"/>
                        <xsl:text>&gt;</xsl:text>
                    </xsl:if>
                    
                </xsl:when>
                <xsl:when test="$node-type = 'text'">
                    <xsl:value-of select="substring($node,1,20)"/>
                    <xsl:if test="string-length($node) &gt; 20">
                        <xsl:text>…</xsl:text>
                    </xsl:if>
                    
                </xsl:when>
                <xsl:when test="$node-type = 'comment'">
                    <xsl:value-of select="substring($node,1,20)"/>
                    <xsl:if test="string-length($node) &gt; 20">
                        <xsl:text>…</xsl:text>
                    </xsl:if>
                    
                </xsl:when>
                <xsl:when test="$node-type = 'processing-instruction'">
                    <xsl:text>&lt;?</xsl:text>
                    <xsl:value-of select="$node/name()"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="substring($node,1,20)"/>
                    <xsl:if test="string-length($node) &gt; 20">
                        <xsl:text>…</xsl:text>
                    </xsl:if>
                    <xsl:text>?&gt;</xsl:text>
                    
                </xsl:when>
                <xsl:when test="$node-type = 'attribute'">
                    <xsl:value-of select="$node/name()"/>
                    <xsl:text>="</xsl:text>
                    <xsl:value-of select="replace(substring($node,1,20),'&quot;','&amp;quot;')"/>
                    <xsl:if test="string-length($node) &gt; 20">
                        <xsl:text>…</xsl:text>
                    </xsl:if>
                    <xsl:text>"</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join($result,'')"/>
    </xsl:function>
    
</xsl:stylesheet>
