<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <!-- 010 - 04X KONTROLLNUMMER OG KODER -->

    <xsl:template match="marcxchange:datafield[@tag='015']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 015 ANDRE BIBLIOGRAFISKE KONTROLLNUMMER'"/>-->
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='019']">
        <xsl:for-each select="marcxchange:subfield[@code='a']/tokenize(replace(text(),'\s',''),'[,\.\-_]')">
            <xsl:choose>
                <xsl:when test=".='a'">
                    <meta property="audience">Ages 0-5</meta>
                </xsl:when>
                <xsl:when test=".='b'">
                    <meta property="audience">Ages 6-8</meta>
                </xsl:when>
                <xsl:when test=".='bu'">
                    <meta property="audience">Ages 9-10</meta>
                </xsl:when>
                <xsl:when test=".='u'">
                    <meta property="audience">Ages 11-12</meta>
                </xsl:when>
                <xsl:when test=".='mu'">
                    <meta property="audience">Ages 13+</meta>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:variable name="b" as="element()*">
            <xsl:for-each select="marcxchange:subfield[@code='b']/tokenize(replace(text(),'\s',''),'[,\.\-_]')">
                <xsl:choose>
                    <xsl:when test=".='a'">
                        <meta property="dc:format.other.no">Kartografisk materiale</meta>
                        <meta property="dc:format.other">Cartographic materials</meta>
                    </xsl:when>
                    <xsl:when test=".='ab'">
                        <meta property="dc:format.other.no">Kartografisk materiale</meta>
                        <meta property="dc:format.other">Cartographic materials</meta>
                        <meta property="dc:format.other.no">Atlas</meta>
                        <meta property="dc:format.other">Atlas</meta>
                    </xsl:when>
                    <xsl:when test=".='aj'">
                        <meta property="dc:format.other.no">Kartografisk materiale</meta>
                        <meta property="dc:format.other">Cartographic materials</meta>
                        <meta property="dc:format.other.no">Kart</meta>
                        <meta property="dc:format.other">Map</meta>
                    </xsl:when>
                    <xsl:when test=".='b'">
                        <meta property="dc:format.other.no">Manuskripter</meta>
                        <meta property="dc:format.other">Manuscripts</meta>
                    </xsl:when>
                    <xsl:when test=".='c'">
                        <meta property="dc:format.other.no">Musikktrykk</meta>
                        <meta property="dc:format.other">Sheet music</meta>
                        <dc:format>Braille</dc:format>
                        <meta property="dc:format.no">Punktskrift</meta>
                    </xsl:when>
                    <xsl:when test=".='d'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                    </xsl:when>
                    <xsl:when test=".='da'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">Grammofonplate</meta>
                        <meta property="dc:format.other">Gramophone record</meta>
                    </xsl:when>
                    <xsl:when test=".='db'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">Kassett</meta>
                        <meta property="dc:format.other">Cassette</meta>
                    </xsl:when>
                    <xsl:when test=".='dc'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">CD (kompaktplate)</meta>
                        <meta property="dc:format.other">Compact Disk</meta>
                        <dc:format>DAISY 2.02</dc:format>
                    </xsl:when>
                    <xsl:when test=".='dd'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">Avspiller med lydfil</meta>
                        <meta property="dc:format.other">Player with audio file</meta>
                    </xsl:when>
                    <xsl:when test=".='de'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">Digikort</meta>
                        <meta property="dc:format.other">Digikort</meta>
                    </xsl:when>
                    <xsl:when test=".='dg'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">Musikk</meta>
                        <meta property="dc:format.other">Music</meta>
                    </xsl:when>
                    <xsl:when test=".='dh'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">Språkkurs</meta>
                        <meta property="dc:format.other">Language course</meta>
                    </xsl:when>
                    <xsl:when test=".='di'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">Lydbok</meta>
                        <meta property="dc:format.other">Audio book</meta>
                    </xsl:when>
                    <xsl:when test=".='dj'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">Annen tale/annet</meta>
                        <meta property="dc:format.other">Other voice/other</meta>
                        <dc:format>DAISY 2.02</dc:format>
                    </xsl:when>
                    <xsl:when test=".='dk'">
                        <meta property="dc:format.other.no">Lydopptak</meta>
                        <meta property="dc:format.other">Audio recording</meta>
                        <meta property="dc:format.other.no">Kombidokument</meta>
                        <meta property="dc:format.other">Combined document</meta>
                    </xsl:when>
                    <xsl:when test=".='e'">
                        <meta property="dc:format.other.no">Film</meta>
                        <meta property="dc:format.other">Video</meta>
                    </xsl:when>
                    <xsl:when test=".='ec'">
                        <meta property="dc:format.other.no">Film</meta>
                        <meta property="dc:format.other">Video</meta>
                        <meta property="dc:format.other.no">Filmspole</meta>
                        <meta property="dc:format.other">Video tape</meta>
                    </xsl:when>
                    <xsl:when test=".='ed'">
                        <meta property="dc:format.other.no">Film</meta>
                        <meta property="dc:format.other">Video</meta>
                        <meta property="dc:format.other.no">Videokassett (VHS)</meta>
                        <meta property="dc:format.other">VHS</meta>
                    </xsl:when>
                    <xsl:when test=".='ee'">
                        <meta property="dc:format.other.no">Film</meta>
                        <meta property="dc:format.other">Video</meta>
                        <meta property="dc:format.other.no">Videoplate (DVD)</meta>
                        <meta property="dc:format.other">DVD</meta>
                    </xsl:when>
                    <xsl:when test=".='ef'">
                        <meta property="dc:format.other.no">Film</meta>
                        <meta property="dc:format.other">Video</meta>
                        <meta property="dc:format.other.no">Blu-ray-plate</meta>
                        <meta property="dc:format.other">Blu-ray</meta>
                    </xsl:when>
                    <xsl:when test=".='eg'">
                        <meta property="dc:format.other.no">Film</meta>
                        <meta property="dc:format.other">Video</meta>
                        <meta property="dc:format.other.no">3D</meta>
                        <meta property="dc:format.other">3D</meta>
                    </xsl:when>
                    <xsl:when test=".='f'">
                        <meta property="dc:format.other.no">Grafisk materiale</meta>
                        <meta property="dc:format.other">Graphic materials</meta>
                    </xsl:when>
                    <xsl:when test=".='fd'">
                        <meta property="dc:format.other.no">Grafisk materiale</meta>
                        <meta property="dc:format.other">Graphic materials</meta>
                        <meta property="dc:format.other.no">Dias</meta>
                        <meta property="dc:format.other">Slides</meta>
                    </xsl:when>
                    <xsl:when test=".='ff'">
                        <meta property="dc:format.other.no">Grafisk materiale</meta>
                        <meta property="dc:format.other">Graphic materials</meta>
                        <meta property="dc:format.other.no">Fotografi</meta>
                        <meta property="dc:format.other">Photography</meta>
                    </xsl:when>
                    <xsl:when test=".='fi'">
                        <meta property="dc:format.other.no">Grafisk materiale</meta>
                        <meta property="dc:format.other">Graphic materials</meta>
                        <meta property="dc:format.other.no">Kunstreproduksjon</meta>
                        <meta property="dc:format.other">Art reproduction</meta>
                    </xsl:when>
                    <xsl:when test=".='g'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <dc:format>XHTML</dc:format>
                    </xsl:when>
                    <xsl:when test=".='gb'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <meta property="dc:format.other.no">Diskett</meta>
                        <meta property="dc:format.other">Floppy</meta>
                    </xsl:when>
                    <xsl:when test=".='gc'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <meta property="dc:format.other.no">DVD-ROM</meta>
                        <meta property="dc:format.other">DVD</meta>
                    </xsl:when>
                    <xsl:when test=".='gd'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <meta property="dc:format.other.no">CD-ROM</meta>
                        <meta property="dc:format.other">CD</meta>
                    </xsl:when>
                    <xsl:when test=".='ge'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <meta property="dc:format.other.no">Nettressurs</meta>
                        <meta property="dc:format.other">Web resource</meta>
                        <dc:format>XHTML</dc:format>
                    </xsl:when>
                    <xsl:when test=".='gf'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <meta property="dc:format.other.no">Lagringsbrikke</meta>
                        <meta property="dc:format.other">Storage card</meta>
                    </xsl:when>
                    <xsl:when test=".='gg'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <meta property="dc:format.other.no">Blu-ray ROM</meta>
                        <meta property="dc:format.other">Blu-ray</meta>
                    </xsl:when>
                    <xsl:when test=".='gh'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <meta property="dc:format.other">UMD</meta>
                    </xsl:when>
                    <xsl:when test=".='gi'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <meta property="dc:format.other.no">Wii-plate</meta>
                        <meta property="dc:format.other">Wii disk</meta>
                    </xsl:when>
                    <xsl:when test=".='gt'">
                        <meta property="dc:format.other.no">Elektronisk ressurs</meta>
                        <meta property="dc:format.other">Electronic resource</meta>
                        <meta property="dc:format.no">DTBok</meta>
                        <dc:format>DTBook</dc:format>
                    </xsl:when>
                    <xsl:when test=".='h'">
                        <meta property="dc:format.other.no">Tredimensjonal gjenstand</meta>
                        <meta property="dc:format.other">Three-dimensional object</meta>
                    </xsl:when>
                    <xsl:when test=".='i'">
                        <meta property="dc:format.other.no">Mikroform</meta>
                        <meta property="dc:format.other">Microform</meta>
                    </xsl:when>
                    <xsl:when test=".='ib'">
                        <meta property="dc:format.other.no">Mikroform</meta>
                        <meta property="dc:format.other">Microform</meta>
                        <meta property="dc:format.other.no">Mikrofilmspole</meta>
                        <meta property="dc:format.other">Microfilm tape</meta>
                    </xsl:when>
                    <xsl:when test=".='ic'">
                        <meta property="dc:format.other.no">Mikroform</meta>
                        <meta property="dc:format.other">Microform</meta>
                        <meta property="dc:format.other.no">Mikrofilmkort</meta>
                        <meta property="dc:format.other">Microfilm card</meta>
                    </xsl:when>
                    <xsl:when test=".='j'">
                        <meta property="dc:format.other.no">Periodika</meta>
                        <meta property="dc:format.other">Serial</meta>
                        <meta property="periodical">true</meta>
                    </xsl:when>
                    <xsl:when test=".='jn'">
                        <meta property="dc:format.other.no">Periodika</meta>
                        <meta property="dc:format.other">Serial</meta>
                        <meta property="dc:format.other.no">Avis</meta>
                        <meta property="dc:format.other">Newspaper</meta>
                        <meta property="periodical">true</meta>
                        <meta property="newspaper">true</meta>
                    </xsl:when>
                    <xsl:when test=".='jp'">
                        <meta property="dc:format.other.no">Periodika</meta>
                        <meta property="dc:format.other">Serial</meta>
                        <meta property="dc:format.other.no">Tidsskrift</meta>
                        <meta property="dc:format.other">Magazine</meta>
                        <meta property="periodical">true</meta>
                        <meta property="magazine">true</meta>
                    </xsl:when>
                    <xsl:when test=".='k'">
                        <meta property="dc:format.other.no">Artikler</meta>
                        <meta property="dc:format.other">Article</meta>
                    </xsl:when>
                    <xsl:when test=".='l'">
                        <meta property="dc:format.other.no">Fysiske bøker</meta>
                        <meta property="dc:format.other">Physical book</meta>
                        <dc:format>Braille</dc:format>
                        <meta property="dc:format.no">Punktskrift</meta>
                    </xsl:when>
                    <xsl:when test=".='m'">
                        <meta property="dc:format.other.no">Dataspill</meta>
                        <meta property="dc:format.other">Video game</meta>
                    </xsl:when>
                    <xsl:when test=".='ma'">
                        <meta property="dc:format.other.no">Dataspill</meta>
                        <meta property="dc:format.other">Video game</meta>
                        <meta property="dc:format.other">PC</meta>
                    </xsl:when>
                    <xsl:when test=".='mb'">
                        <meta property="dc:format.other.no">Dataspill</meta>
                        <meta property="dc:format.other">Video game</meta>
                        <meta property="dc:format.other">Playstation 2</meta>
                    </xsl:when>
                    <xsl:when test=".='mc'">
                        <meta property="dc:format.other.no">Dataspill</meta>
                        <meta property="dc:format.other">Video game</meta>
                        <meta property="dc:format.other">Playstation 3</meta>
                    </xsl:when>
                    <xsl:when test=".='md'">
                        <meta property="dc:format.other.no">Dataspill</meta>
                        <meta property="dc:format.other">Video game</meta>
                        <meta property="dc:format.other">Playstation Portable</meta>
                    </xsl:when>
                    <xsl:when test=".='mi'">
                        <meta property="dc:format.other.no">Dataspill</meta>
                        <meta property="dc:format.other">Video game</meta>
                        <meta property="dc:format.other">Xbox</meta>
                    </xsl:when>
                    <xsl:when test=".='mj'">
                        <meta property="dc:format.other.no">Dataspill</meta>
                        <meta property="dc:format.other">Video game</meta>
                        <meta property="dc:format.other">Xbox 360</meta>
                    </xsl:when>
                    <xsl:when test=".='mn'">
                        <meta property="dc:format.other.no">Dataspill</meta>
                        <meta property="dc:format.other">Video game</meta>
                        <meta property="dc:format.other">Nintendo DS</meta>
                    </xsl:when>
                    <xsl:when test=".='mo'">
                        <meta property="dc:format.other.no">Dataspill</meta>
                        <meta property="dc:format.other">Video game</meta>
                        <meta property="dc:format.other">Nintendo Wii</meta>
                    </xsl:when>
                    <xsl:when test=".='dl'">
                        <meta property="dc:format.other.no">SACD</meta>
                        <meta property="dc:format.other">SACD</meta>
                    </xsl:when>
                    <xsl:when test=".='dm'">
                        <meta property="dc:format.other.no">DVD-audio</meta>
                        <meta property="dc:format.other">DVD-audio</meta>
                    </xsl:when>
                    <xsl:when test=".='dn'">
                        <meta property="dc:format.other.no">Blu-Ray-audio</meta>
                        <meta property="dc:format.other">Blu-Ray-audio</meta>
                    </xsl:when>
                    <xsl:when test=".='dz'">
                        <meta property="dc:format.other.no">MP3</meta>
                        <meta property="dc:format.other">MP3</meta>
                    </xsl:when>
                    <xsl:when test=".='ea'">
                        <meta property="dc:format.other.no">E-film</meta>
                        <meta property="dc:format.other">E-film</meta>
                    </xsl:when>
                    <xsl:when test=".='ga'">
                        <meta property="dc:format.other.no">Nedlastbar fil</meta>
                        <meta property="dc:format.other">Downloadable file</meta>
                    </xsl:when>
                    <xsl:when test=".='je'">
                        <meta property="dc:format.other.no">E-tidsskrifter</meta>
                        <meta property="dc:format.other">E-periodicals</meta>
                    </xsl:when>
                    <xsl:when test=".='ka'">
                        <meta property="dc:format.other.no">E-artikler</meta>
                        <meta property="dc:format.other">E-articles</meta>
                    </xsl:when>
                    <xsl:when test=".='la'">
                        <meta property="dc:format.other.no">E-bøker</meta>
                        <meta property="dc:format.other">E-books</meta>
                    </xsl:when>
                    <xsl:when test=".='me'">
                        <meta property="dc:format.other.no">Playstation 4</meta>
                        <meta property="dc:format.other">Playstation 4</meta>
                    </xsl:when>
                    <xsl:when test=".='mk'">
                        <meta property="dc:format.other.no">Xbox One</meta>
                        <meta property="dc:format.other">Xbox One</meta>
                    </xsl:when>
                    <xsl:when test=".='mp'">
                        <meta property="dc:format.other.no">Nintendo Wii U</meta>
                        <meta property="dc:format.other">Nintendo Wii U</meta>
                    </xsl:when>
                    <xsl:when test=".='n'">
                        <meta property="dc:format.other.no">Filformater</meta>
                        <meta property="dc:format.other">File formats</meta>
                    </xsl:when>
                    <xsl:when test=".='na'">
                        <meta property="dc:format.other.no">PDF</meta>
                        <meta property="dc:format.other">PDF</meta>
                    </xsl:when>
                    <xsl:when test=".='nb'">
                        <meta property="dc:format.other.no">EPUB</meta>
                        <meta property="dc:format.other">EPUB</meta>
                    </xsl:when>
                    <xsl:when test=".='nc'">
                        <meta property="dc:format.other.no">MOBI</meta>
                        <meta property="dc:format.other">MOBI</meta>
                    </xsl:when>
                    <xsl:when test=".='nl'">
                        <meta property="dc:format.other.no">WMA (Windows Media Audio)</meta>
                        <meta property="dc:format.other">WMA (Windows Media Audio)</meta>
                    </xsl:when>
                    <xsl:when test=".='ns'">
                        <meta property="dc:format.other.no">WMV (Windows Media Video)</meta>
                        <meta property="dc:format.other">WMV (Windows Media Video)</meta>
                    </xsl:when>
                    <xsl:when test=".='o'">
                        <meta property="dc:format.other.no">Digital rettighetsadministrasjon (DRM)</meta>
                        <meta property="dc:format.other">Digital rights management (DRM)</meta>
                    </xsl:when>
                    <xsl:when test=".='te'">
                        <!-- non-standard -->
                        <dc:format>Braille</dc:format>
                        <meta property="dc:format.no">Punktskrift</meta>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy-of select="$b"/>

        <xsl:if test="not($b[self::dc:format])">
            <xsl:for-each select="marcxchange:subfield[@code='e']/tokenize(replace(text(),'\s',''),'[,\.\-_]')">
                <xsl:choose>
                    <xsl:when test=".='dc'">
                        <dc:format>DAISY 2.02</dc:format>
                    </xsl:when>
                    <xsl:when test=".='dj'">
                        <dc:format>DAISY 2.02</dc:format>
                    </xsl:when>
                    <xsl:when test=".='te'">
                        <dc:format>Braille</dc:format>
                        <meta property="dc:format.no">Punktskrift</meta>
                    </xsl:when>
                    <xsl:when test=".='c'">
                        <dc:format>Braille</dc:format>
                        <meta property="dc:format.no">Punktskrift</meta>
                    </xsl:when>
                    <xsl:when test=".='l'">
                        <dc:format>Braille</dc:format>
                        <meta property="dc:format.no">Punktskrift</meta>
                    </xsl:when>
                    <xsl:when test=".='gt'">
                        <dc:format>DTBook</dc:format>
                        <meta property="dc:format.no">DTBok</meta>
                    </xsl:when>
                    <xsl:when test=".='ge'">
                        <dc:format>XHTML</dc:format>
                    </xsl:when>
                    <xsl:when test=".='g'">
                        <dc:format>XHTML</dc:format>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>

        <xsl:for-each select="marcxchange:subfield[@code='d']/(for $i in (1 to string-length(text())) return substring(text(),$i,1))">
            <xsl:choose>
                <xsl:when test=".='N'">
                    <meta property="dc:type.genre">Biography</meta>
                    <meta property="dc:type.genre">short story</meta>
                </xsl:when>
                <xsl:when test=".='B'">
                    <meta property="dc:type.genre">Biography</meta>
                    <meta property="dc:type.genre">short story</meta>
                </xsl:when>
                <xsl:when test=".='D'">
                    <meta property="dc:type.genre">poem</meta>
                </xsl:when>
                <xsl:when test=".='R'">
                    <meta property="dc:type.genre">poem</meta>
                </xsl:when>
                <xsl:when test=".='S'">
                    <meta property="dc:type.genre">play</meta>
                </xsl:when>
                <xsl:when test=".='T'">
                    <meta property="dc:type.genre">cartoon</meta>
                </xsl:when>
                <xsl:when test=".='A'">
                    <meta property="dc:type.genre">anthology</meta>
                </xsl:when>
                <xsl:when test=".='L'">
                    <meta property="dc:type.genre">textbook</meta>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='020']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="isbn" scheme="ISBN">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='022']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <meta property="issn" scheme="ISSN">
                <xsl:value-of select="text()"/>
            </meta>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="marcxchange:datafield[@tag='041']">
        <xsl:for-each select="marcxchange:subfield[@code='a']">
            <xsl:variable name="text" select="text()"/>
            <xsl:for-each select="(1 to xs:integer(floor(string-length($text) div 3)))">
                <dc:language>
                    <xsl:value-of select="substring($text,1+(.-1)*3,3)"/>
                </dc:language>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="marcxchange:subfield[@code='h']">
            <xsl:variable name="text" select="text()"/>
            <xsl:for-each select="(1 to xs:integer(floor(string-length($text) div 3)))">
                <meta property="dc:language.original">
                    <xsl:value-of select="substring($text,1+(.-1)*3,3)"/>
                </meta>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
