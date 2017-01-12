<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                type="px:epub-load"
                version="1.0">

    <p:output port="fileset" primary="true">
        <p:pipe port="result" step="fileset"/>
    </p:output>
    <p:output port="opf">
        <p:pipe port="result" step="opf"/>
    </p:output>

    <p:option name="href" required="true">
        <p:documentation>Reference to EPUB file, or if the EPUB is unzipped; either its package document, its container.xml, or its root directory.</p:documentation>
    </p:option>
    <p:option name="output-dir" required="true">
        <p:documentation>The directory where the EPUB will be unzipped, or if already unzipped; where the fileset will be moved to (not physically - see px:fileset-move).</p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl"/>

    <p:variable name="outputDir" select="if (not(ends-with($output-dir,'/'))) then concat($output-dir,'/') else $output-dir"/>
    <p:variable name="resolvedHref" select="resolve-uri($href,base-uri(/*))">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>
    
    <px:info name="href-info">
        <p:with-option name="href" select="$resolvedHref"/>
    </px:info>
    
    <p:choose>
        <p:when test="/c:directory">
            <px:fileset-from-dir>
                <p:with-option name="path" select="$resolvedHref"/>
            </px:fileset-from-dir>
            <px:mediatype-detect/>
            <px:message>
                <p:with-option name="message" select="concat('Root directory used for EPUB fileset: &quot;',/*/base-uri(),'&quot;')"/>
            </px:message>
        </p:when>
        <p:otherwise>
            <px:fileset-create>
                <p:with-option name="base" select="replace($resolvedHref,'[^/]+$','')"/>
            </px:fileset-create>
            <px:fileset-add-entry>
                <p:with-option name="media-type"
                    select="if (ends-with(lower-case($resolvedHref),'.opf')) then 'application/oebps-package+xml' else if (ends-with(lower-case($resolvedHref),'container.xml')) then 'application/xml' else 'application/epub+zip'"/>
                <p:with-option name="href" select="replace($resolvedHref,'^.*/([^/]*)$','$1')"/>
            </px:fileset-add-entry>
        </p:otherwise>
    </p:choose>
    <p:identity name="href-fileset"/>

    <p:choose>
        <p:when test="/*/d:file[@media-type='application/epub+zip']">
            <px:message>
                <p:with-option name="message" select="concat('Unzipping EPUB: &quot;',/*/d:file/@href,'&quot;')"/>
            </px:message>
            <px:fileset-unzip name="unzip" load-to-memory="false" store-to-disk="true">
                <p:with-option name="href" select="resolve-uri(/*/*/(@original-href,@href)[1],/*/*/base-uri(.))"/>
                <p:with-option name="unzipped-basedir" select="$outputDir"/>
            </px:fileset-unzip>
            <px:mediatype-detect>
                <p:input port="source">
                    <p:pipe port="fileset" step="unzip"/>
                </p:input>
            </px:mediatype-detect>

        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="href-fileset"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:identity name="unzipped-fileset"/>

    <p:choose>
        <p:xpath-context>
            <p:pipe port="result" step="href-fileset"/>
        </p:xpath-context>
        <p:when test="/*[count(*)=1]/d:file[@media-type='application/oebps-package+xml']">
            <px:message>
                <p:with-option name="message" select="concat('Loading OPF: &quot;',/*/d:file/@href,'&quot;')"/>
            </px:message>
            <px:fileset-load>
                <p:input port="fileset">
                    <p:pipe port="result" step="href-fileset"/>
                </p:input>
            </px:fileset-load>

        </p:when>
        <p:when test="not(/*/d:file[@href='META-INF/container.xml'])">
            <px:message>
                <p:with-option name="message" select="concat('Loading first OPF in fileset: &quot;',/*/d:file/@href,'&quot;')"/>
            </px:message>
            <p:delete match="/*/d:file[not(@media-type='application/oebps-package+xml')]"/>
            <p:delete match="/*/d:file[position() &gt; 1]"/>
            <px:fileset-load/>

        </p:when>
        <p:otherwise>
            <px:message>
                <p:with-option name="message" select="'Loading: &quot;META-INF/container.xml&quot;'"/>
            </px:message>
            <px:fileset-load href="META-INF/container.xml"/>
            <p:group>
                <p:variable name="full-path" select="(/ocf:container/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml'])[1]/@full-path"/>
                <px:message>
                    <p:with-option name="message" select="concat('Loading OPF referenced from META-INF/container.xml: &quot;',$full-path,'&quot;')"/>
                </px:message>
                <px:fileset-load>
                    <p:with-option name="href" select="if ($full-path) then $full-path else '.'"/>
                    <p:input port="fileset">
                        <p:pipe port="result" step="unzipped-fileset"/>
                    </p:input>
                </px:fileset-load>
            </p:group>

        </p:otherwise>
    </p:choose>
    <px:assert message="There must be a package document" test-count-min="1" test-count-max="1"/>
    <p:identity name="opf"/>

    <p:choose>
        <p:xpath-context>
            <p:pipe port="result" step="href-fileset"/>
        </p:xpath-context>
        <p:when test="/*/d:file[@media-type='application/epub+zip']">
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="unzipped-fileset"/>
                </p:input>
            </p:identity>

        </p:when>
        <p:otherwise>
            <px:message message="Creating fileset from OPF"/>
            <p:xslt name="fileset-from-opf">
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/opf-manifest-to-fileset.xsl"/>
                </p:input>
            </p:xslt>
            <px:fileset-join>
                <p:input port="source">
                    <p:pipe port="result" step="href-fileset"/>
                    <p:pipe port="result" step="fileset-from-opf"/>
                </p:input>
            </px:fileset-join>
            <px:mediatype-detect/>
            <px:fileset-move>
                <p:with-option name="new-base" select="$outputDir"/>
            </px:fileset-move>
        </p:otherwise>
    </p:choose>
    <p:identity name="fileset"/>

</p:declare-step>
