<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:dotify="http://code.google.com/p/dotify/"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                type="dotify:format"
                version="1.0">
    
    <p:input port="source"/>
    <p:output port="result" primary="true"/>
    <p:output port="obfl" sequence="false">
        <p:pipe step="obfl" port="result"/>
    </p:output>
    
    <p:option name="text-transform" select="''"/>
    <p:option name="skip-margin-top-of-page" select="'false'"/>
    
    <p:import href="../../main/resources/xml/css-to-obfl.xpl"/>
    <p:import href="../../main/resources/xml/obfl-normalize-space.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/dotify-utils/library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:variable name="allow-text-overflow-trimming" select="'true'"/>
    
    <cx:message>
        <p:with-option name="message" select="concat('Running test from ',replace(base-uri(),'.*/',''))"/>
    </cx:message>
    <cx:message message="    Running pxi:css-to-obfl"/>
    <pxi:css-to-obfl name="obfl" duplex="true">
        <p:with-option name="text-transform" select="concat($text-transform,'(input:text-css)(output:braille)')"/>
        <p:with-option name="skip-margin-top-of-page" select="$skip-margin-top-of-page"/>
    </pxi:css-to-obfl>
    <cx:message message="    Running pxi:obfl-normalize-space"/>
    <pxi:obfl-normalize-space/>
    <cx:message message="    Running dotify:obfl-to-pef"/>
    <dotify:obfl-to-pef locale="und">
        <p:with-option name="mode" select="concat($text-transform,'(input:text-css)(output:braille)')"/>
        <p:with-param port="parameters" name="allow-text-overflow-trimming" select="$allow-text-overflow-trimming"/>
    </dotify:obfl-to-pef>
    <cx:message message="    Test run complete"/>
    
</p:declare-step>
