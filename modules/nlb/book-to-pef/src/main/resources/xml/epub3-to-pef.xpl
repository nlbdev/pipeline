<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:epub3-to-pef" version="1.0"
    xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    exclude-inline-prefixes="#all"
    name="main">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">EPUB 3 til PEF (NLB)</h1>
        <p px:role="desc">Konverterer en EPUB 3-bok til PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Jostein Austvik Jacobsen</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.nlb.no/">NLB</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:josteinaj@gmail.com">josteinaj@gmail.com</a></dd>
        </dl>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Ammar Usama</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.nlb.no/">NLB</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:Ammar.Usama@nlb.no">Ammar.Usama@nlb.no</a></dd>
        </dl>
    </p:documentation>
    
    <p:option name="epub" required="true" px:type="anyFileURI" px:sequence="false" px:media-type="application/epub+zip application/oebps-package+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">EPUB 3</h2>
            <p px:role="desc">EPUBen du vil konvertere til PEF.</p>
        </p:documentation>
    </p:option>
    
    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Validation status</h1>
            <p px:role="desc" xml:space="preserve">An XML document describing, briefly, whether the validation was successful.

[More details on the file format](http://daisy.github.io/pipeline/wiki/ValidationStatusXML).</p>
        </p:documentation>
        <p:pipe port="validation-status" step="validate-pef"/>
    </p:output>
    
    <p:option name="braille-standard"/>
    <p:option name="hyphenation"/>
    <p:option name="line-spacing"/>
    <p:option name="capital-letters"/>
    <p:option name="force-norwegian"/>
    <p:option name="stylesheet"/>
    <p:option name="page-width"/>
    <p:option name="page-height"/>
    <p:option name="duplex"/>
    <p:option name="include-obfl"/>
    <p:option name="include-captions"/>
    <p:option name="include-images"/>
    <p:option name="include-notes"/>
    <p:option name="include-production-notes"/>
    <p:option name="show-braille-page-numbers"/>
    <p:option name="show-print-page-numbers"/>
    <p:option name="toc-depth"/>
    <p:option name="colophon-metadata-placement"/>
    <p:option name="maximum-number-of-sheets"/>
    <p:option name="pef-output-dir"/>
    <p:option name="preview-output-dir"/>
    <p:option name="temp-dir"/>
    
    <!-- for testing purposes -->
    <p:input port="parameters" kind="parameter" primary="false"/>
    
    <p:import href="http://www.nlb.no/pipeline/modules/braille/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/epub3-to-pef/library.xpl"/>
    
    <p:in-scope-names name="in-scope-names"/>
    <px:merge-parameters>
        <p:input port="source">
            <p:pipe step="in-scope-names" port="result"/>
            <p:pipe step="main" port="parameters"/>
        </p:input>
    </px:merge-parameters>
    <px:delete-parameters parameter-names="stylesheet
                                           include-obfl
                                           pef-output-dir
                                           preview-output-dir
                                           temp-dir"/>
    <px:add-parameters>
        <p:with-param name="main-document-language" select="'no'"/>
    </px:add-parameters>
    <p:identity name="parameters"/>
    <p:sink/>
    
    <px:tempdir name="temp-dir">
        <p:with-option name="href" select="if ($temp-dir!='') then $temp-dir else $pef-output-dir"/>
    </px:tempdir>
    <p:sink/>
    
    <px:epub3-to-pef.load name="load">
        <p:with-option name="epub" select="$epub"/>
        <p:with-option name="temp-dir" select="concat(string(/c:result),'load/')">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
    </px:epub3-to-pef.load>
    
    <px:message message="Running NLB-specific pre-processing steps"/>
    <!--
        Nothing here yet.
        Wait for: https://github.com/snaekobbi/pipeline-mod-braille/issues/63 (=> this is fixed now)
    -->
    <px:message message="Finished running NLB-specific pre-processing steps" severity="DEBUG"/>
    
    <px:epub3-to-pef.convert default-stylesheet="http://www.daisy.org/pipeline/modules/braille/epub3-to-pef/css/default.css"
                             name="convert">
        <p:with-option name="epub" select="$epub"/>
        <p:input port="in-memory.in">
            <p:pipe step="load" port="in-memory.out"/>
        </p:input>
        <p:with-option name="stylesheet" select="string-join((
                                                   'http://www.nlb.no/pipeline/modules/braille/insert-boilerplate.xsl',
                                                   'http://www.nlb.no/pipeline/modules/braille/default.scss',
                                                   if ($stylesheet) then $stylesheet else ()),' ')"/>
        <p:with-option name="transform" select="concat('(formatter:dotify)(translator:nlb)',$braille-standard)"/>
        <p:with-option name="include-obfl" select="$include-obfl"/>
        <p:input port="parameters">
            <p:pipe step="parameters" port="result"/>
        </p:input>
        <p:with-option name="temp-dir" select="concat(string(/c:result),'convert/')">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
    </px:epub3-to-pef.convert>
    <p:sink/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="convert" port="in-memory.out"/>
        </p:input>
    </p:identity>
    <p:delete match="/*/@xml:base"/>
    <pef:validate name="validate-pef" assert-valid="false">
        <p:with-option name="temp-dir" select="string(/c:result)">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
    </pef:validate>
    
    <px:epub3-to-pef.store include-preview="true">
        <p:with-option name="epub" select="$epub"/>
        <p:input port="opf">
            <p:pipe step="load" port="opf"/>
        </p:input>
        <p:input port="obfl">
            <p:pipe step="convert" port="obfl"/>
        </p:input>
        <p:with-option name="pef-output-dir" select="$pef-output-dir"/>
        <p:with-option name="preview-output-dir" select="$preview-output-dir"/>
    </px:epub3-to-pef.store>
    
</p:declare-step>
