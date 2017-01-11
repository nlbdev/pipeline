<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                exclude-inline-prefixes="#all"
                type="px:epub-load-spine"
                name="main"
                version="1.0">

    <p:input port="source" primary="true">
        <p:documentation>Either a OPF or a fileset.</p:documentation>
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
    
    <p:choose>
        <p:when test="namespace-uri(/*) = 'http://www.daisy.org/ns/pipeline/data'">
            <px:epub-load-opf>
                <p:with-option name="fail-on-not-found" select="$fail-on-not-found"/>
                <p:with-option name="load-if-not-in-memory" select="$load-if-not-in-memory"/>
                <p:input port="in-memory">
                    <p:pipe port="in-memory" step="main"/>
                </p:input>
            </px:epub-load-opf>
            
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
    <p:xslt>
        <p:with-param name="spine-only" select="'true'"/>
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
