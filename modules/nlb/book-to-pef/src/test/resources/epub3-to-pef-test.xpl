<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:pef="http://www.daisy.org/ns/2008/pef" exclude-inline-prefixes="#all" name="main" type="nlb:epub3-to-pef-test" version="1.0">

    <p:input port="source" sequence="true">
        <!--
            first doc: opf
            second doc: nav
            remaining docs: content
        -->
    </p:input>

    <!-- results to be returned -->
    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml"/>

    <!-- options to be forwarded -->
    <p:input port="parameters" kind="parameter" primary="true"/>

    <p:import href="http://www.nlb.no/pipeline/modules/braille/epub3-to-pef.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl"/>

    <p:in-scope-names name="in-scope-names"/>
    <px:merge-parameters>
        <p:input port="source">
            <p:pipe step="main" port="parameters"/>
        </p:input>
    </px:merge-parameters>
    <px:delete-parameters parameter-names="epub-temp-dir"/>
    <p:identity name="parameters"/>
    <p:sink/>

    <p:group>
        <p:variable name="epub-temp-dir" select="concat(if (ends-with(/*/c:param[@name='temp-dir']/@value,'/')) then /*/c:param[@name='temp-dir']/@value else concat(/*/c:param[@name='temp-dir']/@value,'/'), 'epub/')">
            <p:pipe port="result" step="parameters"/>
        </p:variable>

        <p:split-sequence test="position() = 1">
            <p:input port="source">
                <p:pipe port="source" step="main"/>
            </p:input>
        </p:split-sequence>
        <p:xslt>
            <p:input port="parameters"/>
            <p:input port="stylesheet">
                <p:document href="generate-content.xsl"/>
            </p:input>
        </p:xslt>
        <p:store name="opf">
            <p:with-option name="href" select="resolve-uri(if (/*/@xml:base) then replace(/*/@xml:base,'.*/','') else 'package.opf', $epub-temp-dir)"/>
        </p:store>

        <p:split-sequence test="position() = 2">
            <p:input port="source">
                <p:pipe port="source" step="main"/>
            </p:input>
        </p:split-sequence>
        <p:xslt>
            <p:input port="parameters"/>
            <p:input port="stylesheet">
                <p:document href="generate-content.xsl"/>
            </p:input>
        </p:xslt>
        <p:store name="nav">
            <p:with-option name="href" select="resolve-uri(if (/*/@xml:base) then replace(/*/@xml:base,'.*/','') else 'nav.xhtml', $epub-temp-dir)"/>
        </p:store>

        <p:split-sequence test="position() &gt; 2">
            <p:input port="source">
                <p:pipe port="source" step="main"/>
            </p:input>
        </p:split-sequence>
        <p:for-each>
            <p:xslt>
                <p:input port="parameters"/>
                <p:input port="stylesheet">
                    <p:document href="generate-content.xsl"/>
                </p:input>
            </p:xslt>
            <p:store name="content-iteration">
                <p:with-option name="href" select="resolve-uri(if (/*/@xml:base) then replace(/*/@xml:base,'.*/','') else concat('content-',p:iteration-position(),'.xhtml'), $epub-temp-dir)"/>
            </p:store>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="content-iteration"/>
                </p:input>
            </p:identity>
        </p:for-each>
        <p:identity name="content"/>
        <p:sink/>

        <p:wrap-sequence wrapper="d:fileset">
            <p:input port="source">
                <p:pipe port="result" step="opf"/>
                <p:pipe port="result" step="nav"/>
                <p:pipe port="result" step="content"/>
            </p:input>
        </p:wrap-sequence>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="$epub-temp-dir"/>
        </p:add-attribute>
        <p:viewport match="/*/*">
            <p:add-attribute match="/*" attribute-name="href">
                <p:with-option name="attribute-value" select="replace(/*/text(),'.*/','')"/>
                <p:input port="source">
                    <p:inline>
                        <d:file/>
                    </p:inline>
                </p:input>
            </p:add-attribute>
        </p:viewport>
        <px:mediatype-detect/>

        <nlb:epub3-to-pef>
            <p:with-option name="epub" select="/*/text()">
                <p:pipe port="result" step="opf"/>
            </p:with-option>
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
        </nlb:epub3-to-pef>
        
    </p:group>

</p:declare-step>
