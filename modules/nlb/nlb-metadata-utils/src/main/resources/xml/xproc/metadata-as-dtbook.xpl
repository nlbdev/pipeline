<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="nlb:metadata-as-dtbook" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:opf="http://www.idpf.org/2007/opf">

    <p:input port="dtbook-template" primary="true"/>
    <p:input port="php-time"/>

    <p:output port="result" primary="false" sequence="true">
        <p:pipe port="result" step="result"/>
    </p:output>

    <p:option name="metadata-endpoint" select="''"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="metadata-load.xpl"/>
    <p:import href="metadata-split.xpl"/>

    <nlb:metadata-load libraries="NLB">
        <p:with-option name="time" select="/*/@previous-month">
            <p:pipe port="php-time" step="main"/>
        </p:with-option>
        <p:with-option name="endpoint" select="$metadata-endpoint"/>
    </nlb:metadata-load>

    <nlb:metadata-split name="split"/>

    <!-- Sett inn i riktig kapittel -->
    <p:identity>
        <p:input port="source">
            <p:pipe port="dtbook-template" step="main"/>
        </p:input>
    </p:identity>
    <p:insert match="//*[@id='periodical-audio-list']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="periodical-audio"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='periodical-braille-list']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="periodical-braille"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='braille-adult-fiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="braille-adult-fiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='braille-adult-nonfiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="braille-adult-nonfiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='braille-juvenile-fiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="braille-juvenile-fiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='braille-juvenile-nonfiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="braille-juvenile-nonfiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='student-braille']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="braille-student"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='audio-adult-fiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="audio-adult-fiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='audio-adult-nonfiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="audio-adult-nonfiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='audio-juvenile-fiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="audio-juvenile-fiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='audio-juvenile-nonfiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="audio-juvenile-nonfiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='student-audio']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="audio-student"/>
        </p:input>
    </p:insert>

    <cx:message message="Konverterer metadata til DTBook..."/>
    <p:viewport match="//opf:metadata">
        <p:xslt>
            <p:with-param name="level" select="'3'"/>
            <p:with-param name="include-field" select="'genre'"/>
            <p:input port="stylesheet">
                <p:document href="../xslt/metadata-to-dtbook.xsl"/>
            </p:input>
        </p:xslt>
    </p:viewport>

    <p:delete match="//dtbook:level3[count(*)=1]"/>
    <p:delete match="//dtbook:list[@id=('periodical-audio-list','periodical-braille-list') and count(*)=0]"/>
    <p:delete match="//dtbook:level2[count(*)=1]"/>
    <p:delete match="//dtbook:li[parent::dtbook:list[@id=('periodical-audio-list','periodical-braille-list')] and lower-case(.)=preceding-sibling::dtbook:li/lower-case(.)]"/>
    <p:delete match="//dtbook:level1[count(*)=2 and @id='student-audio']"/>
    <p:delete match="//dtbook:level1[count(*)=1]"/>

    <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:h3" new-name="h2" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:h4" new-name="h3" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:h5" new-name="h4" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:h6" new-name="h5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:level3" new-name="level2" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:level4" new-name="level3" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:level5" new-name="level4" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:level6" new-name="level5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/sort-books.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt>
        <p:with-param name="params" select="lower-case(concat('year=',/*/@Y,'|month=',lower-case(/*/@F)))">
            <p:pipe port="php-time" step="main"/>
        </p:with-param>
        <p:input port="stylesheet">
            <p:document href="../xslt/template-engine.xsl"/>
        </p:input>
    </p:xslt>

    <p:identity name="result"/>

</p:declare-step>
