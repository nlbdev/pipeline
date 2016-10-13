<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal/bibliofil-publications-list"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:cx="http://xmlcalabash.com/ns/extensions">

    <!--    <p:option name="href" required="true"/>-->
    <p:option name="href" select="'file:/tmp/bibliofil-publications-list.xml'"/>

    <p:http-request>
        <p:input port="source">
            <p:inline>
                <c:request method="get" href="http://websok.nlb.no/cgi-bin/oai?verb=ListIdentifiers&amp;metadataPrefix=marcxchange"/>
            </p:inline>
        </p:input>
    </p:http-request>
    <p:identity name="initial"/>

    <p:store name="store-initial-token">
        <p:with-option name="href" select="$href"/>
        <p:input port="source" select="//oai:resumptionToken"/>
    </p:store>

    <!-- to avoid deep recursion; iterate over a sequence of 10000 <iteration/> elements -->
    <p:xslt cx:depends-on="store-initial-token">
        <p:input port="source">
            <p:inline>
                <iterate/>
            </p:inline>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:template match="/*">
                        <iterate>
                            <xsl:for-each select="1 to 10000">
                                <iteration/>
                            </xsl:for-each>
                        </iterate>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>

    <p:viewport match="/*/*">

        <p:load>
            <p:with-option name="href" select="$href"/>
        </p:load>
        <p:group>
            <p:variable name="resumptionToken" select="normalize-space(/*)"/>
        </p:group>
        <p:choose>
            <p:when test="$resumptionToken=''">
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:request method="get" href="http://websok.nlb.no/cgi-bin/oai?verb=ListIdentifiers&amp;metadataPrefix=marcxchange"/>
                        </p:inline>
                    </p:input>
                </p:identity>
                <p:add-attribute match="/*" attribute-name="href">
                    <p:with-option name="attribute-value" select="concat(/*/@href,'&amp;resumptionToken=',$resumptionToken)"/>
                </p:add-attribute>
                <p:http-request/>
                <p:identity name="part"/>
                <p:store name="store-token">
                    <p:with-option name="href" select="$href"/>
                    <p:input port="source" select="//oai:resumptionToken"/>
                </p:store>
                <p:filter cx:depends-on="store-token">
                    <p:input port="source">
                        <p:pipe port="" step=""></p:pipe>
                    </p:input>
                </p:filter>
            </p:otherwise>
        </p:choose>

    </p:viewport>







    <!--<p:declare-step type="pxi:bibliofil-publications-list-part">
        <p:option name="resumption-token" required="true"/>
        <p:add-attribute>
            <p:input port="source">
                <p:inline>
                    <c:request method="get" href="http://websok.nlb.no/cgi-bin/oai?verb=ListIdentifiers&amp;metadataPrefix=marcxchange&amp;resumptionToken"/>
                </p:inline>
            </p:input>
        </p:add-attribute>
    </p:declare-step>



    <p:output port="result">
        <p:pipe port="result" step="debug"/>
        <!-\-<p:pipe port="result" step="store"/>-\->
    </p:output>





    <p:identity name="debug"/>
    <p:store name="store" indent="true">
        <p:with-option name="href" select="$href"/>
    </p:store>-->

</p:declare-step>
