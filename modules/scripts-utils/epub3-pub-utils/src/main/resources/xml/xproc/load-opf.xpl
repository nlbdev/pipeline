<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                exclude-inline-prefixes="#all"
                type="px:epub-load-opf"
                name="main"
                version="1.0">
    
    <p:input port="fileset" primary="true"/>
    <p:input port="in-memory" sequence="true">
        <p:empty/>
    </p:input>
    <p:output port="result" sequence="true"/>
    
    <p:option name="fail-on-not-found" select="'false'"/>
    <p:option name="load-if-not-in-memory" select="'true'"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    
    <p:choose>
        <p:when test="/*/d:file[@href='META-INF/container.xml']">
            <!-- META-INF/container.xml, with fileset base set to EPUB base -->
            <px:fileset-load href="META-INF/container.xml" name="container"/>
            <px:fileset-load>
                <p:with-option name="href" select="(/ocf:container/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml'])[1]/@full-path"/>
                <p:with-option name="fail-on-not-found" select="$fail-on-not-found"/>
                <p:with-option name="load-if-not-in-memory" select="$load-if-not-in-memory"/>
                <p:input port="fileset">
                    <p:pipe port="fileset" step="main"/>
                </p:input>
                <p:input port="in-memory">
                    <p:pipe port="in-memory" step="main"/>
                </p:input>
            </px:fileset-load>
            
        </p:when>
        <p:when test="/*/d:file[ends-with(@href,'/META-INF/container.xml')]">
            <!-- META-INF/container.xml, with fileset base different from EPUB base -->
            <px:fileset-load href="*/META-INF/container.xml" name="container"/>
            <px:fileset-load>
                <p:with-option name="href" select="(/ocf:container/ocf:rootfiles/ocf:rootfile[@media-type='application/oebps-package+xml'])[1]/@full-path"/>
                <p:with-option name="fail-on-not-found" select="$fail-on-not-found"/>
                <p:with-option name="load-if-not-in-memory" select="$load-if-not-in-memory"/>
                <p:input port="fileset">
                    <p:pipe port="fileset" step="main"/>
                </p:input>
                <p:input port="in-memory">
                    <p:pipe port="in-memory" step="main"/>
                </p:input>
            </px:fileset-load>
            
        </p:when>
        <p:otherwise>
            <!-- otherwise just pick the first available OPF in the fileset -->
            <p:delete match="/*/d:file[not(@media-type='application/oebps-package+xml')]"/>
            <p:delete match="/*/d:file[position() &gt; 1]"/>
            <px:fileset-load>
                <p:with-option name="fail-on-not-found" select="$fail-on-not-found"/>
                <p:with-option name="load-if-not-in-memory" select="$load-if-not-in-memory"/>
                <p:input port="in-memory">
                    <p:pipe port="in-memory" step="main"/>
                </p:input>
            </px:fileset-load>
            
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
