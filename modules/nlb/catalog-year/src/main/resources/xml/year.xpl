<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:nlb="http://metadata.nlb.no/vocabulary/#"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
                xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
                name="catalog-year"
                type="nlb:catalog-year"
                exclude-inline-prefixes="#all"
                xpath-version="2.0"
                version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">NLBs Årskatalog</h1>
        <p px:role="desc">Lager en årskatalog for NLB for et gitt år.</p>
    </p:documentation>

    <p:option name="year" required="true" px:dir="input" px:type="string">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Årstall</h2>
            <p px:role="desc">Året det skal lages årskatalog for.</p>
        </p:documentation>
    </p:option>
    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Resultat</h2>
            <p px:role="desc">Mappe der den ferdige årskatalogen skal lagres.</p>
        </p:documentation>
    </p:option>
    <p:option name="temp-dir" required="true" px:output="temp" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Midlertidig mappe</h2>
        </p:documentation>
    </p:option>

    <!--<p:output port="html-report" px:output="result" px:type="anyDirURI" px:media-type="application/vnd.pipeline.report+xml">
        <p:inline>
            <html xmlns="http://www.w3.org/1999/xhtml"><body><p><stong>Viktig: ODT-filene må åpnes i LibreOffice og lagres på nytt før de kan brukes i Word.</stong></p></body></html>
        </p:inline>
    </p:output>
    
    <p:serialization port="html-report" method="xhtml" indent="true"/>-->
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-html/dtbook-to-html.xpl"/>

    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
    <!--<p:import href="http://www.daisy.org/pipeline/modules/odt-utils/library.xpl"/>-->

    <px:assert message="År må skrives med nøyaktig fire siffer" name="year.assert">
        <p:with-option name="test" select="matches($year,'^\d\d\d\d$')"/>
    </px:assert>
    <p:sink/>
    
    <nlb:metadata-load cx:depends-on="year.assert" libraries="NLB">
        <p:with-option name="time" select="$year"/>
    </nlb:metadata-load>

    <!--<p:identity>
        <p:log port="result" href="file:/tmp/metadata.xml"/>
    </p:identity>-->

    <!--<p:load href="file:/tmp/metadata.xml" cx:depends-on="year.assert"/>
    <p:filter select="/*/*/*"/>-->

    <!--<p:split-sequence test="position() &lt; 100"/>-->

    <nlb:metadata-split name="split"/>

    <!-- Sett inn i riktig kapittel -->
    <p:load href="template.xml"/>
    <p:insert match="//*[@id='braille-adult-fiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="braille-adult-fiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='braille-adult-nonfiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe port="result" step="braille-adult-nonfiction-dewey"/>
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
    <p:insert match="//*[@id='audio-adult-fiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe step="split" port="audio-adult-fiction"/>
        </p:input>
    </p:insert>
    <p:insert match="//*[@id='audio-adult-nonfiction']" position="last-child">
        <p:input port="insertion">
            <p:pipe port="result" step="audio-adult-nonfiction-dewey"/>
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

    <cx:message message="Formaterer metadata som DTBook..."/>
    <p:viewport match="//opf:metadata">
        <p:xslt>
            <p:with-param name="level" select="'4'"/>
            <p:with-param name="extended" select="true()"/>
            <p:with-param name="include-language" select="'true'"/>
            <p:input port="stylesheet">
                <p:document href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/metadata-to-dtbook.xsl"/>
            </p:input>
        </p:xslt>
    </p:viewport>
    
    <p:delete match="//dtbook:level4[count(*)=1]"/>
    <p:delete match="//dtbook:list[@id=('periodical-audio-list','periodical-braille-list') and count(*)=0]"/>
    <p:delete match="//dtbook:level3[count(*)=1]"/>
    <p:delete match="//dtbook:li[parent::dtbook:list[@id=('periodical-audio-list','periodical-braille-list')] and lower-case(.)=preceding-sibling::dtbook:li/lower-case(.)]"/>
    <p:delete match="//dtbook:level2[count(*)=2 and @id='student-audio']"/>
    <p:delete match="//dtbook:level2[count(*)=1]"/>

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/sort-books.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="linegroups-to-tables.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt>
        <p:with-param name="params" select="concat('year=',$year)"/>
        <p:input port="stylesheet">
            <p:document href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/template-engine.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt>
        <p:with-param name="split-type" select="'outer-other'"/>
        <p:input port="stylesheet">
            <p:document href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/dtbook-nlb-language-split.xsl"/>
        </p:input>
    </p:xslt>

    <p:unwrap match="//dtbook:bodymatter//dtbook:level1"/>
    <p:rename match="dtbook:level2" new-name="level1" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="dtbook:h2" new-name="h1" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="dtbook:level3" new-name="level2" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="dtbook:h3" new-name="h2" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="dtbook:level4" new-name="level3" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="dtbook:h4" new-name="h3" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="dtbook:level5" new-name="level4" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="dtbook:h5" new-name="h4" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="dtbook:level6" new-name="level5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    <p:rename match="dtbook:h6" new-name="h5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>

    <p:xslt>
        <p:with-param name="include-adult-nonfiction-dewey" select="true()"/>
        <p:input port="stylesheet">
            <p:document href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/make-toc.xsl"/>
        </p:input>
    </p:xslt>
    <p:delete match="//*[@id='toc']//dtbook:list[dtbook:li/dtbook:lic/dtbook:a[starts-with(@href,'#b_')]]"/>

    <p:group>
        <!-- wrap in level1 -->
        <p:rename match="//dtbook:bodymatter//dtbook:level5" new-name="level6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:bodymatter//dtbook:h5" new-name="h6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:bodymatter//dtbook:level4" new-name="level5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:bodymatter//dtbook:h4" new-name="h5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:bodymatter//dtbook:level3" new-name="level4" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:bodymatter//dtbook:h3" new-name="h4" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:bodymatter//dtbook:level2" new-name="level3" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:bodymatter//dtbook:h2" new-name="h3" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:bodymatter//dtbook:level1" new-name="level2" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:bodymatter//dtbook:h1" new-name="h2" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:identity name="not-wrapped"/>
        <p:for-each>
            <p:iteration-source select="//dtbook:bodymatter/*"/>
            <p:identity/>
        </p:for-each>
        <p:wrap-sequence wrapper="level1" wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/" name="wrapped-level1"/>
        <p:delete match="//dtbook:bodymatter/*">
            <p:input port="source">
                <p:pipe port="result" step="not-wrapped"/>
            </p:input>
        </p:delete>
        <p:insert match="//dtbook:bodymatter" position="first-child">
            <p:input port="insertion">
                <p:pipe port="result" step="wrapped-level1"/>
            </p:input>
        </p:insert>
    </p:group>
    <p:add-attribute match="//*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="concat($output-dir,'DTBook/Årskatalog%20',$year,'.xml')"/>
    </p:add-attribute>
    <p:delete match="//*/@xml:base"/>
    <p:identity name="dtbook"/>
    <p:sink/>
    
    <p:group name="store.braille">
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="dtbook"/>
            </p:input>
        </p:identity>
        <cx:message message="NorBraille cleanup..."/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="http://www.nlb.no/pipeline/modules/nlb-catalog-month/norbraille-cleanup.xsl"/>
            </p:input>
        </p:xslt>
        <p:delete match="@class[not(.='print_toc')]"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="http://www.nlb.no/pipeline/modules/nlb-catalog-month/norbraille-cleanup.whitespace.xsl"/>
            </p:input>
        </p:xslt>
        <p:store doctype-public="-//NISO//DTD dtbook 2005-3//EN" doctype-system="http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd" name="store.norbraille">
            <p:with-option name="href" select="concat($output-dir,'DTBook-NorBraille/Årskatalog%20',$year,'%20-%20NorBraille-tilpasset.xml')"/>
        </p:store>
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="store.norbraille"/>
            </p:input>
        </p:identity>
        
        <!-- TODO: bruk nlb:book-to-pef her istedenfor, sånn at vi får en faktisk PEF og ikke bare en NorBraille-tilpasset DTBok -->
    </p:group>
    <p:sink/>
    
    <p:store doctype-public="-//NISO//DTD dtbook 2005-3//EN" doctype-system="http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd" name="store.dtbook" cx:depends-on="store.braille">
        <p:with-option name="href" select="concat($output-dir,'DTBook/Årskatalog%20',$year,'.xml')"/>
        <p:input port="source">
            <p:pipe port="result" step="dtbook"/>
        </p:input>
    </p:store>

    <p:group name="copy-resources" cx:depends-on="store.dtbook">
        <px:mkdir name="mkdir.html">
            <p:with-option name="href" select="concat($output-dir,'HTML/')"/>
        </px:mkdir>
        
        <px:message message="copying $1 to $2" cx:depends-on="mkdir.html" name="resource.1.message">
            <p:with-option name="param1" select="resolve-uri('dtbook.css',static-base-uri())"/>
            <p:with-option name="param2" select="concat($output-dir,'DTBook/dtbook.css')"/>
        </px:message>
        <px:copy-resource cx:depends-on="resource.1.message" name="resource.1">
            <p:with-option name="href" select="resolve-uri('dtbook.css',static-base-uri())"/>
            <p:with-option name="target" select="concat($output-dir,'DTBook/dtbook.css')"/>
        </px:copy-resource>
        <p:sink/>
        
        <px:message message="copying $1 to $2" cx:depends-on="resource.1" name="resource.2.message">
            <p:with-option name="param1" select="resolve-uri('NLB_logo_blå.jpg',static-base-uri())"/>
            <p:with-option name="param2" select="concat($output-dir,'DTBook/NLB_logo_blå.jpg')"/>
        </px:message>
        <px:copy-resource cx:depends-on="resource.2.message" name="resource.2">
            <p:with-option name="href" select="resolve-uri('NLB_logo_blå.jpg',static-base-uri())"/>
            <p:with-option name="target" select="concat($output-dir,'DTBook/NLB_logo_blå.jpg')"/>
        </px:copy-resource>
        <p:sink/>
        
        <px:message message="copying $1 to $2" cx:depends-on="resource.2" name="resource.3.message">
            <p:with-option name="param1" select="resolve-uri('html.css',static-base-uri())"/>
            <p:with-option name="param2" select="concat($output-dir,'HTML/html.css')"/>
        </px:message>
        <px:copy-resource cx:depends-on="resource.3.message" name="resource.3">
            <p:with-option name="href" select="resolve-uri('html.css',static-base-uri())"/>
            <p:with-option name="target" select="concat($output-dir,'HTML/html.css')"/>
        </px:copy-resource>
        <p:sink/>
        
        <px:message message="copying $1 to $2" cx:depends-on="resource.3" name="resource.4.message">
            <p:with-option name="param1" select="resolve-uri('NLB_logo_blå.jpg',static-base-uri())"/>
            <p:with-option name="param2" select="concat($output-dir,'HTML/NLB_logo_blå.jpg')"/>
        </px:message>
        <px:copy-resource cx:depends-on="resource.4.message" name="resource.4">
            <p:with-option name="href" select="resolve-uri('NLB_logo_blå.jpg',static-base-uri())"/>
            <p:with-option name="target" select="concat($output-dir,'HTML/NLB_logo_blå.jpg')"/>
        </px:copy-resource>
    </p:group>
    <p:sink/>

    <p:group name="html" cx:depends-on="copy-resources">
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="dtbook"/>
            </p:input>
        </p:identity>
        <cx:message message="dtbook-to-html..."/>
        <px:dtbook-to-html assert-valid="false" name="dtbook-to-html">
            <p:with-option name="language" select="'no'"/>
            <p:with-option name="output-dir" select="concat($temp-dir,'HTML/')"/>
        </px:dtbook-to-html>
        <p:directory-list cx:depends-on="dtbook-to-html">
            <p:with-option name="path" select="concat($temp-dir,'HTML/')"/>
        </p:directory-list>
        <p:load>
            <p:with-option name="href" select="concat($temp-dir,'HTML/',/*/*[ends-with(@name,'html')][1]/@name)"/>
        </p:load>
        <p:insert match="/*/*[1]" position="last-child">
            <p:input port="insertion">
                <p:inline xmlns="http://www.w3.org/1999/xhtml">
                    <link rel="stylesheet" type="text/css" href="html.css"/>
                </p:inline>
            </p:input>
        </p:insert>
        <p:replace match="/*/*[1]/html:title">
            <p:input port="replacement">
                <p:inline xmlns="http://www.w3.org/1999/xhtml">
                    <title>REPLACEME</title>
                </p:inline>
            </p:input>
        </p:replace>
        <p:string-replace match="/*/*[1]/html:title/text()">
            <p:with-option name="replace" select="concat('''Årskatalog for ',$year,'''')"/>
        </p:string-replace>
        <p:store indent="true" include-content-type="true" method="xhtml" name="store.html.wrong-doctype" omit-xml-declaration="true">
            <p:with-option name="href" select="concat($output-dir,'HTML/Årskatalog%20',$year,'.html')"/>
        </p:store>
        <px:set-doctype doctype="&lt;!DOCTYPE html&gt;" name="store.html">
            <p:with-option name="href" select="/*/text()">
                <p:pipe port="result" step="store.html.wrong-doctype"/>
            </p:with-option>
        </px:set-doctype>
    </p:group>
    <p:sink/>
    <!--<p:group name="odt" cx:depends-on="copy-resources">
        <px:dtbook-load name="dtbook.load">
            <p:input port="source">
                <p:pipe step="dtbook" port="result"/>
            </p:input>
        </px:dtbook-load>
        
        <px:dtbook-to-odt.convert name="odt">
            <p:input port="content.xsl">
                <p:document href="http://www.daisy.org/pipeline/modules/dtbook-to-odt/content.xsl"/>
            </p:input>
            <p:input port="fileset.in">
                <p:pipe step="dtbook.load" port="fileset.out"/>
            </p:input>
            <p:input port="in-memory.in">
                <p:pipe step="dtbook.load" port="in-memory.out"/>
            </p:input>
            <p:input port="meta">
                <p:empty/>
            </p:input>
            <p:with-option name="temp-dir" select="concat($temp-dir,'ODT/')"/>
            <p:with-option name="template" select="resolve-uri('../templates/nlb.ott')">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
            <p:with-option name="asciimath" select="'ASCIIMATH'"/>
            <p:with-option name="images" select="'EMBED'"/>
        </px:dtbook-to-odt.convert>
        
        <odt:store name="store">
            <p:input port="fileset.in">
                <p:pipe step="odt" port="fileset.out"/>
            </p:input>
            <p:input port="in-memory.in">
                <p:pipe step="odt" port="in-memory.out"/>
            </p:input>
            <p:with-option name="href" select="concat($output-dir, '/', replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1'), '.odt')">
                <p:pipe step="dtbook-to-odt" port="source"/>
            </p:with-option>
        </odt:store>
    </p:group>-->

    <!-- #### stuff that's not connected with default connections (not part of the "flow") #### -->

    <p:identity>
        <p:input port="source">
            <p:pipe step="split" port="braille-adult-nonfiction"/>
        </p:input>
    </p:identity>
    <p:for-each>
        <p:xslt>
            <p:with-param name="level" select="'4'"/>
            <p:with-param name="extended" select="true()"/>
            <p:with-param name="include-language" select="'true'"/>
            <p:input port="stylesheet">
                <p:document href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/metadata-to-dtbook.xsl"/>
            </p:input>
        </p:xslt>
    </p:for-each>
    <nlb:catalog-dewey-split name="braille-adult-nonfiction-dewey" id-prefix="braille-adult-nonfiction"/>

    <p:identity>
        <p:input port="source">
            <p:pipe step="split" port="audio-adult-nonfiction"/>
        </p:input>
    </p:identity>
    <p:for-each>
        <p:xslt>
            <p:with-param name="level" select="'4'"/>
            <p:with-param name="extended" select="true()"/>
            <p:with-param name="include-language" select="'true'"/>
            <p:input port="stylesheet">
                <p:document href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/metadata-to-dtbook.xsl"/>
            </p:input>
        </p:xslt>
    </p:for-each>
    <nlb:catalog-dewey-split name="audio-adult-nonfiction-dewey" id-prefix="audio-adult-nonfiction"/>

</p:declare-step>
