<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="nlb:news-as-html" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0">
    
    <p:documentation>deprecated: use nlb:news instead</p:documentation>
    
    <p:output port="result" primary="false">
        <p:pipe port="result" step="news"/>
    </p:output>
    
    <p:option name="month" required="true"/>
    
    <p:import href="news.xpl"/>
    
    <nlb:news name="news">
        <p:with-option name="month" select="$month"/>
    </nlb:news>

</p:declare-step>
