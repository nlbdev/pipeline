<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:nlb="http://www.nlb.no/ns/pipeline/xslt"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:param name="braille-standard" select="'(dots:6)(grade:0)'"/>
    <xsl:param name="notes-placement" select="''"/>
    <xsl:param name="page-width" select="'32'"/>
    <xsl:param name="page-height" select="'28'"/>
    
    <xsl:variable name="contraction-grade" select="replace($braille-standard, '.*\(grade:(.*)\).*', '$1')"/>
    <xsl:variable name="line-width" select="xs:integer($page-width) - 6"/>
    
    <xsl:variable name="html-namespace" select="'http://www.w3.org/1999/xhtml'"/>
    <xsl:variable name="dtbook-namespace" select="'http://www.daisy.org/z3986/2005/dtbook/'"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:body[not(preceding::html:body)]">
        <xsl:call-template name="generate-titlepage"/>
        <xsl:call-template name="generate-about"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="html:html[not(html:body)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="generate-titlepage"/>
            <xsl:call-template name="generate-about"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="dtbook:book[not(dtbook:frontmatter)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="frontmatter" namespace="{namespace-uri()}">
                <xsl:call-template name="generate-titlepage"/>
                <xsl:call-template name="generate-about"/>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="dtbook:frontmatter">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node() except dtbook:level1[1]/(. | following-sibling::node())"/>
            <xsl:call-template name="generate-titlepage"/>
            <xsl:call-template name="generate-about"/>
            <xsl:apply-templates select="dtbook:level1[1]/(. | following-sibling::node())"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- remove existing titlepage if present -->
    <xsl:template match="dtbook:frontmatter/dtbook:level1[tokenize(@class,'\s+') = 'titlepage']"/>
    <xsl:template match="html:body[tokenize(@class,'\s+') = 'titlepage' or tokenize(@epub:type,'\s+') = 'titlepage']"/>

    <xsl:template name="generate-titlepage">
        <xsl:variable name="namespace-uri" select="namespace-uri()"/>
        
        <xsl:variable name="author" as="xs:string*">
            <xsl:choose>
                <xsl:when test="$namespace-uri = $dtbook-namespace">
                    <xsl:sequence select="/*/dtbook:head/dtbook:meta[@name = 'dc:Creator']/string(@content)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="/*/html:head/html:meta[@name='dc:creator']/string(@content)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="title" as="xs:string">
            <xsl:choose>
                <xsl:when test="$namespace-uri = $dtbook-namespace">
                    <xsl:sequence select="string((/*/dtbook:head/dtbook:meta[@name = 'dc:Title'])[1]/@content)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="string((/*/html:head/html:title)[1]/text())"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="translator" as="xs:string*">
            <xsl:choose>
                <xsl:when test="$namespace-uri = $dtbook-namespace">
                    <xsl:sequence select="/*/dtbook:head/dtbook:meta[@name = 'dc:Contributor' and @role = 'translator' or @name = 'marcrel:trl']/string(@content)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="/*/html:head/html:meta[@name = 'marcrel:trl']/string(@content)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="original-publisher" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$namespace-uri = $dtbook-namespace">
                    <xsl:sequence select="/*/dtbook:book/dtbook:frontmatter/dtbook:level1[tokenize(@class,'\s+')='colophon']/dtbook:p[not(*) and starts-with(text(),'&#x00A9;')]/replace(text(),'^&#x00A9;\s+','')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="/*/html:body[(tokenize(@class,'\s+'),tokenize(@epub:type,'\s+'))='colophon']/html:p[not(*) and starts-with(text(),'&#x00A9;')]/replace(text(),'^&#x00A9;\s+','')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="original-isbn" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$namespace-uri = $dtbook-namespace">
                    <xsl:sequence select="/*/dtbook:book/dtbook:frontmatter/dtbook:level1[tokenize(@class,'\s+')='colophon']/dtbook:p[not(*) and matches(text(),'^(ISBN\s*)?[\d-]+$')]/replace(text(),'^(ISBN\s*)?([\d-]+)$','$1')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="/*/html:body[(tokenize(@class,'\s+'),tokenize(@epub:type,'\s+'))='colophon']/dtbook:p[not(*) and matches(text(),'^(ISBN\s*)?[\d-]+$')]/replace(text(),'^(ISBN\s*)?([\d-]+)$','$1')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:element name="{if ($namespace-uri = $dtbook-namespace) then 'level1' else 'body'}" namespace="{$namespace-uri}">
            <xsl:attribute name="class" select="'pef-titlepage'"/>
            
            <!-- 3 empty rows before author -->
            <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            <xsl:variable name="lines-used" select="3"/>
            
            <xsl:variable name="author-lines" select="nlb:author-lines($author, 3, $line-width, 'mfl.')"/>
            <xsl:for-each select="$author-lines">
                <xsl:call-template name="row">
                    <xsl:with-param name="content" select="."/>
                    <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
                </xsl:call-template>
            </xsl:for-each>
            
            <!-- 2 empty rows before title -->
            <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            <xsl:variable name="lines-used" select="$lines-used + count($author-lines) + 2"/>
            
            <xsl:variable name="title-lines" select="nlb:title-lines($title, 5, $line-width)"/>
            <xsl:for-each select="$title-lines">
                <xsl:call-template name="row">
                    <xsl:with-param name="content" select="."/>
                    <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
                </xsl:call-template>
            </xsl:for-each>
            
            <!-- 2 empty rows before translator -->
            <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            <xsl:variable name="lines-used" select="$lines-used + count($title-lines) + 2"/>
            
            <xsl:variable name="translator-lines" select="nlb:author-lines($translator, 2, $line-width, 'mfl.')"/>
            <xsl:if test="count($translator-lines)">
                <xsl:call-template name="row">
                    <xsl:with-param name="content" select="'Oversatt av:'"/>
                    <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
                </xsl:call-template>
                
                <xsl:for-each select="$translator-lines">
                    <xsl:call-template name="row">
                        <xsl:with-param name="content" select="."/>
                        <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
                    </xsl:call-template>
                </xsl:for-each>
                
                <!-- 2 empty rows after translators -->
                <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
                <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            </xsl:if>
            <xsl:variable name="lines-used" select="if (count($translator-lines)) then $lines-used + 1 + count($author-lines) + 2 else $lines-used"/>
            
            <!-- fill empty lines up to and including page height minus 6 (i.e. row 22) -->
            <xsl:for-each select="($lines-used + 1) to xs:integer($page-height) - 6">
                <xsl:call-template name="empty-row">
                    <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
                </xsl:call-template>
            </xsl:for-each>

            <xsl:variable name="nlb-year" as="xs:string">
                <xsl:value-of select="concat('NLB - ',format-dateTime(current-dateTime(), '[Y]'))"/>
            </xsl:variable>
            <xsl:call-template name="row">
                <xsl:with-param name="content" select="$nlb-year"/>
                <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
            </xsl:call-template>
            
            <xsl:variable name="grade-text" as="xs:string">
                <xsl:choose>
                    <xsl:when test="$contraction-grade = '0'">
                        <xsl:text>Fullskrift</xsl:text>
                    </xsl:when>
                    <xsl:when test="$contraction-grade = '1'">
                        <xsl:text>Kortskrift 1</xsl:text>
                    </xsl:when>
                    <xsl:when test="$contraction-grade = '2'">
                        <xsl:text>Kortskrift 2</xsl:text>
                    </xsl:when>
                    <xsl:when test="$contraction-grade = '3'">
                        <xsl:text>Kortskrift 3</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text><![CDATA[]]></xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="row">
                <xsl:with-param name="content" select="$grade-text"/>
                <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
            </xsl:call-template>
            
            <!-- 2 empty rows before volume number -->
            <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            <xsl:call-template name="empty-row"><xsl:with-param name="namespace-uri" select="$namespace-uri"/></xsl:call-template>
            
            <xsl:call-template name="row">
                <xsl:with-param name="content" select="' av '"/>
                <xsl:with-param name="classes" select="'pef-volume'"/>
                <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="generate-about">
        <xsl:variable name="namespace-uri" select="namespace-uri()"/>
        
        <xsl:element name="{if ($namespace-uri = $dtbook-namespace) then 'level1' else 'body'}" namespace="{$namespace-uri}">
            <xsl:attribute name="class" select="'pef-about'"/>
            <xsl:element name="h1" namespace="{$namespace-uri}">
                <xsl:text>Om boka</xsl:text>
            </xsl:element>

            <xsl:if test="count(//dtbook:note | //@epub:type[tokenize(.,'\s+') = ('note','footnote','endnote','rearnote')])">
                <!-- TODO: handle fallback mechanism for footnotes (bottom-of-page = end-of-volume) -->
                <xsl:variable name="notes-placement" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$notes-placement = 'bottom-of-page'">
                            <xsl:text>Noter er plassert nederst på hver side.</xsl:text>
                        </xsl:when>
                        <xsl:when test="$notes-placement = 'end-of-volume'">
                            <xsl:text>Noter er plassert i slutten av hvert hefte.</xsl:text>
                        </xsl:when>
                        <xsl:when test="$notes-placement = 'end-of-book'">
                            <xsl:text>Noter er plassert bakerst i boken.</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="row">
                    <xsl:with-param name="content" select="$notes-placement"/>
                    <xsl:with-param name="classes" select="'notes-placement'"/>
                    <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
                </xsl:call-template>
            </xsl:if>
            
            <xsl:call-template name="row">
                <xsl:with-param name="content" select="'Antall sider: '"/>
                <xsl:with-param name="classes" select="'pef-pages'"/>
                <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
            </xsl:call-template>
            
            <xsl:call-template name="row">
                <xsl:with-param name="content" select="'Boka skal ikke returneres.'"/>
                <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
            </xsl:call-template>
            <xsl:call-template name="row">
                <xsl:with-param name="content" select="'Feil eller mangler kan meldes til punkt@nlb.no.'"/>
                <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
            </xsl:call-template>
            
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="empty-row" as="element()">
        <xsl:param name="namespace-uri" as="xs:string"/>
        <xsl:call-template name="row">
            <xsl:with-param name="content" select="'&#160;'"/>
            <xsl:with-param name="namespace-uri" select="$namespace-uri"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="row" as="element()">
        <xsl:param name="content" as="xs:string"/>
        <xsl:param name="classes" as="xs:string*"/>
        <xsl:param name="namespace-uri" as="xs:string"/>
        <xsl:element name="p" namespace="{$namespace-uri}">
            <xsl:if test="$classes">
                <xsl:attribute name="class" select="string-join($classes,' ')"/>
            </xsl:if>
            <xsl:value-of select="$content"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="nlb:strings-to-lines-always-break" as="xs:string*">
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:param name="line-length" as="xs:integer"/>
        <xsl:param name="try-length" as="xs:integer"/>
        
        <xsl:variable name="result" as="xs:string*">
            <xsl:analyze-string select="string-join($strings,' ')" regex=".{concat('{',$try-length,'}')}">
                <xsl:matching-substring>
                    <xsl:sequence select="."/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:sequence select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        <xsl:sequence select="if ($try-length &gt; 1 and count($result[nlb:braille-length(.) &gt; $line-length])) then nlb:strings-to-lines-always-break($strings, $line-length, $try-length - 1) else $result"/>
    </xsl:function>
    
    <xsl:function name="nlb:strings-to-lines" as="xs:string*">
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:param name="line-length" as="xs:integer"/>
        <xsl:param name="break-words" as="xs:string"/> <!-- never | avoid | always -->
        
        <xsl:if test="not($break-words = ('never','avoid','always'))">
            <xsl:message select="concat('in nlb:strings-to-lines, the break-words parameter must be either ''never'', ''avoid'', or ''always''. Was: ''',$break-words,'''')" terminate="yes"/>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="$break-words = 'always'">
                <xsl:sequence select="nlb:strings-to-lines-always-break($strings, $line-length, $line-length)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$break-words = 'never' and count($strings[nlb:braille-length(.) &gt; $line-length])">
                        <xsl:sequence select="()"/>
                    </xsl:when>
                    <xsl:when test="nlb:braille-length($strings[1]) &gt; $line-length">
                        <xsl:variable name="braille-extras" select="max((floor($line-length div 3),nlb:braille-length($strings[1]) - string-length($strings[1])))"/>
                        <xsl:sequence select="nlb:strings-to-lines((tokenize(replace($strings[1],concat('^(.{',$line-length - $braille-extras,'})'),'$1 '),' '), $strings[position() &gt; 1]), $line-length, $break-words)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="first-line" as="xs:string?">
                            <xsl:variable name="potential-lines" as="xs:string*">
                                <xsl:for-each select="reverse(1 to count($strings))">
                                    <xsl:sequence select="string-join($strings[position() &lt;= current()],' ')"/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:sequence select="($potential-lines[nlb:braille-length(.) &lt;= $line-length])[1]"/>
                        </xsl:variable>
                        <xsl:sequence select="$first-line"/>
                        
                        <xsl:variable name="remaining-strings" select="$strings[position() &gt; count(tokenize($first-line,'\s+'))]"/>
                        <xsl:if test="count($remaining-strings)">
                            <xsl:sequence select="nlb:strings-to-lines($remaining-strings, $line-length, $break-words)"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="nlb:fit-name-to-lines" as="xs:string*">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="lines-available" as="xs:integer"/>
        <xsl:param name="line-length" as="xs:integer"/>
        
        <xsl:variable name="tokenized-name" select="tokenize($name,'\s+')"/>
        
        <xsl:variable name="last-name" select="if (contains($name,',')) then substring-before($name,',') else $tokenized-name[position() &gt; 1][last()]"/>
        <xsl:variable name="first-name" select="if (contains($name,',')) then tokenize(normalize-space(substring-after($name,',')),'\s+')[1] else $tokenized-name[1]"/>
        <xsl:variable name="middle-name" select="if (contains($name,',')) then tokenize(normalize-space(substring-after($name,',')),'\s+')[position() &gt; 1] else $tokenized-name[not(position() = (1,last()))]"/>
        
        <xsl:variable name="first-name-initials" select="for $n in ($first-name) return concat(substring($n,1,1),'.')"/>
        <xsl:variable name="middle-name-initials" select="for $n in ($middle-name) return concat(substring($n,1,1),'.')"/>
        
        <xsl:variable name="tokenized-name-middle-initials" select="tokenize(if (contains($name,',')) then string-join((string-join($last-name,' '),string-join(($first-name, $middle-name-initials),' ')),',') else string-join(($first-name, $middle-name-initials, $last-name),' '),' ')"/>
        <xsl:variable name="tokenized-name-first-and-middle-initials" select="tokenize(if (contains($name,',')) then string-join((string-join($last-name,' '),string-join(($first-name-initials, $middle-name-initials),' ')),',') else string-join(($first-name-initials, $middle-name-initials, $last-name),' '),' ')"/>
        <xsl:variable name="tokenized-name-no-middle" select="tokenize(if (contains($name,',')) then string-join((string-join($last-name,' '),string-join(($first-name),' ')),',') else string-join(($first-name, $last-name),' '),' ')"/>
        
        <xsl:variable name="full-name-never-break" select="nlb:strings-to-lines($tokenized-name, $line-length, 'never')"/>
        <xsl:variable name="full-name-avoid-break" select="nlb:strings-to-lines($tokenized-name, $line-length, 'avoid')"/>
        <xsl:variable name="full-name-always-break" select="nlb:strings-to-lines($tokenized-name, $line-length, 'always')"/>
        <xsl:variable name="full-name-stripped" select="nlb:strip-last-line($full-name-avoid-break, $lines-available, $line-length)"/>
        
        <xsl:variable name="middle-initials-never-break" select="nlb:strings-to-lines($tokenized-name-middle-initials, $line-length, 'never')"/>
        <xsl:variable name="middle-initials-avoid-break" select="nlb:strings-to-lines($tokenized-name-middle-initials, $line-length, 'avoid')"/>
        <xsl:variable name="middle-initials-always-break" select="nlb:strings-to-lines($tokenized-name-middle-initials, $line-length, 'always')"/>
        
        <xsl:variable name="first-and-middle-initials-never-break" select="nlb:strings-to-lines($tokenized-name-first-and-middle-initials, $line-length, 'never')"/>
        <xsl:variable name="first-and-middle-initials-avoid-break" select="nlb:strings-to-lines($tokenized-name-first-and-middle-initials, $line-length, 'avoid')"/>
        <xsl:variable name="first-and-middle-initials-always-break" select="nlb:strings-to-lines($tokenized-name-first-and-middle-initials, $line-length, 'always')"/>
        
        <xsl:variable name="no-middle-never-break" select="nlb:strings-to-lines($tokenized-name-no-middle, $line-length, 'never')"/>
        <xsl:variable name="no-middle-avoid-break" select="nlb:strings-to-lines($tokenized-name-no-middle, $line-length, 'avoid')"/>
        <xsl:variable name="no-middle-always-break" select="nlb:strings-to-lines($tokenized-name-no-middle, $line-length, 'always')"/>
        
        <xsl:variable name="last-name-never-break" select="nlb:strings-to-lines($last-name, $line-length, 'never')"/>
        <xsl:variable name="last-name-avoid-break" select="nlb:strings-to-lines($last-name, $line-length, 'avoid')"/>
        <xsl:variable name="last-name-always-break" select="nlb:strings-to-lines($last-name, $line-length, 'always')"/>
        <xsl:variable name="last-name-stripped" select="nlb:strip-last-line($last-name-avoid-break, $lines-available, $line-length)"/>
        
        <xsl:choose>
            <xsl:when test="count($full-name-never-break) &gt; 0 and count($full-name-never-break) &lt;= $lines-available">
                <xsl:sequence select="$full-name-never-break"/>
            </xsl:when>
            <xsl:when test="count($full-name-avoid-break) &gt; 0 and count($full-name-avoid-break) &lt;= $lines-available">
                <xsl:sequence select="$full-name-avoid-break"/>
            </xsl:when>
            <xsl:when test="count($full-name-always-break) &gt; 0 and count($full-name-always-break) &lt;= $lines-available">
                <xsl:sequence select="$full-name-always-break"/>
            </xsl:when>
            <xsl:when test="count($middle-initials-never-break) &gt; 0 and count($middle-initials-never-break) &lt;= $lines-available">
                <xsl:sequence select="$middle-initials-never-break"/>
            </xsl:when>
            <xsl:when test="count($middle-initials-avoid-break) &gt; 0 and count($middle-initials-avoid-break) &lt;= $lines-available">
                <xsl:sequence select="$middle-initials-avoid-break"/>
            </xsl:when>
            <xsl:when test="count($middle-initials-always-break) &gt; 0 and count($middle-initials-always-break) &lt;= $lines-available">
                <xsl:sequence select="$middle-initials-always-break"/>
            </xsl:when>
            <xsl:when test="count($first-and-middle-initials-never-break) &gt; 0 and count($first-and-middle-initials-never-break) &lt;= $lines-available">
                <xsl:sequence select="$first-and-middle-initials-never-break"/>
            </xsl:when>
            <xsl:when test="count($first-and-middle-initials-avoid-break) &gt; 0 and count($first-and-middle-initials-avoid-break) &lt;= $lines-available">
                <xsl:sequence select="$first-and-middle-initials-avoid-break"/>
            </xsl:when>
            <xsl:when test="count($first-and-middle-initials-always-break) &gt; 0 and count($first-and-middle-initials-always-break) &lt;= $lines-available">
                <xsl:sequence select="$first-and-middle-initials-always-break"/>
            </xsl:when>
            <xsl:when test="count($no-middle-never-break) &gt; 0 and count($no-middle-never-break) &lt;= $lines-available">
                <xsl:sequence select="$no-middle-never-break"/>
            </xsl:when>
            <xsl:when test="count($no-middle-avoid-break) &gt; 0 and count($no-middle-avoid-break) &lt;= $lines-available">
                <xsl:sequence select="$no-middle-avoid-break"/>
            </xsl:when>
            <xsl:when test="count($no-middle-always-break) &gt; 0 and count($no-middle-always-break) &lt;= $lines-available">
                <xsl:sequence select="$no-middle-always-break"/>
            </xsl:when>
            <xsl:when test="count($last-name-never-break) &gt; 0 and count($last-name-never-break) &lt;= $lines-available">
                <xsl:sequence select="$last-name-never-break"/>
            </xsl:when>
            <xsl:when test="count($last-name-avoid-break) &gt; 0 and count($last-name-avoid-break) &lt;= $lines-available">
                <xsl:sequence select="$last-name-avoid-break"/>
            </xsl:when>
            <xsl:when test="count($last-name-always-break) &gt; 0 and count($last-name-always-break) &lt;= $lines-available">
                <xsl:sequence select="$last-name-always-break"/>
            </xsl:when>
            <xsl:when test="count($last-name-stripped) &gt; 0 and count($last-name-stripped) &lt;= $lines-available">
                <xsl:sequence select="$last-name-stripped"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$full-name-stripped"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- nlb:braille-length accounts for capital letter braille characters, and number characters -->
    <xsl:function name="nlb:braille-length">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="not($string)">
                <xsl:value-of select="0"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="expanded-string" select="replace($string,'[A-Z]','aa')"/>                            <!-- braille character before upper case characters -->
                <xsl:variable name="expanded-string" select="replace($expanded-string,'(^|[^\d])(\d)','$1.$2')"/>        <!-- braille character before numbers -->
                <xsl:variable name="expanded-string" select="replace($expanded-string,'([^a-zA-Z0-9 ,.;:!-])','$1$1')"/> <!-- special characters might be represented with two braille characters -->
                <xsl:value-of select="string-length($expanded-string)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="nlb:author-lines" as="xs:string*">
        <xsl:param name="authors" as="xs:string*"/>
        <xsl:param name="lines-available" as="xs:integer"/>
        <xsl:param name="line-length" as="xs:integer"/>
        <xsl:param name="last-line-if-cropped" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="count($authors) = 1">
                <xsl:sequence select="nlb:fit-name-to-lines($authors[1], $lines-available, $line-length)"/>
            </xsl:when>
            <xsl:when test="count($authors) = (2 to $lines-available)">
                <xsl:for-each select="$authors">
                    <xsl:sequence select="nlb:fit-name-to-lines(., 1, $line-length)"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="count($authors) &gt; $lines-available">
                <xsl:for-each select="$authors[position() = (1 to $lines-available - 1)]">
                    <xsl:sequence select="nlb:fit-name-to-lines(., 1, $line-length)"/>
                </xsl:for-each>
                <xsl:sequence select="$last-line-if-cropped"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="nlb:title-lines" as="xs:string*">
        <xsl:param name="title" as="xs:string"/>
        <xsl:param name="lines-available" as="xs:integer"/>
        <xsl:param name="line-length" as="xs:integer"/>
        
        <xsl:variable name="tokenized-title" select="tokenize($title,'\s+')"/>
        
        <xsl:variable name="title-never-break" select="nlb:strings-to-lines($tokenized-title, $line-length, 'never')"/>
        <xsl:variable name="title-avoid-break" select="nlb:strings-to-lines($tokenized-title, $line-length, 'avoid')"/>
        <xsl:variable name="title-always-break" select="nlb:strings-to-lines($tokenized-title, $line-length, 'always')"/>
        <xsl:variable name="title-stripped" select="nlb:strip-last-line($title-avoid-break, $lines-available, $line-length)"/>
        
        <xsl:choose>
            <xsl:when test="$title = ''">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="count($title-never-break) &gt; 0 and count($title-never-break) &lt;= $lines-available">
                <xsl:sequence select="$title-never-break"/>
            </xsl:when>
            <xsl:when test="count($title-avoid-break) &gt; 0 and count($title-avoid-break) &lt;= $lines-available">
                <xsl:sequence select="$title-avoid-break"/>
            </xsl:when>
            <xsl:when test="count($title-always-break) &gt; 0 and count($title-always-break) &lt;= $lines-available">
                <xsl:sequence select="$title-always-break"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$title-stripped"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="nlb:strip-last-line" as="xs:string*">
        <xsl:param name="lines" as="xs:string*"/>
        <xsl:param name="lines-available" as="xs:integer"/>
        <xsl:param name="line-length" as="xs:integer"/>
        
        <xsl:variable name="last-line" select="string-join($lines[$lines-available],' ')"/>
        <xsl:variable name="braille-extras" select="nlb:braille-length($last-line) - string-length($last-line)"/>
        <xsl:variable name="last-line" select="replace($last-line, concat('^(.{',$line-length - 3 - $braille-extras ,'}).*'), '$1')"/>
        <xsl:variable name="last-line" select="concat($last-line,'...')"/>
        
        <xsl:sequence select="($lines[position() &lt; $lines-available], $last-line)"/>
    </xsl:function>
    
</xsl:stylesheet>
