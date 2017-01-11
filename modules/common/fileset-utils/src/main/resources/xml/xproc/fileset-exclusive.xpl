<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-exclusive" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="err px">
    
    <p:input port="source" sequence="true"/>
    <p:output port="result"/>
    
    <p:xslt template-name="join">
        <p:input port="stylesheet">
            <p:document href="../xslt/fileset-join.xsl"/>
        </p:input>
        <p:with-param name="exclusive" select="'true'">
            <p:empty/>
        </p:with-param>
    </p:xslt>
    
</p:declare-step>
