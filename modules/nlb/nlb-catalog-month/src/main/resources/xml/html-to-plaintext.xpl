<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="nlb:html-to-plaintext" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-inline-prefixes="#all" xpath-version="2.0" version="1.0">

    <p:input port="source"/>
    <p:output port="result"/>
    <p:serialization port="result" indent="true"/>
    
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="html-to-plaintext.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="html-to-plaintext.br.xsl"/>
        </p:input>
    </p:xslt>
    <p:unwrap match="html:line[.//html:line]"/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="html-to-plaintext.wrap-runaway-text.xsl"/>
        </p:input>
    </p:xslt>

    <!-- We don't need to break lines; mailchimp does it automatically. -->
    <!--<p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="wrap-lines.xsl"/>
        </p:input>
    </p:xslt>-->

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:for-each select="*">
                                <xsl:value-of select="."/>
                                <xsl:text>
</xsl:text>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>

</p:declare-step>
