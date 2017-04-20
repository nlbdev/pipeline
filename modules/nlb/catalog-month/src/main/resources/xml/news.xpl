<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:nlb="http://metadata.nlb.no/vocabulary/#"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:j="http://marklogic.com/json"
                exclude-inline-prefixes="#all"
                xpath-version="2.0"
                name="news"
                type="nlb:news"
                version="1.0">

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
    
    <p:option name="temp-dir" required="true"/>
    
    <p:variable name="lastMonthDay" select="if (ends-with($month,'-01')) then '31'
                                        else if (ends-with($month,'-02') and number(tokenize($month,'-')[1]) mod 4 = 0.0) then '29'
                                        else if (ends-with($month,'-02')) then '28'
                                        else if (ends-with($month,'-03')) then '31'
                                        else if (ends-with($month,'-04')) then '30'
                                        else if (ends-with($month,'-05')) then '31'
                                        else if (ends-with($month,'-06')) then '30'
                                        else if (ends-with($month,'-07')) then '31'
                                        else if (ends-with($month,'-08')) then '31'
                                        else if (ends-with($month,'-09')) then '30'
                                        else if (ends-with($month,'-10')) then '31'
                                        else if (ends-with($month,'-11')) then '30'
                                        else '31'"/>
    
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
        <p:when test="starts-with($month,'2016-11')">
            <p:load href="news-feed-archive/manuelt-laget-for-desember-2016.xml"/>
            <p:filter select="/*/*"/>
        </p:when>
        <p:when test="starts-with($month,'2016-12')">
            <p:load href="news-feed-archive/manuelt-laget-for-januar-2017.xml"/>
            <p:filter select="/*/*"/>
        </p:when>
        <p:when test="starts-with($month,'2017-01')">
            <p:load href="news-feed-archive/manuelt-laget-for-februar-2017.xml"/>
            <p:filter select="/*/*"/>
        </p:when>
        <p:when test="starts-with($month,'2017-02')">
            <p:load href="news-feed-archive/manuelt-laget-for-mars-2017.xml"/>
            <p:filter select="/*/*"/>
        </p:when>
        <!--<p:when test="starts-with($month,'2017-03')">
            <p:load href="news-feed-archive/manuelt-laget-for-april-2017.xml"/>
            <p:filter select="/*/*"/>
            (kommentert ut sånn at vi kan teste ny feed med april-nyhetsbrevet)
        </p:when>-->
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <c:request method="GET" href="http://www.nlb.no/_/service/nlb/feedArticle" override-content-type="text/plain"/>
                    </p:inline>
                </p:input>
            </p:identity>
            <p:add-attribute match="/*" attribute-name="href">
                <p:with-option name="attribute-value" select="concat(/*/@href,'?from=',$month,'-01&amp;to=',$month,'-',$lastMonthDay)"/>
            </p:add-attribute>
            <p:http-request/>
            <p:store name="store-news-latin1" encoding="ISO-8859-1">
                <p:with-option name="href" select="concat($temp-dir,'news-',$month,'.xml')"/>
            </p:store>
            <p:load>
                <p:with-option name="href" select="/*/text()">
                    <p:pipe port="result" step="store-news-latin1"/>
                </p:with-option>
            </p:load>
            <p:unescape-markup content-type="application/json"/>
            <p:for-each>
                <p:iteration-source select="/c:body/j:json/j:article/j:item"/>
                <p:variable name="url" select="/*/j:url/text()"></p:variable>
                
                <p:viewport match="j:bodyOriginal | j:introOriginal">
                    <p:unescape-markup content-type="text/html"/>
                    <p:delete match="html:html/*[not(self::html:body)]"/>
                    <p:unwrap match="html:html"/>
                    <p:unwrap match="html:body"/>
                </p:viewport>
                
                <p:viewport match="j:actionsLinks/j:item">
                    <p:add-attribute match="/*/j:title" attribute-name="href">
                        <p:with-option name="attribute-value" select="/*/j:url/text()"/>
                    </p:add-attribute>
                    <p:rename match="/*" new-name="li" new-namespace="http://www.w3.org/1999/xhtml"/>
                    <p:rename match="/*/j:title" new-name="a" new-namespace="http://www.w3.org/1999/xhtml"/>
                    <p:delete match="/*/*[not(self::html:a)] | /*/@* | /*/*/@*[not(name()='href')]"/>
                </p:viewport>
                <p:delete match="j:actionsLinks/@*"/>
                <p:rename match="j:actionsLinks" new-name="ul" new-namespace="http://www.w3.org/1999/xhtml"/>
                
                <p:delete match="/*/j:title/@*"/>
                <p:rename match="/*/j:title" new-name="h1" new-namespace="http://www.w3.org/1999/xhtml"/>
                
                <p:identity name="unescaped-json-article"/>
                <p:insert match="j:bodyOriginal" position="first-child">
                    <p:input port="insertion" select="/*/html:ul">
                        <p:pipe port="result" step="unescaped-json-article"/>
                    </p:input>
                </p:insert>
                <p:insert match="j:bodyOriginal" position="first-child">
                    <p:input port="insertion" select="/*/j:introOriginal/*">
                        <p:pipe port="result" step="unescaped-json-article"/>
                    </p:input>
                </p:insert>
                <p:insert match="j:bodyOriginal" position="first-child">
                    <p:input port="insertion" select="/*/html:h1">
                        <p:pipe port="result" step="unescaped-json-article"/>
                    </p:input>
                </p:insert>
                
                <p:filter select="/*/j:bodyOriginal"/>
                <p:delete match="/*/@*"/>
                <p:rename match="/*" new-name="body" new-namespace="http://www.w3.org/1999/xhtml"/>
                <p:wrap-sequence wrapper="html" wrapper-namespace="http://www.w3.org/1999/xhtml"/>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="$url"/>
                </p:add-attribute>
            </p:for-each>
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
