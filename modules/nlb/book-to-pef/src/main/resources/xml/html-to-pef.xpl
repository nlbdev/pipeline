<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:html-to-pef" version="1.0"
    xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    exclude-inline-prefixes="#all"
    name="main">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">HTML til PEF (NLB)</h1>
        <p px:role="desc">Konverterer HTML til PEF.</p>
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
    
    <p:option name="html" required="true" px:type="anyFileURI" px:sequence="false" px:media-type="application/xhtml+xml text/html">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">HTML</h2>
            <p px:role="desc">HTML-fila du vil konvertere til PEF.</p>
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
    <p:option name="apply-default-stylesheet"/>
    <p:option name="page-width"/>
    <p:option name="page-height"/>
    <p:option name="duplex"/>
    <p:option name="maximum-number-of-pages"/>
    <p:option name="include-obfl"/>
    <p:option name="include-captions"/>
    <p:option name="include-images"/>
    <p:option name="include-notes"/>
    <p:option name="notes-placement"/>
    <p:option name="include-production-notes"/>
    <p:option name="show-braille-page-numbers"/>
    <p:option name="show-print-page-numbers"/>
    <p:option name="toc-depth"/>
    <p:option name="pef-output-dir"/>
    <p:option name="preview-output-dir"/>
    <p:option name="temp-dir"/>
    
    <!-- for testing purposes -->
    <p:input port="parameters" kind="parameter" primary="false"/>
    
    <p:import href="http://www.nlb.no/pipeline/modules/braille/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/html-to-pef/library.xpl"/>
    
    <p:in-scope-names name="in-scope-names"/>
    <px:merge-parameters>
        <p:input port="source">
            <p:pipe step="in-scope-names" port="result"/>
            <p:pipe step="main" port="parameters"/>
        </p:input>
    </px:merge-parameters>
    <px:add-parameters>
        <p:with-param name="maximum-number-of-sheets" select="xs:integer(number($maximum-number-of-pages) div 2)"/>
        <p:with-param name="main-document-language" select="'no'"/>
    </px:add-parameters>
    <px:delete-parameters parameter-names="stylesheet
                                           include-obfl
                                           maximum-number-of-pages
                                           pef-output-dir
                                           preview-output-dir
                                           temp-dir"/>
    <p:identity name="parameters"/>
    <p:sink/>
    
    <px:tempdir name="temp-dir">
        <p:with-option name="href" select="if ($temp-dir!='') then $temp-dir else $pef-output-dir"/>
    </px:tempdir>
    <p:sink/>
    
    <px:html-load name="html">
        <p:with-option name="href" select="$html"/>
    </px:html-load>
    
    <px:message message="Running NLB-specific pre-processing steps"/>
    <!--
        Nothing here yet.
        Wait for: https://github.com/snaekobbi/pipeline-mod-braille/issues/63 (=> this is fixed now)
    -->
    <px:message message="Finished running NLB-specific pre-processing steps" severity="DEBUG"/>
        
    <px:html-to-pef.convert default-stylesheet="http://www.daisy.org/pipeline/modules/braille/html-to-pef/css/default.css"
                            name="convert">
        <p:with-option name="stylesheet" select="concat('http://www.nlb.no/pipeline/modules/braille/default.scss',
                                                        if ($stylesheet) then concat(' ',$stylesheet) else '')"/>
        <p:with-option name="transform" select="concat('(formatter:dotify)(translator:nlb)',$braille-standard)"/>
        <p:with-option name="include-obfl" select="$include-obfl"/>
        <p:input port="parameters">
            <p:pipe step="parameters" port="result"/>
        </p:input>
        <p:with-option name="temp-dir" select="concat(string(/c:result),'convert/')">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
    </px:html-to-pef.convert>
    
    <pef:validate name="validate-pef" assert-valid="false">
        <p:with-option name="temp-dir" select="string(/c:result)">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
    </pef:validate>
    
    <px:xml-to-pef.store include-preview="true">
        <p:with-option name="name" select="replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1')">
            <p:pipe step="html" port="result"/>
        </p:with-option>
        <p:input port="obfl">
            <p:pipe step="convert" port="obfl"/>
        </p:input>
        <p:with-option name="pef-output-dir" select="$pef-output-dir"/>
        <p:with-option name="preview-output-dir" select="$preview-output-dir"/>
    </px:xml-to-pef.store>
    
</p:declare-step>
