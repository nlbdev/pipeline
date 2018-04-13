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
    
    <!-- options to be forwarded -->
    <p:input port="parameters" kind="parameter" primary="true"/>
    
    <p:import href="http://www.nlb.no/pipeline/modules/braille/dtbook-to-pef.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    
    <p:in-scope-names name="in-scope-names"/>
    <px:merge-parameters>
        <p:input port="source">
            <p:pipe step="main" port="parameters"/>
        </p:input>
    </px:merge-parameters>
    <p:identity name="parameters"/>
    <p:sink/>
    
    <p:xslt>
        <p:input port="source">
            <p:pipe port="source" step="main"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="generate-content.xsl"/>
        </p:input>
    </p:xslt>
    
    <nlb:dtbook-to-pef>
        <p:input port="parameters">
            <p:pipe port="parameters" step="main"/>
        </p:input>
        <p:with-option name="temp-dir" select="/*/c:param[@name='temp-dir']/@value">
            <p:pipe port="result" step="parameters"/>
        </p:with-option>
        <p:with-option name="pef-output-dir" select="/*/c:param[@name='pef-output-dir']/@value">
            <p:pipe port="result" step="parameters"/>
        </p:with-option>
        <p:with-option name="preview-output-dir" select="/*/c:param[@name='preview-output-dir']/@value">
            <p:pipe port="result" step="parameters"/>
        </p:with-option>
    </nlb:dtbook-to-pef>

</p:declare-step>
