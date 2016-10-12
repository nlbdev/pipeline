<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:pre-processing" version="1.0"
                 xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
                 xmlns:p="http://www.w3.org/ns/xproc"
                 xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                 xmlns:d="http://www.daisy.org/ns/pipeline/data"
                 xmlns:c="http://www.w3.org/ns/xproc-step"
                 xmlns:pef="http://www.daisy.org/ns/2008/pef"
                 exclude-inline-prefixes="#all"
                 name="main">
    
    <p:input port="source"/>
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="source" step="main"/>
        </p:input>
    </p:identity>
    
    <px:message message="Running NLB-specific pre-processing steps"/>
    <p:xslt>
        <p:input port="parameters">
            <p:pipe step="main" port="parameters"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="pre-processing.xsl"/>
        </p:input>
    </p:xslt>
    
    <px:message message="Inserting boilerplate text" severity="DEBUG"/>
    <p:xslt>
        <p:input port="parameters">
            <p:pipe step="main" port="parameters"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="insert-boilerplate.xsl"/>
        </p:input>
    </p:xslt>
    
    <px:message message="Finished running NLB-specific pre-processing steps" severity="DEBUG"/>
    
</p:declare-step>