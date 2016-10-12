<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:catalog-dewey-split" name="catalog-dewey-split" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all" version="1.0">
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true">
        <p:pipe port="result" step="dewey-result"/>
    </p:output>
    <p:option name="id-prefix" required="true"/>
    
    <p:for-each>
        <p:iteration-source select="/*/*[@steps='1']/*">
            <p:pipe port="result" step="dewey"/>
        </p:iteration-source>
        <p:variable name="class" select="/*/@code"/>
        <p:variable name="name" select="/*"/>
        <p:for-each name="dewey1-level5">
            <p:output port="result" sequence="true"/>
            <p:iteration-source>
                <p:pipe port="source" step="catalog-dewey-split"/>
            </p:iteration-source>
            <p:variable name="dewey" select="(//*[@class='dewey'])[1]"/>
            <p:choose>
                <p:when test="number($class) &lt;= number($dewey) and number($dewey) &lt; number($class) + 1">
                    <p:rename match="dtbook:level4" new-name="level5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                    <p:rename match="dtbook:h4" new-name="h5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                </p:when>
                <p:otherwise>
                    <p:sink/>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>
        </p:for-each>

        <p:in-scope-names name="vars"/>
        <p:template>
            <p:input port="template">
                <p:inline xmlns="http://www.daisy.org/z3986/2005/dtbook/">
                    <level4 id="{$id-prefix}_dewey_{$class}" dewey="{$class}">
                        <h4>{$class} - {$name}</h4>
                    </level4>
                </p:inline>
            </p:input>
            <p:input port="source">
                <p:inline>
                    <doc/>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:pipe step="vars" port="result"/>
            </p:input>
        </p:template>
        <p:insert match="/*" position="last-child">
            <p:input port="insertion">
                <p:pipe port="result" step="dewey1-level5"/>
            </p:input>
        </p:insert>
    </p:for-each>
    <p:split-sequence test="dtbook:level4[count(*) &gt; 1]"/>
    <p:identity name="dewey-result-1"/>
    
    <p:for-each>
        <p:iteration-source select="/*/*[@steps='10']/*">
            <p:pipe port="result" step="dewey"/>
        </p:iteration-source>
        <p:variable name="class" select="/*/@code"/>
        <p:variable name="name" select="/*"/>
        <p:for-each name="dewey10-level5">
            <p:output port="result" sequence="true"/>
            <p:iteration-source>
                <p:pipe port="result" step="dewey-result-1"/>
            </p:iteration-source>
            <p:variable name="dewey" select="number((//*[@class='dewey'])[1])"/>
            <p:choose>
                <p:when test="number($class) &lt;= $dewey and $dewey &lt; number($class) + 10">
                    <p:rename match="dtbook:level5" new-name="level6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                    <p:rename match="dtbook:h5" new-name="h6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                    <p:rename match="dtbook:level4" new-name="level5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                    <p:rename match="dtbook:h4" new-name="h5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                </p:when>
                <p:otherwise>
                    <p:sink/>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>
        </p:for-each>

        <p:in-scope-names name="vars"/>
        <p:template>
            <p:input port="template">
                <p:inline xmlns="http://www.daisy.org/z3986/2005/dtbook/">
                    <level4 id="{$id-prefix}_dewey_{replace($class,'.$','x')}" dewey="{$class}">
                        <h4>{$class} - {$name}</h4>
                    </level4>
                </p:inline>
            </p:input>
            <p:input port="source">
                <p:inline>
                    <doc/>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:pipe step="vars" port="result"/>
            </p:input>
        </p:template>
        <p:insert match="/*" position="last-child">
            <p:input port="insertion">
                <p:pipe port="result" step="dewey10-level5"/>
            </p:input>
        </p:insert>
    </p:for-each>
    <p:split-sequence test="dtbook:level4[count(*) &gt; 1]"/>
    <p:identity name="dewey-result-10"/>
    
    <p:for-each>
        <p:iteration-source select="/*/*[@steps='100']/*">
            <p:pipe port="result" step="dewey"/>
        </p:iteration-source>
        <p:variable name="class" select="/*/@code"/>
        <p:variable name="name" select="/*"/>
        <p:for-each name="dewey100-level5">
            <p:output port="result" sequence="true"/>
            <p:iteration-source>
                <p:pipe port="result" step="dewey-result-10"/>
            </p:iteration-source>
            <p:variable name="dewey" select="number((//*[@class='dewey'])[1])"/>
            <p:choose>
                <p:when test="number($class) &lt;= $dewey and $dewey &lt; number($class) + 100">
                    <p:rename match="dtbook:level6" new-name="level7" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                    <p:rename match="dtbook:h6" new-name="h7" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                    <p:rename match="dtbook:level5" new-name="level6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                    <p:rename match="dtbook:h5" new-name="h6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                    <p:rename match="dtbook:level4" new-name="level5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                    <p:rename match="dtbook:h4" new-name="h5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
                </p:when>
                <p:otherwise>
                    <p:sink/>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>
        </p:for-each>

        <p:in-scope-names name="vars"/>
        <p:template>
            <p:input port="template">
                <p:inline xmlns="http://www.daisy.org/z3986/2005/dtbook/">
                    <level4 id="{$id-prefix}_dewey_{replace($class,'..$','xx')}">
                        <h4>{$class} - {$name}</h4>
                    </level4>
                </p:inline>
            </p:input>
            <p:input port="source">
                <p:inline>
                    <doc/>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:pipe step="vars" port="result"/>
            </p:input>
        </p:template>
        <p:insert match="/*" position="last-child">
            <p:input port="insertion">
                <p:pipe port="result" step="dewey100-level5"/>
            </p:input>
        </p:insert>
        <p:delete match="//@dewey"/>
    </p:for-each>
    <p:split-sequence test="dtbook:level4[count(*) &gt; 1]"/>
    
    <p:for-each>
        <p:viewport match="dtbook:level5">
            <p:unwrap match="dtbook:level6[count(dtbook:level7) &lt;= 5]"/>
            <p:unwrap match="dtbook:level6[count(parent::*/dtbook:level6) = 1]"/>

            <p:delete match="/*/dtbook:h6"/>
            <p:rename match="/*/dtbook:level7/dtbook:h7" new-name="h6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
            <p:rename match="/*/dtbook:level7" new-name="level6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        </p:viewport>

        <p:unwrap match="dtbook:level5[count(dtbook:level6) &lt;= 5]"/>
        <p:unwrap match="dtbook:level5[count(parent::*/dtbook:level5) = 1]"/>

        <p:delete match="/*/dtbook:h5"/>
        <p:rename match="/*/dtbook:level6/dtbook:level7/dtbook:h7" new-name="h6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="/*/dtbook:level6/dtbook:level7" new-name="level6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="/*/dtbook:level6/dtbook:h6" new-name="h5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
        <p:rename match="/*/dtbook:level6" new-name="level5" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
    </p:for-each>
    
    <p:for-each>
        <p:viewport match="//dtbook:level6[dtbook:level7]">
            <p:identity name="dewey-there-is-no-level7"/>
            <p:delete match="//dtbook:level7"/>
            <p:wrap-sequence wrapper="wrapper"/>
            <p:insert match="/*" position="last-child">
                <p:input port="insertion" select="//dtbook:level7">
                    <p:pipe port="result" step="dewey-there-is-no-level7"/>
                </p:input>
            </p:insert>
            <p:rename match="dtbook:level7" new-name="level6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
            <p:rename match="dtbook:h7" new-name="h6" new-namespace="http://www.daisy.org/z3986/2005/dtbook/"/>
            <p:for-each>
                <p:iteration-source select="/*/*"/>
                <p:identity/>
            </p:for-each>
        </p:viewport>
    </p:for-each>
    
    <p:identity name="dewey-result"/>

    <p:identity name="dewey">
        <p:input port="source">
            <p:inline>
                <c:dewey>
                    <c:dewey steps="100">
                        <c:dewey code="000">Generelle emner</c:dewey>
                        <c:dewey code="100">Filosofi og psykologi</c:dewey>
                        <c:dewey code="200">Religion</c:dewey>
                        <c:dewey code="300">Samfunnsvitenskapene</c:dewey>
                        <c:dewey code="400">Språk og språkvitenskap</c:dewey>
                        <c:dewey code="500">Naturvitenskap og matematikk</c:dewey>
                        <c:dewey code="600">Teknologi og anvendt vitenskap</c:dewey>
                        <c:dewey code="700">Kunst og underholdning, sport og idrett</c:dewey>
                        <c:dewey code="800">Litteratur</c:dewey>
                        <c:dewey code="900">Historie, geografi og biografier</c:dewey>
                    </c:dewey>
                    <c:dewey steps="10">
                        <c:dewey code="000">Informatikk, kunnskap og systemer</c:dewey>
                        <c:dewey code="010">Bibliografier</c:dewey>
                        <c:dewey code="020">Bibliotek- og informasjonsvitenskap</c:dewey>
                        <c:dewey code="030">Encyclopedier og leksika</c:dewey>
                        <c:dewey code="040">Informatikk, informasjonsvitenskap og generelle verker</c:dewey>
                        <c:dewey code="050">Periodika</c:dewey>
                        <c:dewey code="060">Foreninger, organisasjoner og museer</c:dewey>
                        <c:dewey code="070">Nyhetsmedier, journalistikk og publisering</c:dewey>
                        <c:dewey code="080">Generelle emner</c:dewey>
                        <c:dewey code="090">Håndskrifter og sjeldne bøker</c:dewey>
                        <c:dewey code="100">Filosofi</c:dewey>
                        <c:dewey code="110">Metafysikk</c:dewey>
                        <c:dewey code="120">Erkjennelsesteori</c:dewey>
                        <c:dewey code="130">Parapsykologi og okkultisme</c:dewey>
                        <c:dewey code="140">Filosofiske skoler</c:dewey>
                        <c:dewey code="150">Psykologi</c:dewey>
                        <c:dewey code="160">Logikk</c:dewey>
                        <c:dewey code="170">Etikk</c:dewey>
                        <c:dewey code="180">Oldtidens, middelalderens og østens filosofi</c:dewey>
                        <c:dewey code="190">Vestens filosofi i nyere tid</c:dewey>
                        <c:dewey code="200">Religion</c:dewey>
                        <c:dewey code="210">Filosofi og teori innen religion</c:dewey>
                        <c:dewey code="220">Bibelen</c:dewey>
                        <c:dewey code="230">Kristendom og kristen teologi</c:dewey>
                        <c:dewey code="240">Kristen livsførsel</c:dewey>
                        <c:dewey code="250">Kristent pastoralt arbeid og religiøse ordener</c:dewey>
                        <c:dewey code="260">Kirkens organisasjon, diakoni og gudsdyrkelse</c:dewey>
                        <c:dewey code="270">Kristendommens historie</c:dewey>
                        <c:dewey code="280">Kristne trossamfunn</c:dewey>
                        <c:dewey code="290">Ikke-kristne religioner</c:dewey>
                        <c:dewey code="300">Samfunnsvitenskap, sosiologi og antropologi</c:dewey>
                        <c:dewey code="310">Statistikk</c:dewey>
                        <c:dewey code="320">Statsvitenskap</c:dewey>
                        <c:dewey code="330">Økonomi</c:dewey>
                        <c:dewey code="340">Rettsvitenskap</c:dewey>
                        <c:dewey code="350">Offentlig administrasjon og militærvesen</c:dewey>
                        <c:dewey code="360">Sosiale problemer og sosiale tjenester</c:dewey>
                        <c:dewey code="370">Utdanning og pedagogikk</c:dewey>
                        <c:dewey code="380">Handel, kommunikasjon og samferdsel</c:dewey>
                        <c:dewey code="390">Skikker, etikette og folkeminne</c:dewey>
                        <c:dewey code="400">Språk og språkvitenskap</c:dewey>
                        <c:dewey code="410">Språkvitenskap</c:dewey>
                        <c:dewey code="420">Engelsk og gammelengelsk</c:dewey>
                        <c:dewey code="430">Tysk og beslektede språk</c:dewey>
                        <c:dewey code="440">Fransk og beslektede språk</c:dewey>
                        <c:dewey code="450">Italiensk, rumensk og beslektede språk</c:dewey>
                        <c:dewey code="460">Spansk og portugisisk</c:dewey>
                        <c:dewey code="470">Latin og italiske språk</c:dewey>
                        <c:dewey code="480">Klassisk gresk og moderne greske språk</c:dewey>
                        <c:dewey code="490">Andre språk</c:dewey>
                        <c:dewey code="500">Naturvitenskap</c:dewey>
                        <c:dewey code="510">Matematikk</c:dewey>
                        <c:dewey code="520">Astronomi</c:dewey>
                        <c:dewey code="530">Fysikk</c:dewey>
                        <c:dewey code="540">Kjemi</c:dewey>
                        <c:dewey code="550">Geovitenskapelige fag og geologi</c:dewey>
                        <c:dewey code="560">Fossiler og forhistorisk liv</c:dewey>
                        <c:dewey code="570">Biologiske fag; biologi</c:dewey>
                        <c:dewey code="580">Planter (Botanikk)</c:dewey>
                        <c:dewey code="590">Dyr (Zoologi)</c:dewey>
                        <c:dewey code="600">Teknologi</c:dewey>
                        <c:dewey code="610">Medisin og helse</c:dewey>
                        <c:dewey code="620">Teknikk</c:dewey>
                        <c:dewey code="630">Landbruk</c:dewey>
                        <c:dewey code="640">Husholdning og familieliv</c:dewey>
                        <c:dewey code="650">Administrasjon og PR-virksomhet</c:dewey>
                        <c:dewey code="660">Kjemiteknikk</c:dewey>
                        <c:dewey code="670">Industriell produksjon</c:dewey>
                        <c:dewey code="680">Produksjon med bestemte bruksområder</c:dewey>
                        <c:dewey code="690">Husbygging</c:dewey>
                        <c:dewey code="700">Kunst</c:dewey>
                        <c:dewey code="710">Landskapsutforming og arealplanlegging</c:dewey>
                        <c:dewey code="720">Arkitektur</c:dewey>
                        <c:dewey code="730">Skulptur; keramisk kunst og metallkunst</c:dewey>
                        <c:dewey code="740">Tegnekunst og kunsthåndverk</c:dewey>
                        <c:dewey code="750">Malerkunst</c:dewey>
                        <c:dewey code="760">Grafiske kunstarter</c:dewey>
                        <c:dewey code="770">Fotografi og datakunst</c:dewey>
                        <c:dewey code="780">Musikk</c:dewey>
                        <c:dewey code="790">Sport, spill og underholdning</c:dewey>
                        <c:dewey code="800">Litteratur, litterær komposisjon og kritikk</c:dewey>
                        <c:dewey code="810">Amerikansk litteratur på engelsk</c:dewey>
                        <c:dewey code="820">Engelsk og gammelengelsk litteratur</c:dewey>
                        <c:dewey code="830">Tysk og beslektede litteraturer</c:dewey>
                        <c:dewey code="840">Fransk og beslektede litteraturer</c:dewey>
                        <c:dewey code="850">Italiensk, rumensk og beslektede litteraturer</c:dewey>
                        <c:dewey code="860">Spansk og portugisisk litteratur</c:dewey>
                        <c:dewey code="870">Latin og italiske språks litteraturer</c:dewey>
                        <c:dewey code="880">Klassisk gresk og nygresk litteratur</c:dewey>
                        <c:dewey code="890">Andre litteraturer</c:dewey>
                        <c:dewey code="900">Historie</c:dewey>
                        <c:dewey code="910">Geografi og reiser</c:dewey>
                        <c:dewey code="920">Biografi</c:dewey>
                        <c:dewey code="930">Oldtidens historie (til ca. 499)</c:dewey>
                        <c:dewey code="940">Europas historie</c:dewey>
                        <c:dewey code="950">Asias historie</c:dewey>
                        <c:dewey code="960">Afrikas historie</c:dewey>
                        <c:dewey code="970">Nord- og Mellom-Amerikas historie</c:dewey>
                        <c:dewey code="980">Sør-Amerikas historie</c:dewey>
                        <c:dewey code="990">Andre områders historie</c:dewey>
                    </c:dewey>
                    <c:dewey steps="1">
                        <c:dewey code="000">Informatikk, informasjonsvitenskap og generelle verker</c:dewey>
                        <c:dewey code="001">Kunnskap og vitenskap</c:dewey>
                        <c:dewey code="002">Boken</c:dewey>
                        <c:dewey code="003">Systemer</c:dewey>
                        <c:dewey code="004">Databehandling og informatikk</c:dewey>
                        <c:dewey code="005">Dataprogrammering, programmer og data</c:dewey>
                        <c:dewey code="006">Spesielle datametoder</c:dewey>
                        <c:dewey code="007" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="008" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="009" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="010">Bibliografi</c:dewey>
                        <c:dewey code="011">Bibliografier</c:dewey>
                        <c:dewey code="012">Bibliografier som gjelder enkeltpersoner</c:dewey>
                        <c:dewey code="013" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="014">Bibliografier over anonyme og pseudonyme verker</c:dewey>
                        <c:dewey code="015">Bibliografier over dokumenter utgitt i bestemte områder</c:dewey>
                        <c:dewey code="016">Bibliografier over dokumenter om bestemte emner</c:dewey>
                        <c:dewey code="017">Kataloger ordnet etter emne</c:dewey>
                        <c:dewey code="018">Kataloger ordnet etter forfatter, dato etc.</c:dewey>
                        <c:dewey code="019">Ordbokskataloger</c:dewey>
                        <c:dewey code="020">Bibliotek- og informasjonsvitenskap</c:dewey>
                        <c:dewey code="021">Bibliotekers forbindelser og samarbeid</c:dewey>
                        <c:dewey code="022">Forvaltning av fysiske anlegg</c:dewey>
                        <c:dewey code="023">Personalforvaltning</c:dewey>
                        <c:dewey code="024" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="025">Bibliotekoperasjoner</c:dewey>
                        <c:dewey code="026">Biblioteker knyttet til bestemte emner</c:dewey>
                        <c:dewey code="027">Generelle biblioteker</c:dewey>
                        <c:dewey code="028">Lesing og bruk av andre informasjonsmedier</c:dewey>
                        <c:dewey code="029" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="030">Generelle encyklopedier</c:dewey>
                        <c:dewey code="031">Encyklopedier på amerikansk-engelsk</c:dewey>
                        <c:dewey code="032">Encyklopedier på engelsk</c:dewey>
                        <c:dewey code="033">Encyklopedier på andre germanske språk</c:dewey>
                        <c:dewey code="034">Encyklopedier på fransk, oksitansk og katalansk</c:dewey>
                        <c:dewey code="035">Encyklopedier på italiensk, rumensk og beslektede språk</c:dewey>
                        <c:dewey code="036">Encyklopedier på spansk og portugisisk</c:dewey>
                        <c:dewey code="037">Encyklopedier på slaviske språk</c:dewey>
                        <c:dewey code="038">Encyklopedier på nordiske språk</c:dewey>
                        <c:dewey code="039">Encyklopedier på andre språk</c:dewey>
                        <c:dewey code="040" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="041" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="042" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="043" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="044" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="045" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="046" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="047" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="048" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="049" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="050">Generelle periodika</c:dewey>
                        <c:dewey code="051">Periodika på amerikansk-engelsk</c:dewey>
                        <c:dewey code="052">Periodika på engelsk</c:dewey>
                        <c:dewey code="053">Periodika på andre germanske språk</c:dewey>
                        <c:dewey code="054">Periodika på fransk, oksitansk og katalansk</c:dewey>
                        <c:dewey code="055">Periodika på italiensk, rumensk og beslektede språk</c:dewey>
                        <c:dewey code="056">Periodika på spansk og portugisisk</c:dewey>
                        <c:dewey code="057">Periodika på slaviske språk</c:dewey>
                        <c:dewey code="058">Periodika på nordiske språk</c:dewey>
                        <c:dewey code="059">Periodika på andre språk</c:dewey>
                        <c:dewey code="060">Generelle organisasjoner og museumskunnskap</c:dewey>
                        <c:dewey code="061">Organisasjoner i Nord-Amerika</c:dewey>
                        <c:dewey code="062">Organisasjoner på de Britiske øyer; i England</c:dewey>
                        <c:dewey code="063">Organisasjoner i Sentral-Europa; i Tyskland</c:dewey>
                        <c:dewey code="064">Organisasjoner i Frankrike og Monaco</c:dewey>
                        <c:dewey code="065">Organisasjoner i Italia med tilgrensende områder</c:dewey>
                        <c:dewey code="066">Organisasjoner på den Iberiske halvøy med tilgrensende øyer</c:dewey>
                        <c:dewey code="067">Organisasjoner i Øst-Europa; i Russland</c:dewey>
                        <c:dewey code="068">Organisasjoner i andre geografiske områder</c:dewey>
                        <c:dewey code="069">Museumskunnskap</c:dewey>
                        <c:dewey code="070">Nyhetsmedier, journalistikk og publisering</c:dewey>
                        <c:dewey code="071">Aviser i Nord-Amerika</c:dewey>
                        <c:dewey code="072">Aviser på de Britiske øyer; i England</c:dewey>
                        <c:dewey code="073">Aviser i Sentral-Europa; i Tyskland</c:dewey>
                        <c:dewey code="074">Aviser i Frankrike og Monaco</c:dewey>
                        <c:dewey code="075">Aviser i Italia og omkringliggende øyer</c:dewey>
                        <c:dewey code="076">Aviser på den Iberiske halvøy og omkringliggende områder</c:dewey>
                        <c:dewey code="077">Aviser i Øst-Europa; i Russland</c:dewey>
                        <c:dewey code="078">Aviser i Norden</c:dewey>
                        <c:dewey code="079">Aviser i andre geografiske områder</c:dewey>
                        <c:dewey code="080">Generelle samlinger</c:dewey>
                        <c:dewey code="081">Samlinger på amerikansk-engelsk</c:dewey>
                        <c:dewey code="082">Samlinger på engelsk</c:dewey>
                        <c:dewey code="083">Samlinger på andre germanske språk</c:dewey>
                        <c:dewey code="084">Samlinger på fransk, oksitansk, katalansk</c:dewey>
                        <c:dewey code="085">Samlinger på italiensk, rumensk og beslektede språk</c:dewey>
                        <c:dewey code="086">Samlinger på spansk og portugisisk</c:dewey>
                        <c:dewey code="087">Samlinger på slaviske språk</c:dewey>
                        <c:dewey code="088">Samlinger på nordiske språk</c:dewey>
                        <c:dewey code="089">Samlinger på andre språk</c:dewey>
                        <c:dewey code="090">Håndskrifter og sjeldne bøker</c:dewey>
                        <c:dewey code="091">Håndskrifter</c:dewey>
                        <c:dewey code="092">Blokkbøker</c:dewey>
                        <c:dewey code="093">Inkunabler</c:dewey>
                        <c:dewey code="094">Trykte bøker</c:dewey>
                        <c:dewey code="095">Bøker med sjelden innbinding</c:dewey>
                        <c:dewey code="096">Bøker med sjeldne illustrasjoner</c:dewey>
                        <c:dewey code="097">Bøker som er kjent på grunn av sine eiere eller sin opprinnelse</c:dewey>
                        <c:dewey code="098">Forbudte bøker, forfalskninger</c:dewey>
                        <c:dewey code="099">Bøker i sjeldent format</c:dewey>
                        <c:dewey code="100">Filosofi og psykologi</c:dewey>
                        <c:dewey code="101">Teori innen filosofi</c:dewey>
                        <c:dewey code="102">Diverse</c:dewey>
                        <c:dewey code="103">Ordbøker og leksika</c:dewey>
                        <c:dewey code="104" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="105">Periodika</c:dewey>
                        <c:dewey code="106">Organisasjoner og administrasjon</c:dewey>
                        <c:dewey code="107">Utdanning, forskning og lignende emner</c:dewey>
                        <c:dewey code="108">Bestemte kategorier personer</c:dewey>
                        <c:dewey code="109">Filosofiens historie, personer knyttet til filosofi</c:dewey>
                        <c:dewey code="110">Metafysikk</c:dewey>
                        <c:dewey code="111">Ontologi</c:dewey>
                        <c:dewey code="112" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="113">Kosmologi</c:dewey>
                        <c:dewey code="114">Rom</c:dewey>
                        <c:dewey code="115">Tid</c:dewey>
                        <c:dewey code="116">Forandring</c:dewey>
                        <c:dewey code="117">Struktur</c:dewey>
                        <c:dewey code="118">Kraft og energi</c:dewey>
                        <c:dewey code="119">Tall og mengde</c:dewey>
                        <c:dewey code="120">Erkjennelsesteori, årsakssammenheng og mennesket</c:dewey>
                        <c:dewey code="121">Erkjennelsesteori</c:dewey>
                        <c:dewey code="122">Årsakssammenheng</c:dewey>
                        <c:dewey code="123">Determinisme og indeterminisme</c:dewey>
                        <c:dewey code="124">Teleologi</c:dewey>
                        <c:dewey code="125" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="126">Selvet</c:dewey>
                        <c:dewey code="127">Det ubevisste og det underbevisste</c:dewey>
                        <c:dewey code="128">Mennesket</c:dewey>
                        <c:dewey code="129">Individuelle sjelers opprinnelse og bestemmelse</c:dewey>
                        <c:dewey code="130">Parapsykologi og okkultisme</c:dewey>
                        <c:dewey code="131">Parapsykologiske og okkulte midler</c:dewey>
                        <c:dewey code="132" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="133">Bestemte emner innen parapsykologi og okkultisme</c:dewey>
                        <c:dewey code="134" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="135">Drømmer og mysterier</c:dewey>
                        <c:dewey code="136" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="137">Spåing ved hjelp av grafologi</c:dewey>
                        <c:dewey code="138">Fysiognomikk</c:dewey>
                        <c:dewey code="139">Frenologi</c:dewey>
                        <c:dewey code="140">Bestemte filosofiske skoler</c:dewey>
                        <c:dewey code="141">Idealisme og lignende systemer</c:dewey>
                        <c:dewey code="142">Kritisk filosofi</c:dewey>
                        <c:dewey code="143">Bergsonisme og intuisjonisme</c:dewey>
                        <c:dewey code="144">Humanisme og lignende systemer</c:dewey>
                        <c:dewey code="145">Sensualisme</c:dewey>
                        <c:dewey code="146">Naturalisme og lignende systemer</c:dewey>
                        <c:dewey code="147">Panteisme og lignende systemer</c:dewey>
                        <c:dewey code="148">Eklektisisme, liberalisme og tradisjonalisme</c:dewey>
                        <c:dewey code="149">Andre filosofiske systemer</c:dewey>
                        <c:dewey code="150">Psykologi</c:dewey>
                        <c:dewey code="151" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="152">Sansing, bevegelse, emosjoner og fysiologiske drifter</c:dewey>
                        <c:dewey code="153">Mentale prosesser og intelligens</c:dewey>
                        <c:dewey code="154">Underbevisste og endrede tilstander</c:dewey>
                        <c:dewey code="155">Differensialpsykologi og utviklingspsykologi</c:dewey>
                        <c:dewey code="156">Sammenlignende psykologi</c:dewey>
                        <c:dewey code="157" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="158">Anvendt psykologi</c:dewey>
                        <c:dewey code="159" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="160">Logikk</c:dewey>
                        <c:dewey code="161">Induksjon</c:dewey>
                        <c:dewey code="162">Deduksjon</c:dewey>
                        <c:dewey code="163" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="164" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="165">Feilslutninger og feilkilder</c:dewey>
                        <c:dewey code="166">Syllogismer</c:dewey>
                        <c:dewey code="167">Hypoteser</c:dewey>
                        <c:dewey code="168">Argumentasjon og overtalelse</c:dewey>
                        <c:dewey code="169">Analogi</c:dewey>
                        <c:dewey code="170">Etikk</c:dewey>
                        <c:dewey code="171">Etiske systemer</c:dewey>
                        <c:dewey code="172">Politisk etikk</c:dewey>
                        <c:dewey code="173">Familieetikk</c:dewey>
                        <c:dewey code="174">Yrkesetikk</c:dewey>
                        <c:dewey code="175">Etikk vedrørende fritidsvirksomhet og fornøyelser</c:dewey>
                        <c:dewey code="176">Etikk vedrørende seksualitet og reproduksjon</c:dewey>
                        <c:dewey code="177">Etikk i mellommenneskelige forhold</c:dewey>
                        <c:dewey code="178">Forbrukeretikk</c:dewey>
                        <c:dewey code="179">Andre etiske normer</c:dewey>
                        <c:dewey code="180">Oldtidens, middelalderens og østens filosofi</c:dewey>
                        <c:dewey code="181">Østens filosofi</c:dewey>
                        <c:dewey code="182">Gresk filosofi før Sokrates</c:dewey>
                        <c:dewey code="183">Sokrates og beslektet filosofi</c:dewey>
                        <c:dewey code="184">Platonsk filosofi</c:dewey>
                        <c:dewey code="185">Aristotelisk filosofi</c:dewey>
                        <c:dewey code="186">Skeptisisme og nyplatonisme</c:dewey>
                        <c:dewey code="187">Epikureisme</c:dewey>
                        <c:dewey code="188">Stoisisme</c:dewey>
                        <c:dewey code="189">Vestens filosofi i middelalderen</c:dewey>
                        <c:dewey code="190">Vestens filosofi i nyere tid</c:dewey>
                        <c:dewey code="191">Filosofi i Forente stater og Canada</c:dewey>
                        <c:dewey code="192">Filosofi på de Britiske øyer</c:dewey>
                        <c:dewey code="193">Filosofi i Tyskland og Østerrike</c:dewey>
                        <c:dewey code="194">Filosofi i Frankrike</c:dewey>
                        <c:dewey code="195">Filosofi i Italia</c:dewey>
                        <c:dewey code="196">Filosofi i Spania og Portugal</c:dewey>
                        <c:dewey code="197">Filosofi i tidligere Sovjetunionen</c:dewey>
                        <c:dewey code="198">Filosofi i Norden</c:dewey>
                        <c:dewey code="199">Filosofi i andre geografiske områder</c:dewey>
                        <c:dewey code="200">Religion</c:dewey>
                        <c:dewey code="201">Religiøs mytologi og sosialteologi</c:dewey>
                        <c:dewey code="202">Dogmer</c:dewey>
                        <c:dewey code="203">Offentlig gudsdyrkelse</c:dewey>
                        <c:dewey code="204">Religiøse opplevelser og religiøs livsførsel</c:dewey>
                        <c:dewey code="205">Moralteologi</c:dewey>
                        <c:dewey code="206">Ledere og organisasjoner</c:dewey>
                        <c:dewey code="207">Misjon og religionsundervisning</c:dewey>
                        <c:dewey code="208">Kilder</c:dewey>
                        <c:dewey code="209">Sekter og reformbevegelser</c:dewey>
                        <c:dewey code="210">Filosofi og teori innen religion</c:dewey>
                        <c:dewey code="211">Gudsbegrep</c:dewey>
                        <c:dewey code="212">Guds eksistens og egenskaper, muligheten for å erkjenne Gud</c:dewey>
                        <c:dewey code="213">Verdens skapelse</c:dewey>
                        <c:dewey code="214">Teodicé</c:dewey>
                        <c:dewey code="215">Naturvitenskap og religion</c:dewey>
                        <c:dewey code="216" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="217" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="218">Mennesket</c:dewey>
                        <c:dewey code="219" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="220">Bibelen</c:dewey>
                        <c:dewey code="221">Det Gamle testamente (Tanak)</c:dewey>
                        <c:dewey code="222">De historiske bøker fra det Gamle testamente</c:dewey>
                        <c:dewey code="223">De poetiske bøker fra det Gamle testamente</c:dewey>
                        <c:dewey code="224">Profetenes bøker i det Gamle testamente</c:dewey>
                        <c:dewey code="225">Det Nye testamente</c:dewey>
                        <c:dewey code="226">Evangeliene og Apostlenes gjerninger</c:dewey>
                        <c:dewey code="227">Brevene</c:dewey>
                        <c:dewey code="228">Johannes' åpenbaring (apokalypsen)</c:dewey>
                        <c:dewey code="229">Apokryfer og pseudepigrafer</c:dewey>
                        <c:dewey code="230">Kristendom og kristen teologi</c:dewey>
                        <c:dewey code="231">Gud</c:dewey>
                        <c:dewey code="232">Jesus Kristus og hans familie</c:dewey>
                        <c:dewey code="233">Menneskeheten</c:dewey>
                        <c:dewey code="234">Frelsen og Guds nåde</c:dewey>
                        <c:dewey code="235">Åndelige vesener</c:dewey>
                        <c:dewey code="236">Eskatologi</c:dewey>
                        <c:dewey code="237" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="238">Trosbekjennelser og katekismer</c:dewey>
                        <c:dewey code="239">Apologetikk og polemikk</c:dewey>
                        <c:dewey code="240">Kristen etikk og oppbyggelig teologi</c:dewey>
                        <c:dewey code="241">Kristen etikk</c:dewey>
                        <c:dewey code="242">Oppbyggelig litteratur</c:dewey>
                        <c:dewey code="243">Vekkelseslitteratur for enkeltpersoner</c:dewey>
                        <c:dewey code="244" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="245" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="246">Bruk av kunst i kristendom</c:dewey>
                        <c:dewey code="247">Kirkelig innredning og utsmykning</c:dewey>
                        <c:dewey code="248">Kristne opplevelser, gudsdyrkelse og personlig kristenliv</c:dewey>
                        <c:dewey code="249">Kristenliv i familien</c:dewey>
                        <c:dewey code="250">Kristne religiøse ordener og den lokale kirke</c:dewey>
                        <c:dewey code="251">Prekenlære</c:dewey>
                        <c:dewey code="252">Prekentekster</c:dewey>
                        <c:dewey code="253">Pastoralt arbeid og prestens plikter</c:dewey>
                        <c:dewey code="254">Administrasjon av sognet</c:dewey>
                        <c:dewey code="255">Religiøse kongregasjoner og ordener</c:dewey>
                        <c:dewey code="256" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="257" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="258" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="259">Pastoralt arbeid for familier og bestemte kategorier personer</c:dewey>
                        <c:dewey code="260">Kristen sosialteologi og kirketeologi</c:dewey>
                        <c:dewey code="261">Sosialteologi</c:dewey>
                        <c:dewey code="262">Kirken og dens grunnsetninger</c:dewey>
                        <c:dewey code="263">Helligdager, høytider og hellige steder</c:dewey>
                        <c:dewey code="264">Offentlig gudsdyrkelse</c:dewey>
                        <c:dewey code="265">Sakramenter, andre riter og handlinger</c:dewey>
                        <c:dewey code="266">Misjon</c:dewey>
                        <c:dewey code="267">Foreninger som driver kristent arbeid</c:dewey>
                        <c:dewey code="268">Religionsundervisning</c:dewey>
                        <c:dewey code="269">Åndelig fornyelse</c:dewey>
                        <c:dewey code="270">Kristendommens historie og kirkehistorie</c:dewey>
                        <c:dewey code="271">Religiøse ordener innen kirkehistorie</c:dewey>
                        <c:dewey code="272">Forfølgelser i kirkehistorien</c:dewey>
                        <c:dewey code="273">Dogmestrid og kjetteri</c:dewey>
                        <c:dewey code="274">Kristendommens historie i Europa</c:dewey>
                        <c:dewey code="275">Kristendommens historie i Asia</c:dewey>
                        <c:dewey code="276">Kristendommens historie i Afrika</c:dewey>
                        <c:dewey code="277">Kristendommens historie i Nord-Amerika</c:dewey>
                        <c:dewey code="278">Kristendommens historie i Sør-Amerika</c:dewey>
                        <c:dewey code="279">Kristendommens historie i andre områder</c:dewey>
                        <c:dewey code="280">Kristne trossamfunn og sekter</c:dewey>
                        <c:dewey code="281">Oldkirken og ortodokse kirker</c:dewey>
                        <c:dewey code="282">Romersk-katolske kirke</c:dewey>
                        <c:dewey code="283">Anglikanske kirker</c:dewey>
                        <c:dewey code="284">Protestantiske trossamfunn med opprinnelse i Europa</c:dewey>
                        <c:dewey code="285">Presbyterianske, reformerte og kongregasjonalistkirker</c:dewey>
                        <c:dewey code="286">Baptistkirker, Disciples of Christ og adventistkirker</c:dewey>
                        <c:dewey code="287">Metodistkirker og beslektede kirker</c:dewey>
                        <c:dewey code="288" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="289">Andre trossamfunn og sekter</c:dewey>
                        <c:dewey code="290">Andre religioner</c:dewey>
                        <c:dewey code="291" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="292">Gresk og romersk religion</c:dewey>
                        <c:dewey code="293">Germansk religion</c:dewey>
                        <c:dewey code="294">Religioner av indisk opprinnelse</c:dewey>
                        <c:dewey code="295">Zarathustras lære</c:dewey>
                        <c:dewey code="296">Jødedom</c:dewey>
                        <c:dewey code="297">Islam, babisme og bahai</c:dewey>
                        <c:dewey code="298" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="299">Religioner som ikke har annen plassering</c:dewey>
                        <c:dewey code="300">Samfunnsvitenskap</c:dewey>
                        <c:dewey code="301">Sosiologi og antropologi</c:dewey>
                        <c:dewey code="302">Sosial interaksjon</c:dewey>
                        <c:dewey code="303">Sosiale prosesser</c:dewey>
                        <c:dewey code="304">Faktorer som påvirker sosial atferd</c:dewey>
                        <c:dewey code="305">Sosiale grupper</c:dewey>
                        <c:dewey code="306">Kultur og sosiale institusjoner</c:dewey>
                        <c:dewey code="307">Lokalsamfunn</c:dewey>
                        <c:dewey code="308" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="309" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="310">Generelle statistikksamlinger</c:dewey>
                        <c:dewey code="311" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="312" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="313" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="314">Generell statistikk for Europa</c:dewey>
                        <c:dewey code="315">Generell statistikk for Asia</c:dewey>
                        <c:dewey code="316">Generell statistikk for Afrika</c:dewey>
                        <c:dewey code="317">Generell statistikk for Nord- og Mellom-Amerika</c:dewey>
                        <c:dewey code="318">Generell statistikk for Sør-Amerika</c:dewey>
                        <c:dewey code="319">Generell statistikk for andre områder</c:dewey>
                        <c:dewey code="320">Statsvitenskap</c:dewey>
                        <c:dewey code="321">Regjeringssystemer og statsformer</c:dewey>
                        <c:dewey code="322">Statens forhold til organiserte grupper og deres medlemmer</c:dewey>
                        <c:dewey code="323">Menneskerettigheter, borgerrettigheter og politiske rettigheter</c:dewey>
                        <c:dewey code="324">Politiske prosesser</c:dewey>
                        <c:dewey code="325">Internasjonal flytting</c:dewey>
                        <c:dewey code="326">Slaveri og frigjøring</c:dewey>
                        <c:dewey code="327">Internasjonale forhold</c:dewey>
                        <c:dewey code="328">Den lovgivende prosess</c:dewey>
                        <c:dewey code="329" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="330">Økonomi</c:dewey>
                        <c:dewey code="331">Arbeidsøkonomi</c:dewey>
                        <c:dewey code="332">Finansøkonomi</c:dewey>
                        <c:dewey code="333">Forvaltning av landområder og energi</c:dewey>
                        <c:dewey code="334">Samvirke</c:dewey>
                        <c:dewey code="335">Sosialisme og lignende systemer</c:dewey>
                        <c:dewey code="336">Offentlige finanser</c:dewey>
                        <c:dewey code="337">Internasjonal økonomi</c:dewey>
                        <c:dewey code="338">Produksjon</c:dewey>
                        <c:dewey code="339">Makroøkonomi og lignende emner</c:dewey>
                        <c:dewey code="340">Rettsvitenskap</c:dewey>
                        <c:dewey code="341">Folkerett</c:dewey>
                        <c:dewey code="342">Forfatningsrett og forvaltningsrett</c:dewey>
                        <c:dewey code="343">Militærrett, skatter, handel og næringsliv</c:dewey>
                        <c:dewey code="344">Arbeidsrett, sosialrett, utdanning og kultur</c:dewey>
                        <c:dewey code="345">Strafferett</c:dewey>
                        <c:dewey code="346">Privatrett</c:dewey>
                        <c:dewey code="347">Sivilprosess og sivile domstoler</c:dewey>
                        <c:dewey code="348">Lover, forskrifter og domssamlinger</c:dewey>
                        <c:dewey code="349">Bestemte myndighetsområders rett</c:dewey>
                        <c:dewey code="350">Offentlig administrasjon og militærvesen</c:dewey>
                        <c:dewey code="351">Offentlig administrasjon</c:dewey>
                        <c:dewey code="352">Generelle betraktninger innen offentlig administrasjon</c:dewey>
                        <c:dewey code="353">Bestemte områder innen offentlig administrasjon</c:dewey>
                        <c:dewey code="354">Offentlig administrasjon av økonomi og miljø</c:dewey>
                        <c:dewey code="355">Militærvesen</c:dewey>
                        <c:dewey code="356">Infanteri og deres krigføring</c:dewey>
                        <c:dewey code="357">Kavaleristyrker og deres krigføring</c:dewey>
                        <c:dewey code="358">Luftforsvar og andre spesialiserte styrker</c:dewey>
                        <c:dewey code="359">Sjøstridskrefter og deres krigføring</c:dewey>
                        <c:dewey code="360">Sosiale problemer og sosiale tjenester; foreninger</c:dewey>
                        <c:dewey code="361">Sosiale problemer og sosial velferd generelt</c:dewey>
                        <c:dewey code="362">Sosiale velferdsproblemer og tjenester</c:dewey>
                        <c:dewey code="363">Andre sosiale problemer og tjenester</c:dewey>
                        <c:dewey code="364">Kriminologi</c:dewey>
                        <c:dewey code="365">Fengselsvesen</c:dewey>
                        <c:dewey code="366">Foreninger</c:dewey>
                        <c:dewey code="367">Generelle foreninger</c:dewey>
                        <c:dewey code="368">Forsikring</c:dewey>
                        <c:dewey code="369">Diverse typer foreninger</c:dewey>
                        <c:dewey code="370">Utdanning og pedagogikk</c:dewey>
                        <c:dewey code="371">Skoler og deres virksomhet; spesialpedagogikk</c:dewey>
                        <c:dewey code="372">Førskoleopplæring og grunnskole</c:dewey>
                        <c:dewey code="373">Videregående opplæring</c:dewey>
                        <c:dewey code="374">Voksenopplæring</c:dewey>
                        <c:dewey code="375">Læreplaner</c:dewey>
                        <c:dewey code="376" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="377" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="378">Høyere utdanning</c:dewey>
                        <c:dewey code="379">Utdanningspolitikk</c:dewey>
                        <c:dewey code="380">Handel, kommunikasjon og samferdsel</c:dewey>
                        <c:dewey code="381">Handel</c:dewey>
                        <c:dewey code="382">Internasjonal handel</c:dewey>
                        <c:dewey code="383">Post</c:dewey>
                        <c:dewey code="384">Kommunikasjon; telekommunikasjon</c:dewey>
                        <c:dewey code="385">Jernbanetransport</c:dewey>
                        <c:dewey code="386">Transport på vannveier i innlandet; fergetransport</c:dewey>
                        <c:dewey code="387">Transport til vanns, luftfart og romfart</c:dewey>
                        <c:dewey code="388">Samferdsel; landtransport</c:dewey>
                        <c:dewey code="389">Mål og vekt; standardisering</c:dewey>
                        <c:dewey code="390">Skikker, etikette og folkeminne</c:dewey>
                        <c:dewey code="391">Klesdrakt og personlig utseende</c:dewey>
                        <c:dewey code="392">Skikker knyttet til livssyklus og familieliv</c:dewey>
                        <c:dewey code="393">Skikker knyttet til dødsfall</c:dewey>
                        <c:dewey code="394">Generelle samfunnsskikker</c:dewey>
                        <c:dewey code="395">Etikette (Manerer)</c:dewey>
                        <c:dewey code="396" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="397" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="398">Folkeminne</c:dewey>
                        <c:dewey code="399">Skikker knyttet til krig og diplomati</c:dewey>
                        <c:dewey code="400">Språk og språkvitenskap</c:dewey>
                        <c:dewey code="401">Filosofi og teori</c:dewey>
                        <c:dewey code="402">Diverse</c:dewey>
                        <c:dewey code="403">Ordbøker og leksika</c:dewey>
                        <c:dewey code="404">Spesielle emner</c:dewey>
                        <c:dewey code="405">Periodika</c:dewey>
                        <c:dewey code="406">Organisasjoner og ledelse</c:dewey>
                        <c:dewey code="407">Utdanning, forskning og lignende emner</c:dewey>
                        <c:dewey code="408">Språk som gjelder bestemte kategorier personer</c:dewey>
                        <c:dewey code="409">Geografisk behandling og personer</c:dewey>
                        <c:dewey code="410">Språkvitenskap</c:dewey>
                        <c:dewey code="411">Skriftsystemer</c:dewey>
                        <c:dewey code="412">Etymologi</c:dewey>
                        <c:dewey code="413">Ordbøker</c:dewey>
                        <c:dewey code="414">Fonologi og fonetikk</c:dewey>
                        <c:dewey code="415">Grammatikk</c:dewey>
                        <c:dewey code="416" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="417">Dialektologi og historisk lingvistikk</c:dewey>
                        <c:dewey code="418">Normert språkbruk og anvendt lingvistikk</c:dewey>
                        <c:dewey code="419">Tegnspråk</c:dewey>
                        <c:dewey code="420">Engelsk og gammelengelsk</c:dewey>
                        <c:dewey code="421">Engelske skriftsystemer og fonologi</c:dewey>
                        <c:dewey code="422">Engelsk etymologi</c:dewey>
                        <c:dewey code="423">Engelske ordbøker</c:dewey>
                        <c:dewey code="424" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="425">Engelsk grammatikk</c:dewey>
                        <c:dewey code="426" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="427">Engelske språkvariasjoner</c:dewey>
                        <c:dewey code="428">Normert engelsk språkbruk</c:dewey>
                        <c:dewey code="429">Gammelengelsk (angelsaksisk)</c:dewey>
                        <c:dewey code="430">Germanske språk; tysk</c:dewey>
                        <c:dewey code="431">Tyske skriftsystemer og fonologi</c:dewey>
                        <c:dewey code="432">Tysk etymologi</c:dewey>
                        <c:dewey code="433">Tyske ordbøker</c:dewey>
                        <c:dewey code="434" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="435">Tysk grammatikk</c:dewey>
                        <c:dewey code="436" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="437">Tyske språkvariasjoner</c:dewey>
                        <c:dewey code="438">Normert tysk språkbruk</c:dewey>
                        <c:dewey code="439">Andre germanske språk</c:dewey>
                        <c:dewey code="440">Romanske språk; fransk</c:dewey>
                        <c:dewey code="441">Franske skriftsystemer og fonologi</c:dewey>
                        <c:dewey code="442">Fransk etymologi</c:dewey>
                        <c:dewey code="443">Franske ordbøker</c:dewey>
                        <c:dewey code="444" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="445">Fransk grammatikk</c:dewey>
                        <c:dewey code="446" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="447">Franske språkvariasjoner</c:dewey>
                        <c:dewey code="448">Normert fransk språkbruk</c:dewey>
                        <c:dewey code="449">Oksitansk og katalansk</c:dewey>
                        <c:dewey code="450">Italiensk, rumensk og beslektede språk</c:dewey>
                        <c:dewey code="451">Italienske skriftsystemer og fonologi</c:dewey>
                        <c:dewey code="452">Italiensk etymologi</c:dewey>
                        <c:dewey code="453">Italienske ordbøker</c:dewey>
                        <c:dewey code="454" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="455">Italiensk grammatikk</c:dewey>
                        <c:dewey code="456" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="457">Italienske språkvariasjoner</c:dewey>
                        <c:dewey code="458">Normert italiensk språkbruk</c:dewey>
                        <c:dewey code="459">Rumensk og beslektede språk</c:dewey>
                        <c:dewey code="460">Spansk og portugisisk</c:dewey>
                        <c:dewey code="461">Spanske skriftsystemer og fonologi</c:dewey>
                        <c:dewey code="462">Spansk etymologi</c:dewey>
                        <c:dewey code="463">Spanske ordbøker</c:dewey>
                        <c:dewey code="464" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="465">Spansk grammatikk</c:dewey>
                        <c:dewey code="466" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="467">Spanske språkvariasjoner</c:dewey>
                        <c:dewey code="468">Normert spansk språkbruk</c:dewey>
                        <c:dewey code="469">Portugisisk</c:dewey>
                        <c:dewey code="470">Italiske språk; latin</c:dewey>
                        <c:dewey code="471">Klassisk latinske skriftsystemer og fonologi</c:dewey>
                        <c:dewey code="472">Klassisk latinsk etymologi</c:dewey>
                        <c:dewey code="473">Klassisk latinske ordbøker</c:dewey>
                        <c:dewey code="474" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="475">Klassisk latinsk grammatikk</c:dewey>
                        <c:dewey code="476" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="477">Gammellatin, postklassisk latin og vulgærlatin</c:dewey>
                        <c:dewey code="478">Normert klassisk latin</c:dewey>
                        <c:dewey code="479">Andre italiske språk</c:dewey>
                        <c:dewey code="480">Greske språk; klassisk gresk</c:dewey>
                        <c:dewey code="481">Klassisk greske skriftsystemer og fonologi</c:dewey>
                        <c:dewey code="482">Klassisk gresk etymologi</c:dewey>
                        <c:dewey code="483">Klassisk greske ordbøker</c:dewey>
                        <c:dewey code="484" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="485">Klassisk gresk grammatikk</c:dewey>
                        <c:dewey code="486" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="487">Preklassisk og postklassisk gresk</c:dewey>
                        <c:dewey code="488">Normert klassisk gresk</c:dewey>
                        <c:dewey code="489">Andre greske språk</c:dewey>
                        <c:dewey code="490">Andre språk</c:dewey>
                        <c:dewey code="491">Østindoeuropeiske og keltiske språk</c:dewey>
                        <c:dewey code="492">Afroasiatiske språk; semittiske språk</c:dewey>
                        <c:dewey code="493">Ikke-semittiske afroasiatiske språk</c:dewey>
                        <c:dewey code="494">Altaiske, uralske, hyperboreiske og dravidiske språk</c:dewey>
                        <c:dewey code="495">Språk i Øst- og Sørøst-Asia</c:dewey>
                        <c:dewey code="496">Afrikanske språk</c:dewey>
                        <c:dewey code="497">Nord- og mellomamerikanske urbefolkningers språk</c:dewey>
                        <c:dewey code="498">Søramerikanske urbefolkningers språk</c:dewey>
                        <c:dewey code="499">Austronesiske og diverse språk</c:dewey>
                        <c:dewey code="500">Naturvitenskap og matematikk</c:dewey>
                        <c:dewey code="501">Filosofi og teori</c:dewey>
                        <c:dewey code="502">Diverse</c:dewey>
                        <c:dewey code="503">Ordbøker og leksika</c:dewey>
                        <c:dewey code="504" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="505">Periodika</c:dewey>
                        <c:dewey code="506">Organisasjoner og administrasjon</c:dewey>
                        <c:dewey code="507">Utdanning, forskning og lignende emner</c:dewey>
                        <c:dewey code="508">Naturhistorie</c:dewey>
                        <c:dewey code="509">Historisk eller geografisk behandling og personer</c:dewey>
                        <c:dewey code="510">Matematikk</c:dewey>
                        <c:dewey code="511">Generelle matematiske prinsipper</c:dewey>
                        <c:dewey code="512">Algebra</c:dewey>
                        <c:dewey code="513">Aritmetikk</c:dewey>
                        <c:dewey code="514">Topologi</c:dewey>
                        <c:dewey code="515">Matematisk analyse</c:dewey>
                        <c:dewey code="516">Geometri</c:dewey>
                        <c:dewey code="517" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="518">Numerisk analyse</c:dewey>
                        <c:dewey code="519">Sannsynlighetsregning og anvendt matematikk</c:dewey>
                        <c:dewey code="520">Astronomi og lignende vitenskaper</c:dewey>
                        <c:dewey code="521">Celest mekanikk</c:dewey>
                        <c:dewey code="522">Teknikker, utstyr og materialer</c:dewey>
                        <c:dewey code="523">Bestemte himmellegemer og fenomener</c:dewey>
                        <c:dewey code="524" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="525">Jorda (astronomisk geografi)</c:dewey>
                        <c:dewey code="526">Matematisk geografi</c:dewey>
                        <c:dewey code="527">Astronomisk navigasjon</c:dewey>
                        <c:dewey code="528">Efemerider</c:dewey>
                        <c:dewey code="529">Tidsregning</c:dewey>
                        <c:dewey code="530">Fysikk</c:dewey>
                        <c:dewey code="531">Klassisk mekanikk; faste legemers mekanikk</c:dewey>
                        <c:dewey code="532">Fluidmekanikk; væskemekanikk</c:dewey>
                        <c:dewey code="533">Gassers mekanikk</c:dewey>
                        <c:dewey code="534">Lyd og lignende svingninger</c:dewey>
                        <c:dewey code="535">Lys og infrarøde og ultrafiolette fenomener</c:dewey>
                        <c:dewey code="536">Varme</c:dewey>
                        <c:dewey code="537">Elektrisitet og elektronikk</c:dewey>
                        <c:dewey code="538">Magnetisme</c:dewey>
                        <c:dewey code="539">Moderne fysikk</c:dewey>
                        <c:dewey code="540">Kjemi og lignende vitenskaper</c:dewey>
                        <c:dewey code="541">Fysikalsk kjemi</c:dewey>
                        <c:dewey code="542">Teknikker, utstyr og materialer</c:dewey>
                        <c:dewey code="543">Analytisk kjemi</c:dewey>
                        <c:dewey code="544" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="545" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="546">Uorganisk kjemi</c:dewey>
                        <c:dewey code="547">Organisk kjemi</c:dewey>
                        <c:dewey code="548">Krystallografi</c:dewey>
                        <c:dewey code="549">Mineralogi</c:dewey>
                        <c:dewey code="550">Geovitenskapelige fag</c:dewey>
                        <c:dewey code="551">Geologi, hydrologi og meteorologi</c:dewey>
                        <c:dewey code="552">Petrologi</c:dewey>
                        <c:dewey code="553">Økonomisk geologi</c:dewey>
                        <c:dewey code="554">Europas geovitenskap</c:dewey>
                        <c:dewey code="555">Asias geovitenskap</c:dewey>
                        <c:dewey code="556">Afrikas geovitenskap</c:dewey>
                        <c:dewey code="557">Nord- og Mellom-Amerikas geovitenskap</c:dewey>
                        <c:dewey code="558">Sør-Amerikas geovitenskap</c:dewey>
                        <c:dewey code="559">Andre områders geovitenskap</c:dewey>
                        <c:dewey code="560">Paleontologi; paleozoologi</c:dewey>
                        <c:dewey code="561">Paleobotanikk; fossile mikroorganismer</c:dewey>
                        <c:dewey code="562">Fossile virvelløse dyr</c:dewey>
                        <c:dewey code="563">Fossile marine virvelløse dyr og fossile virvelløse dyr i fjæra</c:dewey>
                        <c:dewey code="564">Fossile bløtdyr og lignende dyr</c:dewey>
                        <c:dewey code="565">Fossile leddyr</c:dewey>
                        <c:dewey code="566">Fossile ryggstrengdyr</c:dewey>
                        <c:dewey code="567">Fossile vekselvarme virveldyr; fossile fisker</c:dewey>
                        <c:dewey code="568">Fossile fugler</c:dewey>
                        <c:dewey code="569">Fossile pattedyr</c:dewey>
                        <c:dewey code="570">Biologiske fag; biologi</c:dewey>
                        <c:dewey code="571">Fysiologi og lignende emner</c:dewey>
                        <c:dewey code="572">Biokjemi</c:dewey>
                        <c:dewey code="573">Bestemte fysiologiske systemer i dyr</c:dewey>
                        <c:dewey code="574" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="575">Bestemte deler av og systemer i planter</c:dewey>
                        <c:dewey code="576">Genetikk og evolusjon</c:dewey>
                        <c:dewey code="577">Økologi</c:dewey>
                        <c:dewey code="578">Organismers naturhistorie</c:dewey>
                        <c:dewey code="579">Mikroorganismer, sopper og alger</c:dewey>
                        <c:dewey code="580">Planter (Botanikk)</c:dewey>
                        <c:dewey code="581">Bestemte emner innen naturhistorie</c:dewey>
                        <c:dewey code="582">Planter som kjennetegnes ved karakteristika og blomster</c:dewey>
                        <c:dewey code="583">Tofrøbladete planter</c:dewey>
                        <c:dewey code="584">Enfrøbladete planter</c:dewey>
                        <c:dewey code="585">Nakenfrøete planter; bartrær</c:dewey>
                        <c:dewey code="586">Planter uten frø</c:dewey>
                        <c:dewey code="587">Karplanter uten frø</c:dewey>
                        <c:dewey code="588">Moser</c:dewey>
                        <c:dewey code="589" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="590">Dyr (Zoologi)</c:dewey>
                        <c:dewey code="591">Bestemte emner innen naturhistorie</c:dewey>
                        <c:dewey code="592">Virvelløse dyr</c:dewey>
                        <c:dewey code="593">Marine virvelløse dyr og virvelløse dyr i fjæra</c:dewey>
                        <c:dewey code="594">Bløtdyr og lignende dyr</c:dewey>
                        <c:dewey code="595">Leddyr</c:dewey>
                        <c:dewey code="596">Ryggstrengdyr</c:dewey>
                        <c:dewey code="597">Vekselvarme virveldyr; fisker</c:dewey>
                        <c:dewey code="598">Fugler</c:dewey>
                        <c:dewey code="599">Pattedyr</c:dewey>
                        <c:dewey code="600">Teknologi</c:dewey>
                        <c:dewey code="601">Filosofi og teori</c:dewey>
                        <c:dewey code="602">Diverse</c:dewey>
                        <c:dewey code="603">Ordbøker og leksika</c:dewey>
                        <c:dewey code="604">Spesielle emner</c:dewey>
                        <c:dewey code="605">Periodika</c:dewey>
                        <c:dewey code="606">Organisasjoner</c:dewey>
                        <c:dewey code="607">Utdanning, forskning og lignende emner</c:dewey>
                        <c:dewey code="608">Oppfinnelser og patenter</c:dewey>
                        <c:dewey code="609">Historisk eller geografisk behandling og personer</c:dewey>
                        <c:dewey code="610">Medisin og helse</c:dewey>
                        <c:dewey code="611">Menneskets anatomi, cellebiologi og vevsbiologi</c:dewey>
                        <c:dewey code="612">Menneskets fysiologi</c:dewey>
                        <c:dewey code="613">Personlig helse og sikkerhet</c:dewey>
                        <c:dewey code="614">Sykdomsforekomst og forebyggende medisin</c:dewey>
                        <c:dewey code="615">Farmakologi og terapi</c:dewey>
                        <c:dewey code="616">Sykdommer</c:dewey>
                        <c:dewey code="617">Kirurgi og beslektede medisinske områder</c:dewey>
                        <c:dewey code="618">Gynekologi, obstetrikk, pediatri og geriatri</c:dewey>
                        <c:dewey code="619" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="620">Teknikk og lignende fagområder</c:dewey>
                        <c:dewey code="621">Anvendt fysikk</c:dewey>
                        <c:dewey code="622">Gruvedrift og lignende operasjoner</c:dewey>
                        <c:dewey code="623">Militær og nautisk teknikk</c:dewey>
                        <c:dewey code="624">Sivil teknikk</c:dewey>
                        <c:dewey code="625">Teknikk for jernbaner og veier</c:dewey>
                        <c:dewey code="626" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="627">Vannbygging</c:dewey>
                        <c:dewey code="628">Sanitær- og kommunalteknikk</c:dewey>
                        <c:dewey code="629">Andre områder innen teknikk</c:dewey>
                        <c:dewey code="630">Landbruk og lignende fagområder</c:dewey>
                        <c:dewey code="631">Teknikker, utstyr og materialer</c:dewey>
                        <c:dewey code="632">Skader, sykdommer, skadedyrangrep på planter</c:dewey>
                        <c:dewey code="633">Jordbruksplanter</c:dewey>
                        <c:dewey code="634">Frukthager, frukt og skogbruk</c:dewey>
                        <c:dewey code="635">Hagebruk (hortikultur)</c:dewey>
                        <c:dewey code="636">Husdyrhold</c:dewey>
                        <c:dewey code="637">Meieridrift og lignende fagområder</c:dewey>
                        <c:dewey code="638">Insektavl</c:dewey>
                        <c:dewey code="639">Jakt, fiske og vern av biologiske ressurser</c:dewey>
                        <c:dewey code="640">Husholdning og familieliv</c:dewey>
                        <c:dewey code="641">Mat og drikke</c:dewey>
                        <c:dewey code="642">Måltider og servering</c:dewey>
                        <c:dewey code="643">Boliger og husholdningsutstyr</c:dewey>
                        <c:dewey code="644">Oppvarming, belysning, ventilasjon, vannforsyning</c:dewey>
                        <c:dewey code="645">Hjemmeinnredning</c:dewey>
                        <c:dewey code="646">Søm, klær og privatliv</c:dewey>
                        <c:dewey code="647">Offentlige husholdninger</c:dewey>
                        <c:dewey code="648">Husstell</c:dewey>
                        <c:dewey code="649">Oppfostring av barn og hjemmepleie</c:dewey>
                        <c:dewey code="650">Administrasjon og ledelse</c:dewey>
                        <c:dewey code="651">Kontorfunksjoner</c:dewey>
                        <c:dewey code="652">Arbeidsoperasjoner knyttet til skriftlig kommunikasjon</c:dewey>
                        <c:dewey code="653">Stenografi</c:dewey>
                        <c:dewey code="654" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="655" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="656" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="657">Regnskap</c:dewey>
                        <c:dewey code="658">Ledelse og bedriftsøkonomi</c:dewey>
                        <c:dewey code="659">Reklame og PR-virksomhet</c:dewey>
                        <c:dewey code="660">Kjemiteknikk</c:dewey>
                        <c:dewey code="661">Industrikjemikalier</c:dewey>
                        <c:dewey code="662">Eksplosiver, brennstoffer og lignende produkter</c:dewey>
                        <c:dewey code="663">Industriell drikkevareproduksjon</c:dewey>
                        <c:dewey code="664">Næringsmiddelteknologi</c:dewey>
                        <c:dewey code="665">Oljer, fettstoffer, voks og gasser</c:dewey>
                        <c:dewey code="666">Keramisk og lignende teknologi</c:dewey>
                        <c:dewey code="667">Rensing, farging og overflatebehandling</c:dewey>
                        <c:dewey code="668">Andre organiske produkters teknologi</c:dewey>
                        <c:dewey code="669">Metallurgi</c:dewey>
                        <c:dewey code="670">Industriell produksjon</c:dewey>
                        <c:dewey code="671">Metallindustri og primærprodukter av metall</c:dewey>
                        <c:dewey code="672">Jern, stål og andre jernlegeringer</c:dewey>
                        <c:dewey code="673">Ikke-jernholdige metaller</c:dewey>
                        <c:dewey code="674">Trelastproduksjon, treprodukter og kork</c:dewey>
                        <c:dewey code="675">Lær-, pels- og skinnindustri</c:dewey>
                        <c:dewey code="676">Cellulose- og papirteknologi</c:dewey>
                        <c:dewey code="677">Tekstiler</c:dewey>
                        <c:dewey code="678">Elastomerer og elastomerprodukter</c:dewey>
                        <c:dewey code="679">Produkter laget av andre bestemte råstoffer</c:dewey>
                        <c:dewey code="680">Produksjon med bestemte bruksområder</c:dewey>
                        <c:dewey code="681">Presisjonsinstrumenter og andre presisjonsapparater</c:dewey>
                        <c:dewey code="682">Smedhåndverk</c:dewey>
                        <c:dewey code="683">Jernvarer og husholdningsutstyr</c:dewey>
                        <c:dewey code="684">Innredning og hobbyverksteder</c:dewey>
                        <c:dewey code="685">Lær-, pels-, skinnvarer og lignende produkter</c:dewey>
                        <c:dewey code="686">Trykking og lignende virksomhet</c:dewey>
                        <c:dewey code="687">Klær og tilbehør</c:dewey>
                        <c:dewey code="688">Andre sluttprodukter og emballering</c:dewey>
                        <c:dewey code="689" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="690">Husbygging</c:dewey>
                        <c:dewey code="691">Byggematerialer</c:dewey>
                        <c:dewey code="692">Tilleggsaktiviteter ved bygging</c:dewey>
                        <c:dewey code="693">Bestemte materialer og formål</c:dewey>
                        <c:dewey code="694">Bygging med tre og bygningssnekring</c:dewey>
                        <c:dewey code="695">Taktekking</c:dewey>
                        <c:dewey code="696">VVS (varme-, ventilasjons- og sanitærteknikk)</c:dewey>
                        <c:dewey code="697">Oppvarming, ventilasjon og klimaanlegg</c:dewey>
                        <c:dewey code="698">Annet bygningsarbeid</c:dewey>
                        <c:dewey code="699" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="700">Kunst og underholdning</c:dewey>
                        <c:dewey code="701">Filosofi og teori innen arkitektur, bildende kunst, kunsthåndverk</c:dewey>
                        <c:dewey code="702">Diverse innen arkitektur, bildende kunst, kunsthåndverk</c:dewey>
                        <c:dewey code="703">Ordbøker, leksika innen arkitektur, bildende kunst, kunsthåndverk</c:dewey>
                        <c:dewey code="704">Spesielle emner innen arkitektur, bildende kunst, kunsthåndverk</c:dewey>
                        <c:dewey code="705">Periodika innen arkitektur, bildende kunst, kunsthåndverk</c:dewey>
                        <c:dewey code="706">Organisasjoner og administrasjon</c:dewey>
                        <c:dewey code="707">Utdanning, forskning og lignende emner</c:dewey>
                        <c:dewey code="708">Gallerier, museer og private samlinger</c:dewey>
                        <c:dewey code="709">Historisk eller geografisk behandling, personer</c:dewey>
                        <c:dewey code="710">Arealplanlegging og landskapsarkitektur</c:dewey>
                        <c:dewey code="711">Arealplanlegging</c:dewey>
                        <c:dewey code="712">Landskapsarkitektur</c:dewey>
                        <c:dewey code="713">Landskapsarkitektur for trafikkårer</c:dewey>
                        <c:dewey code="714">Vann i landskapsarkitektur</c:dewey>
                        <c:dewey code="715">Vedplanter</c:dewey>
                        <c:dewey code="716">Urteplanter</c:dewey>
                        <c:dewey code="717">Struktur i landskapsarkitektur</c:dewey>
                        <c:dewey code="718">Landskapsutforming for kirkegårder</c:dewey>
                        <c:dewey code="719">Naturlandskap</c:dewey>
                        <c:dewey code="720">Arkitektur</c:dewey>
                        <c:dewey code="721">Arkitektoniske byggverk</c:dewey>
                        <c:dewey code="722">Oldtidens arkitektur fram til ca. 300</c:dewey>
                        <c:dewey code="723">Arkitektur fra ca. 300 til 1399</c:dewey>
                        <c:dewey code="724">Arkitektur fra 1400</c:dewey>
                        <c:dewey code="725">Offentlige byggverk</c:dewey>
                        <c:dewey code="726">Bygninger for religiøse formål</c:dewey>
                        <c:dewey code="727">Bygninger for utdannings- og forskningsformål</c:dewey>
                        <c:dewey code="728">Boliger og lignende bygninger</c:dewey>
                        <c:dewey code="729">Utforming og utsmykning</c:dewey>
                        <c:dewey code="730">Plastisk kunst; skulptur</c:dewey>
                        <c:dewey code="731">Arbeidsprosesser, former og motiver innen skulptur</c:dewey>
                        <c:dewey code="732">Skulptur til ca. 500</c:dewey>
                        <c:dewey code="733">Gresk, etruskisk og romersk skulptur</c:dewey>
                        <c:dewey code="734">Skulptur fra ca. 500 til 1399</c:dewey>
                        <c:dewey code="735">Skulptur fra 1400</c:dewey>
                        <c:dewey code="736">Utskjæring og utskjæringer</c:dewey>
                        <c:dewey code="737">Numismatikk og sigillografi</c:dewey>
                        <c:dewey code="738">Keramisk kunst</c:dewey>
                        <c:dewey code="739">Metallkunst</c:dewey>
                        <c:dewey code="740">Tegnekunst og kunsthåndverk</c:dewey>
                        <c:dewey code="741">Tegnekunst og tegninger</c:dewey>
                        <c:dewey code="742">Perspektiv i tegnekunst</c:dewey>
                        <c:dewey code="743">Tegning og tegninger inndelt etter motiv</c:dewey>
                        <c:dewey code="744" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="745">Kunsthåndverk</c:dewey>
                        <c:dewey code="746">Tekstilkunst</c:dewey>
                        <c:dewey code="747">Dekorativ innredning</c:dewey>
                        <c:dewey code="748">Glass</c:dewey>
                        <c:dewey code="749">Møbler og tilbehør</c:dewey>
                        <c:dewey code="750">Malerkunst og malerier</c:dewey>
                        <c:dewey code="751">Teknikker, utstyr, materialer og former</c:dewey>
                        <c:dewey code="752">Farger</c:dewey>
                        <c:dewey code="753">Symbolikk, allegorier, mytologi og legender</c:dewey>
                        <c:dewey code="754">Genremaleri</c:dewey>
                        <c:dewey code="755">Religion</c:dewey>
                        <c:dewey code="756" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="757">Menneskeskikkelser</c:dewey>
                        <c:dewey code="758">Andre motiver</c:dewey>
                        <c:dewey code="759">Historisk eller geografisk behandling, personer</c:dewey>
                        <c:dewey code="760">Grafiske kunstarter; grafikkframstilling og grafikk</c:dewey>
                        <c:dewey code="761">Høytrykk</c:dewey>
                        <c:dewey code="762" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="763">Litografi</c:dewey>
                        <c:dewey code="764">Fargelitografi og serigrafi</c:dewey>
                        <c:dewey code="765">Metallgravering</c:dewey>
                        <c:dewey code="766">Mezzotint, akvatint og lignende prosesser</c:dewey>
                        <c:dewey code="767">Etsing og kaldnålsradering</c:dewey>
                        <c:dewey code="768" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="769">Grafiske trykk</c:dewey>
                        <c:dewey code="770">Fotografi, fotografier og datakunst</c:dewey>
                        <c:dewey code="771">Teknikker, utstyr og materialer</c:dewey>
                        <c:dewey code="772">Metallsaltprosesser</c:dewey>
                        <c:dewey code="773">Pigmentprosesser for trykking</c:dewey>
                        <c:dewey code="774">Holografi</c:dewey>
                        <c:dewey code="775">Digitalt fotografi</c:dewey>
                        <c:dewey code="776">Datakunst (Digital kunst)</c:dewey>
                        <c:dewey code="777" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="778">Fagområder og typer fotografering</c:dewey>
                        <c:dewey code="779">Fotografier</c:dewey>
                        <c:dewey code="780">Musikk</c:dewey>
                        <c:dewey code="781">Generelle prinsipper og musikalske former</c:dewey>
                        <c:dewey code="782">Vokalmusikk</c:dewey>
                        <c:dewey code="783">Musikk for enkeltstemmer; stemmen</c:dewey>
                        <c:dewey code="784">Instrumenter og instrumentalensembler</c:dewey>
                        <c:dewey code="785">Ensembler med ett instrument på hver stemme</c:dewey>
                        <c:dewey code="786">Tasteinstrumenter og andre instrumenter</c:dewey>
                        <c:dewey code="787">Strengeinstrumenter</c:dewey>
                        <c:dewey code="788">Blåseinstrumenter</c:dewey>
                        <c:dewey code="789" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="790">Fritid, underholdning, sport</c:dewey>
                        <c:dewey code="791">Offentlige opptredener</c:dewey>
                        <c:dewey code="792">Scenekunst</c:dewey>
                        <c:dewey code="793">Innendørs spill og underholdning</c:dewey>
                        <c:dewey code="794">Innendørs ferdighetsspill</c:dewey>
                        <c:dewey code="795">Hasardspill</c:dewey>
                        <c:dewey code="796">Sport, idrett og friluftsliv</c:dewey>
                        <c:dewey code="797">Vannsport og luftsport</c:dewey>
                        <c:dewey code="798">Hestesport og konkurranser med dyr</c:dewey>
                        <c:dewey code="799">Fiske, jakt og skyttersport</c:dewey>
                        <c:dewey code="800">Litteratur og litteraturvitenskap</c:dewey>
                        <c:dewey code="801">Filosofi og teori</c:dewey>
                        <c:dewey code="802">Diverse</c:dewey>
                        <c:dewey code="803">Ordbøker og leksika</c:dewey>
                        <c:dewey code="804" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="805">Periodika</c:dewey>
                        <c:dewey code="806">Organisasjoner og ledelse</c:dewey>
                        <c:dewey code="807">Utdanning, forskning og lignende emner</c:dewey>
                        <c:dewey code="808">Litterær komposisjon og samlinger av litterære tekster</c:dewey>
                        <c:dewey code="809">Historie, beskrivelse og kritikk</c:dewey>
                        <c:dewey code="810">Amerikansk litteratur på engelsk</c:dewey>
                        <c:dewey code="811">Amerikanske dikt på engelsk</c:dewey>
                        <c:dewey code="812">Amerikansk drama på engelsk</c:dewey>
                        <c:dewey code="813">Amerikanske romaner og noveller på engelsk</c:dewey>
                        <c:dewey code="814">Amerikanske essayer på engelsk</c:dewey>
                        <c:dewey code="815">Amerikanske taler på engelsk</c:dewey>
                        <c:dewey code="816">Amerikanske brev på engelsk</c:dewey>
                        <c:dewey code="817">Amerikansk humor og satire på engelsk</c:dewey>
                        <c:dewey code="818">Annen amerikansk litteratur på engelsk</c:dewey>
                        <c:dewey code="819" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="820">Engelsk og gammelengelsk litteratur</c:dewey>
                        <c:dewey code="821">Engelske dikt</c:dewey>
                        <c:dewey code="822">Engelsk drama</c:dewey>
                        <c:dewey code="823">Engelske romaner og noveller</c:dewey>
                        <c:dewey code="824">Engelske essayer</c:dewey>
                        <c:dewey code="825">Engelske taler</c:dewey>
                        <c:dewey code="826">Engelske brev</c:dewey>
                        <c:dewey code="827">Engelsk humor og satire</c:dewey>
                        <c:dewey code="828">Annen engelsk litteratur</c:dewey>
                        <c:dewey code="829">Gammelengelsk (angelsaksisk)</c:dewey>
                        <c:dewey code="830">Germanske språks litteraturer</c:dewey>
                        <c:dewey code="831">Tyske dikt</c:dewey>
                        <c:dewey code="832">Tysk drama</c:dewey>
                        <c:dewey code="833">Tyske romaner og noveller</c:dewey>
                        <c:dewey code="834">Tyske essayer</c:dewey>
                        <c:dewey code="835">Tyske taler</c:dewey>
                        <c:dewey code="836">Tyske brev</c:dewey>
                        <c:dewey code="837">Tysk humor og satire</c:dewey>
                        <c:dewey code="838">Annen tysk litteratur</c:dewey>
                        <c:dewey code="839">Annen germansk litteratur</c:dewey>
                        <c:dewey code="840">Romanske språks litteraturer</c:dewey>
                        <c:dewey code="841">Franske dikt</c:dewey>
                        <c:dewey code="842">Fransk drama</c:dewey>
                        <c:dewey code="843">Franske romaner og noveller</c:dewey>
                        <c:dewey code="844">Franske essayer</c:dewey>
                        <c:dewey code="845">Franske taler</c:dewey>
                        <c:dewey code="846">Franske brev</c:dewey>
                        <c:dewey code="847">Fransk humor og satire</c:dewey>
                        <c:dewey code="848">Annen fransk litteratur</c:dewey>
                        <c:dewey code="849">Oksitanske og katalanske litteraturer</c:dewey>
                        <c:dewey code="850">Italiensk, rumensk og beslektede litteraturer</c:dewey>
                        <c:dewey code="851">Italienske dikt</c:dewey>
                        <c:dewey code="852">Italiensk drama</c:dewey>
                        <c:dewey code="853">Italienske romaner og noveller</c:dewey>
                        <c:dewey code="854">Italienske essayer</c:dewey>
                        <c:dewey code="855">Italienske taler</c:dewey>
                        <c:dewey code="856">Italienske brev</c:dewey>
                        <c:dewey code="857">Italiensk humor og satire</c:dewey>
                        <c:dewey code="858">Annen italiensk litteratur</c:dewey>
                        <c:dewey code="859">Rumensk og beslektede litteraturer</c:dewey>
                        <c:dewey code="860">Spansk og portugisisk litteratur</c:dewey>
                        <c:dewey code="861">Spanske dikt</c:dewey>
                        <c:dewey code="862">Spansk drama</c:dewey>
                        <c:dewey code="863">Spanske romaner og noveller</c:dewey>
                        <c:dewey code="864">Spanske essayer</c:dewey>
                        <c:dewey code="865">Spanske taler</c:dewey>
                        <c:dewey code="866">Spanske brev</c:dewey>
                        <c:dewey code="867">Spansk humor og satire</c:dewey>
                        <c:dewey code="868">Annen spansk litteratur</c:dewey>
                        <c:dewey code="869">Portugisisk litteratur</c:dewey>
                        <c:dewey code="870">Italiske språks litteraturer; latinsk litteratur</c:dewey>
                        <c:dewey code="871">Latinske dikt</c:dewey>
                        <c:dewey code="872">Latinske dramatiske dikt og drama</c:dewey>
                        <c:dewey code="873">Latinske episke dikt og fortellinger</c:dewey>
                        <c:dewey code="874">Latinske lyriske dikt</c:dewey>
                        <c:dewey code="875">Latinske taler</c:dewey>
                        <c:dewey code="876">Latinske brev</c:dewey>
                        <c:dewey code="877">Latinsk humor og satire</c:dewey>
                        <c:dewey code="878">Annen latinsk litteratur</c:dewey>
                        <c:dewey code="879">Andre italiske språks litteraturer</c:dewey>
                        <c:dewey code="880">Greske språks litteraturer; klassisk gresk litteratur</c:dewey>
                        <c:dewey code="881">Klassisk greske dikt</c:dewey>
                        <c:dewey code="882">Klassisk greske dramatiske dikt og drama</c:dewey>
                        <c:dewey code="883">Klassisk greske episke dikt og fortellinger</c:dewey>
                        <c:dewey code="884">Klassisk greske lyriske dikt</c:dewey>
                        <c:dewey code="885">Klassisk greske taler</c:dewey>
                        <c:dewey code="886">Klassisk greske brev</c:dewey>
                        <c:dewey code="887">Klassisk gresk humor og satire</c:dewey>
                        <c:dewey code="888">Annen klassisk gresk litteratur</c:dewey>
                        <c:dewey code="889">Nygresk litteratur</c:dewey>
                        <c:dewey code="890">Andre språks litteraturer</c:dewey>
                        <c:dewey code="891">Østindoeuropeiske og keltiske språks litteraturer</c:dewey>
                        <c:dewey code="892">Afroasiatiske språks litteraturer; semittiske språks litteraturer</c:dewey>
                        <c:dewey code="893">Ikke-semittiske afroasiatiske språks litteraturer</c:dewey>
                        <c:dewey code="894">Altaiske, uralske, hyperboreiske og dravidiske språks litteraturer</c:dewey>
                        <c:dewey code="895">Litteratur på språk i Øst- og Sørøst-Asia</c:dewey>
                        <c:dewey code="896">Afrikanske språks litteraturer</c:dewey>
                        <c:dewey code="897">Litteraturer på nord- og mellomamerikanske urbefolkningers språk</c:dewey>
                        <c:dewey code="898">Litteraturer på søramerikanske urbefolkningers språk</c:dewey>
                        <c:dewey code="899">Litteraturer på austronesiske språk og andre språk</c:dewey>
                        <c:dewey code="900">Historie og geografi</c:dewey>
                        <c:dewey code="901">Filosofi og teori</c:dewey>
                        <c:dewey code="902">Diverse</c:dewey>
                        <c:dewey code="903">Ordbøker og leksika</c:dewey>
                        <c:dewey code="904">Samlede beretninger om ulike begivenheter</c:dewey>
                        <c:dewey code="905">Periodika</c:dewey>
                        <c:dewey code="906">Organisasjoner og administrasjon</c:dewey>
                        <c:dewey code="907">Utdanning, forskning og lignende emner</c:dewey>
                        <c:dewey code="908">Bestemte kategorier personer</c:dewey>
                        <c:dewey code="909">Verdenshistorie</c:dewey>
                        <c:dewey code="910">Geografi og reiser</c:dewey>
                        <c:dewey code="911">Historisk geografi</c:dewey>
                        <c:dewey code="912">Atlas, kart, plansjer og planer</c:dewey>
                        <c:dewey code="913">Geografi og reiser i oldtidens stater og landområder</c:dewey>
                        <c:dewey code="914">Geografi og reiser i Europa</c:dewey>
                        <c:dewey code="915">Geografi og reiser i Asia</c:dewey>
                        <c:dewey code="916">Geografi og reiser i Afrika</c:dewey>
                        <c:dewey code="917">Geografi og reiser i Nord-Amerika</c:dewey>
                        <c:dewey code="918">Geografi og reiser i Sør-Amerika</c:dewey>
                        <c:dewey code="919">Geografi og reiser i andre områder</c:dewey>
                        <c:dewey code="920">Biografi, genealogi og insignier</c:dewey>
                        <c:dewey code="921" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="922" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="923" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="924" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="925" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="926" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="927" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="928" unused="true">Tillatt nummer</c:dewey>
                        <c:dewey code="929">Genealogi, navn og insignier</c:dewey>
                        <c:dewey code="930">Oldtidens historie til ca. 499</c:dewey>
                        <c:dewey code="931">Kina til 420</c:dewey>
                        <c:dewey code="932">Egypt til 640</c:dewey>
                        <c:dewey code="933">Palestina til 70</c:dewey>
                        <c:dewey code="934">India til 647</c:dewey>
                        <c:dewey code="935">Mesopotamia og den iranske høyslette til 637</c:dewey>
                        <c:dewey code="936">Europa nord og vest for Italia til ca. 499</c:dewey>
                        <c:dewey code="937">Italia og tilgrensende områder til 476</c:dewey>
                        <c:dewey code="938">Hellas til 323</c:dewey>
                        <c:dewey code="939">Andre oldtidskulturer til ca. 640</c:dewey>
                        <c:dewey code="940">Europas historie</c:dewey>
                        <c:dewey code="941">Britiske øyer</c:dewey>
                        <c:dewey code="942">England og Wales</c:dewey>
                        <c:dewey code="943">Sentral Europa; Tyskland</c:dewey>
                        <c:dewey code="944">Frankrike og Monaco</c:dewey>
                        <c:dewey code="945">Italienske halvøy og omkringliggende øyer</c:dewey>
                        <c:dewey code="946">Iberiske halvøy og omkringliggende øyer</c:dewey>
                        <c:dewey code="947">Øst Europa; Russland</c:dewey>
                        <c:dewey code="948">Norden</c:dewey>
                        <c:dewey code="949">Andre europeiske stater</c:dewey>
                        <c:dewey code="950">Asias historie; Fjerne Østen</c:dewey>
                        <c:dewey code="951">Kina med tilgrensende områder</c:dewey>
                        <c:dewey code="952">Japan</c:dewey>
                        <c:dewey code="953">Arabiske halvøy med tilgrensende områder</c:dewey>
                        <c:dewey code="954">Sør-Asia; India</c:dewey>
                        <c:dewey code="955">Iran</c:dewey>
                        <c:dewey code="956">Midtøsten</c:dewey>
                        <c:dewey code="957">Sibir (asiatiske deler av Russland)</c:dewey>
                        <c:dewey code="958">Sentral-Asia</c:dewey>
                        <c:dewey code="959">Sørøst-Asia</c:dewey>
                        <c:dewey code="960">Afrikas historie</c:dewey>
                        <c:dewey code="961">Tunisia og Libya</c:dewey>
                        <c:dewey code="962">Egypt og Sudan</c:dewey>
                        <c:dewey code="963">Etiopia og Eritrea</c:dewey>
                        <c:dewey code="964">Nordvestafrikanske kyst og øyene utenfor</c:dewey>
                        <c:dewey code="965">Algerie</c:dewey>
                        <c:dewey code="966">Vest-Afrika og øyene utenfor kysten</c:dewey>
                        <c:dewey code="967">Sentral-Afrika og øyene utenfor kysten</c:dewey>
                        <c:dewey code="968">Sørlige Afrika; Republikken Sør-Afrika</c:dewey>
                        <c:dewey code="969">Øyene i det Sør-Indiske hav</c:dewey>
                        <c:dewey code="970">Nord- og Mellom-Amerikas historie</c:dewey>
                        <c:dewey code="971">Canada</c:dewey>
                        <c:dewey code="972">Midtre Amerika; Mexico</c:dewey>
                        <c:dewey code="973">Forente stater</c:dewey>
                        <c:dewey code="974">Nordøstlige stater</c:dewey>
                        <c:dewey code="975">Sørøstlige stater</c:dewey>
                        <c:dewey code="976">Sørlige sentralstater</c:dewey>
                        <c:dewey code="977">Nordlige sentralstater</c:dewey>
                        <c:dewey code="978">Veststatene</c:dewey>
                        <c:dewey code="979">Great Basin og statene langs Stillehavskysten</c:dewey>
                        <c:dewey code="980">Sør-Amerikas historie</c:dewey>
                        <c:dewey code="981">Brasil</c:dewey>
                        <c:dewey code="982">Argentina</c:dewey>
                        <c:dewey code="983">Chile</c:dewey>
                        <c:dewey code="984">Bolivia</c:dewey>
                        <c:dewey code="985">Peru</c:dewey>
                        <c:dewey code="986">Colombia og Ecuador</c:dewey>
                        <c:dewey code="987">Venezuela</c:dewey>
                        <c:dewey code="988">Guyana</c:dewey>
                        <c:dewey code="989">Paraguay og Uruguay</c:dewey>
                        <c:dewey code="990">Andre områders historie</c:dewey>
                        <c:dewey code="991" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="992" unused="true">Ubenyttet</c:dewey>
                        <c:dewey code="993">New Zealand</c:dewey>
                        <c:dewey code="994">Australia</c:dewey>
                        <c:dewey code="995">Melanesia; Ny Guinea</c:dewey>
                        <c:dewey code="996">Andre deler av Stillehavet; Polynesia</c:dewey>
                        <c:dewey code="997">Atlanterhavsøyene</c:dewey>
                        <c:dewey code="998">Arktiske øyer og Antarktis</c:dewey>
                        <c:dewey code="999">Himmellegemer utenfor jorda</c:dewey>
                    </c:dewey>
                </c:dewey>
            </p:inline>
        </p:input>
    </p:identity>
    <p:sink/>
</p:declare-step>
