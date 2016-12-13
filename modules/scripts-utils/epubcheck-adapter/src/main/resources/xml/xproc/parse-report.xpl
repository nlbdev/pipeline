<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                type="px:epubcheck-parse-report"
                name="main"
                version="1.0">
    
    <p:input port="source">
        <p:documentation>The epubcheck XML report</p:documentation>
    </p:input>
    
    <p:output port="html-report" primary="true">
        <p:documentation>HTML-formatted validation report</p:documentation>
        <p:pipe port="result" step="html-report"/>
    </p:output>
    
    <p:output port="pipeline-report">
        <p:documentation>Validation report corresponding to the grammar used by other steps in the DAISY Pipeline 2 framework</p:documentation>
        <p:pipe port="result" step="pipeline-report"/>
    </p:output>
    
    <p:output port="status">
        <p:documentation>Status document stating whether or not the EPUB is valid</p:documentation>
        <p:pipe port="result" step="status"/>
    </p:output>
    
    <p:xslt name="xml-report.not-wrapped">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/epubcheck-report-to-pipeline-report.xsl"/>
        </p:input>
    </p:xslt>
    <p:for-each>
        <p:iteration-source select="//d:warn">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    <p:wrap-sequence wrapper="d:warnings" name="warnings"/>
    <p:for-each>
        <p:iteration-source select="//d:error">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    <p:wrap-sequence wrapper="d:errors" name="errors"/>
    <p:for-each name="exception">
        <p:iteration-source select="//d:exception">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    <p:wrap-sequence wrapper="d:exceptions" name="exceptions"/>
    <p:for-each name="hint">
        <p:iteration-source select="//d:hint">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>
    <p:wrap-sequence wrapper="d:hints" name="hints"/>
    <p:delete match="//d:report/*">
        <p:input port="source">
            <p:pipe port="result" step="xml-report.not-wrapped"/>
        </p:input>
    </p:delete>
    <p:insert match="//d:report" position="first-child">
        <p:input port="insertion">
            <p:pipe port="result" step="exceptions"/>
            <p:pipe port="result" step="errors"/>
            <p:pipe port="result" step="warnings"/>
            <p:pipe port="result" step="hints"/>
        </p:input>
    </p:insert>
    <p:delete match="//d:report/*[not(*)]"/>
    <p:identity name="xml-report"/>
    
    <p:xslt name="html-report">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/epubcheck-pipeline-report-to-html-report.xsl"/>
        </p:input>
    </p:xslt>
    
    <p:group name="status">
        <p:output port="result"/>
        <p:for-each>
            <p:iteration-source select="/d:document-validation-report/d:document-info/d:error-count">
                <p:pipe port="result" step="xml-report"/>
            </p:iteration-source>
            <p:identity/>
        </p:for-each>
        <p:wrap-sequence wrapper="d:validation-status"/>
        <p:add-attribute attribute-name="result" match="/*">
            <p:with-option name="attribute-value" select="if (sum(/*/*/number(.))&gt;0) then 'error' else 'ok'"/>
        </p:add-attribute>
        <p:delete match="/*/node()"/>
    </p:group>
    <p:sink/>
    
</p:declare-step>