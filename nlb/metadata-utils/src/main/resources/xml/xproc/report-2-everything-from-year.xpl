<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="nlb:report-2-everything-from-year" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:SRU="http://www.loc.gov/zing/sru/" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" exclude-inline-prefixes="#all" version="1.0"
    xpath-version="2.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Rapport 2: Alle titler for et gitt år</h1>
        <p px:role="desc">Regneark med oversikt over alle titler gjort tilgjengelig for utlån et gitt år (samt MARC XML).</p>
    </p:documentation>

    <p:output port="report" primary="true" px:media-type="application/vnd.pipeline.report+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Rapport</h2>
            <p px:role="desc">Viser kort statistikk over metadataen som ble hentet.</p>
        </p:documentation>
    </p:output>

    <p:option name="csv-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Regneark</h2>
            <p px:role="desc">Inneholder oversikt over alle titler gjort tilgjengelig for det gitte året.</p>
        </p:documentation>
    </p:option>

    <p:option name="marcxml-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">MARC XML</h2>
            <p px:role="desc">Lagrer MARC XML for alle produksjoner dette året.</p>
        </p:documentation>
    </p:option>

    <p:option name="year" required="true" px:dir="input" px:type="string">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Årstall</h2>
            <p px:role="desc">Året det skal lages regneark for.</p>
        </p:documentation>
    </p:option>

    <p:option name="author-in-columns" select="'true'" px:dir="input" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Lag separate kolonner for forfatter or oversetter</h2>
            <p px:role="desc">Med separate kolonner vil det kun vises én rad per bok.</p>
        </p:documentation>
    </p:option>

    <p:option name="narrator-in-columns" select="'true'" px:dir="input" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Lag separate kolonner for innlesere</h2>
            <p px:role="desc">Med separate kolonner vil det kun vises én rad per bok, med mindre forfatter-kolonner er deaktivert. Forfatter- og innleser-kolonner kan ikke være deaktivert
                samtidig.</p>
        </p:documentation>
    </p:option>

    <p:option name="library" select="'NLB'" px:dir="input" px:type="string">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Bibliotek</h2>
            <p px:role="desc">For eksempel 'NLB' eller 'KABB'.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="metadata-load.xpl"/>

    <px:assert message="År må skrives med nøyaktig fire siffer" name="year.assert">
        <p:with-option name="test" select="matches($year,'^\d\d\d\d$')"/>
    </px:assert>
    <p:sink/>

    <nlb:metadata-load cx:depends-on="year.assert">
        <p:with-option name="time" select="$year"/>
    <p:with-option name="libraries" select="if ($library='') then 'NLB' else $library"/>
    </nlb:metadata-load>

    <p:for-each name="for-each">
        <p:variable name="identifier" select="/*/*/*/*[@tag='090']/*[@code='a']/text()"/>

        <px:assert message="Klarte ikke å finne boknummer i 090$a...">
            <p:with-option name="test" select="not($identifier='')"/>
        </px:assert>
        <px:message message="Behandler $1...">
            <p:with-option name="param1" select="$identifier"/>
        </px:message>

        <p:store indent="true">
            <p:with-option name="href" select="concat($marcxml-dir,'/MARCXML-',$identifier,'.xml')"/>
        </p:store>

        <p:xslt>
            <p:input port="source">
                <p:pipe port="current" step="for-each"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/marcxchange-to-opf/marcxchange-to-opf.xsl"/>
            </p:input>
        </p:xslt>

        <p:xslt>
            <p:with-param name="extended" select="'true'"/>
            <p:with-param name="include-categorization-attributes" select="'true'"/>
            <p:input port="stylesheet">
                <p:document href="../xslt/metadata-to-dtbook.xsl"/>
            </p:input>
        </p:xslt>

    </p:for-each>

    <p:wrap-sequence wrapper="wrapper" name="wrapped-dtbook" wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:xslt template-name="main">
        <p:with-param name="author-in-columns" select="$author-in-columns"/>
        <p:with-param name="narrator-in-columns" select="$narrator-in-columns"/>
        <p:input port="stylesheet">
            <p:document href="../xslt/dtbook-metadata-to-csv.xsl"/>
        </p:input>
    </p:xslt>
    <p:store method="text">
        <p:with-option name="href" select="concat($csv-dir,'/Metadata_for_',$year,'.csv')"/>
    </p:store>

    <p:xslt>
        <p:input port="source">
            <p:pipe port="result" step="wrapped-dtbook"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/wrapped-dtbook-to-short-html-statistics.xsl"/>
        </p:input>
    </p:xslt>

</p:declare-step>
