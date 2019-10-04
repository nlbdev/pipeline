<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="nlb:catalog-month" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">NLBs Nyhetsbrev</h1>
        <p px:role="desc">Lager et nyhetsbrev for NLB som inneholder nyheter og bøker produsert forrige måned.</p>
    </p:documentation>

    <p:option name="month" required="true" px:dir="input" px:type="string">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">År og måned</h2>
            <p px:role="desc">År og måned det skal lages nyhetsbrev for (ÅÅÅÅ-MM; for eksempel "2012-10" for oktober 2012).</p>
        </p:documentation>
    </p:option>
    <p:option name="make-email" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Lag e-post</h2>
            <p px:role="desc">Lag en e-postkampanje på NLBs MailChimp-konto.</p>
        </p:documentation>
    </p:option>
    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Utputt-mappe</h2>
            <p px:role="desc">Mappe der nyhetsbrevet i DTBook- og HTML-format skal lagres.</p>
        </p:documentation>
    </p:option>
    <p:option name="metadata-endpoint" required="false" select="''" px:type="string">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Tjener for metadata</h2>
            <p px:role="desc">Dette er mest for testing. Normalt bør denne være tom.</p>
        </p:documentation>
    </p:option>
    <p:option name="news-href" required="false" select="''" px:type="anyFileURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Fil som inneholder nyheter</h2>
            <p px:role="desc">Brukes mest for testing. Normalt bør denne stå tom.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="news.xpl"/>
    <p:import href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/library.xpl"/>
    <p:import href="make-email.xpl"/>
    <p:import href="make-dtbook.xpl"/>
    <p:import href="make-html.xpl"/>
    
    <p:variable name="outputDir" select="if (ends-with($output-dir,'/')) then $output-dir else concat($output-dir,'/')"/>
    <p:variable name="metadataEndpoint" select="replace($metadata-endpoint, '(^\s+|\s+$)', '')"/>

    <p:choose>
        <p:when test="not(matches($month,'^\d\d\d\d-\d\d$'))">
            <p:error code="NLBN001">
                <p:input port="source">
                    <p:inline>
                        <c:message>Måned må skrives på formatet "ÅÅÅÅ-MM". For eksempel "2012-11" for november 2012.</c:message>
                    </p:inline>
                </p:input>
            </p:error>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
        </p:when>
        <p:otherwise>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
        </p:otherwise>
    </p:choose>

    <!-- Hent nyheter -->
    <cx:message message="Henter nyheter" name="message.nyheter">
        <p:input port="source">
            <p:empty/>
        </p:input>
    </cx:message>
    <p:sink/>
    <nlb:news name="news-as-html" cx:depends-on="message.nyheter">
        <p:with-option name="month" select="/*/@previous-month">
            <p:pipe port="result" step="php-time"/>
        </p:with-option>
        <p:with-option name="href" select="$news-href"/>
    </nlb:news>

    <!-- Hent bøker -->
    <p:load href="template-dtbook.xml"/>
    <cx:message message="Henter bøker"/>
    <nlb:metadata-as-dtbook name="metadata-as-dtbook.step" include-language="true">
        <p:with-option name="metadata-endpoint" select="$metadataEndpoint"/>
        <p:input port="php-time">
            <p:pipe port="result" step="php-time"/>
        </p:input>
    </nlb:metadata-as-dtbook>
    <p:add-attribute match="/*/dtbook:head/dtbook:meta[@name=('dtb:uid','dc:Identifier')]" attribute-name="content">
        <p:input port="source">
            <p:pipe port="result" step="metadata-as-dtbook.step"/>
        </p:input>
        <p:with-option name="attribute-value" select="concat('NLB-NEWSLETTER-', /*/@Y, /*/@m)">
            <p:pipe port="result" step="php-time"/>
        </p:with-option>
    </p:add-attribute>
    <p:identity name="metadata-as-dtbook"/>

    <!-- Lag nyhetsbrev som DTBook -->
    <cx:message message="Lager nyhetsbrev som DTBook" name="message.dtbook">
        <p:input port="source">
            <p:empty/>
        </p:input>
    </cx:message>
    <nlb:make-dtbook cx:depends-on="message.dtbook" name="make-dtbook">
        <p:with-option name="output-dir" select="$outputDir"/>
        <p:input port="news-as-html">
            <p:pipe port="result" step="news-as-html"/>
        </p:input>
        <p:input port="metadata-as-dtbook">
            <p:pipe port="result" step="metadata-as-dtbook"/>
        </p:input>
        <p:input port="php-time">
            <p:pipe port="result" step="php-time"/>
        </p:input>
    </nlb:make-dtbook>
    
    <!-- Lag nyhetsbrev som HTML -->
    <cx:message message="Lager nyhetsbrev som HTML" name="message.html" cx:depends-on="make-dtbook">
        <p:input port="source">
            <p:empty/>
        </p:input>
    </cx:message>
    <nlb:make-html cx:depends-on="message.html">
        <p:with-option name="output-dir" select="$outputDir"/>
        <p:input port="news-as-html">
            <p:pipe port="result" step="news-as-html"/>
        </p:input>
        <p:input port="metadata-as-dtbook">
            <p:pipe port="result" step="metadata-as-dtbook"/>
        </p:input>
        <p:input port="php-time">
            <p:pipe port="result" step="php-time"/>
        </p:input>
    </nlb:make-html>

    <!-- Lag nyhetsbrev som e-post -->
    <p:choose>
        <p:when test="$make-email='true'">
            <cx:message message="Lager nyhetsbrev som e-post" name="message.e-post">
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </cx:message>
            <p:sink/>

            <nlb:make-email cx:depends-on="message.e-post">
                <p:input port="news-as-html">
                    <p:pipe port="result" step="news-as-html"/>
                </p:input>
                <p:input port="metadata-as-dtbook">
                    <p:pipe port="result" step="metadata-as-dtbook"/>
                </p:input>
                <p:input port="logo-as-html">
                    <p:pipe port="result" step="logo-as-html"/>
                </p:input>
                <p:input port="php-time">
                    <p:pipe port="result" step="php-time"/>
                </p:input>
            </nlb:make-email>
        </p:when>
        <p:otherwise>
            <cx:message message="Lager ikke e-post...">
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </cx:message>
            <p:sink/>
        </p:otherwise>
    </p:choose>

    <!-- Regn ut tidsinformasjon for valgt måned -->
    <p:group name="php-time">
        <p:output port="result"/>
        <p:xslt>
            <p:with-param name="dateTime" select="concat($month,'-01')">
                <p:empty/>
            </p:with-param>
            <p:input port="source">
                <p:inline>
                    <c:result/>
                </p:inline>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nlb="http://www.nlb.no/ns/" version="2.0">
                        <xsl:import href="http://www.nlb.no/pipeline/modules/nlb-metadata-utils/template-engine.xsl"/>
                        <xsl:param name="dateTime" required="yes"/>
                        <xsl:template match="/*">
                            <xsl:copy>
                                <xsl:attribute name="d" select="nlb:template-time('d', $dateTime)"/>
                                <xsl:attribute name="z" select="nlb:template-time('z', $dateTime)"/>
                                <xsl:attribute name="F" select="nlb:template-time('F', $dateTime)"/>
                                <xsl:attribute name="m" select="nlb:template-time('m', $dateTime)"/>
                                <xsl:attribute name="M" select="nlb:template-time('M', $dateTime)"/>
                                <xsl:attribute name="t" select="nlb:template-time('t', $dateTime)"/>
                                <xsl:attribute name="L" select="nlb:template-time('L', $dateTime)"/>
                                <xsl:attribute name="Y" select="nlb:template-time('Y', $dateTime)"/>
                                <xsl:attribute name="H" select="nlb:template-time('H', $dateTime)"/>
                                <xsl:attribute name="i" select="nlb:template-time('i', $dateTime)"/>
                                <xsl:attribute name="s" select="nlb:template-time('s', $dateTime)"/>
                                <xsl:attribute name="u" select="nlb:template-time('u', $dateTime)"/>
                                <xsl:attribute name="e" select="nlb:template-time('e', $dateTime)"/>
                                <xsl:attribute name="c" select="nlb:template-time('c', $dateTime)"/>
                                <xsl:attribute name="U" select="nlb:template-time('U', $dateTime)"/>
                                
                                <xsl:variable name="tokenized" select="tokenize($dateTime,'-')"/>
                                <xsl:variable name="month-1" select="number($tokenized[2])-1"/>
                                <xsl:attribute name="previous-month" select="if ($tokenized[2] = '01') then concat(floor(number($tokenized[1])-1),'-12') else concat($tokenized[1],'-',if ($month-1 &lt; 10) then '0' else '', $month-1)"/>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>
    </p:group>

    <!-- Velg logo basert på tid -->
    <cx:message message="Velger logo basert på måned" name="message.logo">
        <p:input port="source">
            <p:empty/>
        </p:input>
    </cx:message>
    <p:sink/>
    <p:group name="logo-as-html" cx:depends-on="message.logo">
        <p:output port="result"/>
        <p:delete>
            <p:with-option name="match" select="concat('/*/*[not(@class=&quot;logo-',lower-case(/*/@F),'&quot;)]')">
                <p:pipe port="result" step="php-time"/>
            </p:with-option>
            <p:input port="source">
                <p:inline>
                    <span>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_blue.png" class="logo-januar"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_pink.png" class="logo-februar"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_green.png" class="logo-mars"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_yellow.png" class="logo-april"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_red.png" class="logo-mai"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_dark_green.png" class="logo-juni"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_green.png" class="logo-juli"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_yellow.png" class="logo-august"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_orange.png" class="logo-september"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_red_orange.png" class="logo-oktober"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_pink.png" class="logo-november"/>
                        <img alt="NLB" src="http://gallery.mailchimp.com/3c55b291cdcd82ece169afccc/images/logo_red.png" class="logo-desember"/>
                    </span>
                </p:inline>
            </p:input>
        </p:delete>
        <p:add-attribute match="/*/*" attribute-name="style" attribute-value="'max-width:180px;'"/>
        <p:add-attribute match="/*/*" attribute-name="id" attribute-value="'headerImage campaign-icon'"/>
    </p:group>
    <p:sink/>

</p:declare-step>
