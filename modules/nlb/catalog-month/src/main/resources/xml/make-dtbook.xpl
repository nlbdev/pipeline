<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="nlb:make-dtbook" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0">

    <p:input port="news-as-html" primary="false"/>
    <p:input port="metadata-as-dtbook" primary="false"/>
    <p:input port="php-time" primary="false"/>

    <p:option name="output-dir" required="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.nlb.no/pipeline/modules/html-to-dtbook/html-to-dtbook.convert.xpl"/>

    <!-- Konverter nyheter til DTBook -->
    <p:group name="dtbook.news">
        <p:output port="result"/>

        <p:identity>
            <p:input port="source">
                <p:pipe port="news-as-html" step="main"/>
            </p:input>
        </p:identity>
        <cx:message message="Konverter nyheter til DTBook"/>
        <p:delete match="//html:a[@class='nlb.news.articleLink']"/>
        <p:wrap-sequence wrapper="body" wrapper-namespace="http://www.w3.org/1999/xhtml"/>
        <p:wrap-sequence wrapper="html" wrapper-namespace="http://www.w3.org/1999/xhtml"/>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="p:resolve-uri('news.xml',$output-dir)"/>
        </p:add-attribute>
        <p:delete match="/*/@xml:base"/>
        <p:identity name="dtbook.news.xhtml"/>

        <px:fileset-create>
            <p:with-option name="base" select="$output-dir"/>
        </px:fileset-create>
        <px:fileset-add-entry media-type="application/xhtml+xml">
            <p:with-option name="href" select="base-uri(/*)">
                <p:pipe port="result" step="dtbook.news.xhtml"/>
            </p:with-option>
        </px:fileset-add-entry>
        <p:identity name="dtbook.news.fileset"/>

        <px:html-to-dtbook-convert name="dtbook.news.convert">
            <p:with-option name="output-dir" select="$output-dir"/>
            <p:input port="in-memory.in">
                <p:pipe port="result" step="dtbook.news.xhtml"/>
            </p:input>
            <p:input port="fileset.in">
                <p:pipe port="result" step="dtbook.news.fileset"/>
            </p:input>
        </px:html-to-dtbook-convert>
        <p:sink/>

        <p:identity>
            <p:input port="source">
                <p:pipe port="in-memory.out" step="dtbook.news.convert"/>
            </p:input>
        </p:identity>
        <p:delete match="//*[(self::dtbook:p or self::dtbook:div) and normalize-space(string-join(descendant::text(),''))='']"/>
        <p:wrap match="//node()[(self::dtbook:strong or self::dtbook:span or self::text() and not(normalize-space()='')) and not(ancestor::*/local-name()=('p','h1','h2','h3','h4','h5','h6','doctitle','docauthor','lic','span','strong'))]" wrapper="p" wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:viewport match="//dtbook:level1 | //dtbook:level2 | //dtbook:level3 | //dtbook:level4 | //dtbook:level5 | //dtbook:level6">
            <p:add-attribute match="/*" attribute-name="id">
                <p:with-option name="attribute-value" select="concat('h_',(p:iteration-position()-1))"/>
            </p:add-attribute>
        </p:viewport>
    </p:group>
    <p:sink/>

    <!-- Sett nyheter inn i bokliste og lagre DTBok -->
    <p:group>
        <p:identity>
            <p:input port="source">
                <p:pipe port="metadata-as-dtbook" step="main"/>
            </p:input>
        </p:identity>
        
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="norbraille-cleanup.xsl"/>
            </p:input>
        </p:xslt>
        
        <!-- nyheter -->
        <p:insert match="/dtbook:dtbook/dtbook:book/dtbook:bodymatter" position="first-child">
            <p:input port="insertion" select="/dtbook:dtbook/dtbook:book/dtbook:bodymatter/*">
                <p:pipe port="result" step="dtbook.news"/>
            </p:input>
        </p:insert>
        
        <!-- innholdsfortegnelse -->
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/make-toc.xsl"/>
            </p:input>
        </p:xslt>
        
        <!-- fjern bilder (inkl. bildebeskrivelser) -->
        <p:delete match="dtbook:img"/>
        
        <!-- NorBraille cleanup -->
        <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:h5" new-name="h6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:h4" new-name="h5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:h3" new-name="h4" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:h2" new-name="h3" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:level5" new-name="level6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:level4" new-name="level5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:level3" new-name="level4" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="//dtbook:level1[@id='student-audio']//dtbook:level2" new-name="level3" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.daisy.org/z3986/2005/dtbook/" xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/" version="2.0">
                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="level1[@id='student-audio']">
                            <xsl:copy>
                                <xsl:copy-of select="@*"/>
                                <xsl:copy-of select="*[position()&lt;=2]"/>
                                <level2>
                                    <h2/>
                                    <xsl:apply-templates select="*[position()&gt;2]"/>
                                </level2>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>
        
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="norbraille-cleanup.xsl"/>
            </p:input>
        </p:xslt>
        <p:delete match="@class[not(.='print_toc')]"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="norbraille-cleanup.whitespace.xsl"/>
            </p:input>
        </p:xslt>

        <p:store doctype-public="-//NISO//DTD dtbook 2005-3//EN" doctype-system="http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd" indent="false">
            <p:with-option name="href" select="concat($output-dir,'Nyhetsbrev%20',lower-case(/*/@F),'%20',/*/@Y,'.xml')">
                <p:pipe port="php-time" step="main"/>
            </p:with-option>
        </p:store>
    </p:group>

</p:declare-step>
