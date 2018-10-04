<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="nlb:make-html" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0">
    
    <p:input port="news-as-html" primary="false"/>
    <p:input port="metadata-as-dtbook" primary="false"/>
    <p:input port="php-time" primary="false"/>
    
    <p:option name="output-dir" required="true"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    
    <!-- Rydd opp litt i nyhetene -->
    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="news-as-html"/>
        </p:input>
    </p:identity>
    <p:delete match="//html:a[@class='nlb.news.articleLink']"/>
    <p:delete match="//*[(self::html:p or self::html:div) and normalize-space(string-join(descendant::text(),''))='']"/>
    <p:wrap match="//node()[(self::html:strong or self::html:span or self::text() and not(normalize-space()='')) and not(ancestor::*/local-name()=('p','h1','h2','h3','h4','h5','h6','span','strong'))]" wrapper="p" wrapper-namespace="http://www.w3.org/1999/xhtml"/>
    <p:viewport match="//html:section">
        <p:add-attribute match="/*" attribute-name="id">
            <p:with-option name="attribute-value" select="concat('h_',(p:iteration-position()-1))"/>
        </p:add-attribute>
    </p:viewport>
    <p:rename match="//*[exists(html:h1 | html:h2 | html:h3 | html:h4 | html:h5 | html:h6)]" new-name="section" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:rename match="//html:h2" new-name="h1" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:rename match="//html:h3" new-name="h2" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:rename match="//html:h4" new-name="h3" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:rename match="//html:h5" new-name="h4" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:rename match="//html:h6" new-name="h5" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:identity name="news.cleaned"/>
    <p:sink/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="metadata-as-dtbook"/>
        </p:input>
    </p:identity>
    
    <!-- flytt punktbøker til starten -->
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.daisy.org/z3986/2005/dtbook/" xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/" version="2.0">
                    <xsl:template match="@*|node()">
                        <xsl:copy exclude-result-prefixes="#all">
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="*[*/@id = 'braille']">
                        <xsl:copy exclude-result-prefixes="#all">
                            <xsl:copy-of select="@*" exclude-result-prefixes="#all"/>
                            <xsl:copy-of select="*[not(matches(local-name(), 'level\d'))]" exclude-result-prefixes="#all"/>
                            <xsl:copy-of select="*[matches(local-name(), 'level\d') and @id = 'braille']" exclude-result-prefixes="#all"/>
                            <xsl:copy-of select="*[matches(local-name(), 'level\d') and not(@id = 'braille')]" exclude-result-prefixes="#all"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    
    <!-- Konverter boklisten til HTML -->
    <p:xslt name="metadata-as-html">
        <p:with-param name="media" select="'braille'"/>
        <p:input port="stylesheet">
            <p:document href="dtbook-to-html.xsl"/>
        </p:input>
    </p:xslt>
    
    <!-- sett inn nyheter -->
    <p:insert match="/html:html/html:body/html:section[@id='contact']" position="after">
        <p:input port="insertion">
            <p:pipe step="news.cleaned" port="result"/>
        </p:input>
    </p:insert>
    
    <!-- fjern bilder (inkl. bildebeskrivelser) -->
    <p:delete match="html:img"/>
    
    <!-- sørg for riktig språk -->
    <p:add-attribute match="/*/html:head/html:meta[@name='dc:language']" attribute-name="value" attribute-value="no"/>
    
    <p:store indent="true">
        <p:with-option name="href" select="concat($output-dir,'Nyhetsbrev%20',lower-case(/*/@F),'%20',/*/@Y,'.xhtml')">
            <p:pipe port="php-time" step="main"/>
        </p:with-option>
    </p:store>
    
</p:declare-step>
