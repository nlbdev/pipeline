<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
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
    
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
    <!--<xsl:import href="../../../../../../common/file-utils/src/main/resources/xml/xslt/uri-functions.xsl"/>-->
    
    
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
                    <xsl:value-of select="substring(normalize-space($node),1,20)"/>
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
                    <xsl:choose>
                        <xsl:when test="$node[namespace-uri() = '' and local-name() = 'class' or namespace-uri() = 'http://www.idpf.org/2007/ops' and local-name() = 'type']">
                            <xsl:value-of select="f:normalize-tokens($node)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="replace(substring($node,1,20),'&quot;','&amp;quot;')"/>
                            <xsl:if test="string-length($node) &gt; 20">
                                <xsl:text>…</xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>"</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join($result,'')"/>
    </xsl:function>
    
    <xsl:template name="attach-error">
        <xsl:param name="node" select="." as="node()"/>
        <xsl:param name="desc" as="xs:string"/>
        <xsl:param name="href" select="f:filename($node, $node/ancestor-or-self::*[last()]/d:fileset/base-uri())" as="xs:string"/>
        <xsl:param name="was" select="''" as="xs:string"/>
        <xsl:param name="expected" select="''" as="xs:string"/>
        
        <xsl:variable name="message">
            <xsl:value-of select="replace($href,'\|','&amp;#124;')"/>
            <xsl:text> | </xsl:text>
            <xsl:value-of select="replace($desc,'\|','&amp;#124;')"/>
            <xsl:text> | </xsl:text>
            <xsl:value-of select="replace($was,'\|','&amp;#124;')"/>
            <xsl:text> | </xsl:text>
            <xsl:value-of select="replace($expected,'\|','&amp;#124;')"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="f:node-type($node) = 'attribute'">
                <xsl:attribute name="d:error-{generate-id($node)}" select="$message"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment select="concat('d:error ',$message)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="f:normalize-tokens" as="xs:string">
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:variable name="result">
            <xsl:for-each select="for $s in $strings return tokenize($s,'\s+')">
                <xsl:sort select="."/>
                <xsl:if test="position() &gt; 1">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($result,'')"/>
    </xsl:function>
    
    
    <!-- ############################################################# -->
    <!-- ########## Feilmeldinger for elementer uten regler ########## -->
    <!-- ############################################################# -->
    
    <xsl:template match="@* | node()" mode="#all">
        <xsl:choose>
            <xsl:when test="f:node-type(.) = 'element'">
                <xsl:copy>
                    <xsl:call-template name="attach-error">
                        <xsl:with-param name="desc" select="concat('Ingen regel for ',f:node-type(.))"/>
                        <xsl:with-param name="was" select="concat(f:xpath(.), ': ', f:node-content(.))"/>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
                <xsl:call-template name="attach-error">
                    <xsl:with-param name="desc" select="concat('Ingen regel for ',f:node-type(.))"/>
                    <xsl:with-param name="was" select="concat(f:xpath(.), ': ', f:node-content(.))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- ############################################################################## -->
    <!-- ########## Hoved-template som sjekker filsettet og plukker ut OPFen ########## -->
    <!-- ############################################################################## -->
    
    <xsl:template match="/c:wrapper">
        
        <!-- Finn META-INF/container.xml -->
        <xsl:variable name="ocf" select="/*/*[base-uri() = resolve-uri('META-INF/container.xml',/*/d:fileset/base-uri())]"/>
        <xsl:if test="count($ocf) = 0">
            <xsl:call-template name="attach-error">
                <xsl:with-param name="desc" select="'Finner ikke META-INF/container.xml'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="count($ocf/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml']) &gt; 1">
            <xsl:call-template name="attach-error">
                <xsl:with-param name="desc" select="'Multiple Rendition EPUB er ikke støttet'"/>
            </xsl:call-template>
        </xsl:if>
        
        <!-- Finn OPF -->
        <xsl:variable name="opf" select="/*/*[base-uri() = $ocf/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml']/resolve-uri(concat('../',@full-path),base-uri())]"/>
        <xsl:if test="count($opf) = 0">
            <xsl:call-template name="attach-error">
                <xsl:with-param name="desc" select="'Fant ingen OPF'"/>
            </xsl:call-template>
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
                    <xsl:call-template name="attach-error">
                        <xsl:with-param name="desc" select="concat(pf:relativize-uri(base-uri(),/*/d:fileset/base-uri()), ' er ikke referert til fra OPFen')"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        
        <xsl:for-each select="$opf/opf:manifest/opf:item[not(../../opf:spine/opf:itemref/@idref = @id) and @media-type='application/xhtml+xml']">
            <xsl:call-template name="attach-error">
                <xsl:with-param name="desc" select="'Dokumentet er ikke en del av boka'"/>
            </xsl:call-template>
        </xsl:for-each>
        
        <!-- Behandle XML-filer (OPF, HTML, etc.) -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            
            <xsl:copy-of select="* except (* | opf:* | ncx:*)"/>
            
            <xsl:for-each select="* | opf:* | ncx:*">
                <xsl:choose>
                    <xsl:when test="base-uri() = $opf/opf:manifest/opf:item[tokenize(@properties,'\s+') = 'nav']/resolve-uri(@href,.)">
                        <!-- Navigation Document behandles i egen modus for å skille det fra andre HTML-filer -->
                        <xsl:apply-templates select="." mode="nav"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- Tillat xml:base på alle top-level elementer -->
    <xsl:template match="/*/*/@xml:base">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- ############ -->
    <!-- Behandle OPF -->
    <!-- ############ -->
    
    <xsl:template match="opf:package">
        <xsl:copy>
            <xsl:attribute name="version" select="'3.1'"/>
            <xsl:apply-templates select="@* except @version"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opf:package/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="opf:package/@unique-identifier | opf:package/@prefix">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:package/opf:metadata">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opf:metadata/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:metadata/dc:identifier">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dc:identifier/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dc:identifier/@id | dc:identifier/@opf:scheme">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:metadata/dc:title">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dc:title/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dc:title/@id">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:metadata/dc:language">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dc:language/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dc:language/@id">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:metadata/dc:publisher">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dc:publisher/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dc:publisher/@id">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:metadata/dc:creator">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dc:creator/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dc:creator/@id | dc:creator/@opf:role">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:metadata/dc:contributor">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dc:contributor/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dc:contributor/@id | dc:contributor/@opf:role">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:metadata/dc:date[not(@opf:event) or @opf:event=('publication','original-publication')]">
        <xsl:copy>
            <xsl:apply-templates select="@* except @opf:event"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opf:metadata/dc:date[@opf:event=('modification')]">
        <xsl:element name="meta" namespace="http://www.idpf.org/2007/opf">
            <xsl:attribute name="property" select="'dcterms:modified'"/>
            <xsl:apply-templates select="@* except @opf:event"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="opf:metadata/dc:date[@opf:event=('creation','epub-creation')]">
        <xsl:element name="meta" namespace="http://www.idpf.org/2007/opf">
            <xsl:attribute name="property" select="'dcterms:created'"/>
            <xsl:apply-templates select="@* except @opf:event"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dc:date/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dc:date/@id">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:metadata/opf:meta[@property]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opf:metadata/opf:meta[@name]">
        <!-- OPF 2-metadata -->
        <xsl:choose>
            <xsl:when test="../opf:meta[not(@refines) and @property = current()/@name and text() = current()/@content]">
                <!-- Identisk metadata finnes allerede med OPF 3-syntaks; ignorer dette elementet -->
            </xsl:when>
            <xsl:otherwise>
                <!-- Skriv om metadataen til OPF 3-syntaks -->
                <xsl:copy>
                    <xsl:attribute name="property" select="@name"/>
                    <xsl:apply-templates select="@* except (@name, @content)"/>
                    <xsl:value-of select="@content"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="opf:meta/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="opf:meta/@id | opf:meta/@property">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:package/opf:manifest">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opf:manifest/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:item[@media-type = 'application/x-dtbncx+xml']">
        <!-- Fjern NCX fra manifestet -->
    </xsl:template>
    <xsl:template match="opf:item">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opf:item/@id | opf:item/@media-type | opf:item/@href | opf:item/@properties">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:package/opf:spine">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opf:spine/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="opf:spine/@toc">
        <!-- Fjern referanse til NCX -->
    </xsl:template>
    
    <xsl:template match="opf:itemref">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opf:itemref/@id | opf:itemref/@idref | opf:itemref/@linear">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="opf:guide">
        <!-- Fjern guide element -->
    </xsl:template>
    
    
    <!-- ############# -->
    <!-- Behandle NCX  -->
    <!-- ############# -->
    
    <xsl:template match="ncx:ncx">
        <!-- Ikke inkluder NCX i resultatet -->
    </xsl:template>
    
    
    <!-- ############# -->
    <!-- Behandle HTML -->
    <!-- ############# -->
    
    <xsl:template match="html">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="html/@xml:lang | html/@lang">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="html/@version">
        <!-- attributt generert av HTML 4 DTD; fjernes -->
    </xsl:template>
    
    <xsl:template match="html/head">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="head/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="head/meta">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="meta/@http-equiv[lower-case(.)='content-type' and matches(parent::*/@content,'^text/html;\s*charset=.*[Uu][Tt][Ff]-8$')]">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="meta/@name | meta/@content">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="head/title">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="title/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="head/link">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="link[@rel='stylesheet' and @type='text/css']/@rel">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="link[@rel='stylesheet' and @type='text/css']/@type">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="link[@rel='stylesheet' and @type='text/css']/@href">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="head/script">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="script/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="script[string(@type)=('','text/javascript')]/@type">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="script[string(@type)=('','text/javascript')]/@src">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="script/@xml:space">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="head/style">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="style/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="style/@type[.='text/css']">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="html/body">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="body/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/div | div/div">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="div/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="div/@id | div/@class | div/@style">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/p | div/p">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="p/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="p/@style | p/@class">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/img | div/img | p/img | td/img">
        <xsl:choose>
            <xsl:when test="count(@*) = 0">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="img[@src and count(@alt) &gt; 0]/@src">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="img[@src and count(@alt) &gt; 0]/@alt">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="img/@id | img/@style | img/@class">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/span | div/span | p/span | td/span | span/span | em/span | strong/span | b/span | i/span | sup/span | a/span">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="span/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="span/@id | span/@style | span/@class">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/strong | div/strong | p/strong | td/strong | span/strong | em/strong | strong/strong | b/strong | i/strong | sup/strong | a/strong">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="strong/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="strong/@id | strong/@style | strong/@class">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/em | div/em | p/em | td/em | span/em | em/em | strong/em | b/em | i/em | sup/em | a/em">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="em/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="em/@id | em/@style | em/@class">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/b | div/b | p/b | td/b | span/b | em/b | strong/b | b/b | i/b | sup/b | a/b">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="b/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="b/@id | b/@style | b/@class">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/i | div/i | p/i | td/i | span/i | em/i | strong/i | b/i | i/i | sup/i | a/i">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="i/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="i/@id | i/@style | i/@class">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/sup | div/sup | p/sup | td/sup | span/sup | em/sup | strong/sup | b/sup | i/sup | sup/sup | a/sup">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="sup/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="sup/@id | sup/@style | sup/@class">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/a | div/a | p/a | em/a | td/a | span/a | em/a | strong/a | b/a | i/a | sup/a">
        <xsl:choose>
            <xsl:when test="ancestor::a">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="a/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="a/@id | a/@href | a/@class | a/@title | a/@style">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="h1 | h2 | h3 | h4 | h5 | h6">
        <xsl:choose>
            <xsl:when test="parent::body | parent::div">
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="h1/text() | h2/text() | h3/text() | h4/text() | h5/text() | h6/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="html:*[matches(local-name(),'^h\d$')]/@class | html:*[matches(local-name(),'^h\d$')]/@id | html:*[matches(local-name(),'^h\d$')]/@style">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="body/table | div/table">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="table/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="table/@id | table/@class | table/@style">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="table/thead">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="thead/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="thead/@id | thead/@class | thead/@style">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="table/tfoot">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tfoot/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="tfoot/@id | tfoot/@class | tfoot/@style">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="table/tbody">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tbody/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="tbody/@id | tbody/@class | tbody/@style">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="table/tr | thead/tr | tfoot/tr | tbody/tr">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tr/text()[normalize-space()='']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="tr/@id | tr/@class | tr/@style">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="tr/th">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="th/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="th/@id | th/@class | th/@style | th/@colspan | th/@rowspan">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="tr/td">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="td/text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="td/@id | td/@class | td/@style | td/@colspan | td/@rowspan">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="p/br | div/br | h1/br | h2/br | h3/br | h4/br | h5/br | h6/br | td/br | span/br | em/br | strong/br | i/br | b/br">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="body/hr | div/hr">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="hr/@class">
        <xsl:copy-of select="."/>
    </xsl:template>
    
</xsl:stylesheet>
