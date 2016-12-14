<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:pxp="http://exproc.org/proposed/steps"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                px:input-filesets="epub3"
                px:output-filesets="epub3"
                type="nlb:epub-to-nlbpub"
                name="main"
                xpath-version="2.0"
                version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">EPUB til NLBPUB</h1>
        <p px:role="desc">Konverterer en vilkårlig EPUB til NLBs EPUB-standard.</p>
    </p:documentation>
    
    <p:serialization port="html-report" method="xhtml" indent="true"/>

    <p:option name="epub" required="true" px:type="anyFileURI" px:media-type="application/epub+zip application/oebps-package+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">EPUB</h2>
        </p:documentation>
    </p:option>

    <p:option name="temp-dir" required="true" px:output="temp" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Mappe for midlertidige filer</h2>
        </p:documentation>
    </p:option>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">NLBPUB</h2>
        </p:documentation>
    </p:option>
    
    <p:output port="html-report" px:type="application/vnd.pipeline.report+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Valideringsrapport</h2>
            <p px:role="desc">En HTML-formatert valideringsrapport.</p>
        </p:documentation>
        <p:pipe port="result" step="html-report"/>
    </p:output>
    
    <p:output port="validation-status" px:type="application/vnd.pipeline.status+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Valideringsstatus</h1>
        </p:documentation>
        <p:pipe port="result" step="status"/>
    </p:output>

    <p:import href="nlbpub.validate.xpl"/>
    <p:import href="epub-to-nlbpub.convert.xpl"/>
    <p:import href="nlbpub-to-nordic.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epubcheck-adapter/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/validation-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl"/>

    <p:variable name="epub-href" select="resolve-uri($epub,base-uri(/*))">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>
    
    <p:variable name="outputDir" select="if (not(ends-with($output-dir,'/'))) then concat($output-dir,'/') else $output-dir"/>
    <p:variable name="tempDir" select="if (not(ends-with($temp-dir,'/'))) then concat($temp-dir,'/') else $temp-dir"/>
    
    <px:fileset-create>
        <p:with-option name="base" select="replace($epub-href,'[^/]+$','')"/>
    </px:fileset-create>
    <px:fileset-add-entry>
        <p:with-option name="media-type" select="if (tokenize(lower-case($epub-href),'\.|/')[last()]='opf') then 'application/oebps-package+xml' else 'application/epub+zip'"/>
        <p:with-option name="href" select="replace($epub-href,'^.*/([^/]*)$','$1')"/>
    </px:fileset-add-entry>
    
    <p:choose name="unzip">
        <p:when test="/*/d:file[@media-type='application/epub+zip']">
            <p:output port="fileset.out" primary="true">
                <p:pipe port="result" step="unzipped-fileset"/>
            </p:output>
            <p:output port="opf">
                <p:pipe port="result" step="unzipped-opf"/>
            </p:output>
            
            <px:message message="[progress 5 px:fileset-filter] Pakker ut EPUB"/>
            <px:fileset-filter media-types="application/epub+zip"/>
            <px:message message="Pakker ut EPUB"/>
            <px:fileset-unzip name="fileset-unzip" load-to-memory="false" store-to-disk="true">
                <p:with-option name="href" select="resolve-uri(/*/*/(@original-href,@href)[1],/*/*/base-uri(.))"/>
                <p:with-option name="unzipped-basedir" select="concat($tempDir,'epub/')"/>
            </px:fileset-unzip>
            <px:message message="Bestemmer filtyper"/>
            <px:mediatype-detect name="unzipped-fileset"/>
            
            <px:message message="Laster META-INF/container.xml"/>
            <px:fileset-load href="META-INF/container.xml" name="container"/>
            <px:assert message="Det må finnes nøyaktig én META-INF/container.xml" error-code="NLBPUB001" test-count-min="1" test-count-max="1"/>
            <px:message message="Laster OPF"/>
            <px:fileset-load>
                <p:with-option name="href" select="(/ocf:container/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml'])[1]/@full-path"/>
                <p:input port="fileset">
                    <p:pipe port="result" step="unzipped-fileset"/>
                </p:input>
            </px:fileset-load>
            <px:assert message="META-INF/container.xml må referere til minst én OPF-fil" error-code="NLBPUB002" test-count-min="1" test-count-max="1"/>
            <p:identity name="unzipped-opf"/>
            
        </p:when>
        <p:otherwise>
            <p:output port="fileset.out" primary="true"/>
            <p:output port="opf" primary="false">
                <p:pipe port="result" step="opf"/>
            </p:output>
            
            <px:message message="[progress 5] EPUB er allerede pakket ut"/>
            <px:message message="Laster OPF"/>
            <px:fileset-load media-types="application/oebps-package+xml" name="opf"/>
            <px:assert message="Det må finnes nøyaktig én OPF-fil" error-code="NLBPUB003" test-count-min="1" test-count-max="1"/>
            <px:message message="Lager liste over filer basert på OPF"/>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/opf-manifest-to-fileset.xsl"/>
                </p:input>
            </p:xslt>
            <px:message message="Bestemmer filtyper"/>
            <px:mediatype-detect/>
            <px:message message="Flytter til midlertidig mappe"/>
            <px:fileset-move>
                <p:with-option name="new-base" select="concat($tempDir,'epub/')"/>
            </px:fileset-move>
        </p:otherwise>
    </p:choose>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="opf" step="unzip"/>
        </p:input>
    </p:identity>
    <px:message message="[progress 30 px:epubcheck] Validerer EPUB i henhold til EPUB-standard"/>
    <px:epubcheck mode="opf">
        <p:with-option name="version" select="if (starts-with(/*/@version, '3')) then '3' else '2'"/>
        <p:with-option name="epub" select="base-uri(/*)"/>
    </px:epubcheck>
    <px:epubcheck-parse-report name="validate.epubcheck"/>
    <p:sink/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="fileset.out" step="unzip"/>
        </p:input>
    </p:identity>
    <px:message message="[progress 30 nlb:nlbpub.validate] Validerer EPUB i henhold til NLB-standard"/>
    <nlb:nlbpub.validate name="validate.nlbpub">
        <p:log port="fileset.out" href="file:/tmp/validate.nlbpub.fileset.out.xml"/>
        <p:log port="in-memory.out" href="file:/tmp/validate.nlbpub.in-memory.out.xml"/>
        <p:log port="report.out" href="file:/tmp/validate.nlbpub.report.out.xml"/>
        <p:log port="status.out" href="file:/tmp/validate.nlbpub.status.out.xml"/>
        <p:input port="in-memory.in">
            <p:pipe port="opf" step="unzip"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="xml-report" step="validate.epubcheck"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status" step="validate.epubcheck"/>
        </p:input>
    </nlb:nlbpub.validate>
    
    <px:message message="[progress 30 px:epub-to-nlbpub.convert] Normaliserer EPUB i henhold til NLB-standard"/>
    <nlb:epub-to-nlbpub.convert name="convert.nlbpub" fail-on-error="false">
        <p:log port="fileset.out" href="file:/tmp/epub-to-nlbpub.convert.fileset.out.xml"/>
        <p:log port="in-memory.out" href="file:/tmp/epub-to-nlbpub.convert.in-memory.out.xml"/>
        <p:log port="report.out" href="file:/tmp/epub-to-nlbpub.convert.report.out.xml"/>
        <p:log port="status.out" href="file:/tmp/epub-to-nlbpub.convert.status.out.xml"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="validate.nlbpub"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="report.out" step="validate.nlbpub"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status.out" step="validate.nlbpub"/>
        </p:input>
    </nlb:epub-to-nlbpub.convert>
    
    <px:message message="[progress 4 px:epub3-store] Pakker sammen EPUB"/>
    <px:epub3-store name="store">
        <p:with-option name="href" select="concat($outputDir,(//dc:identifier[not(@refines)]/text(),tokenize(replace($epub-href,'\.[^/]*$',''),'/')[last()])[1],'.epub')">
            <p:pipe port="opf" step="unzip"/>
        </p:with-option>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="convert.nlbpub"/>
        </p:input>
    </px:epub3-store>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="report.out" step="validate.nlbpub"/>
        </p:input>
    </p:identity>
    <px:message message="[progress 1 px:validation-report-to-html] Lager HTML-rapport"/>
    <px:validation-report-to-html name="html-report" toc="false"/>
    
    <px:validation-status name="status">
        <p:input port="source">
            <p:pipe port="report.out" step="validate.nlbpub"/>
        </p:input>
    </px:validation-status>
    
</p:declare-step>
