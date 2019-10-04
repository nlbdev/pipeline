<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:metadata-load.year" xmlns:p="http://www.w3.org/ns/xproc" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" exclude-inline-prefixes="#all" version="1.0">

    <p:option name="time" required="true"/>
    <p:option name="endpoint" select="''"/>
    <p:option name="libraries" select="''"/>

    <p:output port="result" sequence="true">
        <p:pipe port="result" step="load.01"/>
        <p:pipe port="result" step="load.02"/>
        <p:pipe port="result" step="load.03"/>
        <p:pipe port="result" step="load.04"/>
        <p:pipe port="result" step="load.05"/>
        <p:pipe port="result" step="load.06"/>
        <p:pipe port="result" step="load.07"/>
        <p:pipe port="result" step="load.08"/>
        <p:pipe port="result" step="load.09"/>
        <p:pipe port="result" step="load.10"/>
        <p:pipe port="result" step="load.11"/>
        <p:pipe port="result" step="load.12"/>
    </p:output>

    <p:import href="metadata-load.month.xpl"/>

    <nlb:metadata-load.month name="load.01">
        <p:with-option name="time" select="concat($time,'01')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.02">
        <p:with-option name="time" select="concat($time,'02')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.03">
        <p:with-option name="time" select="concat($time,'03')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.04">
        <p:with-option name="time" select="concat($time,'04')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.05">
        <p:with-option name="time" select="concat($time,'05')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.06">
        <p:with-option name="time" select="concat($time,'06')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.07">
        <p:with-option name="time" select="concat($time,'07')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.08">
        <p:with-option name="time" select="concat($time,'08')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.09">
        <p:with-option name="time" select="concat($time,'09')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.10">
        <p:with-option name="time" select="concat($time,'10')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.11">
        <p:with-option name="time" select="concat($time,'11')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

    <nlb:metadata-load.month name="load.12">
        <p:with-option name="time" select="concat($time,'12')"/>
        <p:with-option name="libraries" select="$libraries"/>
    </nlb:metadata-load.month>
    <p:sink/>

</p:declare-step>
