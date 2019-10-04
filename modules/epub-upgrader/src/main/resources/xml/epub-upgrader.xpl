<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:pxp="http://exproc.org/proposed/steps"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                px:input-filesets="epub3"
                px:output-filesets="epub3"
                type="px:epub-upgrader"
                name="main"
                xpath-version="2.0"
                version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">EPUB Upgrader</h1>
        <p px:role="desc">Upgrades from EPUB 2 or EPUB 3.0 to EPUB 3.1.</p>
    </p:documentation>
    
    <p:serialization port="html-report" method="xhtml" indent="true"/>

    <p:option name="href" required="true" px:type="anyFileURI" px:media-type="application/epub+zip application/oebps-package+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">EPUB</h2>
            <p px:desc="desc">EPUB file, OPF file, or path to unzipped EPUB.</p>
        </p:documentation>
    </p:option>

    <p:option name="temp-dir" required="true" px:output="temp" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Folder for temporary files.</h2>
        </p:documentation>
    </p:option>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Output directory for the converted EPUB</h2>
        </p:documentation>
    </p:option>
    
    <p:option name="zip-results" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Use EPUB container for result files.</h2>
            <p px:role="desc">If disabled, will give an "exploded" version of the EPUB with all the HTML-files (etc.) instead of zipping it in a single '*.epub' file.</p>
        </p:documentation>
    </p:option>
    
    <p:output port="html-report" px:type="application/vnd.pipeline.report+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Validation report</h2>
            <p px:role="desc">A HTML formatted validation report.</p>
        </p:documentation>
        <p:pipe port="result" step="html-report"/>
    </p:output>
    
    <p:output port="validation-status" px:type="application/vnd.pipeline.status+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Validation status</h1>
        </p:documentation>
        <p:pipe port="result" step="status"/>
    </p:output>

    <p:import href="epub-upgrader.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/validation-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/library.xpl"/>

    <p:variable name="resolvedHref" select="resolve-uri($href,base-uri(/*))">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>
    
    <p:variable name="outputDir" select="if (not(ends-with($output-dir,'/'))) then concat($output-dir,'/') else $output-dir"/>
    <p:variable name="tempDir" select="if (not(ends-with($temp-dir,'/'))) then concat($temp-dir,'/') else $temp-dir"/>
    
    <px:message message="[progress 10 px:epub-load] Loading EPUB">
        <p:input port="source">
            <p:empty/>
        </p:input>
    </px:message>
    <px:epub-load name="load">
        <p:with-option name="href" select="$resolvedHref"/>
        <p:with-option name="output-dir" select="concat($tempDir,'epub/')"/>
    </px:epub-load>
    
    <px:message message="[progress 80 px:epub-upgrader.convert] Upgrading EPUB"/>
    <px:epub-upgrader.convert name="convert" fail-on-error="false">
        <p:input port="in-memory.in">
            <p:pipe port="opf" step="load"/>
        </p:input>
    </px:epub-upgrader.convert>
    
    <p:choose>
        <p:when test="$zip-results = 'true'">
            <p:variable name="epubHref" select="concat($outputDir,(//dc:identifier[not(@refines)]/text(),tokenize(replace($resolvedHref,'\.[^/]*$',''),'/')[last()])[1],'.epub')">
                <p:pipe port="opf" step="load"/>
            </p:variable>
            <px:message>
                <p:with-option name="message" select="concat('[progress 10 px:epub3-store] Storing EPUB in file &quot;', $epubHref,'&quot;')"/>
            </px:message>
            <px:epub3-store>
                <p:with-option name="href" select="$epubHref"/>
                <p:input port="in-memory.in">
                    <p:pipe port="in-memory.out" step="convert"/>
                </p:input>
            </px:epub3-store>
        </p:when>
        <p:otherwise>
            <px:message>
                <p:with-option name="message" select="concat('[progress 10 px:epub3-store] Storing EPUB in directory &quot;', $outputDir,'&quot;')"/>
            </px:message>
            <px:fileset-move name="move">
                <p:with-option name="new-base" select="$outputDir"/>
                <p:input port="in-memory.in">
                    <p:pipe port="in-memory.out" step="convert"/>
                </p:input>
            </px:fileset-move>
            <px:fileset-store>
                <p:input port="in-memory.in">
                    <p:pipe port="in-memory.out" step="move"/>
                </p:input>
            </px:fileset-store>
        </p:otherwise>
    </p:choose>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="report.out" step="convert"/>
        </p:input>
    </p:identity>
    <px:message message="[progress 1 px:validation-report-to-html] Lager HTML-rapport"/>
    <px:validation-report-to-html name="html-report" toc="false"/>
    
    <px:validation-status name="status">
        <p:input port="source">
            <p:pipe port="report.out" step="convert"/>
        </p:input>
    </px:validation-status>
    
</p:declare-step>
