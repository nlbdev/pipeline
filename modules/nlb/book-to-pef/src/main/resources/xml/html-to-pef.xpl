<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:html-to-pef" version="1.0"
    xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    exclude-inline-prefixes="#all"
    name="main">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">HTML til PEF (NLB)</h1>
        <p px:role="desc">Konverterer HTML til PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Jostein Austvik Jacobsen</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.nlb.no/">NLB</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:josteinaj@gmail.com">josteinaj@gmail.com</a></dd>
        </dl>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Ammar Usama</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.nlb.no/">NLB</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:Ammar.Usama@nlb.no">Ammar.Usama@nlb.no</a></dd>
        </dl>
    </p:documentation>
    
    <p:input port="source" primary="true" px:name="source" px:media-type="application/xhtml+xml text/html">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">HTML</h2>
            <p px:role="desc">XHTML5-fila du vil konvertere til PEF.</p>
        </p:documentation>
    </p:input>
    
    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Validation status</h1>
            <p px:role="desc" xml:space="preserve">An XML document describing, briefly, whether the validation was successful.

[More details on the file format](http://daisy.github.io/pipeline/wiki/ValidationStatusXML).</p>
        </p:documentation>
        <p:pipe step="try-convert-and-store" port="status"/>
    </p:output>
    
    <p:output port="table-issues-report" px:media-type="application/vnd.pipeline.report+xml" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Table issues</h1>
            <p px:role="desc" xml:space="preserve">An HTML report listing problematic tables.</p>
        </p:documentation>
        <p:pipe step="validate-tables" port="report"/>
    </p:output>
    
    <p:option name="braille-standard"/>
    <p:option name="hyphenation"/>
    <p:option name="line-spacing"/>
    <p:option name="capital-letters"/>
    <p:option name="force-norwegian"/>
    <p:option name="stylesheet"/>
    <p:option name="apply-default-stylesheet"/>
    <p:option name="page-width"/>
    <p:option name="page-height"/>
    <p:option name="duplex"/>
    <p:option name="maximum-number-of-pages"/>
    <p:option name="include-obfl"/>
    <p:option name="include-captions"/>
    <p:option name="include-images"/>
    <p:option name="include-notes"/>
    <p:option name="notes-placement"/>
    <p:option name="include-production-notes"/>
    <p:option name="show-braille-page-numbers"/>
    <p:option name="show-print-page-numbers"/>
    <p:option name="toc-depth"/>
    <p:option name="insert-boilerplate"/>
    <p:option name="pef-output-dir"/>
    <p:option name="preview-output-dir"/>
    <p:option name="obfl-output-dir"/>
    <p:option name="temp-dir"/>
    
    <!-- for testing purposes -->
    <p:input port="parameters" kind="parameter" primary="false"/>
    
    <p:import href="http://www.nlb.no/pipeline/modules/braille/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/html-to-pef/library.xpl"/>
    
    <p:in-scope-names name="in-scope-names"/>
    <px:merge-parameters>
        <p:input port="source">
            <p:pipe step="in-scope-names" port="result"/>
            <p:pipe step="main" port="parameters"/>
        </p:input>
    </px:merge-parameters>
    <px:add-parameters>
        <p:with-param name="maximum-number-of-sheets" select="if ($duplex='false')
                                                              then //c:param[@name='maximum-number-of-pages']/@value
                                                              else xs:integer(number(//c:param[@name='maximum-number-of-pages']/@value) div 2)"/>
        <p:with-param name="main-document-language" select="'no'"/>
    </px:add-parameters>
    <px:delete-parameters parameter-names="stylesheet
                                           include-obfl
                                           maximum-number-of-pages
                                           pef-output-dir
                                           preview-output-dir
                                           obfl-output-dir
                                           temp-dir"/>
    <p:identity name="parameters"/>
    <p:sink/>
    
    <px:tempdir name="temp-dir">
        <p:with-option name="href" select="if ($temp-dir!='') then $temp-dir else $pef-output-dir"/>
    </px:tempdir>
    <p:sink/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="source" step="main"/>
        </p:input>
    </p:identity>
    
    <nlb:validate-tables name="validate-tables"/>
    
    <p:try name="try-convert-and-store">
        <p:group>
            <p:output port="status"/>
            <p:variable name="default-table-class" select="//c:param[@name='default-table-class']/@value">
                <p:pipe step="main" port="parameters"/>
            </p:variable>
            <px:html-to-pef.convert default-stylesheet="http://www.daisy.org/pipeline/modules/braille/html-to-pef/css/default.css"
                                      name="convert">
                <p:with-option name="stylesheet" select="string-join((
                                                           'http://www.nlb.no/pipeline/modules/braille/pre-processing.xsl',
                                                           'http://www.daisy.org/pipeline/modules/braille/xml-to-pef/generate-toc.xsl',
                                                           if ($default-table-class = '') then resolve-uri('add-table-classes.xsl') else (),
                                                           if ($insert-boilerplate = 'true') then 'http://www.nlb.no/pipeline/modules/braille/insert-boilerplate.xsl' else (),
                                                           if ($apply-default-stylesheet = 'true') then 'http://www.nlb.no/pipeline/modules/braille/default.scss' else (),
                                                           if ($stylesheet) then tokenize($stylesheet,',') else ()),' ')"/>
                <p:with-option name="transform" select="concat('(formatter:dotify)(translator:nlb)',$braille-standard)"/>
                <p:with-option name="include-obfl" select="$include-obfl"/>
                <p:input port="parameters">
                    <p:pipe port="result" step="parameters"/>
                </p:input>
                <p:with-option name="temp-dir" select="string(/c:result)">
                    <p:pipe step="temp-dir" port="result"/>
                </p:with-option>
            </px:html-to-pef.convert>
            <p:choose>
                <p:xpath-context>
                    <p:pipe step="convert" port="status"/>
                </p:xpath-context>
                <p:when test="/d:validation-status[@result='ok']">
                    <p:output port="status">
                        <p:pipe step="validate-pef" port="validation-status"/>
                    </p:output>
                    <pef:validate name="validate-pef" assert-valid="false">
                        <p:with-option name="temp-dir" select="string(/c:result)">
                            <p:pipe step="temp-dir" port="result"/>
                        </p:with-option>
                    </pef:validate>
                    <px:html-to-pef.store include-preview="true">
                        <p:input port="html">
                            <p:pipe step="main" port="source"/>
                        </p:input>
                        <p:input port="obfl">
                            <p:pipe step="convert" port="obfl"/>
                        </p:input>
                        <p:with-option name="pef-output-dir" select="$pef-output-dir"/>
                        <p:with-option name="preview-output-dir" select="$preview-output-dir"/>
                        <p:with-option name="obfl-output-dir" select="$obfl-output-dir"/>
                    </px:html-to-pef.store>
                </p:when>
                <p:otherwise>
                    <p:output port="status"/>
                    <p:identity>
                        <p:input port="source">
                            <p:pipe step="convert" port="status"/>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>
        </p:group>
        <p:catch>
            <p:output port="status"/>
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <d:validation-status result="error"/>
                    </p:inline>
                </p:input>
            </p:identity>
        </p:catch>
    </p:try>
    
</p:declare-step>
