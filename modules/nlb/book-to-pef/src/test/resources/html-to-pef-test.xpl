<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                exclude-inline-prefixes="#all"
                name="main"
                type="nlb:dtbook-to-pef-test"
                version="1.0">
    
    <p:input port="source" primary="true" px:name="source" px:media-type="application/x-dtbook+xml"/>
    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml"/>
    
    <p:option name="temp-dir" required="true"/>
    <p:option name="pef-output-dir" required="true"/>
    <p:option name="preview-output-dir" required="true"/>
    
    <p:option name="show-print-page-numbers" required="true"/>
    <p:option name="show-braille-page-numbers" required="true"/>
    <p:option name="toc-depth" required="true"/>
    <p:option name="maximum-number-of-pages" required="true"/>
    
    <p:import href="http://www.nlb.no/pipeline/modules/braille/html-to-pef.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    
    <p:in-scope-names name="in-scope-names"/>
    <px:merge-parameters>
        <p:input port="source">
            <p:pipe step="in-scope-names" port="result"/>
        </p:input>
    </px:merge-parameters>
    <p:identity name="parameters"/>
    <p:sink/>
    
    <p:xslt>
        <p:input port="source">
            <p:pipe port="source" step="main"/>
        </p:input>
        <p:input port="parameters">
            <p:pipe port="result" step="parameters"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="generate-content.xsl"/>
        </p:input>
    </p:xslt>
    
    <nlb:html-to-pef>
        <p:with-option name="temp-dir" select="$temp-dir"/>
        <p:with-option name="pef-output-dir" select="$pef-output-dir"/>
        <p:with-option name="preview-output-dir" select="$preview-output-dir"/>
        <p:with-option name="show-print-page-numbers" select="$show-print-page-numbers"/>
        <p:with-option name="show-braille-page-numbers" select="$show-braille-page-numbers"/>
        <p:with-option name="toc-depth" select="$toc-depth"/>
        <p:with-option name="maximum-number-of-pages" select="$maximum-number-of-pages"/>
    </nlb:html-to-pef>

</p:declare-step>
