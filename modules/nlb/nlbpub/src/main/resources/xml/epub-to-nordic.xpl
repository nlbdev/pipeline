<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:pxp="http://exproc.org/proposed/steps"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                px:input-filesets="epub3"
                px:output-filesets="epub3"
                type="nlb:epub-to-nordic"
                name="main"
                xpath-version="2.0"
                version="1.0">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">EPUB til NLBPUB</h1>
        <p px:role="desc">Konverterer en vilkårlig EPUB til NLBs EPUB-standard.</p>
    </p:documentation>
    
    <p:serialization port="html-report" method="xhtml" indent="true"/>
    
    <p:option name="epub" required="true" px:type="anyFileURI" px:media-type="application/epub+zip">
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
    
    <p:variable name="epub-href" select="resolve-uri($epub,base-uri(/*))">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>
    
    <px:fileset-create>
        <p:with-option name="base" select="replace($epub-href,'[^/]+$','')"/>
    </px:fileset-create>
    <px:fileset-add-entry media-type="application/epub+zip">
        <p:with-option name="href" select="replace($epub-href,'^.*/([^/]*)$','$1')"/>
    </px:fileset-add-entry>
    
    <p:group name="unzip">
        <p:output port="fileset.out" primary="true">
            <p:pipe port="result" step="unzipped-fileset"/>
        </p:output>
        <p:output port="in-memory.out">
            <p:pipe port="result" step="container"/>
            <p:pipe port="result" step="opf"/>
        </p:output>
        <p:output port="opf" primary="false">
            <p:pipe port="result" step="opf"/>
        </p:output>
        
        <p:choose>
            <p:when test="/*/d:file[@media-type='application/epub+zip']">
                <px:fileset-filter media-types="application/epub+zip"/>
                <px:message message="[progress 5 px:unzip-fileset] Pakker ut EPUB"/>
                <px:unzip-fileset name="unzip" load-to-memory="false" store-to-disk="true">
                    <p:with-option name="href" select="resolve-uri(/*/*/(@original-href,@href)[1],/*/*/base-uri(.))"/>
                    <p:with-option name="unzipped-basedir" select="concat($temp-dir,'epub/')"/>
                </px:unzip-fileset>
                <p:sink/>
                
                <px:mediatype-detect>
                    <p:input port="source">
                        <p:pipe port="fileset" step="unzip"/>
                    </p:input>
                </px:mediatype-detect>
            </p:when>
            <p:otherwise>
                <px:message message="[progress 5 p:identity] EPUB er allerede pakket ut"/>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        <p:identity name="unzipped-fileset"/>
        
        <px:message message="Henter ut OPF"/>
        <px:fileset-load href="META-INF/container.xml" name="container"/>
        <px:assert message="Det må finnes nøyaktig én META-INF/container.xml" error-code="NLBPUB001" test-count-min="1" test-count-max="1"/>
        <px:fileset-load>
            <p:with-option name="href" select="(/ocf:container/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml'])[1]/@full-path"/>
            <p:input port="fileset">
                <p:pipe port="result" step="unzipped-fileset"/>
            </p:input>
        </px:fileset-load>
        <px:assert message="META-INF/container.xml må referere til minst én OPF-fil" error-code="NLBPUB002" test-count-min="1" test-count-max="1"/>
        <p:identity name="opf"/>
    </p:group>
    
    <px:message message="[progress 18 px:epubcheck] Validerer EPUB i henhold til EPUB-standard"/>
    <px:epubcheck mode="opf">
        <p:with-option name="version" select="if (starts-with(/*/@version, '3')) then '3' else '2'">
            <p:pipe port="opf" step="unzip"/>
        </p:with-option>
        <p:with-option name="href" select="base-uri(/*)">
            <p:pipe port="opf" step="unzip"/>
        </p:with-option>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="unzip"/>
        </p:input>
    </px:epubcheck>
    <px:epubcheck-parse-report name="validate.epubcheck"/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="fileset.out" step="unzip"/>
        </p:input>
    </p:identity>
    <px:message message="[progress 18 nlb:nlbpub.validate] Validerer EPUB i henhold til NLB-standard"/>
    <nlb:nlbpub.validate name="validate.nlbpub">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="unzip"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="pipeline-report" step="validate.epub"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status" step="validate.epub"/>
        </p:input>
    </nlb:nlbpub.validate>
    
    <px:message message="[progress 18 px:epub-to-nlbpub.convert] Normaliserer EPUB i henhold til NLB-standard"/>
    <nlb:epub-to-nlbpub.convert name="convert.nlbpub">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="validate.nlbpub"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="in-memory.out" step="validate.nlbpub"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="in-memory.out" step="validate.nlbpub"/>
        </p:input>
    </nlb:epub-to-nlbpub.convert>
    
    <px:message message="[progress 18 nlb:nlbpub-to-nordic.convert] Konverterer fra NLB-standard til Nordic EPUB 3 Markup Guidelines"/>
    <nlb:nlbpub-to-nordic.convert name="convert.nordic">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="convert.nlbpub"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="in-memory.out" step="convert.nlbpub"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="in-memory.out" step="convert.nlbpub"/>
        </p:input>
    </nlb:nlbpub-to-nordic.convert>
    
    <px:message message="[progress 18 px:nordic-epub3-validate-step] Validerer resultat opp mot Nordic EPUB 3 Markup Guidelines"/>
    <px:message message="Ikke implementert"/>
    <!--<px:nordic-epub3-validate.step name="validate.nordic">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="convert.nordic"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="in-memory.out" step="convert.nordic"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="in-memory.out" step="convert.nordic"/>
        </p:input>
    </px:nordic-epub3-validate.step>-->
    
    <px:message message="[progress 5 px:epub3-store] Pakker sammen EPUB"/>
    <px:epub3-store>
        <p:with-option name="href" select="concat($output-dir,(//dc:identifier[not(@refines)]/text(),tokenize(replace($epub-href,'\.[^/]*$',''),'/')[last()])[1])">
            <p:pipe port="opf" step="unzip"/>
        </p:with-option>
        <p:input port="in-memory.in">
            <!--            <p:pipe port="in-memory.out" step="validate.nordic"/>-->
            <p:pipe port="in-memory.out" step="convert.nordic"/>
        </p:input>
    </px:epub3-store>
    
    <px:combine-validation-reports name="xml-report" document-type="EPUB">
        <p:with-option name="document-name" select="replace($epub-href,'.*/','')"/>
        <p:input port="source">
            <p:pipe port="reports.out" step="validate.epub"/>
            <p:pipe port="reports.out" step="validate.nlbpub"/>
        </p:input>
    </px:combine-validation-reports>
    
    <px:validation-report-to-html name="html-report" toc="false"/>
    
    <px:validation-status name="status">
        <p:input port="source">
            <p:pipe port="report.out" step="choose"/>
        </p:input>
    </px:validation-status>
    
</p:declare-step>
