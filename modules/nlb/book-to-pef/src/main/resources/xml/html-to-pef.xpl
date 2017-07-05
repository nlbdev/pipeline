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
    
    <p:option name="html" required="true" px:type="anyFileURI" px:sequence="false" px:media-type="application/xhtml+xml text/html">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">HTML</h2>
            <p px:role="desc">HTML-fila du vil konvertere til PEF.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="braille-standard"/>
    <p:option name="hyphenation"/>
    <p:option name="line-spacing"/>
    <p:option name="capital-letters"/>
    <p:option name="stylesheet"/>
    <p:option name="page-width"/>
    <p:option name="page-height"/>
    <p:option name="duplex"/>
    <p:option name="include-captions"/>
    <p:option name="include-images"/>
    <p:option name="include-notes"/>
    <p:option name="include-production-notes"/>
    <p:option name="show-braille-page-numbers"/>
    <p:option name="show-print-page-numbers"/>
    <p:option name="toc-depth"/>
    <p:option name="colophon-metadata-placement"/>
    <p:option name="maximum-number-of-sheets"/>
    <p:option name="pef-output-dir"/>
    <p:option name="preview-output-dir"/>
    <p:option name="temp-dir"/>
    
    <p:import href="http://www.nlb.no/pipeline/modules/braille/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/html-to-pef/html-to-pef.xpl"/>
    
    <px:message message="Running NLB-specific pre-processing steps"/>
    <!--
        Nothing here yet.
        Wait for: https://github.com/snaekobbi/pipeline-mod-braille/issues/63
    -->
    <px:message message="Finished running NLB-specific pre-processing steps" severity="DEBUG"/>
    
    <px:html-to-pef>
        <p:with-option name="html" select="$html"/>
        <p:with-option name="stylesheet" select="concat('http://www.nlb.no/pipeline/modules/braille/default.scss', if ($stylesheet) then concat(' ',$stylesheet) else '')"/>
        <p:with-option name="transform" select="concat('(formatter:dotify)(translator:nlb)',$braille-standard)"/>
        <p:with-option name="main-document-language" select="'no'"/>
        <p:with-option name="include-preview" select="'true'"/>
        <p:with-option name="page-width" select="$page-width"/>
        <p:with-option name="page-height" select="$page-height"/>
        <p:with-option name="duplex" select="$duplex"/>
        <p:with-option name="hyphenation" select="$hyphenation"/>
        <p:with-option name="line-spacing" select="$line-spacing"/>
        <p:with-option name="capital-letters" select="$capital-letters"/>
        <p:with-option name="include-captions" select="$include-captions"/>
        <p:with-option name="include-images" select="$include-images"/>
        <p:with-option name="include-note-references" select="$include-notes"/>
        <p:with-option name="include-production-notes" select="$include-production-notes"/>
        <p:with-option name="show-braille-page-numbers" select="$show-braille-page-numbers"/>
        <p:with-option name="show-print-page-numbers" select="$show-print-page-numbers"/>
        <p:with-option name="toc-depth" select="$toc-depth"/>
        <p:with-option name="colophon-metadata-placement" select="$colophon-metadata-placement"/>
        <p:with-option name="maximum-number-of-sheets" select="$maximum-number-of-sheets"/>
        <p:with-option name="pef-output-dir" select="$pef-output-dir"/>
        <p:with-option name="preview-output-dir" select="$preview-output-dir"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:html-to-pef>
    
</p:declare-step>
