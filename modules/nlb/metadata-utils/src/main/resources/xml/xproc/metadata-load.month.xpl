<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:metadata-load.month" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:SRU="http://www.loc.gov/zing/sru/" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" exclude-inline-prefixes="#all" version="1.0">

    <p:option name="time" required="true"/>
    <p:option name="endpoint" select="''"/>
    <p:option name="libraries" select="''"/>

    <p:output port="result" sequence="true">
        <p:pipe port="result" step="result"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>

    <p:declare-step type="pxi:metadata-load.month">
        <p:option name="time" required="true"/>
        <p:option name="endpoint" required="true"/>
        <p:option name="startRecord" required="true"/>

        <p:output port="result" sequence="true">
            <p:pipe port="result" step="part-result"/>
        </p:output>

        <p:variable name="endpoint-href-1"
            select="if ($endpoint) then $endpoint else 'http://websok.nlb.no/cgi-bin/sru?version=1.2&amp;operation=searchRetrieve&amp;recordSchema=bibliofilmarcnoholdings&amp;query=cql.serverChoice='"/>
        <p:variable name="endpoint-href-2" select="concat($endpoint-href-1,'&quot;pre=',$time,'&quot;&amp;startRecord=',$startRecord)"/>
        <p:variable name="endpoint-href" select="if (starts-with($endpoint-href-2,'file:')) then replace($endpoint-href-2,'[&quot;&amp;=]','') else replace($endpoint-href-2,'&quot;','&amp;quot;')"/>

        <p:add-attribute match="/*" attribute-name="href">
            <p:input port="source">
                <p:inline>
                    <c:request method="GET" override-content-type="application/xml"/>
                </p:inline>
            </p:input>
            <p:with-option name="attribute-value" select="$endpoint-href"/>
        </p:add-attribute>
        <px:message message="Henter metadata for $1: $2">
            <p:with-option name="param1"
                select="if (ends-with($time,'01')) then 'januar' else
                if (ends-with($time,'02')) then 'februar' else
                if (ends-with($time,'03')) then 'mars' else
                if (ends-with($time,'04')) then 'april' else
                if (ends-with($time,'05')) then 'mai' else
                if (ends-with($time,'06')) then 'juni' else
                if (ends-with($time,'07')) then 'juli' else
                if (ends-with($time,'08')) then 'august' else
                if (ends-with($time,'09')) then 'september' else
                if (ends-with($time,'10')) then 'oktober' else
                if (ends-with($time,'11')) then 'november' else
                if (ends-with($time,'12')) then 'desember' else
                'ukjent måned'"/>
            <p:with-option name="param2" select="/*/@href"/>
        </px:message>
        <p:http-request name="http-request"/>
        <px:message>
            <p:with-option name="message" select="concat('Hentet liste over ',/*/text(),' produksjoner...')">
                <p:pipe port="result" step="part-count"/>
            </p:with-option>
        </px:message>
        <p:identity name="part-result-document"/>

        <p:choose>
            <p:when test="not(/*/SRU:nextRecordPosition) or /*/SRU:records/SRU:record/SRU:recordPosition/text() = /*/SRU:nextRecordPosition/text() or not(/*/SRU:records/SRU:record/SRU:recordPosition)">
                <!-- no more results -->
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <pxi:metadata-load.month>
                    <p:with-option name="time" select="replace($time,'-','')"/>
                    <p:with-option name="endpoint" select="$endpoint"/>
                    <p:with-option name="startRecord" select="/*/SRU:nextRecordPosition/text()"/>
                </pxi:metadata-load.month>
            </p:otherwise>
        </p:choose>
        <p:identity name="nextRecords"/>

        <p:filter name="thisRecords" select="/*/SRU:records/SRU:record">
            <p:input port="source">
                <p:pipe port="result" step="part-result-document"/>
            </p:input>
        </p:filter>

        <p:identity name="part-result">
            <p:input port="source">
                <p:pipe port="result" step="thisRecords"/>
                <p:pipe port="result" step="nextRecords"/>
            </p:input>
        </p:identity>

        <p:count name="part-count">
            <p:input port="source" select="/*/SRU:records/SRU:record">
                <p:pipe port="result" step="http-request"/>
            </p:input>
        </p:count>
        <p:sink/>
    </p:declare-step>

    <px:message name="production-list-message">
        <p:with-option name="message"
            select="concat('Henter liste over produksjoner fra ',if (contains($endpoint,'?')) then substring-before($endpoint,'?') else if ($endpoint='') then 'standard-plassering' else $endpoint)"/>
    </px:message>

    <pxi:metadata-load.month startRecord="1" name="load">
        <p:with-option name="time" select="replace($time,'-','')"/>
        <p:with-option name="endpoint" select="$endpoint"/>
    </pxi:metadata-load.month>
    <p:for-each>
        <p:choose>
            <p:when test="$libraries != ''">
                <p:split-sequence>
                    <p:with-option name="test" select="concat('//marcxchange:datafield[@tag=''850'']/marcxchange:subfield[@code=''a'']/(for $library in tokenize(''',$libraries,''','' '') return starts-with(text(), $library)) = true()')"/>
                </p:split-sequence>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:for-each>

    <px:message severity="DEBUG">
        <p:with-option name="message" select="concat('Hentet all metadata fra ',/*/text(),' produksjoner.')">
            <p:pipe port="result" step="count"/>
        </p:with-option>
    </px:message>
    <p:for-each>
        <p:add-attribute match="*[not(*)]" attribute-name="xml:space" attribute-value="preserve"/>
    </p:for-each>
    <p:identity name="result"/>

    <p:count name="count">
        <p:input port="source">
            <p:pipe port="result" step="load"/>
        </p:input>
    </p:count>
    <p:sink/>

</p:declare-step>
