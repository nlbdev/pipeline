<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:nlb="http://www.nlb.no/"
                xmlns:SRU="http://www.loc.gov/zing/sru/"
                xmlns:normarc="info:lc/xmlns/marcxchange-v1"
                xmlns:marcxchange="info:lc/xmlns/marcxchange-v1"
                xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns="http://www.idpf.org/2007/opf"
                exclude-result-prefixes="#all"
                xpath-default-namespace="http://www.idpf.org/2007/opf"
                version="2.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:param name="nested" select="false()"/>
    <xsl:param name="include-source-reference" select="false()"/>
    <xsl:param name="identifier" select="''"/>
    
    <xsl:template match="@*|node()">
        <xsl:choose>
            <xsl:when test="self::*[@tag]">
                <xsl:message>
                    <xsl:text>Ingen regel for NORMARC-felt: </xsl:text>
                    <xsl:value-of select="@tag"/>
                    <xsl:text> (boknummer: </xsl:text>
                    <xsl:value-of select="../*[@tag='001']/text()"/>
                    <xsl:text>)</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:when test="self::*[@code]">
                <xsl:message>
                    <xsl:text>Ingen regel for NORMARC-delfelt: </xsl:text>
                    <xsl:value-of select="parent::*/@tag"/>
                    <xsl:text> $</xsl:text>
                    <xsl:value-of select="@code"/>
                    <xsl:text> (boknummer: </xsl:text>
                    <xsl:value-of select="../../*[@tag='001']/text()"/>
                    <xsl:text>)</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:when test="self::*">
                <!--<xsl:message
                    select="concat('marcxchange-to-opf.xsl: no match for element &quot;',concat('/',string-join((ancestor-or-self::*)/concat(name(),'[',count(preceding-sibling::*)+1,']'),'/')),'&quot; with attributes: ',string-join(for $attribute in @* return concat($attribute/name(),'=&quot;',$attribute,'&quot;'),' '))"
                />-->
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="/*" priority="2">
        <xsl:variable name="result" as="element()*">
            <xsl:next-match/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count($result)">
                <xsl:sequence select="$result"/>
            </xsl:when>
            <xsl:otherwise>
                <metadata/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="SRU:*">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="*:record[not(self::SRU:*)]">
        <xsl:variable name="metadata" as="element()">
            <metadata>
                <xsl:namespace name="dc" select="'http://purl.org/dc/elements/1.1/'"/>
                <xsl:variable name="with-duplicates" as="element()*">
                    <xsl:apply-templates select="node()"/>
                </xsl:variable>
                <xsl:variable name="without-duplicates" as="element()*">
                    <xsl:for-each select="$with-duplicates">
                        <xsl:variable name="position" select="position()"/>
                        <xsl:choose>
                            <xsl:when test="self::dc:*">
                                <xsl:if test="not($with-duplicates[position() &lt; $position and name()=current()/name() and text()=current()/text() and string(@refines)=string(current()/@refines)])">
                                    <xsl:copy exclude-result-prefixes="#all">
                                        <xsl:copy-of select="$with-duplicates[self::dc:*[name()=current()/name() and text()=current()/text() and string(@refines)=string(current()/@refines)]]/@*" exclude-result-prefixes="#all"/>
                                        <xsl:copy-of select="node()" exclude-result-prefixes="#all"/>
                                    </xsl:copy>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="self::meta">
                                <xsl:variable name="this" select="."/>
                                <xsl:if
                                    test="not($with-duplicates[position() &lt; $position and @property=current()/@property and text()=current()/text() and string(@refines)=string(current()/@refines)])">
                                    <xsl:copy exclude-result-prefixes="#all">
                                        <xsl:copy-of select="$with-duplicates[self::meta[@property=current()/@property and text()=current()/text() and string(@refines)=string(current()/@refines)]]/@*" exclude-result-prefixes="#all"/>
                                        <xsl:copy-of select="node()" exclude-result-prefixes="#all"/>
                                    </xsl:copy>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
    
                <xsl:variable name="sorted" as="element()*">
                    <xsl:for-each select="$without-duplicates[self::dc:*[not(@refines)]]">
                        <xsl:sort
                            select="if (not(contains('dc:identifier dc:title dc:creator dc:format',name()))) then 100 else count(tokenize(substring-before('dc:identifier dc:title dc:creator dc:format',name()),' '))"/>
                        <xsl:copy-of select="." exclude-result-prefixes="#all"/>
                        <xsl:if test="@id">
                            <xsl:call-template name="copy-meta-refines">
                                <xsl:with-param name="meta-set" select="$with-duplicates"/>
                                <xsl:with-param name="id" select="string(@id)"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="$without-duplicates[self::meta[starts-with(@property,'dc:') and not(@refines)]]">
                        <xsl:sort select="@property"/>
                        <xsl:copy-of select="." exclude-result-prefixes="#all"/>
                        <xsl:if test="@id">
                            <xsl:call-template name="copy-meta-refines">
                                <xsl:with-param name="meta-set" select="$with-duplicates"/>
                                <xsl:with-param name="id" select="string(@id)"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="$without-duplicates[self::meta[not(starts-with(@property,'dc:')) and contains(@property,':') and not(@refines)]]">
                        <xsl:sort select="@property"/>
                        <xsl:copy-of select="." exclude-result-prefixes="#all"/>
                        <xsl:if test="@id">
                            <xsl:call-template name="copy-meta-refines">
                                <xsl:with-param name="meta-set" select="$with-duplicates"/>
                                <xsl:with-param name="id" select="string(@id)"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="$without-duplicates[self::meta[not(contains(@property,':')) and not(@refines)]]">
                        <xsl:sort select="@property"/>
                        <xsl:copy-of select="." exclude-result-prefixes="#all"/>
                        <xsl:if test="@id">
                            <xsl:call-template name="copy-meta-refines">
                                <xsl:with-param name="meta-set" select="$with-duplicates"/>
                                <xsl:with-param name="id" select="string(@id)"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
    
                <xsl:for-each select="$sorted">
                    <!-- remove unneccessary id's on non-DC elements -->
                    <xsl:copy exclude-result-prefixes="#all">
                        <xsl:copy-of select="@* except @id" exclude-result-prefixes="#all"/>
                        <xsl:if test="self::dc:* or @id and $sorted[@refines = concat('#',current()/@id)]">
                            <xsl:copy-of select="@id" exclude-result-prefixes="#all"/>
                        </xsl:if>
                        <xsl:copy-of select="node()" exclude-result-prefixes="#all"/>
                    </xsl:copy>
                </xsl:for-each>
            </metadata>
        </xsl:variable>
    
        <xsl:choose>
            <xsl:when test="string($nested) = 'true'">
                <xsl:for-each select="$metadata">
                    <xsl:copy exclude-result-prefixes="#all">
                        <xsl:copy-of select="@*" exclude-result-prefixes="#all"/>
                        <xsl:for-each select="*[not(@refines)] | comment()">
                            <xsl:choose>
                                <xsl:when test="self::comment()">
                                    <xsl:copy-of select="." exclude-result-prefixes="#all"/>
                                </xsl:when>
                                <xsl:when test="self::*">
                                    <xsl:apply-templates select="." mode="nesting"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$metadata" exclude-result-prefixes="#all"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="copy-meta-refines">
        <xsl:param name="meta-set" required="yes" as="element()*"/>
        <xsl:param name="id" required="yes" as="xs:string"/>
        <xsl:variable name="idref" select="concat('#',$id)"/>
        <xsl:for-each select="$meta-set[self::meta[@refines=$idref]]">
            <xsl:sort select="@property"/>
            <xsl:copy-of select="." exclude-result-prefixes="#all"/>
            <xsl:if test="@id">
                <xsl:call-template name="copy-meta-refines">
                    <xsl:with-param name="meta-set" select="$meta-set"/>
                    <xsl:with-param name="id" select="string(@id)"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*" mode="nesting">
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:copy-of select="@* except (@property, @refines)" exclude-result-prefixes="#all"/>
            <xsl:if test="@property">
                <xsl:attribute name="name" select="@property"/>
            </xsl:if>
            <xsl:attribute name="content" select="text()"/>
            <xsl:if test="@id">
                <xsl:apply-templates select="../*[@refines = concat('#',current()/@id)]" mode="nesting"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="meta">
        <xsl:param name="context" as="element()?" select="."/>
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:param name="id" as="xs:string?" select="()"/>
        <xsl:param name="refines" as="xs:string?" select="()"/>
        
        <xsl:variable name="dublin-core" select="$property = ('dc:contributor', 'dc:coverage', 'dc:creator', 'dc:date', 'dc:description', 'dc:format', 'dc:identifier',
                                                              'dc:language', 'dc:publisher', 'dc:relation', 'dc:rights', 'dc:source', 'dc:subject', 'dc:title', 'dc:type')" as="xs:boolean"/>
        
        <xsl:element name="{if ($dublin-core) then $property else 'meta'}">
            <xsl:if test="$include-source-reference">
                <xsl:variable name="identifier" as="xs:string?" select="($context/(../* | ../../*)[self::*:controlfield[@tag='001']])[1]/text()"/>
                <xsl:variable name="tag" select="($context/../@tag, $context/@tag, '???')[1]"/>
                <xsl:attribute name="nlb:metadata-source" select="concat('Bibliofil', if ($identifier) then concat('@',$identifier) else '', ' *', $tag, if ($context/@code) then concat('$',$context/@code) else '')"/>
            </xsl:if>
            
            <xsl:if test="not($dublin-core)">
                <xsl:attribute name="property" select="$property"/>
            </xsl:if>
            
            <xsl:if test="$id">
                <xsl:attribute name="id" select="$id"/>
            </xsl:if>
            
            <xsl:if test="$refines">
                <xsl:attribute name="refines" select="concat('#',$refines)"/>
            </xsl:if>
            
            <xsl:value-of select="$value"/>
        </xsl:element>
    </xsl:template>
    
    <!-- 00X KONTROLLFELT -->
    
    <xsl:template match="*:leader"/>
    
    <xsl:template match="*:controlfield[@tag='000']">
        <xsl:variable name="POS05" select="substring(text(),6,1)"/>
        <xsl:if test="$POS05 = 'd'">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'availability'"/><xsl:with-param name="value" select="'deleted'"/></xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:controlfield[@tag='001']">
        <xsl:variable name="edition-identifier" select="if ($identifier) then $identifier else text()"/>
        
        <xsl:call-template name="meta">
            <xsl:with-param name="property" select="'dc:identifier'"/>
            <xsl:with-param name="value" select="$edition-identifier"/>
            <xsl:with-param name="id" select="'pub-id'"/>
        </xsl:call-template>
        
        <xsl:if test="starts-with(string($edition-identifier), '5') and not(exists(../*:datafield[@tag='850']/*:subfield[@code='a']))">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'library'"/><xsl:with-param name="value" select="'NLB'"/></xsl:call-template>
        </xsl:if>
        
        <xsl:if test="matches(string($edition-identifier), '^\d{12}$')">
            <xsl:variable name="year" select="substring($edition-identifier,9)"/>
            <xsl:variable name="month" select="substring($edition-identifier,7,2)"/>
            <xsl:if test="not(../*:datafield[@tag='260']/*:subfield[@code='c'])">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:date.issued'"/><xsl:with-param name="value" select="$year"/></xsl:call-template>
            </xsl:if>
            <xsl:if test="not(../*:datafield[@tag='596']/*:subfield[@code='c'])">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:date.issued.original'"/><xsl:with-param name="value" select="$year"/></xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:controlfield[@tag='003']">
        <!-- Ignoreres. Dette er noe som ble brukt "i riktig gamle dager". -->
    </xsl:template>
    
    <xsl:template match="*:controlfield[@tag='007']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 007 FYSISK BESKRIVELSE AV DOKUMENTET'"/>-->
    </xsl:template>
    
    <xsl:template match="*:controlfield[@tag='008']">
        <xsl:variable name="POS00-05" select="substring(text(),1,6)"/>
        <xsl:variable name="POS22" select="substring(text(),23,1)"/>
        <xsl:variable name="POS33" select="substring(text(),34,1)"/>
        <xsl:variable name="POS34" select="substring(text(),35,1)"/>
        <xsl:variable name="POS35-37" select="substring(text(),36,3)"/>
        
        <xsl:if test="matches($POS00-05,'^\d\d\d\d\d\d$')">
            <xsl:variable name="current-year" select="xs:integer(tokenize(xs:string(current-date()),'-')[1])"/>
            <xsl:variable name="year" select="xs:integer(substring($POS00-05,1,2))"/>
            <xsl:variable name="year" select="xs:string($current-year - $current-year mod 100 + (if ($year gt $current-year mod 100) then $year - 100 else $year))"/>
            <xsl:variable name="month" select="substring($POS00-05,3,2)"/>
            <xsl:variable name="day" select="substring($POS00-05,5,2)"/>
            <xsl:variable name="registered" select="concat($year,'-',$month,'-',$day)"/>
            
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:date.registered'"/><xsl:with-param name="value" select="$registered"/></xsl:call-template>
            
            <xsl:variable name="available" as="element()*">
                <xsl:apply-templates select="(../*:datafield[@tag=('592','598')])"/>
            </xsl:variable>
            <xsl:if test="count($available[@property='dc:date.available']) = 0 and matches($year,'^19..$')">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:date.available'"/><xsl:with-param name="value" select="$registered"/></xsl:call-template>
            </xsl:if>
        </xsl:if>
        
        <xsl:variable name="ageRanges" as="xs:string*">
            <xsl:sequence select="if ($POS22 = 'a') then '17-INF' else ()"/>
            <xsl:for-each select="../*:datafield[@tag='019']/*:subfield[@code='a']/tokenize(replace(text(),'\s',''),'[,\.\-_]')">
                <xsl:choose>
                    <xsl:when test=".='a'">
                        <xsl:sequence select="'0-5'"/>
                    </xsl:when>
                    <xsl:when test=".='b'">
                        <xsl:sequence select="'6-7'"/>
                    </xsl:when>
                    <xsl:when test=".='bu'">
                        <xsl:sequence select="'8-10'"/>
                    </xsl:when>
                    <xsl:when test=".='u'">
                        <xsl:sequence select="'11-12'"/>
                    </xsl:when>
                    <xsl:when test=".='mu'">
                        <xsl:sequence select="'13-16'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="ageRangeFrom" select="if (count($ageRanges) = 0) then '' else xs:integer(min(for $range in ($ageRanges) return xs:double(tokenize($range,'-')[1])))"/>
        <xsl:variable name="ageMax" select="if (count($ageRanges) = 0) then '' else max(for $range in ($ageRanges) return xs:double(tokenize($range,'-')[2]))"/>
        <xsl:variable name="ageRangeTo" select="if ($ageMax and $ageMax = xs:double('INF')) then '' else $ageMax"/>
        
        <xsl:if test="$ageRangeFrom or $ageRangeTo">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'typicalAgeRange'"/><xsl:with-param name="value" select="concat($ageRangeFrom,'-',$ageRangeTo)"/></xsl:call-template>
        </xsl:if>
        
        <!-- 
            - if 008 POS 22 is 'a', or ageRangeFrom > 13, then use "Adult"
            - if ageRangeFrom = 13, then use "Adolescent"
            - if ageRangeFrom < 13, then use "Child"
        -->
        <xsl:choose>
            <xsl:when test="$ageRangeFrom and $ageRangeFrom gt 13 or $POS22='a'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'audience'"/><xsl:with-param name="value" select="'Adult'"/></xsl:call-template>
            </xsl:when>
            <xsl:when test="$ageRangeFrom and $ageRangeFrom = 13">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'audience'"/><xsl:with-param name="value" select="'Adolescent'"/></xsl:call-template>
            </xsl:when>
            <xsl:when test="$ageRangeFrom and $ageRangeFrom lt 13 or $POS22='j'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'audience'"/><xsl:with-param name="value" select="'Child'"/></xsl:call-template>
            </xsl:when>
        </xsl:choose>
    
        <xsl:choose>
            <xsl:when test="$POS33='0'">
                <meta property="dc:type.fiction">false</meta>
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Non-fiction'"/></xsl:call-template>
            </xsl:when>
            <xsl:when test="$POS33='1'">
                <meta property="dc:type.fiction">true</meta>
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Fiction'"/></xsl:call-template>
            </xsl:when>
        </xsl:choose>
    
        <xsl:choose>
            <xsl:when test="$POS34='0'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Non-biography'"/></xsl:call-template>
            </xsl:when>
            <xsl:when test="$POS34='1'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Biography'"/></xsl:call-template>
            </xsl:when>
            <xsl:when test="$POS34='a'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Biography'"/></xsl:call-template>
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Autobiography'"/></xsl:call-template>
            </xsl:when>
            <xsl:when test="$POS34='b'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Biography'"/></xsl:call-template>
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Individual biography'"/></xsl:call-template>
            </xsl:when>
            <xsl:when test="$POS34='c'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Biography'"/></xsl:call-template>
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Collective biography'"/></xsl:call-template>
            </xsl:when>
            <xsl:when test="$POS34='d'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Biography'"/></xsl:call-template>
            </xsl:when>
        </xsl:choose>
    
        <xsl:choose>
            <xsl:when test="normalize-space($POS35-37) and normalize-space($POS35-37) != 'mul'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:language'"/><xsl:with-param name="value" select="$POS35-37"/></xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- 010 - 04X KONTROLLNUMMER OG KODER -->
    
    <xsl:template match="*:datafield[@tag='015']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 015 ANDRE BIBLIOGRAFISKE KONTROLLNUMMER'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='019']">
        <!-- *019$a handled in template for *008 -->
    
        <xsl:variable name="b" as="element()*">
            <xsl:for-each select="*:subfield[@code='b']">
                <xsl:variable name="context" select="."/>
                <xsl:for-each select="tokenize(replace(text(),'\s',''),'[,\.\-_]')">
                    <xsl:choose>
                        <xsl:when test=".='a'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Kartografisk materiale'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Cartographic materials'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ab'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Kartografisk materiale'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Cartographic materials'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Atlas'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Atlas'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='aj'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Kartografisk materiale'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Cartographic materials'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Kart'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Map'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='b'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Manuskripter'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Manuscripts'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='c'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Musikktrykk'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Sheet music'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'Braille'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.no'"/><xsl:with-param name="value" select="'Punktskrift'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='d'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='da'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Grammofonplate'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Gramophone record'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='db'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Kassett'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Cassette'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dc'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'CD (kompaktplate)'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Compact Disk'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'DAISY 2.02'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dd'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Avspiller med lydfil'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Player with audio file'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='de'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Digikort'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Digikort'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dg'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Musikk'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Music'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dh'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Språkkurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Language course'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='di'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydbok'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio book'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dj'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Annen tale/annet'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Other voice/other'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'DAISY 2.02'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dk'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lydopptak'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Audio recording'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Kombidokument'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Combined document'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='e'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Film'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ec'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Film'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Filmspole'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video tape'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ed'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Film'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Videokassett (VHS)'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'VHS'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ee'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Film'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Videoplate (DVD)'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'DVD'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ef'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Film'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Blu-ray-plate'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Blu-ray'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='eg'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Film'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'3D'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'3D'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='f'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Grafisk materiale'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Graphic materials'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='fd'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Grafisk materiale'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Graphic materials'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dias'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Slides'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ff'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Grafisk materiale'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Graphic materials'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Fotografi'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Photography'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='fi'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Grafisk materiale'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Graphic materials'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Kunstreproduksjon'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Art reproduction'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='g'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'XHTML'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='gb'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Diskett'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Floppy'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='gc'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'DVD-ROM'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'DVD'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='gd'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'CD-ROM'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'CD'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ge'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Nettressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Web resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'XHTML'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='gf'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Lagringsbrikke'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Storage card'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='gg'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Blu-ray ROM'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Blu-ray'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='gh'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'UMD'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='gi'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Wii-plate'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Wii disk'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='gt'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Elektronisk ressurs'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Electronic resource'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'EPUB'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='h'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Tredimensjonal gjenstand'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Three-dimensional object'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='i'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Mikroform'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Microform'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ib'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Mikroform'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Microform'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Mikrofilmspole'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Microfilm tape'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ic'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Mikroform'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Microform'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Mikrofilmkort'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Microfilm card'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='j'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Periodika'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Serial'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'periodical'"/><xsl:with-param name="value" select="'true'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='jn'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Periodika'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Serial'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Avis'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Newspaper'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'periodical'"/><xsl:with-param name="value" select="'true'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'newspaper'"/><xsl:with-param name="value" select="'true'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='jp'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Periodika'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Serial'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Tidsskrift'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Magazine'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'periodical'"/><xsl:with-param name="value" select="'true'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'magazine'"/><xsl:with-param name="value" select="'true'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='k'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Artikler'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Article'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='l'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Fysiske bøker'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Physical book'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'Braille'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.no'"/><xsl:with-param name="value" select="'Punktskrift'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='m'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dataspill'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video game'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ma'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dataspill'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video game'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'PC'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='mb'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dataspill'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video game'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Playstation 2'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='mc'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dataspill'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video game'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Playstation 3'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='md'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dataspill'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video game'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Playstation Portable'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='mi'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dataspill'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video game'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Xbox'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='mj'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dataspill'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video game'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Xbox 360'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='mn'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dataspill'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video game'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Nintendo DS'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='mo'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Dataspill'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Video game'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Nintendo Wii'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dl'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'SACD'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'SACD'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dm'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'DVD-audio'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'DVD-audio'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dn'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Blu-Ray-audio'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Blu-Ray-audio'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dz'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'MP3'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'MP3'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ea'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'E-film'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'E-film'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ga'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Nedlastbar fil'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Downloadable file'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='je'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'E-tidsskrifter'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'E-periodicals'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ka'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'E-artikler'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'E-articles'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='la'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'E-bøker'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'E-books'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'XHTML'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='me'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Playstation 4'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Playstation 4'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='mk'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Xbox One'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Xbox One'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='mp'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Nintendo Wii U'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Nintendo Wii U'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='n'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Filformater'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'File formats'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='na'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'PDF'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'PDF'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='nb'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'EPUB'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'EPUB'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='nc'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'MOBI'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'MOBI'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='nl'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'WMA (Windows Media Audio)'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'WMA (Windows Media Audio)'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ns'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'WMV (Windows Media Video)'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'WMV (Windows Media Video)'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='o'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Digital rettighetsadministrasjon (DRM)'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Digital rights management (DRM)'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='te'">
                            <!-- non-standard -->
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'Braille'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.no'"/><xsl:with-param name="value" select="'Punktskrift'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='za'">
                            <!-- non-standard -->
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'Braille'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.no'"/><xsl:with-param name="value" select="'Punktskrift'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy-of select="$b" exclude-result-prefixes="#all"/>
    
        <xsl:if test="not($b[self::dc:format])">
            <xsl:for-each select="*:subfield[@code='e']">
                <xsl:variable name="context" select="."/>
                <xsl:for-each select="tokenize(replace(text(),'\s',''),'[,\.\-_]')">
                    <xsl:choose>
                        <xsl:when test=".='dc'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'DAISY 2.02'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='dj'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'DAISY 2.02'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='te'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'Braille'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.no'"/><xsl:with-param name="value" select="'Punktskrift'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='c'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other.no'"/><xsl:with-param name="value" select="'Musikktrykk'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.other'"/><xsl:with-param name="value" select="'Sheet music'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'Braille'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.no'"/><xsl:with-param name="value" select="'Punktskrift'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='l'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'Braille'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.no'"/><xsl:with-param name="value" select="'Punktskrift'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='gt'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'EPUB'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='ge'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'XHTML'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='g'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'XHTML'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    
        <xsl:for-each select="*:subfield[@code='d']">
            <xsl:variable name="context" select="."/>
                <xsl:for-each select="for $i in (1 to string-length(text())) return substring(text(),$i,1)">
                    <xsl:variable name="subject-id" select="concat('subject-019d-', position())"/>
                    <xsl:choose>
                        <xsl:when test=".='N'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Biography'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'short story'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Noveller'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="'20282100'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='B'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Biography'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'short story'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Noveller'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="'20282100'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='D'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'poem'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Dikt'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="'20697500'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='R'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'poem'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Dikt'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="'20697500'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='S'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'play'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'Hørespill'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="'19883700'"/><xsl:with-param name="context" select="$context"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='T'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'cartoon'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='A'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'anthology'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                        <xsl:when test=".='L'">
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'textbook'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                            <xsl:call-template name="meta"><xsl:with-param name="property" select="'educationalUse'"/><xsl:with-param name="value" select="'true'"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='020']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:if test="not(text() = '0')">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'isbn'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='022']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:if test="not(text() = '0')">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'issn'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='041']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:variable name="text" select="text()"/>
            <xsl:variable name="context" select="."/>
            <xsl:for-each select="(1 to xs:integer(floor(string-length($text) div 3)))">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:language'"/><xsl:with-param name="value" select="substring($text,1+(.-1)*3,3)"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='h']">
            <xsl:variable name="text" select="text()"/>
            <xsl:variable name="context" select="."/>
            <xsl:for-each select="(1 to xs:integer(floor(string-length($text) div 3)))">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="concat('dc:language.original',if (position() lt last()) then '.intermediary' else '','')"/><xsl:with-param name="value" select="substring($text,1+(.-1)*3,3)"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='048']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'instrument'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 050 - 099 KLASSIFIKASJONSKODER -->
    
    <xsl:template match="*:datafield[@tag='082']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='b']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[matches(@tag,'09\d')]">
        <!--<xsl:message select="'NORMARC-felt ignorert: 09X LOKALT FELT'"/>-->
    </xsl:template>
    
    <!-- 1XX HOVEDORDNINGSORD -->
    
    <xsl:template match="*:datafield[@tag='100']">
        <xsl:variable name="creator-id" select="concat('creator-',1+count(preceding-sibling::*:datafield[@tag='100' or @tag='110']))"/>
        <xsl:variable name="name" select="(*:subfield[@code='q'], *:subfield[@code='a'], *:subfield[@code='w'])[normalize-space(.)][1]/text()"/>
        
        <xsl:if test="$name">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:creator'"/><xsl:with-param name="value" select="$name"/><xsl:with-param name="id" select="$creator-id"/></xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='b']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'honorificSuffix'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
            </xsl:for-each>
        
            <xsl:for-each select="*:subfield[@code='c']">
                <xsl:choose>
                    <xsl:when test="matches(text(), $PSEUDONYM)">
                        <xsl:variable name="pseudonym" select="replace(text(), $PSEUDONYM_REPLACE, '$1')"/>
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'pseudonym'"/><xsl:with-param name="value" select="$pseudonym"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'honorificPrefix'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        
            <xsl:for-each select="*:subfield[@code='d']">
                <xsl:variable name="birthDeath" select="tokenize(nlb:parseBirthDeath(text()), ',')"/>
                <xsl:if test="$birthDeath[1]">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'birthDate'"/><xsl:with-param name="value" select="$birthDeath[1]"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
                </xsl:if>
                <xsl:if test="$birthDeath[2]">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'deathDate'"/><xsl:with-param name="value" select="$birthDeath[2]"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
                </xsl:if>
            </xsl:for-each>
            
            <xsl:for-each select="*:subfield[@code='j']">
                <xsl:variable name="context" select="."/>
                <xsl:for-each select="tokenize(replace(text(),'[\.,? ]',''), '-')">
                    <xsl:variable name="nationality" select="nlb:parseNationality(.)"/>
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'nationality'"/><xsl:with-param name="value" select="$nationality"/><xsl:with-param name="refines" select="$creator-id"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
            
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='110']">
        <xsl:variable name="creator-id" select="concat('creator-',1+count(preceding-sibling::*:datafield[@tag='100' or @tag='110']))"/>
        <xsl:choose>
            <xsl:when test="*:subfield[@code='a']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:creator'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$creator-id"/></xsl:call-template>
                <xsl:if test="*:subfield[@code='b']">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'department'"/><xsl:with-param name="value" select="*:subfield[@code='b'][1]/text()"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:when test="*:subfield[@code='b']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:creator'"/><xsl:with-param name="value" select="*:subfield[@code='b'][1]/text()"/><xsl:with-param name="id" select="$creator-id"/></xsl:call-template>
            </xsl:when>
        </xsl:choose>
        
        <xsl:for-each select="*:subfield[@code='3']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='130']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.alternative'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 2XX TITTEL-, ANSVARS- OG UTGIVELSESOPPLYSNINGER -->
    
    <xsl:template match="*:datafield[@tag='240']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.alternative'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='245']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    
        <xsl:for-each select="*:subfield[@code='b']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.subTitle'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/></xsl:call-template>
        </xsl:for-each>
        
        <xsl:variable name="format019" as="element()*">
            <xsl:apply-templates select="../*:datafield[@tag='019']"/>
        </xsl:variable>
        <xsl:if test="count($format019/dc:format) gt 0">
            <xsl:for-each select="*:subfield[@code='h']">
                <xsl:choose>
                    <xsl:when test="matches(text(),'.*da[i\\ss][si]y[\\.\\s]*.*','i') or matches(text(),'.*2[.\\s]*0?2.*','i')">
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'DAISY 2.02'"/></xsl:call-template>
                    </xsl:when>
                    <xsl:when test="matches(text(),'.*(dtbook|epub).*','i')">
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type'"/><xsl:with-param name="value" select="'Full Text'"/></xsl:call-template>
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format'"/><xsl:with-param name="value" select="'EPUB'"/></xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
        
        <!-- https://github.com/nlbdev/normarc/issues/5 -->
        <xsl:for-each select="*:subfield[@code='n']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'position'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/></xsl:call-template>
        </xsl:for-each>
        
        <xsl:for-each select="*:subfield[@code='p']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="concat('dc:title.part',if (count(../*:datafield[@tag='740']/*:subfield[@code='a']) eq 0) then '' else '.other')"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/></xsl:call-template>
        </xsl:for-each>
        
        <xsl:for-each select="*:subfield[@code='w']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.part.sortingKey'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
        
        <!-- *245 finnes alltid, men ikke alltid *250. Opprett bookEdition herifra dersom *250 ikke definerer bookEdition. -->
        <xsl:if test="count(../*:datafield[@tag='250']/*:subfield[@code='a']) = 0">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bookEdition'"/><xsl:with-param name="value" select="'1'"/></xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='246']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.alternative'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
        
        <xsl:for-each select="*:subfield[@code='b']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.subTitle.alternative.other'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
        
        <xsl:for-each select="*:subfield[@code='n']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'position'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
        
        <xsl:for-each select="*:subfield[@code='p']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.subTitle.alternative'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='250']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bookEdition'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='260']">
        <xsl:variable name="publisher-id" select="concat('publisher-260-',1+count(preceding-sibling::*:datafield[@tag='260']))"/>
        <xsl:variable name="issued" select="min(../*:datafield[@tag='260']/*:subfield[@code='c' and matches(text(),'^\d+$')]/xs:integer(text()))"/>
        <xsl:variable name="primary" select="(not($issued) and not(preceding-sibling::*:datafield[@tag='260'])) or (*:subfield[@code='c']/text() = string($issued) and not(preceding-sibling::*:datafield[@tag='260']/*:subfield[@code='c' and text() = string($issued)]))"/>
        
        <xsl:if test="*:subfield[@code='b']">
            <xsl:call-template name="meta">
                <xsl:with-param name="property" select="if ($primary) then 'dc:publisher' else 'dc:publisher.other'"/>
                <xsl:with-param name="value" select="(*:subfield[@code='b'])[1]/text()"/>
                <xsl:with-param name="id" select="$publisher-id"/>
                <xsl:with-param name="context" select="(*:subfield[@code='b'])[1]"/>
            </xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$publisher-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
        
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:publisher.location'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/><xsl:with-param name="refines" select="if ($primary) then () else $publisher-id"/></xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='c']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:date.issued'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="if ($primary) then () else $publisher-id"/></xsl:call-template>
        </xsl:for-each>
        
        <xsl:for-each select="*:subfield[@code='9' and text()='n']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'watermark'"/><xsl:with-param name="value" select="'none'"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 3XX FYSISK BESKRIVELSE -->
    
    <xsl:template match="*:datafield[@tag='300']">
        <xsl:variable name="fields" as="element()*">
            <xsl:apply-templates select="../*:datafield[@tag='245']"/>
        </xsl:variable>
        <xsl:variable name="fields" as="element()*">
            <xsl:choose>
                <xsl:when test="$fields[self::dc:format]">
                    <xsl:copy-of select="$fields" exclude-result-prefixes="#all"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="../*:datafield[@tag='019']"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:variable name="numberOfPages" select="(if (matches(lower-case(replace(text(),'[\[\]]','')),'^.*?(\d+)\s*s.*$')) then replace(lower-case(replace(text(),'[\[\]]','')),'^.*?(\d+)\s*s.*$','$1') else ())[1]"/>
            <xsl:variable name="numberOfVolumes" select="(if (matches(lower-case(replace(text(),'[\[\]]','')),'^.*?(\d+)\s*(heft|b).*$')) then replace(lower-case(replace(text(),'[\[\]]','')),'^.*?(\d+)\s*(heft|b).*$','$1') else ())[1]"/>
            
            <xsl:choose>
                <xsl:when test="matches(text(),'^.*?\d+ *t+\.? *\d+ *min\.?.*?$')">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.extent.duration'"/><xsl:with-param name="value" select="replace(text(),'^.*?(\d+) *t+\.? *(\d+) *min\.?.*?$','$1 t. $2 min.')"/></xsl:call-template>
                </xsl:when>
                <xsl:when test="matches(text(),'^.*?\d+ *min\.?.*?$')">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.extent.duration'"/><xsl:with-param name="value" select="replace(text(),'^.*?(\d+) *min\.?.*?$','0 t. $1 min.')"/></xsl:call-template>
                </xsl:when>
                <xsl:when test="matches(text(),'^.*?\d+ *t\.?.*?$')">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.extent.duration'"/><xsl:with-param name="value" select="replace(text(),'^.*?(\d+) *t\.?.*?$','$1 t. 0 min.')"/></xsl:call-template>
                </xsl:when>
                <xsl:when test="$numberOfPages">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.extent.pages'"/><xsl:with-param name="value" select="$numberOfPages"/></xsl:call-template>
                </xsl:when>
                <xsl:when test="$numberOfVolumes">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.extent.volumes'"/><xsl:with-param name="value" select="$numberOfVolumes"/></xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.extent'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='b']">
            <xsl:if test="tokenize(replace(text(),'\s',''),'[,\.\-_]') = 'o'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'drm'"/><xsl:with-param name="value" select="'true'"/></xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='310']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'periodicity'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 4XX SERIEANGIVELSER -->
    
    <xsl:template match="*:datafield[@tag='440']">
        <xsl:variable name="title-id" select="concat('series-title-',1+count(preceding-sibling::*:datafield[@tag='440' or @tag='490']))"/>
    
        <xsl:variable name="series-title" as="element()?">
            <xsl:if test="*:subfield[@code='a']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.series'"/><xsl:with-param name="value" select="*:subfield[@code='a'][1]/text()"/><xsl:with-param name="id" select="$title-id"/></xsl:call-template>
            </xsl:if>
        </xsl:variable>
        <xsl:copy-of select="$series-title" exclude-result-prefixes="#all"/>
        <xsl:for-each select="*:subfield[@code='p']">
            <xsl:call-template name="meta">
                <xsl:with-param name="property" select="'dc:title.subSeries'"/>
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="refines" select="if ($series-title) then $title-id else ()"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='x']">
            <xsl:if test="not(text() = '0')">
                <xsl:call-template name="meta">
                    <xsl:with-param name="property" select="'series.issn'"/>
                    <xsl:with-param name="value" select="text()"/>
                    <xsl:with-param name="refines" select="if ($series-title) then $title-id else ()"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='v']">
            <xsl:call-template name="meta">
                <xsl:with-param name="property" select="'series.position'"/>
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="refines" select="if ($series-title) then $title-id else ()"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='449']">
        <xsl:for-each select="*:subfield[@code='n']">
            <xsl:if test="matches(text(),'\d')">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.extent.cd'"/><xsl:with-param name="value" select="replace(text(),'^[^\d]*(\d+).*?$','$1')"/></xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='490']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 490 SERIEANGIVELSE UTEN BIINNFØRSEL'"/>-->
    </xsl:template>
    
    <!-- 5XX NOTER -->
    
    <xsl:template match="*:datafield[@tag='500']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 500 GENERELL NOTE'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='501']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 490 &quot;SAMMEN MED&quot;-NOTE'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='503']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bookEdition.history'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='505']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:description.content'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='511']">
        <xsl:variable name="contributor-id" select="concat('contributor-511-',1+count(preceding-sibling::*:datafield[@tag='511']))"/>
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:variable name="contributor-name" select="text()"/>
            <xsl:call-template name="meta">
                <xsl:with-param name="property" select="'dc:contributor.narrator'"/>
                <xsl:with-param name="value" select="$contributor-name"/>
                <xsl:with-param name="id" select="$contributor-id"/>
            </xsl:call-template>
            
            <xsl:variable name="pos" select="position()"/>
            <xsl:for-each select="../*:subfield[@code='3'][position() = $pos]">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$contributor-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='520']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:description.abstract'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='522']">
        <!-- Ignoreres. Dette er noe som ble brukt "i riktig gamle dager". -->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='523']">
        <!-- Ignoreres. Dette er noe som ble brukt "i riktig gamle dager". -->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='533']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 533 FYSISK BESKRIVELSE'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='537']">
        <!-- Duplikat av 505. Ignoreres. -->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='539']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 539 SERIER'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='574']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.original'"/><xsl:with-param name="value" select="replace(text(),'^\s*Ori?ginaltit\w*\s*:?\s*','')"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='590']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 590 LOKALE NOTER'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='591']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 591 LOKALE NOTER'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='592']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:variable name="available" select="nlb:parseDate(text())"/>
            <xsl:if test="$available">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:date.available'"/><xsl:with-param name="value" select="$available"/></xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='593']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 593 LOKALE NOTER'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='594']">
        <!-- Karakteristikk -->
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:choose>
                <xsl:when test="text() = 'Åpen linjeavstand' or text() = 'Dobbel linjeavstand'">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.linespacing'"/><xsl:with-param name="value" select="'double'"/></xsl:call-template>
                </xsl:when>
                <xsl:when test="text() = 'Enkeltsidig trykk'">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.printing'"/><xsl:with-param name="value" select="'single-sided'"/></xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='595']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 595 LOKALE NOTER'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='596']">
        <xsl:variable name="preceding-issued-years" select="(for $year in (preceding-sibling::*:datafield[@tag='596']/*:subfield[@code='c']/number(nlb:parseYear(text(), false()))) return if ($year eq $year) then $year else (), xs:double('INF'))"/>
        <xsl:variable name="following-issued-years" select="(for $year in (following-sibling::*:datafield[@tag='596']/*:subfield[@code='c']/number(nlb:parseYear(text(), false()))) return if ($year eq $year) then $year else (), xs:double('INF'))"/>
        <xsl:variable name="issued-year" select="(*:subfield[@code='c']/number(nlb:parseYear(text(), false())))[1]"/>
        
        <xsl:if test="$issued-year lt min($preceding-issued-years) and $issued-year le min($following-issued-years)
                      or not($issued-year eq $issued-year) and min(($preceding-issued-years, $following-issued-years)) = xs:double('INF') and not(preceding-sibling::*:datafield[@tag='596'])">
            <xsl:for-each select="*:subfield[@code='b']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:publisher.original'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='a']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:publisher.location.original'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='c']">
                <xsl:if test="string(number($issued-year)) != 'NaN'">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:date.issued.original'"/><xsl:with-param name="value" select="string($issued-year)"/></xsl:call-template>
                </xsl:if>
            </xsl:for-each>
            <xsl:choose>
                <xsl:when test="count(*:subfield[@code='d']) = 0">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'bookEdition.original'"/><xsl:with-param name="value" select="'1'"/></xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="*:subfield[@code='d']">
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'bookEdition.original'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/></xsl:call-template>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="*:subfield[@code='e']">
                <xsl:choose>
                    <xsl:when test="matches(text(),'^\s*\d+\s*s?[\.\s]*$') and string-length(replace(text(),'[^\d]','')) lt 10">
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.extent.pages.original'"/><xsl:with-param name="value" select="replace(text(),'[^\d]','')"/></xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:format.extent.original'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='f']">
                <xsl:variable name="length" select="string-length(replace(text(),'[^0-9xX]',''))" as="xs:integer"/>
                <xsl:if test="not(text() = '0') and $length gt 0">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="concat(if ($length lt 9) then 'issn' else 'isbn', '.original')"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='597']">
        <!--<xsl:message select="'NORMARC-felt ignorert: 597 LOKALE NOTER'"/>-->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='598']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:choose>
                <xsl:when test="contains(text(),'RNIB')">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'external-production'"/><xsl:with-param name="value" select="'RNIB'"/></xsl:call-template>
                </xsl:when>
                <xsl:when test="contains(text(),'TIGAR')">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'external-production'"/><xsl:with-param name="value" select="'TIGAR'"/></xsl:call-template>
                </xsl:when>
                <xsl:when test="contains(text(),'INNKJØPT')">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'external-production'"/><xsl:with-param name="value" select="'WIPS'"/></xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:variable name="tag592">
                <xsl:apply-templates select="../../*:datafield[@tag='592']"/>
            </xsl:variable>
            <xsl:if test="not($tag592/meta[@property='dc:date.available'])">
                <xsl:variable name="available" select="nlb:parseDate(text())"/>
                <xsl:if test="$available">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:date.available'"/><xsl:with-param name="value" select="$available"/></xsl:call-template>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='599']">
        <xsl:choose>
            <xsl:when test="*:subfield[@code='a']/text() = 'EPUB-nr' and exists(*:subfield[@code='b'])">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'epub-nr'"/><xsl:with-param name="value" select="(*:subfield[@code='b'])[1]/text()"/></xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!--<xsl:message select="'NORMARC-felt ignorert: 599 LOKALE NOTER'"/>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 6XX EMNEINNFØRSLER -->
    
    <xsl:template match="*:datafield[@tag='600']">
        <xsl:for-each select="*:subfield[@code='0']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='x']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='1']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    
        <xsl:variable name="subject-id" select="concat('subject-600-',1+count(preceding-sibling::*:datafield[@tag='600']))"/>
        <xsl:variable name="name" select="(*:subfield[@code='q'], *:subfield[@code='a'], *:subfield[@code='w'])[normalize-space(.)][1]/text()"/>
        
        <xsl:if test="not($name='')">
    
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject'"/><xsl:with-param name="value" select="$name"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='b']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'honorificSuffix'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='c']">
                <xsl:choose>
                    <xsl:when test="matches(text(), $PSEUDONYM)">
                        <xsl:variable name="pseudonym" select="replace(text(), $PSEUDONYM_REPLACE, '$1')"/>
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'pseudonym'"/><xsl:with-param name="value" select="$pseudonym"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'honorificPrefix'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='d']">
                <xsl:variable name="birthDeath" select="tokenize(nlb:parseBirthDeath(text()), ',')"/>
                <xsl:if test="$birthDeath[1]">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'birthDate'"/><xsl:with-param name="value" select="$birthDeath[1]"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
                </xsl:if>
                <xsl:if test="$birthDeath[2]">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'deathDate'"/><xsl:with-param name="value" select="$birthDeath[2]"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
                </xsl:if>
            </xsl:for-each>
            
            <xsl:for-each select="*:subfield[@code='j']">
                <xsl:variable name="context" select="."/>
                <xsl:for-each select="tokenize(replace(text(),'[\.,? ]',''), '-')">
                    <xsl:variable name="nationality" select="nlb:parseNationality(.)"/>
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'nationality'"/><xsl:with-param name="value" select="$nationality"/><xsl:with-param name="refines" select="$subject-id"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='610']">
        <xsl:variable name="subject-id" select="concat('subject-610-',1+count(preceding-sibling::*:datafield[@tag='610']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
    
            <xsl:for-each select="*:subfield[@code='1']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='b']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='q']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='611']">
        <xsl:variable name="subject-id" select="concat('subject-611-',1+count(preceding-sibling::*:datafield[@tag='611']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='650']">
        <xsl:variable name="subject-id" select="concat('subject-650-',1+count(preceding-sibling::*:datafield[@tag='650']))"/>
    
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
            
            <xsl:if test="*:subfield[@code='a']/text()=('Tidsskrifter','Avis')">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'periodical'"/><xsl:with-param name="value" select="'true'"/></xsl:call-template>
            </xsl:if>
            <xsl:if test="*:subfield[@code='a']/text()='Tidsskrifter'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'magazine'"/><xsl:with-param name="value" select="'true'"/></xsl:call-template>
            </xsl:if>
            <xsl:if test="*:subfield[@code='a']/text()='Avis'">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'newspaper'"/><xsl:with-param name="value" select="'true'"/></xsl:call-template>
            </xsl:if>
    
            <xsl:for-each select="*:subfield[@code='0']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='1']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='c']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='d']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.time'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='q']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='w']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='x']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='z']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.location'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='651']">
        <xsl:variable name="subject-id" select="concat('subject-651-',1+count(preceding-sibling::*:datafield[@tag='651']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.location'"/><xsl:with-param name="value" select="*:subfield[@code='a']/replace(text(),'[\[\]]','')"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
    
            <xsl:for-each select="*:subfield[@code='1']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='q']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.location'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='x']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='z']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.location'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='653']">
        <xsl:variable name="subject-id" select="concat('subject-653-',1+count(preceding-sibling::*:datafield[@tag='653']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='1']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='c']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='q']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='x']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='655']">
        <xsl:variable name="subject-id" select="concat('subject-655-',1+count(preceding-sibling::*:datafield[@tag='655']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:variable name="context" select="."/>
            <xsl:variable name="mainGenre" select="*:subfield[@code='a']/text()"/>
            <xsl:variable name="subGenre" as="xs:string*">
                <xsl:for-each select="*:subfield[@code='x']">
                    <xsl:sort/>
                    <xsl:sequence select="text()"/>
                </xsl:for-each>
                <xsl:for-each select="*:subfield[@code='9']">
                    <xsl:choose>
                        <xsl:when test="normalize-space(.) = ('nno','nob','non','nor','n')">
                            <xsl:sequence select="'Norsk'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="genre" select="if (count($subGenre)) then concat($mainGenre, ' (', string-join($subGenre,'/'), ')') else $mainGenre"/>
            
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="$genre"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre.no'"/><xsl:with-param name="value" select="$genre"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.mainGenre'"/><xsl:with-param name="value" select="$mainGenre"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            <xsl:for-each select="$subGenre">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.subGenre'"/><xsl:with-param name="value" select="."/><xsl:with-param name="refines" select="$subject-id"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='1']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='691']">
        <xsl:variable name="subject-id" select="concat('subject-691-',1+count(preceding-sibling::*:datafield[@tag='691']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
    
            <xsl:for-each select="*:subfield[@code='1']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='x']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='692']">
        <xsl:variable name="subject-id" select="concat('subject-692-',1+count(preceding-sibling::*:datafield[@tag='692']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='693']">
        <xsl:variable name="subject-id" select="concat('subject-693-',1+count(preceding-sibling::*:datafield[@tag='693']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='694']">
        <!-- På gamle slettede kassetter står det i mange tilfeller teksten "Uten Daisy" i dette feltet. Ignoreres. -->
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='695']">
        <xsl:variable name="subject-id" select="concat('subject-695-',1+count(preceding-sibling::*:datafield[@tag='695']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='696']">
        <xsl:variable name="subject-id" select="concat('subject-696-',1+count(preceding-sibling::*:datafield[@tag='696']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='697']">
        <xsl:variable name="subject-id" select="concat('subject-697-',1+count(preceding-sibling::*:datafield[@tag='697']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='699']">
        <xsl:variable name="subject-id" select="concat('subject-699-',1+count(preceding-sibling::*:datafield[@tag='699']))"/>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="*:subfield[@code='a']/text()"/><xsl:with-param name="id" select="$subject-id"/></xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='1']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='c']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='d']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.time'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='q']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='x']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.keyword'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='z']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'location'"/><xsl:with-param name="value" select="replace(text(),'[\[\]]','')"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
    
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$subject-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!-- 700 - 75X BIINNFØRSLER -->
    
    <xsl:template match="*:datafield[@tag='700']">
        <xsl:variable name="contributor-id" select="concat('contributor-700-',1+count(preceding-sibling::*:datafield[@tag='700']))"/>
        <xsl:variable name="name" select="(*:subfield[@code='q'], *:subfield[@code='a'], *:subfield[@code='w'])[normalize-space(.)][1]/text()"/>
        
        <xsl:if test="$name">
            <xsl:variable name="role" select="nlb:parseRole(concat('',(*:subfield[@code='e'], *:subfield[@code='r'], *:subfield[@code='x'])[1]/text()))"/>
            <xsl:variable name="role" select="if ($role='dc:creator') then 'dc:contributor.other' else $role">
                <!-- because 700 never is the main author -->
            </xsl:variable>
            
            <xsl:call-template name="meta">
                <xsl:with-param name="property" select="$role"/>
                <xsl:with-param name="value" select="$name"/>
                <xsl:with-param name="id" select="$contributor-id"/>
            </xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='b']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'honorificSuffix'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$contributor-id"/></xsl:call-template>
            </xsl:for-each>
        
            <xsl:for-each select="*:subfield[@code='c']">
                <xsl:choose>
                    <xsl:when test="matches(text(), $PSEUDONYM)">
                        <xsl:variable name="pseudonym" select="replace(text(), $PSEUDONYM_REPLACE, '$1')"/>
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'pseudonym'"/><xsl:with-param name="value" select="$pseudonym"/><xsl:with-param name="refines" select="$contributor-id"/></xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="meta"><xsl:with-param name="property" select="'honorificPrefix'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$contributor-id"/></xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        
            <xsl:for-each select="*:subfield[@code='d']">
                <xsl:variable name="birthDeath" select="tokenize(nlb:parseBirthDeath(text()), ',')"/>
                <xsl:if test="$birthDeath[1]">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'birthDate'"/><xsl:with-param name="value" select="$birthDeath[1]"/><xsl:with-param name="refines" select="$contributor-id"/></xsl:call-template>
                </xsl:if>
                <xsl:if test="$birthDeath[2]">
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'deathDate'"/><xsl:with-param name="value" select="$birthDeath[2]"/><xsl:with-param name="refines" select="$contributor-id"/></xsl:call-template>
                </xsl:if>
            </xsl:for-each>
            
            <xsl:for-each select="*:subfield[@code='j']">
                <xsl:variable name="context" select="."/>
                <xsl:for-each select="tokenize(replace(text(),'[\.,? ]',''), '-')">
                    <xsl:variable name="nationality" select="nlb:parseNationality(.)"/>
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'nationality'"/><xsl:with-param name="value" select="$nationality"/><xsl:with-param name="refines" select="$contributor-id"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
        
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$contributor-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='710']">
        <xsl:for-each select="*:subfield[@code='1']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:subject.dewey'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
        
        <xsl:if test="*:subfield[@code='a']">
            <xsl:variable name="contributor-id" select="concat('contributor-700-',1+count(preceding-sibling::*:datafield[@tag='700']))"/>
            
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:contributor'"/><xsl:with-param name="value" select="*:subfield[@code='a'][1]/text()"/><xsl:with-param name="id" select="$contributor-id"/></xsl:call-template>
            
            <xsl:for-each select="*:subfield[@code='3']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$contributor-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='730']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.alternative'"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='740']">
        <xsl:if test="*:subfield[@code='a']">
            <xsl:variable name="title-id" select="concat('title-740-',1+count(preceding-sibling::*:datafield[@tag='740']))"/>
            <xsl:for-each select="*:subfield[@code='a']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.part'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="id" select="$title-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='b']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.part.subTitle.other'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$title-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='n']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'position'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$title-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='p']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.part.subTitle'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$title-id"/></xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="*:subfield[@code='w']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.part.sortingKey'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$title-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!-- 760 - 79X LENKER / RELASJONER -->
    
    <xsl:template match="*:datafield[@tag='780']">
        <xsl:variable name="series-preceding-id" select="concat('series-preceding-',1+count(preceding-sibling::*:datafield[@tag='780']))"/>
    
        <xsl:if test="*:subfield[@code='t']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.series.preceding'"/><xsl:with-param name="value" select="*:subfield[@code='t']/text()"/><xsl:with-param name="id" select="$series-preceding-id"/></xsl:call-template>
        </xsl:if>
        <xsl:for-each select="*:subfield[@code='w']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:identifier.series.preceding.uri'"/><xsl:with-param name="value" select="concat('urn:NBN:no-nb_nlb_',text())"/><xsl:with-param name="refines" select="$series-preceding-id"/></xsl:call-template>
            <xsl:call-template name="meta">
                <xsl:with-param name="property" select="'dc:identifier.series.preceding'"/>
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="id" select="if (not(count(parent::*/*:subfield[@code='t']))) then $series-preceding-id else ()"/>
                <xsl:with-param name="refines" select="if (count(parent::*/*:subfield[@code='t'])) then $series-preceding-id else ()"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.series.preceding.alternative'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$series-preceding-id"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='785']">
        <xsl:variable name="series-sequel-id" select="concat('series-sequel-',1+count(preceding-sibling::*:datafield[@tag='785']))"/>
    
        <xsl:for-each select="*:subfield[@code='t']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.series.sequel'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="id" select="$series-sequel-id"/></xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='w']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:identifier.series.sequel.uri'"/><xsl:with-param name="value" select="concat('urn:NBN:no-nb_nlb_',text())"/><xsl:with-param name="refines" select="$series-sequel-id"/></xsl:call-template>
            <xsl:call-template name="meta">
                <xsl:with-param name="property" select="'dc:identifier.series.sequel'"/>
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="id" select="if (not(count(parent::*/*:subfield[@code='t']))) then $series-sequel-id else ()"/>
                <xsl:with-param name="refines" select="if (count(parent::*/*:subfield[@code='t'])) then $series-sequel-id else ()"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:title.series.sequel.alternative'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$series-sequel-id"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 800 - 830 SERIEINNFØRSLER - ANNEN FORM ENN SERIEFELTET -->
    
    <xsl:template match="*:datafield[@tag='800']">
        <xsl:variable name="creator-id" select="concat('series-creator-',1+count(preceding-sibling::*:datafield[@tag='800']))"/>
        <xsl:variable name="name" select="(*:subfield[@code='q'], *:subfield[@code='a'], *:subfield[@code='w'])[normalize-space(.)][1]/text()"/>
        
        <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:creator.series'"/><xsl:with-param name="value" select="$name"/><xsl:with-param name="id" select="$creator-id"/></xsl:call-template>
        
        <xsl:for-each select="*:subfield[@code='t']">
            <xsl:variable name="alternate-title" select="string((../../*:datafield[@tag='440']/*:subfield[@code='a'])[1]/text()) != (text(),'')"/>
            <xsl:call-template name="meta"><xsl:with-param name="property" select="concat('dc:title.series',if ($alternate-title or preceding-sibling::*[@code='t']) then '.alternate' else '','')"/><xsl:with-param name="value" select="text()"/></xsl:call-template>
        </xsl:for-each>
    
        <xsl:for-each select="*:subfield[@code='b']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'honorificSuffix'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
        </xsl:for-each>
    
        <xsl:for-each select="*:subfield[@code='c']">
            <xsl:choose>
                <xsl:when test="matches(text(), $PSEUDONYM)">
                    <xsl:variable name="pseudonym" select="replace(text(), $PSEUDONYM_REPLACE, '$1')"/>
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'pseudonym'"/><xsl:with-param name="value" select="$pseudonym"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="meta"><xsl:with-param name="property" select="'honorificPrefix'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    
        <xsl:for-each select="*:subfield[@code='d']">
            <xsl:variable name="birthDeath" select="tokenize(nlb:parseBirthDeath(text()), ',')"/>
            <xsl:if test="$birthDeath[1]">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'birthDate'"/><xsl:with-param name="value" select="$birthDeath[1]"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
            </xsl:if>
            <xsl:if test="$birthDeath[2]">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'deathDate'"/><xsl:with-param name="value" select="$birthDeath[2]"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    
        <xsl:for-each select="*:subfield[@code='j']">
            <xsl:variable name="context" select="."/>
            <xsl:for-each select="tokenize(replace(text(),'[\.,? ]',''), '-')">
                <xsl:variable name="nationality" select="nlb:parseNationality(.)"/>
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'nationality'"/><xsl:with-param name="value" select="$nationality"/><xsl:with-param name="refines" select="$creator-id"/><xsl:with-param name="context" select="$context"/></xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
    
        <xsl:for-each select="*:subfield[@code='3']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$creator-id"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 85X LOKALISERINGSDATA -->
    
    <xsl:template match="*:datafield[@tag='850']">
        <xsl:for-each select="*:subfield[@code='a']">
            <xsl:if test="text()=('NLB/S')">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:type.genre'"/><xsl:with-param name="value" select="'textbook'"/></xsl:call-template>
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'educationalUse'"/><xsl:with-param name="value" select="'true'"/></xsl:call-template>
            </xsl:if>
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'library'"/><xsl:with-param name="value" select="tokenize(text(),'/')[1]"/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='856']">
        <xsl:if test="*:subfield[@code='u']/text() = 'URN:NBN:no-nb_nlb_'">
            <xsl:for-each select="*:subfield[@code='s']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'dc:source.urn-nbn'"/><xsl:with-param name="value" select="concat('urn:nbn:no-nb_nlb_', text())"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!-- 9XX HENVISNINGER -->
    <xsl:template match="*:datafield[@tag=('900','950')]">
        <xsl:variable name="preceding-datafield" select="(preceding-sibling::* except preceding-sibling::*:datafield[starts-with(@tag,'9')])[last()]"/>
        <xsl:variable name="preceding-datafield-refines" as="element()*">
            <xsl:apply-templates select="$preceding-datafield"/>
        </xsl:variable>
        <xsl:variable name="preceding-datafield-refines" as="xs:string" select="string(($preceding-datafield-refines[@property='bibliofil-id']/@refines)[1])"/>
        <xsl:if test="$preceding-datafield-refines">
            <xsl:for-each select="*:subfield[@code='~']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'bibliofil-id.reference'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$preceding-datafield-refines"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!-- TODO: 911c and 911d (TIGAR project) -->
    
    <xsl:template match="*:datafield[@tag='996']">
        <xsl:variable name="websok-id" select="concat('websok-',1+count(preceding-sibling::*:datafield[@tag='996']))"/>
    
        <xsl:if test="*:subfield[@code='u']">
            <xsl:call-template name="meta"><xsl:with-param name="property" select="'websok.url'"/><xsl:with-param name="value" select="*:subfield[@code='u']/text()"/><xsl:with-param name="id" select="$websok-id"/></xsl:call-template>
    
            <xsl:for-each select="*:subfield[@code='t']">
                <xsl:call-template name="meta"><xsl:with-param name="property" select="'websok.type'"/><xsl:with-param name="value" select="text()"/><xsl:with-param name="refines" select="$websok-id"/></xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:variable name="DAY_MONTH_YEAR" select="'\d+-\d+-\d+'"/>
    <xsl:variable name="FORMAT_245H_DAISY2_1" select="'(?i).*da[i\ss][si]y[\.\s]*.*'"/>
    <xsl:variable name="FORMAT_245H_DAISY2_2" select="'.*2[.\s]*0?2.*'"/>
    <xsl:variable name="FORMAT_245H_DTBOOK" select="'(?i).*dtbook.*'"/>
    <xsl:variable name="PSEUDONYM" select="'pse[uv]d.*'"/>
    <xsl:variable name="PSEUDONYM_REPLACE" select="'pse[uv]d.*?f.*?\s+(.*)$'"/>
    <xsl:variable name="FIRST_LAST_NAME" select="'^(.*\S.*)\s+(\S+)\s*$'"/>
    <xsl:variable name="YEAR" select="'.*[^\d-].*'"/>
    <xsl:variable name="YEAR_NEGATIVE" select="'.*f.*(Kr.*)?'"/>
    <xsl:variable name="YEAR_VALUE" select="'[^\d]'"/>
    <xsl:variable name="AVAILABLE" select="'^.*?(\d+)[\./]+(\d+)[\./]+(\d+).*?$'"/>
    <xsl:variable name="DEWEY" select="'^.*?(\d+\.?\d*).*?$'"/>
    
    <xsl:function name="nlb:parseNationality">
        <xsl:param name="nationality"/>
        <xsl:choose>
            <xsl:when test="$nationality='somal'">
                <xsl:sequence select="'so'"/>
            </xsl:when>
            <xsl:when test="$nationality='ned'">
                <xsl:sequence select="'nl'"/>
            </xsl:when>
            <xsl:when test="$nationality='am'">
                <xsl:sequence select="'us'"/>
            </xsl:when>
            <xsl:when test="$nationality='liban'">
                <xsl:sequence select="'lb'"/>
            </xsl:when>
            <xsl:when test="$nationality='skzimb'">
                <xsl:sequence select="'sw'"/>
            </xsl:when>
            <xsl:when test="$nationality='pal'">
                <xsl:sequence select="'ps'"/>
            </xsl:when>
            <xsl:when test="$nationality='kongol'">
                <xsl:sequence select="'cd'"/>
            </xsl:when>
            <xsl:when test="$nationality='som'">
                <xsl:sequence select="'so'"/>
            </xsl:when>
            <xsl:when test="$nationality='n'">
                <xsl:sequence select="'no'"/>
            </xsl:when>
            <xsl:when test="$nationality='bulg'">
                <xsl:sequence select="'bg'"/>
            </xsl:when>
            <xsl:when test="$nationality='kan'">
                <xsl:sequence select="'ca'"/>
            </xsl:when>
            <xsl:when test="$nationality='eng'">
                <xsl:sequence select="'gb'"/>
            </xsl:when>
            <xsl:when test="$nationality='ind'">
                <xsl:sequence select="'in'"/>
            </xsl:when>
            <xsl:when test="$nationality='sv'">
                <xsl:sequence select="'se'"/>
            </xsl:when>
            <xsl:when test="$nationality='newzeal'">
                <xsl:sequence select="'nz'"/>
            </xsl:when>
            <xsl:when test="$nationality='pol'">
                <xsl:sequence select="'pl'"/>
            </xsl:when>
            <xsl:when test="$nationality='gr'">
                <xsl:sequence select="'gr'"/>
            </xsl:when>
            <xsl:when test="$nationality='fr'">
                <xsl:sequence select="'fr'"/>
            </xsl:when>
            <xsl:when test="$nationality='belg'">
                <xsl:sequence select="'be'"/>
            </xsl:when>
            <xsl:when test="$nationality='ir'">
                <xsl:sequence select="'ie'"/>
            </xsl:when>
            <xsl:when test="$nationality='columb'">
                <xsl:sequence select="'co'"/>
            </xsl:when>
            <xsl:when test="$nationality='r'">
                <xsl:sequence select="'ru'"/>
            </xsl:when>
            <xsl:when test="$nationality='øst'">
                <xsl:sequence select="'at'"/>
            </xsl:when>
            <xsl:when test="$nationality='sveit'">
                <xsl:sequence select="'ch'"/>
            </xsl:when>
            <xsl:when test="$nationality='tyrk'">
                <xsl:sequence select="'tr'"/>
            </xsl:when>
            <xsl:when test="$nationality='aserb'">
                <xsl:sequence select="'az'"/>
            </xsl:when>
            <xsl:when test="$nationality='t'">
                <xsl:sequence select="'de'"/>
            </xsl:when>
            <xsl:when test="$nationality='pak'">
                <xsl:sequence select="'pk'"/>
            </xsl:when>
            <xsl:when test="$nationality='iran'">
                <xsl:sequence select="'ir'"/>
            </xsl:when>
            <xsl:when test="$nationality='rwand'">
                <xsl:sequence select="'rw'"/>
            </xsl:when>
            <xsl:when test="$nationality='sudan'">
                <xsl:sequence select="'sd'"/>
            </xsl:when>
            <xsl:when test="$nationality='zimb'">
                <xsl:sequence select="'zw'"/>
            </xsl:when>
            <xsl:when test="$nationality='liby'">
                <xsl:sequence select="'ly'"/>
            </xsl:when>
            <xsl:when test="$nationality='rus'">
                <xsl:sequence select="'ru'"/>
            </xsl:when>
            <xsl:when test="$nationality='russ'">
                <xsl:sequence select="'ru'"/>
            </xsl:when>
            <xsl:when test="$nationality='ukr'">
                <xsl:sequence select="'ua'"/>
            </xsl:when>
            <xsl:when test="$nationality='br'">
                <xsl:sequence select="'br'"/>
            </xsl:when>
            <xsl:when test="$nationality='burm'">
                <xsl:sequence select="'mm'"/>
            </xsl:when>
            <xsl:when test="$nationality='d'">
                <xsl:sequence select="'dk'"/>
            </xsl:when>
            <xsl:when test="$nationality='bosn'">
                <xsl:sequence select="'ba'"/>
            </xsl:when>
            <xsl:when test="$nationality='kin'">
                <xsl:sequence select="'cn'"/>
            </xsl:when>
            <xsl:when test="$nationality='togo'">
                <xsl:sequence select="'tg'"/>
            </xsl:when>
            <xsl:when test="$nationality='bangl'">
                <xsl:sequence select="'bd'"/>
            </xsl:when>
            <xsl:when test="$nationality='indon'">
                <xsl:sequence select="'id'"/>
            </xsl:when>
            <xsl:when test="$nationality='fi'">
                <xsl:sequence select="'fi'"/>
            </xsl:when>
            <xsl:when test="$nationality='isl'">
                <xsl:sequence select="'is'"/>
            </xsl:when>
            <xsl:when test="$nationality='ugand'">
                <xsl:sequence select="'ug'"/>
            </xsl:when>
            <xsl:when test="$nationality='malay'">
                <xsl:sequence select="'my'"/>
            </xsl:when>
            <xsl:when test="$nationality='tanz'">
                <xsl:sequence select="'tz'"/>
            </xsl:when>
            <xsl:when test="$nationality='hait'">
                <xsl:sequence select="'ht'"/>
            </xsl:when>
            <xsl:when test="$nationality='irak'">
                <xsl:sequence select="'iq'"/>
            </xsl:when>
            <xsl:when test="$nationality='am'">
                <xsl:sequence select="'us'"/>
            </xsl:when>
            <xsl:when test="$nationality='viet'">
                <xsl:sequence select="'vn'"/>
            </xsl:when>
            <xsl:when test="$nationality='eng'">
                <xsl:sequence select="'gb'"/>
            </xsl:when>
            <xsl:when test="$nationality='portug'">
                <xsl:sequence select="'pt'"/>
            </xsl:when>
            <xsl:when test="$nationality='dominik'">
                <xsl:sequence select="'do'"/>
            </xsl:when>
            <xsl:when test="$nationality='marok'">
                <xsl:sequence select="'ma'"/>
            </xsl:when>
            <xsl:when test="$nationality='indian'">
                <xsl:sequence select="'in'"/>
            </xsl:when>
            <xsl:when test="$nationality='alb'">
                <xsl:sequence select="'al'"/>
            </xsl:when>
            <xsl:when test="$nationality='syr'">
                <xsl:sequence select="'sy'"/>
            </xsl:when>
            <xsl:when test="$nationality='afg'">
                <xsl:sequence select="'af'"/>
            </xsl:when>
            <xsl:when test="$nationality='trinid'">
                <xsl:sequence select="'tt'"/>
            </xsl:when>
            <xsl:when test="$nationality='est'">
                <xsl:sequence select="'ee'"/>
            </xsl:when>
            <xsl:when test="$nationality='guadel'">
                <xsl:sequence select="'gp'"/>
            </xsl:when>
            <xsl:when test="$nationality='mex'">
                <xsl:sequence select="'mx'"/>
            </xsl:when>
            <xsl:when test="$nationality='egypt'">
                <xsl:sequence select="'eg'"/>
            </xsl:when>
            <xsl:when test="$nationality='chil'">
                <xsl:sequence select="'cl'"/>
            </xsl:when>
            <xsl:when test="$nationality='colomb'">
                <xsl:sequence select="'co'"/>
            </xsl:when>
            <xsl:when test="$nationality='lit'">
                <xsl:sequence select="'lt'"/>
            </xsl:when>
            <xsl:when test="$nationality='sam'">
                <xsl:sequence select="'ws'"/>
            </xsl:when>
            <xsl:when test="$nationality='guatem'">
                <xsl:sequence select="'gt'"/>
            </xsl:when>
            <xsl:when test="$nationality='kor'">
                <xsl:sequence select="'kr'"/>
            </xsl:when>
            <xsl:when test="$nationality='ung'">
                <xsl:sequence select="'hu'"/>
            </xsl:when>
            <xsl:when test="$nationality='rum'">
                <xsl:sequence select="'ro'"/>
            </xsl:when>
            <xsl:when test="$nationality='niger'">
                <xsl:sequence select="'ne'"/>
            </xsl:when>
            <xsl:when test="$nationality='tsj'">
                <xsl:sequence select="'cz'"/>
            </xsl:when>
            <xsl:when test="$nationality='fær'">
                <xsl:sequence select="'fo'"/>
            </xsl:when>
            <xsl:when test="$nationality='jug'">
                <xsl:sequence select="'mk'"/>
            </xsl:when>
            <xsl:when test="$nationality='urug'">
                <xsl:sequence select="'uy'"/>
            </xsl:when>
            <xsl:when test="$nationality='cub'">
                <xsl:sequence select="'cu'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$nationality"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="nlb:parseRole">
        <xsl:param name="role"/>
        <!--
            Note: based on MARC relators
		    (http://lcweb2.loc.gov/diglib/loc.terms/relators/dc-contributor.html)
        -->
        <xsl:variable name="role" select="lower-case($role)"/>
    
        <xsl:choose>
            <xsl:when test="matches($role,'^fr.\s.*') or matches($role,'^til\s.*') or matches($role,'^p.\s.*') or matches($role,'.*(overs|.versett|overatt|omsett).*')">
                <xsl:value-of select="'dc:contributor.translator'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*(foto|billed).*')">
                <xsl:value-of select="'dc:contributor.photographer'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*(illu|tegning|teikni|tegnet).*')">
                <xsl:value-of select="'dc:contributor.illustrator'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*(konsulent|faglig|r.dgiver|research).*')">
                <xsl:value-of select="'dc:contributor.consultant'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*(red[ia\.]|bearb|tilrett|edit|eds|instrukt|instruert|revid).*') or $role='ed' or $role='red' or $role='hovedred'">
                <xsl:value-of select="'dc:contributor.editor'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*(forord|innl|intro).*')">
                <xsl:value-of select="'dc:creator.foreword'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*etterord.*')">
                <!-- Author of afterword, colophon, etc. -->
                <xsl:value-of select="'dc:creator.afterword'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*noter.*')">
                <!-- Other -->
                <xsl:value-of select="'dc:contributor.other'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*kommentar.*')">
                <!-- Commentator for written text -->
                <xsl:value-of select="'dc:contributor.commentator'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*(bidrag|medarb|ansvarl|utgjeve|utgave|medvirk|et\.? al|medf).*')">
                <xsl:value-of select="'dc:contributor'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*(lest|fort|presentert).*')">
                <!-- Narrator -->
                <xsl:value-of select="'dc:contributor.narrator'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*regi.*')">
                <!-- Director -->
                <xsl:value-of select="'dc:contributor.director'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*musikk.*')">
                <!-- Musician -->
                <xsl:value-of select="'dc:contributor.musician'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*komponist.*')">
                <!-- Composer -->
                <xsl:value-of select="'dc:contributor.composer'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*(samlet|utvalg).*')">
                <!-- Compiler -->
                <xsl:value-of select="'dc:contributor.compiler'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'dc:contributor.other'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="nlb:parseDate">
        <xsl:param name="date"/>
        <xsl:choose>
            <xsl:when test="matches($date, $AVAILABLE)">
                <xsl:sequence select="replace($date, $AVAILABLE, '$3-$2-$1')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="nlb:parseBirthDeath">
        <xsl:param name="value"/>
        
        <xsl:variable name="split" select="tokenize($value,'-')"/>
        
        <xsl:choose>
            <xsl:when test="count($split) gt 2">
                <xsl:value-of select="','"/>
                
            </xsl:when>
            <xsl:when test="count($split) = 2">
                <xsl:variable name="year_death" select="nlb:parseYear($split[2], false())"/>
                <xsl:variable name="year_birth" select="nlb:parseYear($split[1], number($year_death) lt 0)"/>
                <xsl:value-of select="concat($year_birth,',',$year_death)"/>
                
            </xsl:when>
            <xsl:when test="count($split) = 1">
                <xsl:value-of select="concat(nlb:parseYear($split[1], false()),',')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="nlb:parseYear">
        <xsl:param name="value"/>
        <xsl:param name="assume-negative"/>
        
        <xsl:variable name="sign" select="if (matches($value,$YEAR_NEGATIVE) or $assume-negative) then '-' else ''"/>
        <xsl:variable name="year" select="replace($value, '^[^\d]*(\d+)([^\d].*)?$', '$1')"/>
        <xsl:variable name="year" select="if (matches($year,'^\d+$')) then $year else ''"/>
        
        <xsl:choose>
            <xsl:when test="$year">
                <xsl:sequence select="concat($sign, $year)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
