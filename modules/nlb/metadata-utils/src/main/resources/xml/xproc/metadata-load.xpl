<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:metadata-load" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:SRU="http://www.loc.gov/zing/sru/" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" exclude-inline-prefixes="#all" version="1.0">

    <p:option name="time" required="true"/>
    <p:option name="endpoint" select="''"/>
    <p:option name="libraries" select="''"/>

    <p:output port="result" sequence="true"/>

    <p:import href="metadata-load.month.xpl"/>
    <p:import href="metadata-load.year.xpl"/>

    <p:choose>
        <p:when test="matches($time,'^\d\d\d\d$')">
            <nlb:metadata-load.year>
                <p:with-option name="time" select="$time"/>
                <p:with-option name="endpoint" select="$endpoint"/>
                <p:with-option name="libraries" select="$libraries"/>
            </nlb:metadata-load.year>
        </p:when>
        <p:otherwise>
            <nlb:metadata-load.month>
                <p:with-option name="time" select="$time"/>
                <p:with-option name="endpoint" select="$endpoint"/>
                <p:with-option name="libraries" select="$libraries"/>
            </nlb:metadata-load.month>
        </p:otherwise>
    </p:choose>

</p:declare-step>
