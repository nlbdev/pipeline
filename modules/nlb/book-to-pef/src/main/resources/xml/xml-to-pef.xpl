<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:xml-to-pef" version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    exclude-inline-prefixes="#all"
    name="main">
    
    <!-- ====== -->
    <!-- Layout -->
    <!-- ====== -->
    <p:option name="braille-standard" select="'(dots:6)(grade:0)'">
        <p:pipeinfo>
            <px:data-type>
                <choice>
                    <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0" xml:lang="no">
                        <value>6-punkt, fullskrift</value>
                        <value>6-punkt, kortskrift nivå 1</value>
                        <value>6-punkt, kortskrift nivå 2</value>
                        <value>6-punkt, kortskrift nivå 3</value>
                        <value>8-punkt</value>
                    </documentation>
                    <value>(dots:6)(grade:0)</value>
                    <value>(dots:6)(grade:1)</value>
                    <value>(dots:6)(grade:2)</value>
                    <value>(dots:6)(grade:3)</value>
                    <value>(dots:8)(grade:0)</value>
                </choice>
            </px:data-type>
        </p:pipeinfo>
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Tekstformatering: Punktstandard</h2>
        </p:documentation>
    </p:option>
    <p:option name="hyphenation" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Tekstformatering: Orddeling</h2>
        </p:documentation>
    </p:option>
    <p:option name="line-spacing" select="'single'">
        <p:pipeinfo>
            <px:data-type>
                <choice>
                    <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0" xml:lang="no">
                        <value>Enkel</value>
                        <value>Dobbel</value>
                    </documentation>
                    <value>single</value>
                    <value>double</value>
                </choice>
            </px:data-type>
        </p:pipeinfo>
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Tekstformatering: Linjeavstand</h2>
        </p:documentation>
    </p:option>
    <p:option name="capital-letters" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Tekstformatering: Stor bokstav-tegn</h2>
        </p:documentation>
    </p:option>
    <p:option name="force-norwegian" select="'true'" required="false" px:type="boolean">
        <p:documentation>
            <h2 px:role="name">Tekstformatering: Bruk alltid norsk punktstandard</h2>
            <p px:role="desc" xml:space="preserve">Med dette valget brukes alltid norsk punktstandard, uavhengig av hvilket språk teksten er markert opp med.

Ved å deaktivere dette valget vil punktstandarden tilhørende hvert enkelt språk brukes, istedenfor norsk.
Dersom språket ikke har en implementert punktstandard, så vil den norske standarden alikevel brukes.
Kortskrift vil aldri brukes for fremmedspråklige tekster.

Eksempel på bruk av språkkode på del av dokument:

~~~xml
&lt;p&gt;Amerikas forente stater (engelsk: &lt;span xml:lang="en"&gt;United States of America&lt;/span&gt;),
   er en forbundsrepublikk i Nord-Amerika.&lt;/p&gt;
~~~

Eksempel på bruk av språkkode på et helt dokument

~~~xml
&lt;dtbook xml:lang="en"&gt;
&lt;!-- ...eller... --&gt;
&lt;html xml:lang="en"&gt;
~~~
</p>
        </p:documentation>
    </p:option>
    
    <!-- ====== -->
    <!-- Layout -->
    <!-- ====== -->
    <p:option name="stylesheet" px:type="anyFileURI" px:sequence="true" px:media-type="text/css text/scss" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Layout: CSS-stilark</h2>
            <p px:role="desc" xml:space="preserve">Valgfritt stilark som kan brukes for å legge til CSS-regler. NLBs standard-stilark brukes alltid, dette stilarket kommer i tillegg.</p>
        </p:documentation>
    </p:option>
    <p:option name="page-width" select="'32'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Layout: Sidebredde</h2>
        </p:documentation>
    </p:option>
    <p:option name="page-height" select="'28'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Layout: Sidehøyde</h2>
        </p:documentation>
    </p:option>
    <p:option name="duplex" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Layout: Tosidig trykk</h2>
        </p:documentation>
    </p:option>
    <p:option name="maximum-number-of-pages" select="'86'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Hefter: Største antall sider</h2>
        </p:documentation>
    </p:option>
    <p:option name="include-obfl" required="false" px:type="boolean" select="'false'">
        <p:documentation>
            <h2 px:role="name">Layout: Inkluder OBFL</h2>
            <p px:role="desc" xml:space="preserve">Lagrer mellom-formatet OBFL som en fil i resultatet.

Dette kan være nyttig for å løse problemer med formatering av PEF'en.</p>
        </p:documentation>
    </p:option>
    
    <!-- =============== -->
    <!-- Blokk-elementer -->
    <!-- =============== -->
    <p:option name="include-captions" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Blokkelementer: Inkluder bildetekst og tabelltekst</h2>
        </p:documentation>
    </p:option>
    <p:option name="include-images" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Blokkelementer: Inkluder alternativ tekst for bilder</h2>
        </p:documentation>
    </p:option>
    
    <!-- =============== -->
    <!-- Tekst-elementer -->
    <!-- =============== -->
    <p:option name="include-notes" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Tekstelementer: Inkluder noter</h2>
        </p:documentation>
    </p:option>
    <p:option name="notes-placement" select="'end-of-volume'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Tekstelementer: Plassering av noter</h2>
        </p:documentation>
        <p:pipeinfo>
            <px:data-type>
                <choice xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0">
                    <value>bottom-of-page</value>
                    <a:documentation xml:lang="en">Noter nederst på side</a:documentation>
                    <value>end-of-volume</value>
                    <a:documentation xml:lang="en">Noter i slutten av hefte</a:documentation>
                    <value>end-of-book</value>
                    <a:documentation xml:lang="en">Noter i slutten av boken</a:documentation>
                </choice>
            </px:data-type>
        </p:pipeinfo>
    </p:option>
    <p:option name="include-production-notes" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Tekstelementer: Inkluder produsentkommentarer</h2>
        </p:documentation>
    </p:option>
    
    <!-- ========== -->
    <!-- Sidenummer -->
    <!-- ========== -->
    <p:option name="show-braille-page-numbers" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Sidenummer: Vis punktskrift-sidenummer</h2>
        </p:documentation>
    </p:option>
    <p:option name="show-print-page-numbers" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Sidenummer: Vis original-sidenummer</h2>
        </p:documentation>
    </p:option>
    
    <!-- ================ -->
    <!-- Generert innhold -->
    <!-- ================ -->
    <p:option name="toc-depth" select="'2'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Generert innhold: Dybde på innholdsfortegnelse</h2>
        </p:documentation>
    </p:option>
    
    <!-- ====== -->
    <!-- Utputt -->
    <!-- ====== -->
    <p:option name="pef-output-dir">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">PEF</h2>
        </p:documentation>
    </p:option>
    <p:option name="preview-output-dir">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Forhåndsvisning</h2>
        </p:documentation>
    </p:option>
    <p:option name="obfl-output-dir"/>
    <p:option name="temp-dir">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Midlertidige filer</h2>
        </p:documentation>
    </p:option>
    
    <!-- ================== -->
    <!-- Ikke gjør noenting -->
    <!-- ================== -->
    <p:sink>
        <p:input port="source">
            <p:empty/>
        </p:input>
    </p:sink>
    
</p:declare-step>
