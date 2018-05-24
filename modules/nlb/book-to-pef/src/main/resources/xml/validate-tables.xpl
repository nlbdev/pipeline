<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:validate-tables" version="1.0"
                xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:input port="source"/>
    <p:output port="result" primary="true">
        <p:pipe step="main" port="source"/>
    </p:output>
    <p:output port="report" sequence="true">
        <p:pipe step="report" port="result"/>
    </p:output>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    
    <p:add-attribute match="*[local-name()='table']" attribute-name="css:display" attribute-value="table"/>
    
    <css:make-table-grid/>
    
    <p:xslt name="report">
        <p:input port="stylesheet">
            <p:document href="validate-tables.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
