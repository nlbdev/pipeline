<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline type="pxi:block-translate" version="1.0"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
            xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
            xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
            exclude-inline-prefixes="#all">

        <p:option name="text-transform" required="true"/>
        <p:option name="no-wrap" select="'false'"/>

        <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>

        <p:declare-step type="px:nfc">
            <p:input port="source"/>
            <p:output port="result"/>
        </p:declare-step>

        <px:nfc/>

        <css:parse-properties properties="display"/>

        <p:xslt>
                <p:input port="stylesheet">
                        <p:document href="block-translate.xsl"/>
                </p:input>
                <p:with-param name="text-transform" select="$text-transform"/>
                <p:with-param name="no-wrap" select="$no-wrap"/>
        </p:xslt>

</p:pipeline>
