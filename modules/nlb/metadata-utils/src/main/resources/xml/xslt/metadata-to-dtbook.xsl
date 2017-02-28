<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:h="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.daisy.org/z3986/2005/dtbook/" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" exclude-result-prefixes="#all" version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:opf="http://www.idpf.org/2007/opf" xpath-default-namespace="http://www.idpf.org/2007/opf" xmlns:f="#" xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:output indent="yes"/>
    <xsl:param name="level" select="'1'"/>
    <xsl:param name="extended" select="false()"/>
    <xsl:param name="include-field" select="''"/>
    <xsl:param name="include-language" select="'false'"/>
    <xsl:param name="include-categorization-attributes" select="'false'"/>

    <xsl:template match="/*" name="metadata">
        <!-- use named template with parameters and context to be able to test with xspec -->
        <xsl:param name="level" select="$level"/>
        <xsl:param name="extended" select="$extended"/>
        <xsl:param name="includeField" select="tokenize($include-field,' ')"/>
        <xsl:param name="include-categorization-attributes" select="$include-categorization-attributes"/>
        <xsl:param name="context" select="/*"/>
        <xsl:for-each select="$context">

            <xsl:variable name="format" select="dc:format/text()"/>
            <xsl:variable name="audience"
                select="(meta[@property='audience' and text()='Student'], meta[@property='audience' and text()='Adult'], meta[@property='audience' and text()='Juvenile'])[1]/text()"/>
            <xsl:variable name="mainGenre" select="(meta[@property='dc:type.genre']/(.[text()='Fiction'],.[text()='Non-fiction']))[1]/text()"/>
            <xsl:variable name="genre" select="distinct-values(meta[@property='dc:type.genre.no']/text())"/>
            <xsl:variable name="newspaper" select="meta[@property='newspaper']/text() = 'true'"/>
            <xsl:variable name="magazine" select="meta[@property='magazine']/text() = 'true'"/>
            <xsl:variable name="periodical" select="meta[@property='periodical']/text() = 'true' or $newspaper or $magazine"/>
            <xsl:variable name="external-production" select="meta[@property='external-production'][1]/text()"/>

            <xsl:variable name="identifier" select="(dc:identifier/text())[1]"/>
            <xsl:variable name="production-available" select="meta[@property='dc:date.available'][1]/text()"/>
            <xsl:variable name="dewey" select="distinct-values(meta[@property='dc:subject.dewey']/text()/replace(.,'^.*?(\d+\.?\d*).*?$','$1'))"/>
            <xsl:variable name="languageName" select="f:language-codes-to-names(dc:language[not(@refines)]/text())"/>
            <xsl:variable name="languageCode" select="f:language-names-to-codes($languageName)"/>
            <xsl:variable name="authors" select="if ($include-categorization-attributes) then for $creator in (dc:creator) return string-join(($creator/text(),$creator[@id]/parent::*/*[@property='bibliofil-id' and @refines=concat('#',$creator/@id)]),'|') else dc:creator/text()"/>
            <xsl:variable name="contributors" select="if ($include-categorization-attributes) then for $contributor in (dc:contributor) return string-join(($contributor/text(),$contributor[@id]/parent::*/*[@property='bibliofil-id' and @refines=concat('#',$contributor/@id)]),'|') else dc:contributor/text()"/>
            <xsl:variable name="title" select="(dc:title)[1]/text()"/>
            <xsl:variable name="subTitle" select="(meta[@property='dc:title.subTitle'])[1]/text()"/>
            <xsl:variable name="partName" select="(meta[@property='partName'])[1]/text()"/>
            <xsl:variable name="partNumber" select="(meta[@property='partNumber'])[1]/text()"/>
            <xsl:variable name="translators" select="if ($include-categorization-attributes) then for $translator in (meta[@property='dc:contributor.translator']) return string-join(($translator/text(),$translator[@id]/parent::*/*[@property='bibliofil-id' and @refines=concat('#',$translator/@id)]),'|') else meta[@property='dc:contributor.translator']/text()"/>
            <xsl:variable name="introducers" select="if ($include-categorization-attributes) then for $introducer in (meta[@property='dc:contributor.introducer']) return string-join(($introducer/text(),$introducer[@id]/parent::*/*[@property='bibliofil-id' and @refines=concat('#',$introducer/@id)]),'|') else meta[@property='dc:contributor.introducer']/text()"/>
            <xsl:variable name="musicians" select="if ($include-categorization-attributes) then for $musician in (meta[@property='dc:contributor.musician']) return string-join(($musician/text(),$musician[@id]/parent::*/*[@property='bibliofil-id' and @refines=concat('#',$musician/@id)]),'|') else meta[@property='dc:contributor.musician']/text()"/>
            <xsl:variable name="duration_string"
                select="(meta[@property='dc:format.extent.duration'])[1]/normalize-space(replace(replace(replace(replace(text(),'\.',''),'\s*t\s*',':'),'\s*min\s*',':'),'\s*s\s*',''))"/>
            <xsl:variable name="duration"
                select="if (count(tokenize($duration_string,':')) = 1) then concat(number(concat('0',$duration_string)),' s')
                                         else if (count(tokenize($duration_string,':')) = 2) then concat(number(concat('0',tokenize($duration_string,':')[1])),' min')
                                         else if (count(tokenize($duration_string,':')) = 3) then concat(number(concat('0',tokenize($duration_string,':')[1])),' t ',number(concat('0',tokenize($duration_string,':')[2])),' min')
                                         else $duration_string"/>
            <xsl:variable name="extent" select="(meta[@property='dc:format.extent'])[1]/text()"/>
            <xsl:variable name="narrators" select="if ($include-categorization-attributes) then for $narrator in (meta[@property='dc:contributor.narrator']) return string-join(($narrator/text(),$narrator[@id]/parent::*/*[@property='bibliofil-id' and @refines=concat('#',$narrator/@id)]),'|') else meta[@property='dc:contributor.narrator']/text()"/>
            <xsl:variable name="description" select="meta[@property='dc:description.abstract']/text()"/>
            <xsl:variable name="originalTitle" select="meta[@property='dc:title.original']/text()"/>
            <xsl:variable name="publisherPlace" select="meta[@property='dc:publisher.location']/text()"/>
            <xsl:variable name="publisherName" select="dc:publisher/text()"/>
            <xsl:variable name="publisherYear" select="dc:issued/text()"/>
            <xsl:variable name="originalPublisherPlace" select="meta[@property='dc:publisher.original.location']/text()"/>
            <xsl:variable name="originalPublisherName" select="meta[@property='dc:publisher.original']/text()"/>
            <xsl:variable name="originalPublisherYear" select="meta[@property='dc:issued.original']/text()"/>
            <xsl:variable name="topics" select="distinct-values((dc:subject | meta[@property='dc:subject.keyword' or @property='dc:subject.location'])/text())"/>
            <xsl:variable name="ageGroups"
                select="dc:audience[starts-with(text(),'Ages ')]/(if (matches(text(),'\d+\+')) then (number(replace(text(),'.*?(\d+)\+','$1')),'+') else (number(replace(text(),'^.*?(\d+)-.*$','$1')),number(replace(text(),'^.*-(\d+)$','$1'))))"/>

            <xsl:element name="level{$level}" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                <xsl:if test="$include-categorization-attributes = 'true'">
                    <xsl:attribute name="format" select="$format"/>
                    <xsl:attribute name="audience" select="$audience"/>
                    <xsl:attribute name="mainGenre" select="$mainGenre"/>
                    <xsl:attribute name="periodical" select="$periodical"/>
                    <xsl:attribute name="newspaper" select="$newspaper"/>
                    <xsl:attribute name="magazine" select="$magazine"/>
                    <xsl:attribute name="production-available" select="$production-available"/>
                    <xsl:attribute name="external-production" select="$external-production"/>
                </xsl:if>
                <xsl:attribute name="id" select="concat('b_',$identifier)"/>

                <xsl:if test="$include-language='true'">
                   <xsl:attribute name="lang" select="if (count($languageName) = 1) then string-join($languageCode,'-') else 'mul'"/>
                   <xsl:attribute name="langName" select="if (count($languageName) = 1) then $languageName else f:language-codes-to-names('mul')[1]"/>
                </xsl:if>

                <xsl:element name="h{$level}" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                    <xsl:choose>
                        <xsl:when test="count($authors) = 1">
                            <span class="author">
                                <xsl:variable name="authorId" select="string(tokenize($authors[1],'\|')[2])"/>
                                <xsl:if test="$authorId != ''">
                                    <xsl:attribute name="class" select="concat('author bibliofil-id-',$authorId)"/>
                                </xsl:if>
                                <xsl:value-of select="string(tokenize($authors[1],'\|')[1])"/>
                            </span>
                            <br/>
                            <span>
                                <span class="title">
                                    <xsl:value-of select="$title"/>
                                </span>
                                <xsl:if test="$subTitle">
                                    <xsl:text>: </xsl:text>
                                    <span class="subTitle">
                                        <xsl:value-of select="$subTitle"/>
                                    </span>
                                </xsl:if>
                                <xsl:if test="$partName">
                                    <xsl:text>: </xsl:text>
                                    <span class="partName">
                                        <xsl:value-of select="$partName"/>
                                    </span>
                                </xsl:if>
                                <xsl:if test="$partNumber">
                                    <xsl:text> </xsl:text>
                                    <span class="partNumber">
                                        <xsl:value-of select="concat('(',$partNumber,')')"/>
                                    </span>
                                </xsl:if>
                            </span>

                        </xsl:when>
                        <xsl:otherwise>
                            <span>
                                <span class="title">
                                    <xsl:value-of select="$title"/>
                                </span>
                                <xsl:if test="$subTitle">
                                    <xsl:text>: </xsl:text>
                                    <span class="subTitle">
                                        <xsl:value-of select="$subTitle"/>
                                    </span>
                                </xsl:if>
                                <xsl:if test="$partName">
                                    <xsl:text>: </xsl:text>
                                    <span class="partName">
                                        <xsl:value-of select="$partName"/>
                                    </span>
                                </xsl:if>
                                <xsl:if test="$partNumber">
                                    <xsl:text> </xsl:text>
                                    <span class="partNumber">
                                        <xsl:value-of select="concat('(',$partNumber,')')"/>
                                    </span>
                                </xsl:if>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>

                <linegroup>

                    <xsl:choose>
                        <xsl:when test="count($authors) = 1">
                            <!--<line>
                            <span class="title">
                                <xsl:value-of select="$title"/>
                            </span>
                            <xsl:if test="$subTitle">
                                <xsl:text>: </xsl:text>
                                <span class="subTitle">
                                    <xsl:value-of select="$subTitle"/>
                                </span>
                            </xsl:if>
                        </line>-->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="nameList">
                                <xsl:with-param name="names" select="if (count($authors)) then $authors else $contributors"/>
                                <xsl:with-param name="wrapper-class" select="'authors'"/>
                                <xsl:with-param name="class" select="'author'"/>
                                <xsl:with-param name="singular" select="'Forfatter: '"/>
                                <xsl:with-param name="plural" select="'Forfattere: '"/>
                                <xsl:with-param name="websok-type" select="'FO'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:if test="$extended or $includeField='translator'">
                        <xsl:call-template name="nameList">
                            <xsl:with-param name="names" select="$translators"/>
                            <xsl:with-param name="wrapper-class" select="'translators'"/>
                            <xsl:with-param name="class" select="'translator'"/>
                            <xsl:with-param name="singular" select="'Oversatt av: '"/>
                            <xsl:with-param name="plural" select="'Oversatt av: '"/>
                            <xsl:with-param name="websok-type" select="'PE'"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:if test="$extended or $includeField='introducer'">
                        <xsl:call-template name="nameList">
                            <xsl:with-param name="names" select="$introducers"/>
                            <xsl:with-param name="wrapper-class" select="'introducers'"/>
                            <xsl:with-param name="class" select="'introducer'"/>
                            <xsl:with-param name="singular" select="'Forord av: '"/>
                            <xsl:with-param name="plural" select="'Forord av: '"/>
                            <xsl:with-param name="websok-type" select="'PE'"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:if test="$extended or $includeField='musician'">
                        <xsl:call-template name="nameList">
                            <xsl:with-param name="names" select="$musicians"/>
                            <xsl:with-param name="wrapper-class" select="'musicians'"/>
                            <xsl:with-param name="class" select="'musician'"/>
                            <xsl:with-param name="singular" select="'Musikk av: '"/>
                            <xsl:with-param name="plural" select="'Musikk av: '"/>
                            <xsl:with-param name="websok-type" select="'PE'"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:if test="count($duration)">
                        <xsl:choose>
                            <xsl:when test="$extended">
                                <line>
                                    <span class="fieldName">Varighet: </span>
                                    <span class="duration">
                                        <xsl:value-of select="$duration"/>
                                    </span>
                                </line>
                            </xsl:when>
                            <xsl:otherwise>
                                <line class="duration">
                                    <xsl:value-of select="$duration"/>
                                </line>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>

                    <xsl:if test="count($extent)">
                        <xsl:variable name="mostDescriptiveExtent" select="$extent[not(string-length() &lt; string-length($extent))][1]"/>
                        <xsl:choose>
                            <xsl:when test="$extended">
                                <line>
                                    <span class="fieldName">Hefter: </span>
                                    <span class="extent">
                                        <xsl:value-of select="$mostDescriptiveExtent"/>
                                    </span>
                                </line>
                            </xsl:when>
                            <xsl:otherwise>
                                <line class="extent">
                                    <xsl:value-of select="$mostDescriptiveExtent"/>
                                </line>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>

                    <xsl:if test="$format='DAISY 2.02'">
                        <xsl:call-template name="nameList">
                            <xsl:with-param name="names" select="$narrators"/>
                            <xsl:with-param name="wrapper-class" select="'narrators'"/>
                            <xsl:with-param name="class" select="'narrator'"/>
                            <xsl:with-param name="singular" select="'Lest av: '"/>
                            <xsl:with-param name="plural" select="'Lest av: '"/>
                            <xsl:with-param name="websok-type" select="'IN'"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:if test="count($description)">
                        <xsl:choose>
                            <xsl:when test="$extended">
                                <line>
                                    <span class="fieldName">Bokomtale: </span>
                                    <span class="description">
                                        <xsl:value-of select="$description"/>
                                    </span>
                                </line>
                            </xsl:when>
                            <xsl:otherwise>
                                <line class="description">
                                    <xsl:value-of select="$description"/>
                                </line>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>

                    <xsl:if test="$extended or $includeField='originalTitle'">
                        <xsl:if test="count($originalTitle)">
                            <line>
                                <span class="fieldName">Originaltittel: </span>
                                <span class="originalTitle">
                                    <xsl:value-of select="$originalTitle"/>
                                </span>
                            </line>
                        </xsl:if>
                    </xsl:if>

                    <xsl:if test="$extended or $includeField='publisher'">
                        <xsl:if test="count($publisherPlace) or count($publisherName) or count($publisherYear)">
                            <line>
                                <span class="fieldName">Forlag: </span>
                                <span class="publisher">
                                    <xsl:if test="count($publisherName)">
                                        <span class="publisherName">
                                            <xsl:value-of select="$publisherName"/>
                                        </span>
                                        <xsl:if test="$publisherPlace or $publisherYear">
                                            <xsl:value-of select="', '"/>
                                        </xsl:if>
                                    </xsl:if>
                                    <xsl:if test="count($publisherPlace)">
                                        <span class="publisherPlace">
                                            <xsl:value-of select="$publisherPlace"/>
                                        </span>
                                        <xsl:if test="$publisherYear">
                                            <xsl:value-of select="', '"/>
                                        </xsl:if>
                                    </xsl:if>
                                    <xsl:if test="count($publisherYear)">
                                        <span class="publisherYear">
                                            <xsl:value-of select="$publisherYear"/>
                                        </span>
                                    </xsl:if>
                                </span>
                            </line>
                        </xsl:if>
                    </xsl:if>

                    <xsl:if test="$extended or $includeField='originalPublisher'">
                        <xsl:if test="count($originalPublisherPlace) or count($originalPublisherName) or count($originalPublisherYear)">
                            <line>
                                <span class="fieldName">Originalforlag: </span>
                                <span class="originalPublisher">
                                    <xsl:if test="count($originalPublisherName)">
                                        <span class="originalPublisherName">
                                            <xsl:value-of select="$originalPublisherName"/>
                                        </span>
                                        <xsl:if test="$originalPublisherPlace or $originalPublisherYear">
                                            <xsl:value-of select="', '"/>
                                        </xsl:if>
                                    </xsl:if>
                                    <xsl:if test="count($originalPublisherPlace)">
                                        <span class="originalPublisherPlace">
                                            <xsl:value-of select="$originalPublisherPlace"/>
                                        </span>
                                        <xsl:if test="$originalPublisherYear">
                                            <xsl:value-of select="', '"/>
                                        </xsl:if>
                                    </xsl:if>
                                    <xsl:if test="count($originalPublisherYear)">
                                        <span class="originalPublisherYear">
                                            <xsl:value-of select="$originalPublisherYear"/>
                                        </span>
                                    </xsl:if>
                                </span>
                            </line>
                        </xsl:if>
                    </xsl:if>

                    <xsl:if test="$extended or $includeField=('genre','topic')">
                        <xsl:if test="count(($genre,$topics))">
                            <line>
                                <span class="fieldName">Sjanger/Emner: </span>
                                <span class="topics">
                                    <xsl:for-each select="distinct-values(($genre,$topics))">
                                        <span class="topic">
                                            <xsl:value-of select="."/>
                                        </span>
                                        <xsl:if test="not(position()=last())">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </line>
                        </xsl:if>
                    </xsl:if>

                    <xsl:if test="$extended or $includeField='dewey'">
                        <xsl:if test="count($dewey)">
                            <line>
                                <span class="fieldName">Dewey: </span>
                                <span class="deweys">
                                    <xsl:for-each select="$dewey">
                                        <span class="dewey">
                                            <xsl:value-of select="."/>
                                        </span>
                                        <xsl:if test="not(position()=last())">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </line>
                        </xsl:if>
                    </xsl:if>

                    <xsl:if test="$audience='Juvenile' and count($ageGroups)">
                        <line>
                            <span class="fieldName">Aldersgruppe: </span>
                            <span class="age-group">
                                <xsl:variable name="ageGroupPlus" select="(for $a in $ageGroups return string($a)='+')=true()"/>
                                <xsl:variable name="ageGroupNumbers" select="(for $a in $ageGroups return (if (string($a)='+') then () else $a))"/>
                                <xsl:choose>
                                    <xsl:when test="$ageGroupPlus">
                                        <xsl:value-of select="concat(min($ageGroupNumbers),'+')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat(min($ageGroupNumbers),'-',max($ageGroupNumbers))"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                        </line>
                    </xsl:if>

                    <xsl:if test="count($identifier)">
                        <line>
                            <span class="fieldName">Boknummer: </span>
                            <a external="true" href="http://websok.nlb.no/cgi-bin/websok?tnr={$identifier}" class="identifier">
                                <xsl:value-of select="$identifier"/>
                            </a>
                        </line>
                    </xsl:if>

                </linegroup>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="nameList">
        <xsl:param name="names" required="yes"/>
        <xsl:param name="wrapper-class" select="''"/>
        <xsl:param name="class" select="''"/>
        <xsl:param name="singular" select="''"/>
        <xsl:param name="plural" select="''"/>
        <xsl:param name="websok-type" select="''"/>
        <xsl:variable name="namesId" select="for $name in ($names) return string(tokenize($name,'\|')[2])"/>
        <xsl:variable name="names" select="for $name in ($names) return string(tokenize($name,'\|')[1])"/>
        <xsl:variable name="givenNames" select="for $name in ($names) return replace($name,'^(.*),\s+(.*?)$','$2 $1')"/>
        <xsl:choose>
            <xsl:when test="count($givenNames) = 0"/>
            <xsl:when test="count($givenNames) &gt; 1">
                <line>
                    <span class="fieldName">
                        <xsl:value-of select="$plural"/>
                    </span>
                    <span>
                        <xsl:if test="$wrapper-class">
                            <xsl:attribute name="class" select="$wrapper-class"/>
                        </xsl:if>
                        <xsl:for-each select="$givenNames">
                            <xsl:variable name="position" select="position()"/>
                            <xsl:if test="position() = last()">
                                <xsl:value-of select="' og '"/>
                            </xsl:if>
                            <xsl:if test="not(position()=(1,last()))">
                                <xsl:value-of select="', '"/>
                            </xsl:if>
                            <span>
                                <xsl:variable name="classes" select="($class, if ($namesId[$position] != '') then concat('bibliofil-id-',$namesId[$position]) else ())"/>
                                <xsl:if test="count($classes)">
                                    <xsl:attribute name="class" select="string-join($classes,' ')"/>
                                </xsl:if>
                                <xsl:value-of select="."/>
                            </span>
                        </xsl:for-each>
                    </span>
                </line>
            </xsl:when>
            <xsl:otherwise>
                <line>
                    <span class="fieldName">
                        <xsl:value-of select="$singular"/>
                    </span>
                    <span>
                        <xsl:if test="$wrapper-class">
                            <xsl:attribute name="class" select="$wrapper-class"/>
                        </xsl:if>
                        <span>
                            <xsl:variable name="classes" select="($class, if ($namesId[1] != '') then concat('bibliofil-id-',$namesId[1]) else ())"/>
                            <xsl:if test="count($classes)">
                                <xsl:attribute name="class" select="string-join($classes,' ')"/>
                            </xsl:if>
                            <xsl:value-of select="$givenNames"/>
                        </span>
                    </span>
                </line>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
<xsl:function name="f:language-names-to-codes" as="xs:string*">
        <xsl:param name="names" as="xs:string*"/>
        <xsl:variable name="codes-unsorted">
            <xsl:for-each select="$names">
                <xsl:variable name="name" select="."/>
                <xsl:choose>
                    <xsl:when test="$name = 'Acehnesisk'"><xsl:sequence select="('ace')"/></xsl:when>
                    <xsl:when test="$name = 'Acholi'"><xsl:sequence select="('ach')"/></xsl:when>
                    <xsl:when test="$name = 'Afrikaans'"><xsl:sequence select="('afr')"/></xsl:when>
                    <xsl:when test="$name = 'Akkadisk'"><xsl:sequence select="('akk')"/></xsl:when>
                    <xsl:when test="$name = 'Albansk'"><xsl:sequence select="('alb')"/></xsl:when>
                    <xsl:when test="$name = 'Amharisk'"><xsl:sequence select="('amh')"/></xsl:when>
                    <xsl:when test="$name = 'Angelsaksisk'"><xsl:sequence select="('ang')"/></xsl:when>
                    <xsl:when test="$name = 'Arabisk'"><xsl:sequence select="('ara')"/></xsl:when>
                    <xsl:when test="$name = 'Arameisk'"><xsl:sequence select="('arc')"/></xsl:when>
                    <xsl:when test="$name = 'Armensk'"><xsl:sequence select="('arm')"/></xsl:when>
                    <xsl:when test="$name = 'Aserbajdsjansk'"><xsl:sequence select="('aze')"/></xsl:when>
                    <xsl:when test="$name = 'Avestisk'"><xsl:sequence select="('ave')"/></xsl:when>
                    <xsl:when test="$name = 'Bambara'"><xsl:sequence select="('bam')"/></xsl:when>
                    <xsl:when test="$name = 'Bantuspråk'"><xsl:sequence select="('bnt')"/></xsl:when>
                    <xsl:when test="$name = 'Baskisk'"><xsl:sequence select="('baq')"/></xsl:when>
                    <xsl:when test="$name = 'Bemba'"><xsl:sequence select="('bem')"/></xsl:when>
                    <xsl:when test="$name = 'Bengali'"><xsl:sequence select="('ben')"/></xsl:when>
                    <xsl:when test="$name = 'Bilin'"><xsl:sequence select="('byn')"/></xsl:when>
                    <xsl:when test="$name = 'Bislama'"><xsl:sequence select="('bis')"/></xsl:when>
                    <xsl:when test="$name = 'Bokmål'"><xsl:sequence select="('nob')"/></xsl:when>
                    <xsl:when test="$name = 'Bosnisk'"><xsl:sequence select="('bos')"/></xsl:when>
                    <xsl:when test="$name = 'Bretonsk'"><xsl:sequence select="('bre')"/></xsl:when>
                    <xsl:when test="$name = 'Bulgarsk'"><xsl:sequence select="('bul')"/></xsl:when>
                    <xsl:when test="$name = 'Burmesisk'"><xsl:sequence select="('bur')"/></xsl:when>
                    <xsl:when test="$name = 'Cebuano'"><xsl:sequence select="('ceb')"/></xsl:when>
                    <xsl:when test="$name = 'Dansk'"><xsl:sequence select="('dan')"/></xsl:when>
                    <xsl:when test="$name = 'Dari'"><xsl:sequence select="('prs')"/></xsl:when>
                    <xsl:when test="$name = 'Dzongkha'"><xsl:sequence select="('dzo')"/></xsl:when>
                    <xsl:when test="$name = 'Egyptisk'"><xsl:sequence select="('egy')"/></xsl:when>
                    <xsl:when test="$name = 'Engelsk'"><xsl:sequence select="('eng')"/></xsl:when>
                    <xsl:when test="$name = 'Eskimospråk'"><xsl:sequence select="('esk')"/></xsl:when>
                    <xsl:when test="$name = 'Esperanto'"><xsl:sequence select="('epo','esp')"/></xsl:when>
                    <xsl:when test="$name = 'Estisk'"><xsl:sequence select="('est')"/></xsl:when>
                    <xsl:when test="$name = 'Etiopisk'"><xsl:sequence select="('eth','gez')"/></xsl:when>
                    <xsl:when test="$name = 'Ewe'"><xsl:sequence select="('ewe')"/></xsl:when>
                    <xsl:when test="$name = 'Fante'"><xsl:sequence select="('fat')"/></xsl:when>
                    <xsl:when test="$name = 'Fijiansk'"><xsl:sequence select="('fij')"/></xsl:when>
                    <xsl:when test="$name = 'Finsk'"><xsl:sequence select="('fin')"/></xsl:when>
                    <xsl:when test="$name = 'Finsk-ugrisk'"><xsl:sequence select="('fiu')"/></xsl:when>
                    <xsl:when test="$name = 'Fransk'"><xsl:sequence select="('fre')"/></xsl:when>
                    <xsl:when test="$name = 'Frisisk'"><xsl:sequence select="('fri','fry')"/></xsl:when>
                    <xsl:when test="$name = 'Fulfulde'"><xsl:sequence select="('ful')"/></xsl:when>
                    <xsl:when test="$name = 'Færøysk'"><xsl:sequence select="('fao','far')"/></xsl:when>
                    <xsl:when test="$name = 'Galisisk'"><xsl:sequence select="('gag','glg')"/></xsl:when>
                    <xsl:when test="$name = 'Gammelfransk'"><xsl:sequence select="('fro')"/></xsl:when>
                    <xsl:when test="$name = 'Gammelgresk'"><xsl:sequence select="('grc')"/></xsl:when>
                    <xsl:when test="$name = 'Georgisk'"><xsl:sequence select="('geo')"/></xsl:when>
                    <xsl:when test="$name = 'Gotisk'"><xsl:sequence select="('got')"/></xsl:when>
                    <xsl:when test="$name = 'Gresk'"><xsl:sequence select="('gre')"/></xsl:when>
                    <xsl:when test="$name = 'Grønlandsk'"><xsl:sequence select="('kal')"/></xsl:when>
                    <xsl:when test="$name = 'Gujarati'"><xsl:sequence select="('guj')"/></xsl:when>
                    <xsl:when test="$name = 'Gælisk'"><xsl:sequence select="('gae')"/></xsl:when>
                    <xsl:when test="$name = 'Hausa'"><xsl:sequence select="('hau')"/></xsl:when>
                    <xsl:when test="$name = 'Hebraisk'"><xsl:sequence select="('heb')"/></xsl:when>
                    <xsl:when test="$name = 'Hettittisk'"><xsl:sequence select="('hit')"/></xsl:when>
                    <xsl:when test="$name = 'Hiligaynon'"><xsl:sequence select="('hil')"/></xsl:when>
                    <xsl:when test="$name = 'Hindi'"><xsl:sequence select="('hin')"/></xsl:when>
                    <xsl:when test="$name = 'Hviterussisk'"><xsl:sequence select="('bel')"/></xsl:when>
                    <xsl:when test="$name = 'Ibo'"><xsl:sequence select="('ibo')"/></xsl:when>
                    <xsl:when test="$name = 'Iloko'"><xsl:sequence select="('ilo')"/></xsl:when>
                    <xsl:when test="$name = 'Inarisamisk'"><xsl:sequence select="('lai','smn')"/></xsl:when>
                    <xsl:when test="$name = 'Indonesisk'"><xsl:sequence select="('ind')"/></xsl:when>
                    <xsl:when test="$name = 'Inuittisk'"><xsl:sequence select="('iku')"/></xsl:when>
                    <xsl:when test="$name = 'Inupiak'"><xsl:sequence select="('ipk')"/></xsl:when>
                    <xsl:when test="$name = 'Iransk'"><xsl:sequence select="('ira')"/></xsl:when>
                    <xsl:when test="$name = 'Irsk'"><xsl:sequence select="('gle','iri')"/></xsl:when>
                    <xsl:when test="$name = 'Islandsk'"><xsl:sequence select="('ice')"/></xsl:when>
                    <xsl:when test="$name = 'Italiensk'"><xsl:sequence select="('ita')"/></xsl:when>
                    <xsl:when test="$name = 'Jakutisk'"><xsl:sequence select="('sah')"/></xsl:when>
                    <xsl:when test="$name = 'Japansk'"><xsl:sequence select="('jpn')"/></xsl:when>
                    <xsl:when test="$name = 'Jiddish'"><xsl:sequence select="('yid')"/></xsl:when>
                    <xsl:when test="$name = 'Karelsk'"><xsl:sequence select="('krj')"/></xsl:when>
                    <xsl:when test="$name = 'Katalansk'"><xsl:sequence select="('cat')"/></xsl:when>
                    <xsl:when test="$name = 'Khmer'"><xsl:sequence select="('cam','khm')"/></xsl:when>
                    <xsl:when test="$name = 'Khotanesisk'"><xsl:sequence select="('kho')"/></xsl:when>
                    <xsl:when test="$name = 'Kinesisk'"><xsl:sequence select="('chi')"/></xsl:when>
                    <xsl:when test="$name = 'Kinyarwanda'"><xsl:sequence select="('kin')"/></xsl:when>
                    <xsl:when test="$name = 'Kirkeslavisk'"><xsl:sequence select="('chu')"/></xsl:when>
                    <xsl:when test="$name = 'Kongo'"><xsl:sequence select="('kon')"/></xsl:when>
                    <xsl:when test="$name = 'Koptisk'"><xsl:sequence select="('cop')"/></xsl:when>
                    <xsl:when test="$name = 'Koreansk'"><xsl:sequence select="('kor')"/></xsl:when>
                    <xsl:when test="$name = 'Kroatisk'"><xsl:sequence select="('cro','hrv')"/></xsl:when>
                    <xsl:when test="$name = 'Kuanyama'"><xsl:sequence select="('kua')"/></xsl:when>
                    <xsl:when test="$name = 'Kurdisk'"><xsl:sequence select="('kur')"/></xsl:when>
                    <xsl:when test="$name = 'Kurmanji'"><xsl:sequence select="('kmr')"/></xsl:when>
                    <xsl:when test="$name = 'Kusjittisk'"><xsl:sequence select="('cus')"/></xsl:when>
                    <xsl:when test="$name = 'Kvensk'"><xsl:sequence select="('fkv')"/></xsl:when>
                    <xsl:when test="$name = 'Laotisk'"><xsl:sequence select="('lao')"/></xsl:when>
                    <xsl:when test="$name = 'Latin'"><xsl:sequence select="('lat')"/></xsl:when>
                    <xsl:when test="$name = 'Latvisk'"><xsl:sequence select="('lav')"/></xsl:when>
                    <xsl:when test="$name = 'Lavskotsk'"><xsl:sequence select="('sco')"/></xsl:when>
                    <xsl:when test="$name = 'Litauisk'"><xsl:sequence select="('lit')"/></xsl:when>
                    <xsl:when test="$name = 'Lulesamisk'"><xsl:sequence select="('lal','smj')"/></xsl:when>
                    <xsl:when test="$name = 'Madagassisk'"><xsl:sequence select="('mla','mlg')"/></xsl:when>
                    <xsl:when test="$name = 'Makedonsk'"><xsl:sequence select="('mac')"/></xsl:when>
                    <xsl:when test="$name = 'Malayisk'"><xsl:sequence select="('may')"/></xsl:when>
                    <xsl:when test="$name = 'Mandinka'"><xsl:sequence select="('mnk')"/></xsl:when>
                    <xsl:when test="$name = 'Maori'"><xsl:sequence select="('mao')"/></xsl:when>
                    <xsl:when test="$name = 'Marathi'"><xsl:sequence select="('mar')"/></xsl:when>
                    <xsl:when test="$name = 'Maya'"><xsl:sequence select="('myn')"/></xsl:when>
                    <xsl:when test="$name = 'Mellomengelsk'"><xsl:sequence select="('enm')"/></xsl:when>
                    <xsl:when test="$name = 'Mellomfransk'"><xsl:sequence select="('frm')"/></xsl:when>
                    <xsl:when test="$name = 'Mellomnorsk'"><xsl:sequence select="('nom')"/></xsl:when>
                    <xsl:when test="$name = 'Middelhøytysk'"><xsl:sequence select="('gmh')"/></xsl:when>
                    <xsl:when test="$name = 'Moldavisk'"><xsl:sequence select="('mol')"/></xsl:when>
                    <xsl:when test="$name = 'Mongolsk'"><xsl:sequence select="('mon')"/></xsl:when>
                    <xsl:when test="$name = 'Nahuatl'"><xsl:sequence select="('nah')"/></xsl:when>
                    <xsl:when test="$name = 'Ndebele'"><xsl:sequence select="('nbl','nde')"/></xsl:when>
                    <xsl:when test="$name = 'Nederlandsk'"><xsl:sequence select="('dut')"/></xsl:when>
                    <xsl:when test="$name = 'Nedertysk'"><xsl:sequence select="('nds')"/></xsl:when>
                    <xsl:when test="$name = 'Nepali'"><xsl:sequence select="('nep')"/></xsl:when>
                    <xsl:when test="$name = 'Niger-Kongospråk'"><xsl:sequence select="('nic')"/></xsl:when>
                    <xsl:when test="$name = 'Nordsamisk'"><xsl:sequence select="('laf','sme')"/></xsl:when>
                    <xsl:when test="$name = 'Norrønt'"><xsl:sequence select="('non')"/></xsl:when>
                    <xsl:when test="$name = 'Norsk'"><xsl:sequence select="('nor')"/></xsl:when>
                    <xsl:when test="$name = 'Nynorsk'"><xsl:sequence select="('nno')"/></xsl:when>
                    <xsl:when test="$name = 'Oromo'"><xsl:sequence select="('orm')"/></xsl:when>
                    <xsl:when test="$name = 'Pali'"><xsl:sequence select="('pli')"/></xsl:when>
                    <xsl:when test="$name = 'Panjabi'"><xsl:sequence select="('pan')"/></xsl:when>
                    <xsl:when test="$name = 'Pashto'"><xsl:sequence select="('pus')"/></xsl:when>
                    <xsl:when test="$name = 'Persisk'"><xsl:sequence select="('per')"/></xsl:when>
                    <xsl:when test="$name = 'Polsk'"><xsl:sequence select="('pol')"/></xsl:when>
                    <xsl:when test="$name = 'Portugisisk'"><xsl:sequence select="('por')"/></xsl:when>
                    <xsl:when test="$name = 'Prakrit'"><xsl:sequence select="('pra')"/></xsl:when>
                    <xsl:when test="$name = 'Provençalsk'"><xsl:sequence select="('oci','pro')"/></xsl:when>
                    <xsl:when test="$name = 'Retoromansk'"><xsl:sequence select="('roh')"/></xsl:when>
                    <xsl:when test="$name = 'Romani'"><xsl:sequence select="('rom')"/></xsl:when>
                    <xsl:when test="$name = 'Rumensk'"><xsl:sequence select="('rum')"/></xsl:when>
                    <xsl:when test="$name = 'Rundi'"><xsl:sequence select="('run')"/></xsl:when>
                    <xsl:when test="$name = 'Russisk'"><xsl:sequence select="('rus')"/></xsl:when>
                    <xsl:when test="$name = 'Samisk'"><xsl:sequence select="('lap','smi')"/></xsl:when>
                    <xsl:when test="$name = 'Samoansk'"><xsl:sequence select="('sao','smo')"/></xsl:when>
                    <xsl:when test="$name = 'Sanskrit'"><xsl:sequence select="('san')"/></xsl:when>
                    <xsl:when test="$name = 'Santali'"><xsl:sequence select="('sat')"/></xsl:when>
                    <xsl:when test="$name = 'Serbisk'"><xsl:sequence select="('ser','srp')"/></xsl:when>
                    <xsl:when test="$name = 'Serbokroatisk'"><xsl:sequence select="('scc','scr')"/></xsl:when>
                    <xsl:when test="$name = 'Shona'"><xsl:sequence select="('sna')"/></xsl:when>
                    <xsl:when test="$name = 'Sindhi'"><xsl:sequence select="('snd')"/></xsl:when>
                    <xsl:when test="$name = 'Singalesisk'"><xsl:sequence select="('sin','snh')"/></xsl:when>
                    <xsl:when test="$name = 'Sino-tibetansk'"><xsl:sequence select="('sit')"/></xsl:when>
                    <xsl:when test="$name = 'Skoltesamisk'"><xsl:sequence select="('lak','sms')"/></xsl:when>
                    <xsl:when test="$name = 'Skotsk-gælisk'"><xsl:sequence select="('gla')"/></xsl:when>
                    <xsl:when test="$name = 'Slovakisk'"><xsl:sequence select="('slo')"/></xsl:when>
                    <xsl:when test="$name = 'Slovensk'"><xsl:sequence select="('slv')"/></xsl:when>
                    <xsl:when test="$name = 'Somali'"><xsl:sequence select="('som')"/></xsl:when>
                    <xsl:when test="$name = 'Sorbisk'"><xsl:sequence select="('wen')"/></xsl:when>
                    <xsl:when test="$name = 'Spansk'"><xsl:sequence select="('spa')"/></xsl:when>
                    <xsl:when test="$name = 'Sumerisk'"><xsl:sequence select="('sux')"/></xsl:when>
                    <xsl:when test="$name = 'Svensk'"><xsl:sequence select="('swe')"/></xsl:when>
                    <xsl:when test="$name = 'Swahili'"><xsl:sequence select="('swa')"/></xsl:when>
                    <xsl:when test="$name = 'Syrisk'"><xsl:sequence select="('syr')"/></xsl:when>
                    <xsl:when test="$name = 'Sørkurdisk'"><xsl:sequence select="('ckb')"/></xsl:when>
                    <xsl:when test="$name = 'Sørsamisk'"><xsl:sequence select="('las','sma')"/></xsl:when>
                    <xsl:when test="$name = 'Tagalog'"><xsl:sequence select="('tag','tgl')"/></xsl:when>
                    <xsl:when test="$name = 'Tamil'"><xsl:sequence select="('tam')"/></xsl:when>
                    <xsl:when test="$name = 'Tegnspråk'"><xsl:sequence select="('sgn')"/></xsl:when>
                    <xsl:when test="$name = 'Thai'"><xsl:sequence select="('tha')"/></xsl:when>
                    <xsl:when test="$name = 'Tibetansk'"><xsl:sequence select="('tib')"/></xsl:when>
                    <xsl:when test="$name = 'Tigrinja'"><xsl:sequence select="('tir')"/></xsl:when>
                    <xsl:when test="$name = 'Tokelaisk'"><xsl:sequence select="('tkl')"/></xsl:when>
                    <xsl:when test="$name = 'Tongansk'"><xsl:sequence select="('ton')"/></xsl:when>
                    <xsl:when test="$name = 'Tsjekkisk'"><xsl:sequence select="('cze')"/></xsl:when>
                    <xsl:when test="$name = 'Tsjetsjensk'"><xsl:sequence select="('che')"/></xsl:when>
                    <xsl:when test="$name = 'Twi'"><xsl:sequence select="('twi')"/></xsl:when>
                    <xsl:when test="$name = 'Tyrkisk'"><xsl:sequence select="('tur')"/></xsl:when>
                    <xsl:when test="$name = 'Tysk'"><xsl:sequence select="('ger')"/></xsl:when>
                    <xsl:when test="$name = 'Uigurisk'"><xsl:sequence select="('uig')"/></xsl:when>
                    <xsl:when test="$name = 'Ukrainsk'"><xsl:sequence select="('ukr')"/></xsl:when>
                    <xsl:when test="$name = 'Ungarsk'"><xsl:sequence select="('hun')"/></xsl:when>
                    <xsl:when test="$name = 'Urdu'"><xsl:sequence select="('urd')"/></xsl:when>
                    <xsl:when test="$name = 'Usbekisk'"><xsl:sequence select="('uzb')"/></xsl:when>
                    <xsl:when test="$name = 'Vietnamesisk'"><xsl:sequence select="('vie')"/></xsl:when>
                    <xsl:when test="$name = 'Walisisk'"><xsl:sequence select="('wel')"/></xsl:when>
                    <xsl:when test="$name = 'Xhosa'"><xsl:sequence select="('xho')"/></xsl:when>
                    <xsl:when test="$name = 'Yoruba'"><xsl:sequence select="('yor')"/></xsl:when>
                    <xsl:when test="$name = 'Yupikspråk'"><xsl:sequence select="('ypk')"/></xsl:when>
                    <xsl:when test="$name = 'Zulu'"><xsl:sequence select="('zul')"/></xsl:when>
                    <xsl:when test="$name = 'Østsamisk'"><xsl:sequence select="('lae')"/></xsl:when>
                    
                    <xsl:when test="$name = 'Flerspråklig'"><xsl:sequence select="('mul')"/></xsl:when>
                    <xsl:otherwise><xsl:sequence select="concat('und-',string-join($names,'|'))"/></xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$codes-unsorted">
            <xsl:sort/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="f:language-codes-to-names" as="xs:string*">
        <xsl:param name="codes" as="xs:string*"/>
        <xsl:variable name="names-unfiltered" as="xs:string*">
            <xsl:for-each select="$codes">
                <xsl:variable name="code" select="."/>
                <xsl:choose>
                    <xsl:when test="$code = 'ace'"><xsl:sequence select="'Acehnesisk'"/></xsl:when>
                    <xsl:when test="$code = 'ach'"><xsl:sequence select="'Acholi'"/></xsl:when>
                    <xsl:when test="$code = 'afr'"><xsl:sequence select="'Afrikaans'"/></xsl:when>
                    <xsl:when test="$code = 'akk'"><xsl:sequence select="'Akkadisk'"/></xsl:when>
                    <xsl:when test="$code = 'alb'"><xsl:sequence select="'Albansk'"/></xsl:when>
                    <xsl:when test="$code = 'amh'"><xsl:sequence select="'Amharisk'"/></xsl:when>
                    <xsl:when test="$code = 'ang'"><xsl:sequence select="'Angelsaksisk'"/></xsl:when>
                    <xsl:when test="$code = 'ara'"><xsl:sequence select="'Arabisk'"/></xsl:when>
                    <xsl:when test="$code = 'arc'"><xsl:sequence select="'Arameisk'"/></xsl:when>
                    <xsl:when test="$code = 'arm'"><xsl:sequence select="'Armensk'"/></xsl:when>
                    <xsl:when test="$code = 'ave'"><xsl:sequence select="'Avestisk'"/></xsl:when>
                    <xsl:when test="$code = 'aze'"><xsl:sequence select="'Aserbajdsjansk'"/></xsl:when>
                    <xsl:when test="$code = 'bam'"><xsl:sequence select="'Bambara'"/></xsl:when>
                    <xsl:when test="$code = 'baq'"><xsl:sequence select="'Baskisk'"/></xsl:when>
                    <xsl:when test="$code = 'bel'"><xsl:sequence select="'Hviterussisk'"/></xsl:when>
                    <xsl:when test="$code = 'bem'"><xsl:sequence select="'Bemba'"/></xsl:when>
                    <xsl:when test="$code = 'ben'"><xsl:sequence select="'Bengali'"/></xsl:when>
                    <xsl:when test="$code = 'bis'"><xsl:sequence select="'Bislama'"/></xsl:when>
                    <xsl:when test="$code = 'bnt'"><xsl:sequence select="'Bantuspråk'"/></xsl:when>
                    <xsl:when test="$code = 'bos'"><xsl:sequence select="'Bosnisk'"/></xsl:when>
                    <xsl:when test="$code = 'bre'"><xsl:sequence select="'Bretonsk'"/></xsl:when>
                    <xsl:when test="$code = 'bul'"><xsl:sequence select="'Bulgarsk'"/></xsl:when>
                    <xsl:when test="$code = 'bur'"><xsl:sequence select="'Burmesisk'"/></xsl:when>
                    <xsl:when test="$code = 'byn'"><xsl:sequence select="'Bilin'"/></xsl:when>
                    <xsl:when test="$code = 'cam'"><xsl:sequence select="'Khmer'"/></xsl:when>
                    <xsl:when test="$code = 'cat'"><xsl:sequence select="'Katalansk'"/></xsl:when>
                    <xsl:when test="$code = 'ceb'"><xsl:sequence select="'Cebuano'"/></xsl:when>
                    <xsl:when test="$code = 'che'"><xsl:sequence select="'Tsjetsjensk'"/></xsl:when>
                    <xsl:when test="$code = 'chi'"><xsl:sequence select="'Kinesisk'"/></xsl:when>
                    <xsl:when test="$code = 'chu'"><xsl:sequence select="'Kirkeslavisk'"/></xsl:when>
                    <xsl:when test="$code = 'ckb'"><xsl:sequence select="'Sørkurdisk'"/></xsl:when>
                    <xsl:when test="$code = 'cop'"><xsl:sequence select="'Koptisk'"/></xsl:when>
                    <xsl:when test="$code = 'cro'"><xsl:sequence select="'Kroatisk'"/></xsl:when>
                    <xsl:when test="$code = 'cus'"><xsl:sequence select="'Kusjittisk'"/></xsl:when>
                    <xsl:when test="$code = 'cze'"><xsl:sequence select="'Tsjekkisk'"/></xsl:when>
                    <xsl:when test="$code = 'dan'"><xsl:sequence select="'Dansk'"/></xsl:when>
                    <xsl:when test="$code = 'dut'"><xsl:sequence select="'Nederlandsk'"/></xsl:when>
                    <xsl:when test="$code = 'dzo'"><xsl:sequence select="'Dzongkha'"/></xsl:when>
                    <xsl:when test="$code = 'egy'"><xsl:sequence select="'Egyptisk'"/></xsl:when>
                    <xsl:when test="$code = 'eng'"><xsl:sequence select="'Engelsk'"/></xsl:when>
                    <xsl:when test="$code = 'enm'"><xsl:sequence select="'Mellomengelsk'"/></xsl:when>
                    <xsl:when test="$code = 'epo'"><xsl:sequence select="'Esperanto'"/></xsl:when>
                    <xsl:when test="$code = 'esk'"><xsl:sequence select="'Eskimospråk'"/></xsl:when>
                    <xsl:when test="$code = 'esp'"><xsl:sequence select="'Esperanto'"/></xsl:when>
                    <xsl:when test="$code = 'est'"><xsl:sequence select="'Estisk'"/></xsl:when>
                    <xsl:when test="$code = 'eth'"><xsl:sequence select="'Etiopisk'"/></xsl:when>
                    <xsl:when test="$code = 'ewe'"><xsl:sequence select="'Ewe'"/></xsl:when>
                    <xsl:when test="$code = 'fao'"><xsl:sequence select="'Færøysk'"/></xsl:when>
                    <xsl:when test="$code = 'far'"><xsl:sequence select="'Færøysk'"/></xsl:when>
                    <xsl:when test="$code = 'fat'"><xsl:sequence select="'Fante'"/></xsl:when>
                    <xsl:when test="$code = 'fij'"><xsl:sequence select="'Fijiansk'"/></xsl:when>
                    <xsl:when test="$code = 'fin'"><xsl:sequence select="'Finsk'"/></xsl:when>
                    <xsl:when test="$code = 'fiu'"><xsl:sequence select="'Finsk-ugrisk'"/></xsl:when>
                    <xsl:when test="$code = 'fkv'"><xsl:sequence select="'Kvensk'"/></xsl:when>
                    <xsl:when test="$code = 'fre'"><xsl:sequence select="'Fransk'"/></xsl:when>
                    <xsl:when test="$code = 'fri'"><xsl:sequence select="'Frisisk'"/></xsl:when>
                    <xsl:when test="$code = 'frm'"><xsl:sequence select="'Mellomfransk'"/></xsl:when>
                    <xsl:when test="$code = 'fro'"><xsl:sequence select="'Gammelfransk'"/></xsl:when>
                    <xsl:when test="$code = 'fry'"><xsl:sequence select="'Frisisk'"/></xsl:when>
                    <xsl:when test="$code = 'ful'"><xsl:sequence select="'Fulfulde'"/></xsl:when>
                    <xsl:when test="$code = 'gae'"><xsl:sequence select="'Gælisk'"/></xsl:when>
                    <xsl:when test="$code = 'gag'"><xsl:sequence select="'Galisisk'"/></xsl:when>
                    <xsl:when test="$code = 'geo'"><xsl:sequence select="'Georgisk'"/></xsl:when>
                    <xsl:when test="$code = 'ger'"><xsl:sequence select="'Tysk'"/></xsl:when>
                    <xsl:when test="$code = 'gez'"><xsl:sequence select="'Etiopisk'"/></xsl:when>
                    <xsl:when test="$code = 'gla'"><xsl:sequence select="'Skotsk-gælisk'"/></xsl:when>
                    <xsl:when test="$code = 'gle'"><xsl:sequence select="'Irsk'"/></xsl:when>
                    <xsl:when test="$code = 'glg'"><xsl:sequence select="'Galisisk'"/></xsl:when>
                    <xsl:when test="$code = 'gmh'"><xsl:sequence select="'Middelhøytysk'"/></xsl:when>
                    <xsl:when test="$code = 'got'"><xsl:sequence select="'Gotisk'"/></xsl:when>
                    <xsl:when test="$code = 'grc'"><xsl:sequence select="'Gammelgresk'"/></xsl:when>
                    <xsl:when test="$code = 'gre'"><xsl:sequence select="'Gresk'"/></xsl:when>
                    <xsl:when test="$code = 'guj'"><xsl:sequence select="'Gujarati'"/></xsl:when>
                    <xsl:when test="$code = 'hau'"><xsl:sequence select="'Hausa'"/></xsl:when>
                    <xsl:when test="$code = 'heb'"><xsl:sequence select="'Hebraisk'"/></xsl:when>
                    <xsl:when test="$code = 'hil'"><xsl:sequence select="'Hiligaynon'"/></xsl:when>
                    <xsl:when test="$code = 'hin'"><xsl:sequence select="'Hindi'"/></xsl:when>
                    <xsl:when test="$code = 'hit'"><xsl:sequence select="'Hettittisk'"/></xsl:when>
                    <xsl:when test="$code = 'hrv'"><xsl:sequence select="'Kroatisk'"/></xsl:when>
                    <xsl:when test="$code = 'hun'"><xsl:sequence select="'Ungarsk'"/></xsl:when>
                    <xsl:when test="$code = 'ibo'"><xsl:sequence select="'Ibo'"/></xsl:when>
                    <xsl:when test="$code = 'ice'"><xsl:sequence select="'Islandsk'"/></xsl:when>
                    <xsl:when test="$code = 'iku'"><xsl:sequence select="'Inuittisk'"/></xsl:when>
                    <xsl:when test="$code = 'ilo'"><xsl:sequence select="'Iloko'"/></xsl:when>
                    <xsl:when test="$code = 'ind'"><xsl:sequence select="'Indonesisk'"/></xsl:when>
                    <xsl:when test="$code = 'ipk'"><xsl:sequence select="'Inupiak'"/></xsl:when>
                    <xsl:when test="$code = 'ira'"><xsl:sequence select="'Iransk'"/></xsl:when>
                    <xsl:when test="$code = 'iri'"><xsl:sequence select="'Irsk'"/></xsl:when>
                    <xsl:when test="$code = 'ita'"><xsl:sequence select="'Italiensk'"/></xsl:when>
                    <xsl:when test="$code = 'jpn'"><xsl:sequence select="'Japansk'"/></xsl:when>
                    <xsl:when test="$code = 'kal'"><xsl:sequence select="'Grønlandsk'"/></xsl:when>
                    <xsl:when test="$code = 'khm'"><xsl:sequence select="'Khmer'"/></xsl:when>
                    <xsl:when test="$code = 'kho'"><xsl:sequence select="'Khotanesisk'"/></xsl:when>
                    <xsl:when test="$code = 'kin'"><xsl:sequence select="'Kinyarwanda'"/></xsl:when>
                    <xsl:when test="$code = 'kmr'"><xsl:sequence select="'Kurmanji'"/></xsl:when>
                    <xsl:when test="$code = 'kon'"><xsl:sequence select="'Kongo'"/></xsl:when>
                    <xsl:when test="$code = 'kor'"><xsl:sequence select="'Koreansk'"/></xsl:when>
                    <xsl:when test="$code = 'krj'"><xsl:sequence select="'Karelsk'"/></xsl:when>
                    <xsl:when test="$code = 'kua'"><xsl:sequence select="'Kuanyama'"/></xsl:when>
                    <xsl:when test="$code = 'kur'"><xsl:sequence select="'Kurdisk'"/></xsl:when>
                    <xsl:when test="$code = 'lae'"><xsl:sequence select="'Østsamisk'"/></xsl:when>
                    <xsl:when test="$code = 'laf'"><xsl:sequence select="'Nordsamisk'"/></xsl:when>
                    <xsl:when test="$code = 'lai'"><xsl:sequence select="'Inarisamisk'"/></xsl:when>
                    <xsl:when test="$code = 'lak'"><xsl:sequence select="'Skoltesamisk'"/></xsl:when>
                    <xsl:when test="$code = 'lal'"><xsl:sequence select="'Lulesamisk'"/></xsl:when>
                    <xsl:when test="$code = 'lao'"><xsl:sequence select="'Laotisk'"/></xsl:when>
                    <xsl:when test="$code = 'lap'"><xsl:sequence select="'Samisk'"/></xsl:when>
                    <xsl:when test="$code = 'las'"><xsl:sequence select="'Sørsamisk'"/></xsl:when>
                    <xsl:when test="$code = 'lat'"><xsl:sequence select="'Latin'"/></xsl:when>
                    <xsl:when test="$code = 'lav'"><xsl:sequence select="'Latvisk'"/></xsl:when>
                    <xsl:when test="$code = 'lit'"><xsl:sequence select="'Litauisk'"/></xsl:when>
                    <xsl:when test="$code = 'mac'"><xsl:sequence select="'Makedonsk'"/></xsl:when>
                    <xsl:when test="$code = 'mao'"><xsl:sequence select="'Maori'"/></xsl:when>
                    <xsl:when test="$code = 'mar'"><xsl:sequence select="'Marathi'"/></xsl:when>
                    <xsl:when test="$code = 'may'"><xsl:sequence select="'Malayisk'"/></xsl:when>
                    <xsl:when test="$code = 'mla'"><xsl:sequence select="'Madagassisk'"/></xsl:when>
                    <xsl:when test="$code = 'mlg'"><xsl:sequence select="'Madagassisk'"/></xsl:when>
                    <xsl:when test="$code = 'mnk'"><xsl:sequence select="'Mandinka'"/></xsl:when>
                    <xsl:when test="$code = 'mol'"><xsl:sequence select="'Moldavisk'"/></xsl:when>
                    <xsl:when test="$code = 'mon'"><xsl:sequence select="'Mongolsk'"/></xsl:when>
                    <xsl:when test="$code = 'myn'"><xsl:sequence select="'Maya'"/></xsl:when>
                    <xsl:when test="$code = 'nah'"><xsl:sequence select="'Nahuatl'"/></xsl:when>
                    <xsl:when test="$code = 'nbl'"><xsl:sequence select="'Ndebele'"/></xsl:when>
                    <xsl:when test="$code = 'nde'"><xsl:sequence select="'Ndebele'"/></xsl:when>
                    <xsl:when test="$code = 'nds'"><xsl:sequence select="'Nedertysk'"/></xsl:when>
                    <xsl:when test="$code = 'nep'"><xsl:sequence select="'Nepali'"/></xsl:when>
                    <xsl:when test="$code = 'nic'"><xsl:sequence select="'Niger-Kongospråk'"/></xsl:when>
                    <xsl:when test="$code = 'oci'"><xsl:sequence select="'Provençalsk'"/></xsl:when>
                    <xsl:when test="$code = 'orm'"><xsl:sequence select="'Oromo'"/></xsl:when>
                    <xsl:when test="$code = 'pan'"><xsl:sequence select="'Panjabi'"/></xsl:when>
                    <xsl:when test="$code = 'per'"><xsl:sequence select="'Persisk'"/></xsl:when>
                    <xsl:when test="$code = 'pli'"><xsl:sequence select="'Pali'"/></xsl:when>
                    <xsl:when test="$code = 'pol'"><xsl:sequence select="'Polsk'"/></xsl:when>
                    <xsl:when test="$code = 'por'"><xsl:sequence select="'Portugisisk'"/></xsl:when>
                    <xsl:when test="$code = 'pra'"><xsl:sequence select="'Prakrit'"/></xsl:when>
                    <xsl:when test="$code = 'pro'"><xsl:sequence select="'Provençalsk'"/></xsl:when>
                    <xsl:when test="$code = 'prs'"><xsl:sequence select="'Dari'"/></xsl:when>
                    <xsl:when test="$code = 'pus'"><xsl:sequence select="'Pashto'"/></xsl:when>
                    <xsl:when test="$code = 'roh'"><xsl:sequence select="'Retoromansk'"/></xsl:when>
                    <xsl:when test="$code = 'rom'"><xsl:sequence select="'Romani'"/></xsl:when>
                    <xsl:when test="$code = 'rum'"><xsl:sequence select="'Rumensk'"/></xsl:when>
                    <xsl:when test="$code = 'run'"><xsl:sequence select="'Rundi'"/></xsl:when>
                    <xsl:when test="$code = 'rus'"><xsl:sequence select="'Russisk'"/></xsl:when>
                    <xsl:when test="$code = 'sah'"><xsl:sequence select="'Jakutisk'"/></xsl:when>
                    <xsl:when test="$code = 'san'"><xsl:sequence select="'Sanskrit'"/></xsl:when>
                    <xsl:when test="$code = 'sao'"><xsl:sequence select="'Samoansk'"/></xsl:when>
                    <xsl:when test="$code = 'sat'"><xsl:sequence select="'Santali'"/></xsl:when>
                    <xsl:when test="$code = 'scc'"><xsl:sequence select="'Serbokroatisk'"/></xsl:when>
                    <xsl:when test="$code = 'sco'"><xsl:sequence select="'Lavskotsk'"/></xsl:when>
                    <xsl:when test="$code = 'scr'"><xsl:sequence select="'Serbokroatisk'"/></xsl:when>
                    <xsl:when test="$code = 'ser'"><xsl:sequence select="'Serbisk'"/></xsl:when>
                    <xsl:when test="$code = 'sgn'"><xsl:sequence select="'Tegnspråk'"/></xsl:when>
                    <xsl:when test="$code = 'sin'"><xsl:sequence select="'Singalesisk'"/></xsl:when>
                    <xsl:when test="$code = 'sit'"><xsl:sequence select="'Sino-tibetansk'"/></xsl:when>
                    <xsl:when test="$code = 'slo'"><xsl:sequence select="'Slovakisk'"/></xsl:when>
                    <xsl:when test="$code = 'slv'"><xsl:sequence select="'Slovensk'"/></xsl:when>
                    <xsl:when test="$code = 'sma'"><xsl:sequence select="'Sørsamisk'"/></xsl:when>
                    <xsl:when test="$code = 'sme'"><xsl:sequence select="'Nordsamisk'"/></xsl:when>
                    <xsl:when test="$code = 'smi'"><xsl:sequence select="'Samisk'"/></xsl:when>
                    <xsl:when test="$code = 'smj'"><xsl:sequence select="'Lulesamisk'"/></xsl:when>
                    <xsl:when test="$code = 'smn'"><xsl:sequence select="'Inarisamisk'"/></xsl:when>
                    <xsl:when test="$code = 'smo'"><xsl:sequence select="'Samoansk'"/></xsl:when>
                    <xsl:when test="$code = 'sms'"><xsl:sequence select="'Skoltesamisk'"/></xsl:when>
                    <xsl:when test="$code = 'sna'"><xsl:sequence select="'Shona'"/></xsl:when>
                    <xsl:when test="$code = 'snd'"><xsl:sequence select="'Sindhi'"/></xsl:when>
                    <xsl:when test="$code = 'snh'"><xsl:sequence select="'Singalesisk'"/></xsl:when>
                    <xsl:when test="$code = 'som'"><xsl:sequence select="'Somali'"/></xsl:when>
                    <xsl:when test="$code = 'spa'"><xsl:sequence select="'Spansk'"/></xsl:when>
                    <xsl:when test="$code = 'srp'"><xsl:sequence select="'Serbisk'"/></xsl:when>
                    <xsl:when test="$code = 'sux'"><xsl:sequence select="'Sumerisk'"/></xsl:when>
                    <xsl:when test="$code = 'swa'"><xsl:sequence select="'Swahili'"/></xsl:when>
                    <xsl:when test="$code = 'swe'"><xsl:sequence select="'Svensk'"/></xsl:when>
                    <xsl:when test="$code = 'syr'"><xsl:sequence select="'Syrisk'"/></xsl:when>
                    <xsl:when test="$code = 'tag'"><xsl:sequence select="'Tagalog'"/></xsl:when>
                    <xsl:when test="$code = 'tam'"><xsl:sequence select="'Tamil'"/></xsl:when>
                    <xsl:when test="$code = 'tgl'"><xsl:sequence select="'Tagalog'"/></xsl:when>
                    <xsl:when test="$code = 'tha'"><xsl:sequence select="'Thai'"/></xsl:when>
                    <xsl:when test="$code = 'tib'"><xsl:sequence select="'Tibetansk'"/></xsl:when>
                    <xsl:when test="$code = 'tir'"><xsl:sequence select="'Tigrinja'"/></xsl:when>
                    <xsl:when test="$code = 'tkl'"><xsl:sequence select="'Tokelaisk'"/></xsl:when>
                    <xsl:when test="$code = 'ton'"><xsl:sequence select="'Tongansk'"/></xsl:when>
                    <xsl:when test="$code = 'tur'"><xsl:sequence select="'Tyrkisk'"/></xsl:when>
                    <xsl:when test="$code = 'twi'"><xsl:sequence select="'Twi'"/></xsl:when>
                    <xsl:when test="$code = 'uig'"><xsl:sequence select="'Uigurisk'"/></xsl:when>
                    <xsl:when test="$code = 'ukr'"><xsl:sequence select="'Ukrainsk'"/></xsl:when>
                    <xsl:when test="$code = 'urd'"><xsl:sequence select="'Urdu'"/></xsl:when>
                    <xsl:when test="$code = 'uzb'"><xsl:sequence select="'Usbekisk'"/></xsl:when>
                    <xsl:when test="$code = 'vie'"><xsl:sequence select="'Vietnamesisk'"/></xsl:when>
                    <xsl:when test="$code = 'wel'"><xsl:sequence select="'Walisisk'"/></xsl:when>
                    <xsl:when test="$code = 'wen'"><xsl:sequence select="'Sorbisk'"/></xsl:when>
                    <xsl:when test="$code = 'xho'"><xsl:sequence select="'Xhosa'"/></xsl:when>
                    <xsl:when test="$code = 'yid'"><xsl:sequence select="'Jiddish'"/></xsl:when>
                    <xsl:when test="$code = 'yor'"><xsl:sequence select="'Yoruba'"/></xsl:when>
                    <xsl:when test="$code = 'ypk'"><xsl:sequence select="'Yupikspråk'"/></xsl:when>
                    <xsl:when test="$code = 'zul'"><xsl:sequence select="'Zulu'"/></xsl:when>
                    
                    <xsl:when test="$code = ('nno','nob') and $codes = 'nno' and $codes = 'nob'"><xsl:sequence select="'Norsk'"/></xsl:when>
                    <xsl:when test="$code = 'nor' and not($codes = ('nob','nno'))"><xsl:sequence select="'Norsk'"/></xsl:when>
                    
                    <xsl:when test="$code = 'nno'"><xsl:sequence select="'Nynorsk'"/></xsl:when>
                    <xsl:when test="$code = 'nob'"><xsl:sequence select="'Bokmål'"/></xsl:when>
                    <xsl:when test="$code = 'nom'"><xsl:sequence select="'Mellomnorsk'"/></xsl:when>
                    <xsl:when test="$code = 'non'"><xsl:sequence select="'Norrønt'"/></xsl:when>
                    
                    <xsl:when test="$code = 'mul'"><xsl:sequence select="'Flerspråklig'"/></xsl:when>
                    <xsl:otherwise><xsl:sequence select="()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($names-unfiltered)">
            <xsl:sort/>
            <xsl:choose>
                <xsl:when test=". = 'Flerspråklig'">
                    <xsl:if test="count($names-unfiltered[not(.=('Flerspråklig','Bokmål','Nynorsk','Norsk'))]) &gt; 0 or count($names-unfiltered[not(.=('Flerspråklig'))]) = 0">
                        <!-- Must include something more than 'Norsk'/'Bokmål'/'Nynorsk' to be 'Flerspråklig' -->
                        <xsl:sequence select="."/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
</xsl:stylesheet>
