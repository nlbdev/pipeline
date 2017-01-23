<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-to-pef.convert" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>
    <p:output port="fileset.out" primary="true">
        <p:pipe port="result" step="fileset.out"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="result" step="in-memory.out"/>
    </p:output>
    <p:output port="obfl" sequence="true"> <!-- sequence=false when include-obfl=true -->
        <p:pipe step="transform" port="obfl"/>
    </p:output>
    
    <p:input kind="parameter" port="parameters" sequence="true">
        <p:inline>
            <c:param-set/>
        </p:inline>
    </p:input>
    
    <p:option name="default-stylesheet" select="'http://www.daisy.org/pipeline/modules/braille/epub3-to-pef/css/default.css'"/>
    <p:option name="stylesheet" select="''"/>
    <p:option name="apply-document-specific-stylesheets" select="'false'"/>
    <p:option name="transform" select="'(translator:liblouis)(formatter:dotify)'"/>
    <p:option name="include-obfl" select="'false'"/>
    
    <!-- Empty temporary directory dedicated to this conversion -->
    <p:option name="temp-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl"/>
    
    <!-- Ensure that there's exactly one c:param-set -->
    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="parameters"/>
        </p:input>
    </p:identity>
    <px:message message="[progress px:epub3-to-pef.convert 1 px:merge-parameters]"/>
    <px:merge-parameters name="parameters"/>
    
    <!-- Load OPF and add content files to fileset. -->
    <p:identity>
        <p:input port="source">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
    </p:identity>
    <px:message message="[progress px:epub3-to-pef.convert 1 px:epub-load-opf]"/>
    <px:epub-load-opf>
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:epub-load-opf>
    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="base-uri(/*)"/>
    </p:add-attribute>
    <p:identity name="opf"/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="result" step="opf"/>
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
    </p:identity>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/opf-manifest-to-fileset.xsl"/>
        </p:input>
    </p:xslt>
    <px:mediatype-detect/>
    <px:fileset-filter media-types="text/css text/scss"/>
    <px:message message="Storing CSS files to disk so that they can be retrieved during inlining."/>
    <px:fileset-store name="store-css-files">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-store>
    
    <!-- Load XHTML documents in spine order. -->
    <p:identity cx:depends-on="store-css-files">
        <p:input port="source">
            <p:pipe port="result" step="opf"/>
        </p:input>
    </p:identity>
    <px:message message="[progress px:epub3-to-pef.convert 2 px:epub-load-spine] Load XHTML documents in spine order."/>
    <px:epub-load-spine>
        <p:input port="fileset">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:epub-load-spine>
    
    <!-- In case there exists any CSS in the EPUB already, and $apply-document-specific-stylesheets = 'true',  then inline that CSS. -->
    <px:message cx:depends-on="parameters" message="[progress px:epub3-to-pef.convert 9 px:epub3-to-pef.convert.apply-document-specific-stylesheets] Processing CSS that is already present in the EPUB"/>
    <p:for-each>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="base-uri(/*)"/>
        </p:add-attribute>
        
        <px:message>
            <p:with-option name="message" select="concat('Deleting CSS that is not for embossed media from ',replace(base-uri(/*),'.*/',''),'')"/>
        </px:message>
        <p:delete match="//@style | //html:link[@rel='stylesheet' and not(string(@media)='embossed')] | //html:style[not(string(@media)='embossed')]"/>
        
        <px:message>
            <p:with-option name="message" select="concat('[progress px:epub3-to-pef.convert.apply-document-specific-stylesheets 1/',p:iteration-size(),' px:apply-stylesheets]')"/>
        </px:message>
        <p:choose>
            <p:when test="$apply-document-specific-stylesheets='true'">
                <px:message>
                    <p:with-option name="message" select="concat('Inlining document-specific CSS for ',replace(base-uri(/*),'.*/',''),'')"/>
                </px:message>
                <p:group>
                    <!-- <link> not supported in css:inline so we provide the URIs to them explicitly -->
                    <p:variable name="linked-stylesheets" select="string-join(//html:link[@rel='stylesheet' and @media='embossed']/resolve-uri(@href,base-uri(/*)), ' ')"/>
                    <p:delete match="//html:link[@rel='stylesheet' and @media='embossed']"/>
                    <px:apply-stylesheets>
                        <p:with-option name="stylesheets" select="$linked-stylesheets"/>
                        <p:input port="parameters">
                            <p:pipe port="result" step="parameters"/>
                        </p:input>
                    </px:apply-stylesheets>
                </p:group>
            </p:when>
            <p:otherwise>
                <p:delete match="//html:link[@rel='stylesheet' and @media='embossed']"/>
            </p:otherwise>
        </p:choose>
        
        <p:filter select="/*/html:body"/>
    </p:for-each>
    <p:identity name="spine-bodies"/>
    
    <!-- Convert OPF metadata to HTML metadata. -->
    <p:identity>
        <p:input port="source">
            <p:pipe port="result" step="opf"/>
        </p:input>
    </p:identity>
    <px:message message="[progress px:epub3-to-pef.convert 1 opf-to-html-head.xsl] Convert OPF metadata to HTML metadata."/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/opf-to-html-head.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:identity name="opf-as-head"/>
    
    <!-- Create a new HTML document with <head> based on the OPF and all <body> elements from the input HTML documents -->
    <p:wrap-sequence wrapper="html" wrapper-namespace="http://www.w3.org/1999/xhtml">
        <p:input port="source">
            <p:pipe port="result" step="opf-as-head"/>
            <p:pipe port="result" step="spine-bodies"/>
        </p:input>
    </p:wrap-sequence>
    
    <px:message cx:depends-on="parameters" message="[progress px:epub3-to-pef.convert 1 generate-toc.xsl] Generating table of contents"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/generate-toc.xsl"/>
        </p:input>
        <p:with-param name="depth" select="/*/*[@name='toc-depth']/@value">
            <p:pipe step="parameters" port="result"/>
        </p:with-param>
    </p:xslt>
    
    <px:message cx:depends-on="parameters" message="[progress px:epub3-to-pef.convert 10 px:apply-stylesheets] Inlining global CSS"/>
    <p:group>
        <p:variable name="first-css-stylesheet"
                    select="tokenize($stylesheet,'\s+')[matches(.,'\.s?css$')][1]"/>
        <p:variable name="first-css-stylesheet-index"
                    select="(index-of(tokenize($stylesheet,'\s+')[not(.='')], $first-css-stylesheet),10000)[1]"/>
        <p:variable name="stylesheets-to-be-inlined"
                    select="string-join((
                              (tokenize($stylesheet,'\s+')[not(.='')])[position()&lt;$first-css-stylesheet-index],
                              $default-stylesheet,
                              resolve-uri('../../css/default.scss'),
                              (tokenize($stylesheet,'\s+')[not(.='')])[position()&gt;=$first-css-stylesheet-index]),' ')">
            <p:inline><_/></p:inline>
        </p:variable>
        <px:message>
            <p:with-option name="message" select="concat('stylesheets: ',$stylesheets-to-be-inlined)"/>
        </px:message>
        <px:apply-stylesheets>
            <p:with-option name="stylesheets" select="$stylesheets-to-be-inlined"/>
            <p:input port="parameters">
                <p:pipe port="result" step="parameters"/>
            </p:input>
        </px:apply-stylesheets>
    </p:group>
    
    <p:group cx:depends-on="parameters">
        <p:variable name="lang" select="(/*/opf:metadata/dc:language[not(@refines)])[1]/text()">
            <p:pipe port="result" step="opf"/>
        </p:variable>
        <p:variable name="transform-query" select="concat('(input:css)(output:pef)',$transform,'(locale:',$lang,')')">
            <p:pipe step="parameters" port="result"/>
        </p:variable>
        
        <px:message cx:depends-on="opf" message="[progress px:epub3-to-pef.convert 10 px:epub3-to-pef.convert.viewport-math] Transforming MathML"/>
        <p:viewport match="math:math">
            <px:message>
                <p:with-option name="message" select="concat('[progress px:epub3-to-pef.convert.viewport-math 1/',p:iteration-size(),' px:transform]')"/>
            </px:message>
            <px:transform>
                <p:with-option name="query" select="concat('(input:mathml)(locale:',$lang,')')"/>
                <p:with-option name="temp-dir" select="$temp-dir"/>
            </px:transform>
        </p:viewport>
    </p:group>
    
    <p:choose name="transform">
        <p:variable name="lang" select="(/*/opf:metadata/dc:language[not(@refines)])[1]/text()">
            <p:pipe port="result" step="opf"/>
        </p:variable>
        <p:when test="$include-obfl='true'">
            <p:output port="pef" primary="true"/>
            <p:output port="obfl">
                <p:pipe step="obfl" port="result"/>
            </p:output>
            <p:group name="obfl">
                <p:output port="result"/>
                <p:variable name="transform-query" select="concat('(input:css)(output:obfl)',$transform,'(locale:',$lang,')')"/>
                <px:message>
                    <!-- if $transform-query contains 'dotify'; use 'px:dotify-transform' as progress substep since there's currently no way to
                         send messages from java to the execution log. See: https://github.com/daisy/pipeline-issues/issues/477 -->
                    <p:with-option name="message" select="concat('[progress px:epub3-to-pef.convert 31 ',(if (contains($transform-query,'dotify')) then 'px:dotify-transform' else 'px:transform'),'] Transforming from XML with inline CSS to OBFL')"/>
                </px:message>
                <px:message severity="DEBUG">
                    <p:with-option name="message" select="concat('px:transform query=',$transform-query)"/>
                </px:message>
                <px:transform>
                    <p:with-option name="query" select="$transform-query"/>
                    <p:with-option name="temp-dir" select="$temp-dir"/>
                    <p:input port="parameters">
                        <p:pipe port="result" step="parameters"/>
                    </p:input>
                </px:transform>
            </p:group>
            <p:group>
                <p:variable name="transform-query" select="concat('(input:obfl)(input:text-css)(output:pef)',$transform,'(locale:',$lang,')')"/>
                <px:message>
                    <!-- if $transform-query contains 'dotify'; use 'px:dotify-transform' as progress substep since there's currently no way to
                         send messages from java to the execution log. See: https://github.com/daisy/pipeline-issues/issues/477 -->
                    <p:with-option name="message" select="concat('[progress px:epub3-to-pef.convert 30 ',(if (contains($transform-query,'dotify')) then 'px:dotify-transform' else 'px:transform'),'] Transforming from OBFL to PEF')"/>
                </px:message>
                <px:message severity="DEBUG">
                    <p:with-option name="message" select="concat('px:transform query=',$transform-query)"/>
                </px:message>
                <px:transform>
                    <p:with-option name="query" select="$transform-query"/>
                    <p:with-option name="temp-dir" select="$temp-dir"/>
                    <p:input port="parameters">
                        <p:pipe port="result" step="parameters"/>
                    </p:input>
                </px:transform>
            </p:group>
        </p:when>
        <p:otherwise>
            <p:output port="pef" primary="true"/>
            <p:output port="obfl">
                <p:empty/>
            </p:output>
            
            <p:group>
                <p:variable name="transform-query" select="concat('(input:css)(output:pef)',$transform,'(locale:',$lang,')')"/>
                <px:message>
                    <!-- if $transform-query contains 'dotify'; use 'px:dotify-transform' as progress substep since there's currently no way to
                         send messages from java to the execution log. See: https://github.com/daisy/pipeline-issues/issues/477 -->
                    <p:with-option name="message" select="concat('[progress px:epub3-to-pef.convert 61 ',(if (contains($transform-query,'dotify')) then 'px:dotify-transform' else 'px:transform'),'] Transforming from XML with inline CSS to PEF')"/>
                </px:message>
                <px:message>
                    <p:with-option name="message" select="concat('px:transform query=',$transform-query)"/>
                </px:message>
                <px:transform>
                    <p:with-option name="query" select="$transform-query"/>
                    <p:with-option name="temp-dir" select="$temp-dir"/>
                    <p:input port="parameters">
                        <p:pipe port="result" step="parameters"/>
                    </p:input>
                </px:transform>
            </p:group>
        </p:otherwise>
    </p:choose>
    <p:identity name="pef"/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="pef" port="result"/>
            <p:pipe step="opf" port="result"/>
        </p:input>
    </p:identity>
    <px:message message="[progress px:epub3-to-pef.convert 1 add-opf-metadata-to-pef.xsl] Adding metadata to PEF based on EPUB 3 package document metadata"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/braille/pef-utils/add-opf-metadata-to-pef.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <!-- add xml:lang -->
    <p:group>
        <p:variable name="lang" select="(/*/opf:metadata/dc:language[not(@refines)])[1]/text()">
            <p:pipe port="result" step="opf"/>
        </p:variable>
        <p:choose>
            <p:when test="not($lang='und')">
                <p:add-attribute match="/*" attribute-name="xml:lang">
                    <p:with-option name="attribute-value" select="$lang"/>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:group>
    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="replace(base-uri(/*),'[^/]+$',concat(((/*/opf:metadata/dc:identifier[not(@refines)]/text()), 'pef')[1],'.pef'))">
            <p:pipe port="result" step="opf"/>
        </p:with-option>
    </p:add-attribute>
    <p:identity name="in-memory.out"/>
    
    <px:fileset-create>
        <p:with-option name="base" select="replace(base-uri(/*),'[^/]+$','')"/>
    </px:fileset-create>
    <px:message cx:depends-on="in-memory.out" message="[progress px:epub3-to-pef.convert 1 px:fileset-add-entry]"/>
    <px:fileset-add-entry media-type="application/x-pef+xml">
        <p:with-option name="href" select="base-uri(/*)">
            <p:pipe port="result" step="in-memory.out"/>
        </p:with-option>
    </px:fileset-add-entry>
    <p:identity name="fileset.out"/>
    
</p:declare-step>