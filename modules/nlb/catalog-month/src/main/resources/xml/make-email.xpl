<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="nlb:make-email" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0">

    <p:input port="news-as-html" primary="false"/>
    <p:input port="metadata-as-dtbook" primary="false"/>
    <p:input port="logo-as-html" primary="false"/>
    <p:input port="php-time" primary="false"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="http://www.nlb.no/pipeline/modules/mailchimp/api.xpl"/>
    <p:import href="html-to-plaintext.xpl"/>

    <p:group name="news">
        <p:output port="result"/>
        <p:insert match="html:img[matches(@style,'float\s*:\s*right')]" position="after">
            <p:input port="source">
                <p:pipe port="news-as-html" step="main"/>
            </p:input>
            <p:input port="insertion">
                <p:inline xmlns="http://www.w3.org/1999/xhtml">
                    <br/>
                </p:inline>
            </p:input>
        </p:insert>
        <p:viewport match="html:img">
            <p:variable name="width" select="replace(/*/@style,'width\s*:\s*(\d*)\s*px','$1')"/>
            <p:variable name="height" select="replace(/*/@style,'height\s*:\s*(\d*)\s*px','$1')"/>
            <p:choose>
                <p:when test="matches(/*/@width,'^\d+')">
                    <p:identity/>
                </p:when>
                <p:when test="matches($width,'^\d+')">
                    <p:add-attribute match="/*" attribute-name="width">
                        <p:with-option name="attribute-value" select="$width"/>
                    </p:add-attribute>
                </p:when>
                <p:otherwise>
                    <p:add-attribute match="/*" attribute-name="width">
                        <p:with-option name="attribute-value" select="'600'"/>
                    </p:add-attribute>
                    <p:add-attribute match="/*" attribute-name="style">
                        <p:with-option name="attribute-value" select="concat(/*/@style, ' width: 600px;')"/>
                    </p:add-attribute>
                </p:otherwise>
            </p:choose>
            <p:choose>
                <p:when test="matches(/*/@height,'^\d+')">
                    <p:identity/>
                </p:when>
                <p:when test="matches($height,'^\d+')">
                    <p:add-attribute match="/*" attribute-name="height">
                        <p:with-option name="attribute-value" select="$height"/>
                    </p:add-attribute>
                </p:when>
                <p:otherwise>
                    <p:identity/>
                </p:otherwise>
            </p:choose>
        </p:viewport>
        <p:viewport match="html:*[contains(@style,'float')]">
            <!-- remove float styles -->
            <p:add-attribute match="/*" attribute-name="style">
                <p:with-option name="attribute-value" select="string-join(for $s in (tokenize(/*/@style,';')) return (if (matches($s,'^\s*float\s*:.*$')) then () else $s), '; ')"/>
            </p:add-attribute>
        </p:viewport>
        <p:viewport match="html:iframe[matches(@src,'^https?://[^/]*youtube.com/')]">
            <p:variable name="youtube" select="replace(/*/@src,'.*/([^?/]*).*','$1')"/>
            <p:identity name="iframe"/>
            <p:in-scope-names name="vars"/>
            <p:template>
                <p:input port="template">
                    <p:inline xmlns="http://www.w3.org/1999/xhtml">
                        <span>*|YOUTUBE:{$youtube}|*</span>
                    </p:inline>
                </p:input>
                <p:input port="source">
                    <p:pipe step="iframe" port="result"/>
                </p:input>
                <p:input port="parameters">
                    <p:pipe step="vars" port="result"/>
                </p:input>
            </p:template>
        </p:viewport>
    </p:group>

    <p:group name="body">
        <p:output port="xhtml" primary="false">
            <p:pipe port="result" step="body.xhtml"/>
        </p:output>
        <p:output port="escaped" primary="false">
            <p:pipe port="result" step="body.escaped"/>
        </p:output>

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
                <p:document href="dtbook-to-html.xsl"/>
            </p:input>
        </p:xslt>
        <p:delete match="//*[@id='toc']"/>
        <p:delete match="html:head"/>
        <p:unwrap match="html:body"/>
        <p:rename match="//html:h5" new-name="h6" new-namespace="http://www.w3.org/1999/xhtml"/>
        <p:rename match="//html:h4" new-name="h5" new-namespace="http://www.w3.org/1999/xhtml"/>
        <p:rename match="//html:h3" new-name="h4" new-namespace="http://www.w3.org/1999/xhtml"/>
        <p:rename match="//html:h2" new-name="h3" new-namespace="http://www.w3.org/1999/xhtml"/>
        <p:rename match="//html:h1" new-name="h2" new-namespace="http://www.w3.org/1999/xhtml"/>
        <p:add-attribute match="//html:h1 | //html:h2 | //html:h3 | //html:h4 | //html:h5 | //html:h6" attribute-name="data-catalog" attribute-value="true"/>

        <p:insert match="/*" position="first-child">
            <p:input port="insertion">
                <p:inline>
                    <hr xmlns="http://www.w3.org/1999/xhtml"/>
                </p:inline>
                <p:pipe port="result" step="news"/>
                <p:inline>
                    <hr xmlns="http://www.w3.org/1999/xhtml"/>
                </p:inline>
            </p:input>
        </p:insert>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="*[local-name()=('h1','h2','h3','h4','h5','h6')]">
                            <xsl:copy>
                                <xsl:choose>
                                    <xsl:when test="parent::*/starts-with(@id,'b_')">
                                        <xsl:apply-templates select="@* except @id"/>
                                        <xsl:apply-templates select="node()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="@* except @id"/>
                                        <xsl:variable name="anchor" select="concat('h_',count(preceding::*[local-name()=('h1','h2','h3','h4','h5','h6')]))"/>
                                        <xsl:attribute name="id" select="$anchor"/>
                                        <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                                            <xsl:attribute name="name" select="$anchor"/>
                                            <xsl:attribute name="style" select="'color:inherit;text-decoration:none;font-weight:bold;'"/>
                                            <xsl:apply-templates select="node()"/>
                                        </xsl:element>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:copy>
                            <xsl:if
                                test="parent::*[matches(@id,'^(audio|braille|student)')]">
                                <xsl:element name="br" namespace="http://www.w3.org/1999/xhtml"/>
                            </xsl:if>
                        </xsl:template>
                        <xsl:template match="text()" priority="10">
                            <xsl:value-of select="replace(.,'  +',' ')"/>
                        </xsl:template>
                        <xsl:template match="*[local-name()='span' and not(@*)]">
                            <xsl:apply-templates select="node()"/>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>
        <p:identity name="body.xhtml"/>
        <p:delete match="//@data-catalog"/>
        <p:insert match="*[local-name()='div' and starts-with(@id,'b_') and following-sibling::*]" position="after">
            <p:input port="insertion">
                <p:inline><hr xmlns="http://www.w3.org/1999/xhtml"/></p:inline>
            </p:input>
        </p:insert>
        <p:insert match="*[matches(@id,'^(audio|braille|student)')][preceding-sibling::*[@id]]" position="before">
            <p:input port="insertion">
                <p:inline><hr xmlns="http://www.w3.org/1999/xhtml"/></p:inline>
            </p:input>
        </p:insert>
        <p:unwrap match="*[local-name()='div' and starts-with(@id,'b_')]"/>
        <p:escape-markup name="body.escaped" indent="false"/>
    </p:group>

    <p:group name="toc">
        <p:output port="xhtml" primary="false">
            <p:pipe port="result" step="toc.xhtml"/>
        </p:output>
        <p:output port="escaped" primary="false">
            <p:pipe port="result" step="toc.escaped"/>
        </p:output>

        <p:identity>
            <p:input port="source">
                <p:pipe port="xhtml" step="body"/>
            </p:input>
        </p:identity>
        <p:delete match="//*[starts-with(@id, 'student-audio')]/*[not(matches(local-name(),'h\d'))]"/>
        <p:delete match="//*[starts-with(@id, 'b_')]"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="create-nav.xsl"/>
            </p:input>
        </p:xslt>
        <p:delete match="//*[local-name()='ul']//*[local-name()='ul']//*[local-name()='ul']"/>
        <p:delete match="//*[local-name()='ul']//*[local-name()='ul' and not(*/@data-catalog)]"/>
        <p:delete match="//@data-catalog"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                        <!-- fix for <ul/> not being supported by Outlook -->
                        <!-- also add some air between top-level list items -->
                        <xsl:template match="/*">
                            <xsl:copy>
                                <!-- div -->
                                <xsl:copy-of select="@*"/>
                                <xsl:copy-of select="*[1]"/>
                                <xsl:for-each select="*[2]">
                                    <xsl:element name="br" namespace="http://www.w3.org/1999/xhtml"/>
                                    <xsl:copy>
                                        <!-- ul -->
                                        <xsl:copy-of select="@*"/>
                                        <xsl:for-each select="*">
                                            <xsl:copy>
                                                <!-- li -->
                                                <xsl:copy-of select="@*"/>
                                                <xsl:for-each select="*">
                                                    <xsl:choose>
                                                        <xsl:when test="local-name()='ul'">
                                                            <!-- ul -->
                                                            <xsl:for-each select="*">
                                                                <!-- li -->
                                                                <xsl:element name="br" namespace="http://www.w3.org/1999/xhtml"/>&#160;&#160;&#160;&#160;• <xsl:copy-of select="*[not(local-name()='ul')]"/>
                                                            </xsl:for-each>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <!-- a -->
                                                            <xsl:copy-of select="."/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:for-each>
                                            <xsl:element name="br" namespace="http://www.w3.org/1999/xhtml"/>
                                                <xsl:element name="br" namespace="http://www.w3.org/1999/xhtml"/>
                                            </xsl:copy>
                                        </xsl:for-each>
                                    </xsl:copy>
                                </xsl:for-each>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>
        <p:identity name="toc.xhtml"/>
        <p:escape-markup name="toc.escaped" indent="false"/>
    </p:group>

    <p:group name="logo">
        <p:output port="xhtml" primary="false">
            <p:pipe port="result" step="logo.xhtml"/>
        </p:output>
        <p:output port="escaped" primary="false">
            <p:pipe port="result" step="logo.escaped"/>
        </p:output>

        <p:identity name="logo.xhtml">
            <p:input port="source">
                <p:pipe port="logo-as-html" step="main"/>
            </p:input>
        </p:identity>
        <p:escape-markup name="logo.escaped" indent="false"/>
    </p:group>

    <p:group name="text">
        <p:output port="result"/>

        <p:variable name="text_HEADER_ISSUETITLE" select="concat('Nyhetsbrev for ',lower-case(/*/@F),' ',/*/@Y)">
            <p:pipe port="php-time" step="main"/>
        </p:variable>

        <nlb:html-to-plaintext name="text_BODY">
            <p:input port="source">
                <p:pipe port="xhtml" step="body"/>
            </p:input>
        </nlb:html-to-plaintext>
        <nlb:html-to-plaintext name="text_TOC">
            <p:input port="source">
                <p:pipe port="xhtml" step="toc"/>
            </p:input>
        </nlb:html-to-plaintext>
        <nlb:html-to-plaintext name="text_HEADER_IMAGE">
            <p:input port="source">
                <p:pipe port="xhtml" step="logo"/>
            </p:input>
        </nlb:html-to-plaintext>

        <p:load href="template-plaintext.xml"/>
        <p:xslt>
            <p:with-param name="HEADER_ISSUETITLE" select="$text_HEADER_ISSUETITLE"/>
            <p:with-param name="HEADER_IMAGE" select="string-join(//text(),' ')">
                <p:pipe port="result" step="text_HEADER_IMAGE"/>
            </p:with-param>
            <p:with-param name="TOC" select="string-join(//text(),' ')">
                <p:pipe port="result" step="text_TOC"/>
            </p:with-param>
            <p:with-param name="BODY" select="string-join(//text(),' ')">
                <p:pipe port="result" step="text_BODY"/>
            </p:with-param>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                        <xsl:param name="HEADER_ISSUETITLE"/>
                        <xsl:param name="HEADER_IMAGE"/>
                        <xsl:param name="TOC"/>
                        <xsl:param name="BODY"/>
                        <xsl:template match="/*">
                            <xsl:copy>
                                <xsl:value-of
                                    select="replace(replace(replace(replace(string-join(//text(),'')
                                                        ,'\*\|HEADER_ISSUETITLE\|\*',$HEADER_ISSUETITLE)
                                                        ,'\*\|HEADER_IMAGE\|\*',$HEADER_IMAGE)
                                                        ,'\*\|TOC\|\*',$TOC)
                                                        ,'\*\|BODY\|\*',$BODY)"
                                />
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>
    </p:group>

    <p:identity>
        <p:input port="source">
            <p:inline>
                <c:param-set>
                    <c:param name="type" value="regular"/>
                    <c:param name="options[list_id]" value="f11b0888ee"/>
                    <c:param name="options[subject]"/>
                    <c:param name="options[from_email]" value="utlaan@nlb.no"/>
                    <c:param name="options[from_name]" value="NLB"/>
                    <c:param name="options[to_name]" value="*|EMAIL|*"/>
                    <c:param name="options[template_id]" value="2497"/>
                    <c:param name="options[generate_text]" value="true"/>
                    <c:param name="content[sections][HEADER_IMAGE]" value="IMAGE"/>
                    <c:param name="content[sections][HEADER_ISSUETITLE]" value="ISSUETITLE"/>
                    <c:param name="content[sections][BODY]" value="BODY"/>
                    <c:param name="content[sections][TOC]" value="TOC"/>
                    <c:param name="content[text]" value="TEXT"/>
                </c:param-set>
            </p:inline>
        </p:input>
    </p:identity>
    <p:add-attribute match="c:param[@name='content[sections][BODY]']" attribute-name="value">
        <p:with-option name="attribute-value" select="string-join(//text(),' ')">
            <p:pipe port="escaped" step="body"/>
        </p:with-option>
    </p:add-attribute>
    <p:add-attribute match="c:param[@name=('options[subject]','content[sections][HEADER_ISSUETITLE]')]" attribute-name="value">
        <p:with-option name="attribute-value" select="concat('Nyhetsbrev for ',lower-case(/*/@F),' ',/*/@Y)">
            <p:pipe port="php-time" step="main"/>
        </p:with-option>
    </p:add-attribute>
    <p:add-attribute match="c:param[@name='content[sections][TOC]']" attribute-name="value">
        <p:with-option name="attribute-value" select="string-join(//text(),' ')">
            <p:pipe port="escaped" step="toc"/>
        </p:with-option>
    </p:add-attribute>
    <p:add-attribute match="c:param[@name='content[sections][HEADER_IMAGE]']" attribute-name="value">
        <p:with-option name="attribute-value" select="string-join(//text(),' ')">
            <p:pipe port="escaped" step="logo"/>
        </p:with-option>
    </p:add-attribute>
    <p:add-attribute match="c:param[@name='content[text]']" attribute-name="value">
        <p:with-option name="attribute-value" select="string-join(//text(),' ')">
            <p:pipe port="result" step="text"/>
        </p:with-option>
    </p:add-attribute>

    <cx:message message="Sender inn e-post-kampanje til MailChimp..."/>
    <nlb:mailchimp-request method="campaigns/create"/>

    <p:identity name="result"/>
    <p:sink/>

</p:declare-step>
