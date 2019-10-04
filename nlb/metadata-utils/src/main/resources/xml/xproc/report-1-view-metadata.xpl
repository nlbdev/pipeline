<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="nlb:report-1-view-metadata" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:SRU="http://www.loc.gov/zing/sru/" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Rapport 1: NLBs Bibliografiske Metadata</h1>
        <p px:role="desc">Viser metadata for en bok.</p>
    </p:documentation>

    <p:output port="html" primary="true" px:media-type="application/vnd.pipeline.report+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Metadata</h2>
            <p px:role="desc">Viser all metadata med Dublin Core (++) i HTML.</p>
        </p:documentation>
        <p:pipe port="result" step="html"/>
    </p:output>

    <p:output port="opf">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">OPF-metadata</h2>
            <p px:role="desc">Rå output fra MARCXML-to-OPF-transformasjonen.</p>
        </p:documentation>
        <p:pipe port="result" step="opf"/>
    </p:output>

    <p:option name="identifier" required="true" px:dir="input" px:type="string">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Boknummer</h2>
            <p px:role="desc">Vanligvis sekssifret (aka. tilvekstnummer).</p>
        </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>

    <p:variable name="endpoint" select="concat('http://websok.nlb.no/cgi-bin/sru?version=1.2&amp;operation=searchRetrieve&amp;recordSchema=bibliofilmarcnoholdings&amp;query=rec.identifier=',$identifier)"/>

    <p:add-attribute match="/*" attribute-name="href">
        <p:input port="source">
            <p:inline>
                <c:request method="GET" override-content-type="application/xml"/>
            </p:inline>
        </p:input>
        <p:with-option name="attribute-value" select="$endpoint"/>
    </p:add-attribute>
    <px:message>
        <p:with-option name="message" select="concat('Henter: ',/*/@href)"/>
    </px:message>
    <p:http-request name="http-request"/>
    
    <px:message message="Konverterer til OPF..."/>
    
    <p:xslt name="opf">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/marcxchange-to-opf/marcxchange-to-opf.xsl"/>
        </p:input>
    </p:xslt>

    <px:message message="Konverterer til HTML..."/>
    <p:xslt name="html">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/opf-to-html.xsl"/>
        </p:input>
    </p:xslt>


</p:declare-step>
