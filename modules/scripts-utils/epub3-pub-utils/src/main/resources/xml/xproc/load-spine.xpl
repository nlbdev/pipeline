<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:opf="http://www.idpf.org/2007/opf"
                exclude-inline-prefixes="#all"
                type="px:epub-load-spine"
                name="main"
                version="1.0">

    <p:input port="opf" primary="true"/>
    <p:input port="fileset">
        <p:inline>
            <d:fileset/>
        </p:inline>
    </p:input>
    <p:input port="in-memory" sequence="true">
        <p:empty/>
    </p:input>
    <p:output port="result" sequence="true"/>

    <p:option name="fail-on-not-found" select="'false'"/>
    <p:option name="load-if-not-in-memory" select="'true'"/>

    <p:import href="load-opf.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    
    <p:xslt name="opf-fileset">
        <p:with-param name="spine-only" select="'true'"/>
        <p:input port="source">
            <p:pipe port="opf" step="main"/>
            <p:pipe port="fileset" step="main"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/opf-manifest-to-fileset.xsl"/>
        </p:input>
    </p:xslt>
    <px:fileset-load>
        <p:with-option name="fail-on-not-found" select="$fail-on-not-found"/>
        <p:with-option name="load-if-not-in-memory" select="$load-if-not-in-memory"/>
        <p:input port="in-memory">
            <p:pipe port="in-memory" step="main"/>
        </p:input>
    </px:fileset-load>

</p:declare-step>
