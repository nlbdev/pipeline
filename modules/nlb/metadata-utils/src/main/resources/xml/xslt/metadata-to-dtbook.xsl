<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:h="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.daisy.org/z3986/2005/dtbook/" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" exclude-result-prefixes="#all" version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:opf="http://www.idpf.org/2007/opf" xpath-default-namespace="http://www.idpf.org/2007/opf">

    <xsl:output indent="yes"/>
    <xsl:param name="level" select="'1'"/>
    <xsl:param name="extended" select="false()"/>
    <xsl:param name="include-field" select="''"/>
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
</xsl:stylesheet>
