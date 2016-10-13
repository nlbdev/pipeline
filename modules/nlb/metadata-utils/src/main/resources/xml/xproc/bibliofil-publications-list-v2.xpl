<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <!-- TODO: make these required when script is done -->
    <p:option name="from" select="'2014-01-15'"/>
    <p:option name="to" select="'2014-03-15'"/>

    <p:output port="result"/>

    <!--    http://websok.nlb.no/cgi-bin/sru?version=1.2&operation=searchRetrieve&query=cql.serverChoice=%22pre=201401%22  -->

    <p:http-request>
        <p:input port="source">
            <p:inline>
                <c:request method="get" href="http://websok.nlb.no/cgi-bin/sru?version=1.2&amp;operation=searchRetrieve&amp;query=cql.serverChoice%3D%22pre=201401%22"/>
            </p:inline>
        </p:input>
    </p:http-request>

</p:declare-step>
