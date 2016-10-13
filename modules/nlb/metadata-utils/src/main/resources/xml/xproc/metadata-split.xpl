<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:metadata-split" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:h="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all" version="1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf">

    <p:input sequence="true" port="source"/>
    
    <!--<p:log port="periodical-audio" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.periodical-audio.xml"/>
    <p:log port="periodical-braille" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.periodical-braille.xml"/>
    <p:log port="braille-adult-fiction" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.braille-adult-fiction.xml"/>
    <p:log port="braille-adult-nonfiction" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.braille-adult-nonfiction.xml"/>
    <p:log port="braille-juvenile-fiction" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.braille-juvenile-fiction.xml"/>
    <p:log port="braille-juvenile-nonfiction" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.braille-juvenile-nonfiction.xml"/>
    <p:log port="braille-student" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.braille-student.xml"/>
    <p:log port="audio-adult-fiction" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.audio-adult-fiction.xml"/>
    <p:log port="audio-adult-nonfiction" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.audio-adult-nonfiction.xml"/>
    <p:log port="audio-juvenile-fiction" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.audio-juvenile-fiction.xml"/>
    <p:log port="audio-juvenile-nonfiction" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.audio-juvenile-nonfiction.xml"/>
    <p:log port="audio-student" href="file:/home/jostein/nlb/nlb-pipeline-modules/nlb-metadata-utils/src/test/resources/metadata-split.output.audio-student.xml"/>-->
    
    <p:output sequence="true" port="periodical-audio">
        <p:pipe port="result" step="periodical-audio"/>
    </p:output>
    <p:output sequence="true" port="periodical-braille">
        <p:pipe port="result" step="periodical-braille"/>
    </p:output>
    <p:output sequence="true" port="braille-adult-fiction">
        <p:pipe port="result" step="braille-adult-fiction"/>
    </p:output>
    <p:output sequence="true" port="braille-adult-nonfiction">
        <p:pipe port="result" step="braille-adult-nonfiction"/>
    </p:output>
    <p:output sequence="true" port="braille-juvenile-fiction">
        <p:pipe port="result" step="braille-juvenile-fiction"/>
    </p:output>
    <p:output sequence="true" port="braille-juvenile-nonfiction">
        <p:pipe port="result" step="braille-juvenile-nonfiction"/>
    </p:output>
    <p:output sequence="true" port="braille-student">
        <p:pipe port="result" step="braille-student"/>
    </p:output>
    <p:output sequence="true" port="audio-adult-fiction">
        <p:pipe port="result" step="audio-adult-fiction"/>
    </p:output>
    <p:output sequence="true" port="audio-adult-nonfiction">
        <p:pipe port="result" step="audio-adult-nonfiction"/>
    </p:output>
    <p:output sequence="true" port="audio-juvenile-fiction">
        <p:pipe port="result" step="audio-juvenile-fiction"/>
    </p:output>
    <p:output sequence="true" port="audio-juvenile-nonfiction">
        <p:pipe port="result" step="audio-juvenile-nonfiction"/>
    </p:output>
    <p:output sequence="true" port="audio-student">
        <p:pipe port="result" step="audio-student"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    
    <p:for-each>
        <p:filter select="//marcxchange:record"/>
    </p:for-each>
    
    <px:message message="Konverterer metadata fra MARCXML (NORMARC) til OPF (Dublin Core, ++)"/>
    <p:for-each>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/marcxchange-to-opf/marcxchange-to-opf.xsl"/>
            </p:input>
        </p:xslt>
    </p:for-each>

    <px:message message="Splitter metadata i kategorier..."/>
    <p:for-each>
        <p:add-attribute attribute-name="format" match="/*">
            <p:with-option name="attribute-value" select="/*/dc:format[not(@refines)]/text()"/>
        </p:add-attribute>
        <p:add-attribute attribute-name="audience" match="/*">
            <p:with-option name="attribute-value" select="if (/*/opf:meta[not(@refines)][@property='audience']/text()='Student') then 'Student' else (/*/opf:meta[not(@refines)][@property='audience' and text()=('Adult','Juvenile')]/text())[1]"/>
        </p:add-attribute>
        <p:add-attribute attribute-name="genre" match="/*">
            <p:with-option name="attribute-value" select="(/*/opf:meta[not(@refines)][@property='dc:type.genre' and text()=('Fiction','Non-fiction')])[1]/text()"/>
        </p:add-attribute>
        <p:add-attribute attribute-name="periodical" match="/*">
            <p:with-option name="attribute-value" select="/*/opf:meta[not(@refines)][@property='periodical']/text() = 'true' or (/*/dc:subject | /*/opf:meta[@property='dc:subject.keyword'])[not(@refines)]/text() = 'Tidsskrifter'"/>
        </p:add-attribute>
    </p:for-each>
    
    <p:split-sequence name="periodical-split" test="/*[@periodical='false']"/>

    <!-- Del opp i separate sekvenser tilhørende hvert kapittel -->
    <p:split-sequence test="/*[@format='Braille' and @audience='Adult' and @genre='Fiction']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="braille-adult-fiction"/>

    <p:split-sequence test="/*[@format='Braille' and @audience='Adult' and @genre='Non-fiction']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="braille-adult-nonfiction"/>

    <p:split-sequence test="/*[@format='Braille' and @audience='Juvenile' and @genre='Fiction']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="braille-juvenile-fiction"/>

    <p:split-sequence test="/*[@format='Braille' and @audience='Juvenile' and @genre='Non-fiction']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="braille-juvenile-nonfiction"/>

    <p:split-sequence test="/*[@format='Braille' and @audience='Student']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="braille-student"/>

    <p:split-sequence test="/*[@format='DAISY 2.02' and @audience='Adult' and @genre='Fiction']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="audio-adult-fiction"/>

    <p:split-sequence test="/*[@format='DAISY 2.02' and @audience='Adult' and @genre='Non-fiction']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="audio-adult-nonfiction"/>

    <p:split-sequence test="/*[@format='DAISY 2.02' and @audience='Juvenile' and @genre='Fiction']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="audio-juvenile-fiction"/>

    <p:split-sequence test="/*[@format='DAISY 2.02' and @audience='Juvenile' and @genre='Non-fiction']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="audio-juvenile-nonfiction"/>

    <p:split-sequence test="/*[@format='DAISY 2.02' and @audience='Student']">
        <p:input port="source">
            <p:pipe port="matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="audio-student"/>

    <p:split-sequence test="/*/@format='DAISY 2.02'">
        <p:input port="source">
            <p:pipe port="not-matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="periodical-audio"/>

    <p:split-sequence test="/*/@format='Braille'">
        <p:input port="source">
            <p:pipe port="not-matched" step="periodical-split"/>
        </p:input>
    </p:split-sequence>
    <p:for-each>
        <p:delete match="/*/@format | /*/@audience | /*/@genre | /*/@periodical"/>
    </p:for-each>
    <p:identity name="periodical-braille"/>

</p:declare-step>
