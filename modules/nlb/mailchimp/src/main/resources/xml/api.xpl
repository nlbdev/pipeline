<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0">

    <p:declare-step type="nlb:www-form-urlencode" name="www-form-urlencode">
        <p:input port="parameters"/>
        <p:output port="result"/>

        <p:viewport match="/*/*" name="www-form-urlencode.encoded-set">
            <p:add-attribute match="/*" attribute-name="encoded" attribute-value=""/>
            <p:www-form-urlencode match="/*/@encoded">
                <p:with-param name="param" select="/*/@value"/>
            </p:www-form-urlencode>
            <p:add-attribute match="/*" attribute-name="encoded">
                <p:with-option name="attribute-value" select="concat(/*/@name,replace(/*/@encoded,'^param',''))"/>
            </p:add-attribute>
        </p:viewport>

        <p:template>
            <p:input port="template">
                <p:inline>
                    <c:body content-type="application/x-www-form-urlencoded">{string-join(/*/*/@encoded,'&amp;')}</c:body>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:template>
    </p:declare-step>

    <p:declare-step type="nlb:mailchimp-request" name="mailchimp-request">

        <p:input port="parameters"/>

        <p:option name="endpoint" select="'https://us6.api.mailchimp.com/2.0/'"/>
        <p:option name="apikey"/> <!-- for instance: 0123456789abcdef0123456789abcdef-us1 -->
        <p:option name="method" select="'helper/ping'"/>

        <p:output port="result" sequence="true"/>

        <nlb:www-form-urlencode name="mailchimp-request.body"/>

        <p:in-scope-names name="vars"/>

        <p:template>
            <p:input port="template">
                <p:inline>
                    <c:request method="POST" href="{$endpoint}{$method}.xml?apikey={$apikey}">
                        <c:header name="Accept" value="text/plain"/>{/*}</c:request>
                </p:inline>
            </p:input>
            <p:input port="source">
                <p:pipe step="mailchimp-request.body" port="result"/>
            </p:input>
            <p:input port="parameters">
                <p:pipe step="vars" port="result"/>
            </p:input>
        </p:template>

        <p:http-request/>

    </p:declare-step>

</p:library>
