<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="news" type="nlb:news" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">NLBs Nyhetsbrev</h1>
        <p px:role="desc">Henter nyhetene fra hjemmesiden til NLB for en gitt måned i et gitt år (default: forrige måned).</p>
    </p:documentation>

    <p:output port="result"/>

    <p:option name="month" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">År og måned</h2>
            <p px:role="desc">År og måned det skal lages årskatalog for (ÅÅÅÅ-MM).</p>
        </p:documentation>
    </p:option>
    
    <!-- Først; hent nyhetene -->
    <p:choose>
        <p:when test="number(tokenize($month,'-')[1]) &lt;= 2016 and number(replace(tokenize($month,'-')[2],'^0','')) &lt;= 5">
            <p:identity>
                <p:input port="source">
                    <p:document href="news-feed-archive/nyheter-hjemmeside-2011-2016.xml"/>
                </p:input>
            </p:identity>
            
            <p:xslt>
                <p:with-param name="month" select="$month"/>
                <p:input port="stylesheet">
                    <p:inline>
                        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                            <xsl:param name="month" required="yes"/>
                            <xsl:template match="/*">
                                <xsl:copy>
                                    <xsl:for-each select="/*/*/Items/*[Status='Active' and LanguageID='1' and string-length(normalize-space(HtmlContent)) &gt; 0 and starts-with(FromDate,$month)]">
                                        <xsl:sort select="FromDate" order="descending"/>
                                        <xsl:copy-of select="."/>
                                    </xsl:for-each>
                                </xsl:copy>
                            </xsl:template>
                        </xsl:stylesheet>
                    </p:inline>
                </p:input>
            </p:xslt>
            
            <p:for-each>
                <p:iteration-source select="/*/*"/>
                <p:viewport match="HtmlContent">
                    <p:unescape-markup content-type="text/html"/>
                </p:viewport>
            </p:for-each>
            
            <p:for-each>
                <p:add-attribute match="//html:html" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="normalize-space((//FriendlyUrl)[1])"/>
                </p:add-attribute>
            </p:for-each>
            <p:filter select="//html:html"/>
            
        </p:when>
        <p:when test="starts-with($month,'2016-06')">
            <p:load href="news-feed-archive/manuelt-laget-for-juli-2016.xml"/>
            <p:filter select="/*/*"/>
        </p:when>
        <p:when test="starts-with($month,'2016-07')">
            <p:load href="news-feed-archive/manuelt-laget-for-august-2016.xml"/>
            <p:filter select="/*/*"/>
        </p:when>
        <p:when test="starts-with($month,'2016-08')">
            <p:load href="news-feed-archive/manuelt-laget-for-september-2016.xml"/>
            <p:filter select="/*/*"/>
        </p:when>
        <p:when test="starts-with($month,'2016-09')">
            <p:load href="news-feed-archive/manuelt-laget-for-oktober-2016.xml"/>
            <p:filter select="/*/*"/>
        </p:when>
        <p:when test="starts-with($month,'2016-10')">
            <p:load href="news-feed-archive/manuelt-laget-for-november-2016.xml"/>
            <p:filter select="/*/*"/>
        </p:when>
        <p:otherwise>
            <!--
                TODO: trenger ny XML feed
                
                <p:http-request>
                   <p:input port="source">
                       <p:inline>
                           <c:request method="GET" href="http://www.nlb.no/ressurser/nyheter/"/>
                       </p:inline>
                   </p:input>
                </p:http-request>
                
                (...)
            -->
            <p:error code="nlb:missing-xml-feed">
                <p:input port="source">
                    <p:inline>
                        <c:message>Mangler XML-feed for denne måneden.</c:message>
                    </p:inline>
                </p:input>
            </p:error>
            
        </p:otherwise>
    </p:choose>

    <!-- Deretter; gjør små tilpasninger i HTMLen -->
    <p:for-each>
        <p:variable name="base" select="/*/@xml:base"/>
        <p:variable name="iteration-position" select="p:iteration-position()"/>
        <!--<p:insert match="//html:h1" position="after">
            <p:input port="insertion">
                <p:inline xmlns="http://www.w3.org/1999/xhtml">
                    <p><a target="_blank" class="nlb.news.articleLink"><span>Les artikkelen på NLBs hjemmesider.</span></a></p>
                </p:inline>
            </p:input>
        </p:insert>
        <p:add-attribute match="//html:a[@class='nlb.news.articleLink']" attribute-name="href">
            <p:with-option name="attribute-value" select="$base"/>
        </p:add-attribute>-->
        <p:choose>
            <p:when test="$iteration-position&gt;1">
                <p:insert match="//html:h1" position="before">
                    <p:input port="insertion">
                        <p:inline xmlns="http://www.w3.org/1999/xhtml">
                            <hr/>
                        </p:inline>
                    </p:input>
                </p:insert>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        <p:delete match="/*/@xml:base"/>
    </p:for-each>
    <p:wrap-sequence wrapper="div" wrapper-namespace="http://www.w3.org/1999/xhtml"/>
    <p:insert match="/*" position="last-child">
        <p:input port="insertion">
            <!-- Hjemmesidelink før 1.juni 2016 var: http://www.nlb.no/om-nlb/aktuelt/ -->
            <p:inline xmlns="http://www.w3.org/1999/xhtml">
                <p><a href="http://www.nlb.no/?mode=aktuelt" target="_blank" class="nlb.news.articleLink"><span>Les flere nyheter på NLBs nettsider.</span></a></p>
            </p:inline>
        </p:input>
    </p:insert>
    <p:rename match="html:h5" new-name="h6" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:rename match="html:h4" new-name="h5" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:rename match="html:h3" new-name="h4" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:rename match="html:h2" new-name="h3" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:rename match="html:h1" new-name="h2" new-namespace="http://www.w3.org/1999/xhtml"/>
    <p:delete match="html:head"/>
    <p:unwrap match="html:html"/>
    <p:unwrap match="html:body"/>
    <p:viewport match="*[@src]">
        <p:add-attribute match="/*" attribute-name="src">
            <p:with-option name="attribute-value" select="resolve-uri(/*/@src,'http://www.nlb.no/')"/>
        </p:add-attribute>
    </p:viewport>
    <p:viewport match="*[@href]">
        <p:try>
            <p:group>
                <p:add-attribute match="/*" attribute-name="href">
                    <p:with-option name="attribute-value" select="resolve-uri(/*/@href,'http://www.nlb.no/')"/>
                </p:add-attribute>
            </p:group>
            <p:catch>
                <p:template>
                    <p:with-param name="href" select="/*/@href"/>
                    <p:input port="template">
                        <p:inline>
                            <c:message>Klarte ikke å løse nettadressen: "{$href}"</c:message>
                        </p:inline>
                    </p:input>
                </p:template>
                <p:escape-markup name="nlbn001.message"/>
                <p:error code="NLBN002">
                    <p:input port="source">
                        <p:pipe port="result" step="nlbn001.message"/>
                    </p:input>
                </p:error>
            </p:catch>
        </p:try>
    </p:viewport>

</p:declare-step>
