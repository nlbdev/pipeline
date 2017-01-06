<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:opf="http://www.idpf.org/2007/opf"
                type="nlb:epub-to-nlbpub.convert"
                name="main"
                version="1.0">
    
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true">
        <p:empty/>
    </p:input>
    <p:input port="report.in" sequence="true">
        <p:empty/>
    </p:input>
    <p:input port="status.in">
        <p:inline>
            <d:validation-status result="ok"/>
        </p:inline>
    </p:input>
    
    <p:output port="fileset.out" primary="true">
        <p:pipe port="fileset.out" step="choose"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="in-memory.out" step="choose"/>
    </p:output>
    <p:output port="report.out" sequence="true">
        <p:pipe port="report.in" step="main"/>
        <p:pipe port="report.out" step="choose"/>
    </p:output>
    <p:output port="status.out">
        <p:pipe port="result" step="status"/>
    </p:output>
    
    <p:option name="fail-on-error" select="'true'"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/validation-utils/library.xpl"/>
    
    <p:choose name="choose">
        <p:xpath-context>
            <p:pipe port="status.in" step="main"/>
        </p:xpath-context>
        <p:when test="/*/@result='ok' or $fail-on-error = 'false'">
            <p:output port="fileset.out" primary="true">
                <p:pipe port="result" step="epub-to-nlbpub.xsl.fileset"/>
            </p:output>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe port="result" step="epub-to-nlbpub.xsl.in-memory"/>
            </p:output>
            <p:output port="report.out" sequence="true">
                <p:pipe port="result" step="epub-to-nlbpub.xsl.report"/>
            </p:output>
            
            <px:message message="[progress px:epub-to-nlbpub.convert 10 px:fileset-load] Laster XML-filer"/>
            <px:fileset-load media-types="*/xml */*+xml" name="xml-files">
                <p:log port="result" href="file:/tmp/loaded.xml"/>
                <p:input port="in-memory">
                    <p:pipe port="in-memory.in" step="main"/>
                </p:input>
            </px:fileset-load>
            <p:for-each>
                <p:iteration-source>
                    <p:pipe port="fileset.in" step="main"/>
                    <p:pipe port="result" step="xml-files"/>
                </p:iteration-source>
                <p:add-attribute attribute-name="xml:base" match="/*">
                    <p:with-option name="attribute-value" select="(/*/@xml:base, /*/base-uri())[1]"/>
                </p:add-attribute>
                
                <px:message message="Oppgraderer til HTML 5"/>
                <p:choose>
                    <p:when test="/*/namespace-uri() = 'http://www.w3.org/1999/xhtml'">
                        <p:xslt>
                            <p:input port="parameters">
                                <p:empty/>
                            </p:input>
                            <p:input port="stylesheet">
                                <p:document href="http://www.daisy.org/pipeline/modules/html-utils/html5-upgrade.xsl"/>
                            </p:input>
                        </p:xslt>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
            </p:for-each>
            <p:wrap-sequence wrapper="c:wrapper">
                <p:log port="result" href="file:/tmp/wrap-sequence.out.xml"/>
            </p:wrap-sequence>
            
            <!-- TODO: valider med XSD eller RNG for struktur, og Schematron for å sjekke metadata, klassenavn etc. -->
            <!-- TODO: generer nytt navigation document basert på NCX hvis EPUB 2 -->
            
            <px:message message="[progress px:epub-to-nlbpub.convert 90 epub-to-nlbpub.xsl] Konverterer"/>
            <p:xslt name="epub-to-nlbpub.xsl">
                <p:log port="result" href="file:/tmp/epub-to-nlbpub.xsl.out.xml"/>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="epub-to-nlbpub.xsl"/>
                </p:input>
            </p:xslt>
            
            <p:delete match="//comment()[starts-with(.,'d:error ')] | //@d:*[starts-with(local-name(),'error-')]"/>
            <p:filter select="/*/*[position() &gt; 1]"/>
            <p:identity name="epub-to-nlbpub.xsl.in-memory"/>
            
            <p:filter select="/*/*[1]" name="epub-to-nlbpub.xsl.fileset">
                <p:input port="source">
                    <p:pipe port="result" step="epub-to-nlbpub.xsl"/>
                </p:input>
            </p:filter>
            
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="source">
                    <p:pipe port="result" step="epub-to-nlbpub.xsl"/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="epub-to-nlbpub.report.xsl"/>
                </p:input>
            </p:xslt>
            <p:filter select="/*/*"/>
            <p:identity name="epub-to-nlbpub.xsl.report"/>
            
            <!-- TODO: egne schematrons i tillegg her for å validere f.eks. metadata? Og overskriftsoppmerking etc?
                       Valideres mot dokumentet som kommer ut av epub-to-nlbpub.xsl isåfall så kan man legge inn fix på feil som oppstår i XSLTen. -->
            
        </p:when>
        <p:otherwise>
            <p:output port="fileset.out" primary="true"/>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe port="in-memory.in" step="main"/>
            </p:output>
            <p:output port="report.out" sequence="true">
                <p:empty/>
            </p:output>
            
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
    <p:choose name="status">
        <p:xpath-context>
            <p:pipe port="status.in" step="main"/>
        </p:xpath-context>
        <p:when test="/*/@result='ok'">
            <p:output port="result"/>
            <px:validation-status>
                <p:input port="source">
                    <p:pipe port="report.out" step="choose"/>
                </p:input>
            </px:validation-status>
        </p:when>
        <p:otherwise>
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="status.in" step="main"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
