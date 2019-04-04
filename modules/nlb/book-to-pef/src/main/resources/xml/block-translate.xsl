<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="#all">
	
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/transform/block-translator-template.xsl"/>
	
	<xsl:variable name="main-locale" select="'no'"/>
	
	<xsl:variable name="text-transform-defs" as="element()*">
		<!--
		    Note: requires that the @text-transform rules are defined in the style attribute of the
		    root element!
		-->
		<xsl:for-each select="css:parse-stylesheet(/*/@style)[matches(@selector,'^@text-transform')]">
			<xsl:variable name="name" as="xs:string" select="replace(@selector,'^@text-transform\s+(.+)$','$1')"/>
			<xsl:variable name="props" as="element()*" select="css:parse-declaration-list(@style)"/>
			<xsl:if test="$props[@name='system' and @value='-nlb-indicators']">
				<css:text-transform name="{$name}">
					<xsl:if test="not($props[@name='open'])">
						<xsl:message terminate="yes"
						             select="concat('@text-transform &quot;',$name,'&quot; does not define &quot;open&quot;')"/>
					</xsl:if>
					<xsl:attribute name="open" select="css:parse-string($props[@name='open']/@value)/@value"/>
					<xsl:if test="not($props[@name='open'])">
						<xsl:message terminate="yes"
						             select="concat('@text-transform &quot;',$name,'&quot; does not define &quot;close&quot;')"/>
					</xsl:if>
					<xsl:attribute name="close" select="css:parse-string($props[@name='close']/@value)/@value"/>
				</css:text-transform>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:param name="text-transform" required="yes"/>
	
	<xsl:template mode="#default before after" match="css:block">
		<xsl:param name="context" as="element()"/>
		<xsl:variable name="text" as="text()*" select="//text()"/>
		<xsl:variable name="style" as="xs:string*">
			<xsl:apply-templates mode="style"/>
		</xsl:variable>
		<xsl:variable name="lang" select="string(ancestor-or-self::*[@xml:lang][1]/string(@xml:lang))"/>
		<xsl:variable name="new-text-nodes" as="xs:string*">
			<xsl:apply-templates select="node()[1]" mode="emphasis">
				<xsl:with-param name="segments" select="if ($lang=$main-locale)
				                                        then pf:text-transform($text-transform, $text, $style)
				                                        else pf:text-transform($text-transform, $text, $style,
				                                                               for $_ in 1 to count($text) return $lang)"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:apply-templates select="node()[1]" mode="treewalk">
			<xsl:with-param name="new-text-nodes" select="$new-text-nodes"/>
			<!--
			    restore style if translation has been deferred because text contains non-standard hyphenation points
			-->
			<xsl:with-param name="restore-text-style" tunnel="yes"
			                select="not(matches(string-join($new-text-nodes,''),
			                                    '^[ \t\n\r&#x00AD;&#x200B;&#x00A0;&#x2800;-&#x28FF;]*$'))"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template mode="style" match="*" as="xs:string*">
		<xsl:param name="source-style" as="element()*" tunnel="yes"/>
		<xsl:variable name="source-style" as="element()*">
			<xsl:call-template name="css:computed-properties">
				<xsl:with-param name="properties" select="$text-properties"/>
				<xsl:with-param name="context" select="$dummy-element"/>
				<xsl:with-param name="cascaded-properties" tunnel="yes"
				                select="css:deep-parse-stylesheet(@style)[not(@selector)]/css:property"/>
				<xsl:with-param name="parent-properties" tunnel="yes" select="$source-style"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:apply-templates mode="#current">
			<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template mode="emphasis" match="*" as="xs:string*" priority="1">
		<xsl:param name="segments" as="xs:string*" required="yes"/>
		<xsl:param name="source-style" as="element()*" tunnel="yes"/>
		<xsl:variable name="source-style" as="element()*">
			<xsl:call-template name="css:computed-properties">
				<xsl:with-param name="properties" select="'text-transform'"/>
				<xsl:with-param name="context" select="$dummy-element"/>
				<xsl:with-param name="cascaded-properties" tunnel="yes"
				                select="css:deep-parse-stylesheet(@style)[not(@selector)]/css:property"/>
				<xsl:with-param name="parent-properties" tunnel="yes" select="$source-style"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:next-match>
			<xsl:with-param name="segments" select="$segments"/>
			<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
		</xsl:next-match>
	</xsl:template>
	
	<!--
	    do not inherit text-transform values strong, em, u and strike, because these values are
	    handled at the level of the element on which they are specified
	-->
	<xsl:template match="css:property[@name='text-transform']" mode="css:compute">
		<xsl:param name="concretize-inherit" as="xs:boolean"/>
		<xsl:param name="concretize-initial" as="xs:boolean"/>
		<xsl:param name="validate" as="xs:boolean"/>
		<xsl:param name="context" as="element()"/>
		<xsl:choose>
			<xsl:when test="@value='inherit'">
				<xsl:sequence select="."/>
			</xsl:when>
			<xsl:when test="@value='none'">
				<xsl:sequence select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="parent-computed" as="element()">
					<xsl:call-template name="css:parent-property">
						<xsl:with-param name="property" select="@name"/>
						<xsl:with-param name="compute" select="true()"/>
						<xsl:with-param name="concretize-inherit" select="true()"/>
						<xsl:with-param name="concretize-initial" select="$concretize-initial"/>
						<xsl:with-param name="validate" select="$validate"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="parent-computed-value" as="xs:string*"
				              select="tokenize(normalize-space($parent-computed/@value),' ')[not(.=('strong','em','u','strike'))]"/>
				<xsl:variable name="parent-computed" as="element()?">
					<xsl:if test="exists($parent-computed-value)">
						<xsl:sequence select="css:property(@name, string-join($parent-computed-value,' '))"/>
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="not(exists($parent-computed))">
						<xsl:sequence select="."/>
					</xsl:when>
					<xsl:when test="@value=('initial','auto') and $parent-computed/@value='none'">
						<xsl:sequence select="."/>
					</xsl:when>
					<xsl:when test="@value=('initial','auto')">
						<xsl:sequence select="$parent-computed"/>
					</xsl:when>
					<xsl:when test="$parent-computed/@value=('auto','none','initial')">
						<xsl:sequence select="."/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="css:property(
						                        @name,
						                        string-join(
						                          distinct-values((
						                            tokenize(normalize-space(@value), ' '),
						                            tokenize(normalize-space($parent-computed/@value), ' '))),
						                          ' '))"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
	    properties that should not be passed to the Java part of the translator
	    1) word-spacing handled later in formatter
	    2) text-transform=strong|em|u|strike handled in the XSLT part

	-->
	<xsl:template mode="style" match="text()" as="xs:string">
		<xsl:param name="source-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:variable name="source-style" as="element()*"
		              select="for $p in $source-style
		                      return if ($p/@name='text-transform')
		                             then css:property('text-transform',
		                                               string-join(
		                                                 tokenize(normalize-space($p/@value),' ')[not(.=('strong','em','u','strike'))],
		                                                 ' '))
		                                  [not(@value='')]
		                             else $p"/>
		<xsl:sequence select="css:serialize-declaration-list(
		                        $source-style[not(@name='word-spacing')
		                                      and not(@value=css:initial-value(@name))])"/>
	</xsl:template>
	
	<!--
	    properties handled by this translator
	-->
	<xsl:template mode="translate-style"
	              match="css:property[@name=('letter-spacing',
	                                         'font-style',
	                                         'font-weight',
	                                         'text-decoration',
	                                         'text-transform',
	                                         'color')]"/>
	
	<xsl:template mode="translate-style" match="css:property[@name='hyphens' and @value='auto']">
		<css:property name="hyphens" value="manual"/>
	</xsl:template>
	
	<xsl:template mode="translate-style" match="css:rule[matches(@selector,'^@text-transform')]"/>
	
	<xsl:template match="*" mode="emphasis" as="xs:string*">
		<xsl:param name="segments" as="xs:string*" required="yes"/>
		<xsl:param name="source-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:choose>
			<xsl:when test="$source-style[@name='text-transform'
			                              and tokenize(normalize-space(@value),' ')=$text-transform-defs/@name]">
				<xsl:variable name="text-transform" as="xs:string" select="$source-style[@name='text-transform']/@value"/>
				<xsl:variable name="text-transform-def" as="element()"
				              select="$text-transform-defs[@name=tokenize(normalize-space($text-transform),' ')][1]"/>
				<xsl:call-template name="mark-emphasis">
					<xsl:with-param name="segments" select="$segments"/>
					<xsl:with-param name="opening-mark" select="$text-transform-def/@open"/>
					<xsl:with-param name="closing-mark" select="$text-transform-def/@close"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="text-node-count" select="count(.//text())"/>
				<xsl:apply-templates select="child::node()[1]" mode="#current">
					<xsl:with-param name="segments" select="$segments[position()&lt;=$text-node-count]"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="following-sibling::node()[1]" mode="#current">
					<xsl:with-param name="segments" select="$segments[position()&gt;$text-node-count]"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="text()" mode="emphasis" as="xs:string*">
		<xsl:param name="segments" as="xs:string*" required="yes"/>
		<xsl:value-of select="$segments[1]"/>
		<xsl:apply-templates select="following-sibling::node()[1]" mode="#current">
			<xsl:with-param name="segments" select="$segments[position()&gt;1]"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template name="mark-emphasis">
		<xsl:param name="segments" as="xs:string*" required="yes"/>
		<xsl:param name="opening-mark" as="xs:string" required="yes"/>
		<xsl:param name="closing-mark" as="xs:string" required="yes"/>
		<xsl:variable name="text-node-count" select="count(.//text())"/>
		<xsl:variable name="segments-inside" as="xs:string*">
			<xsl:apply-templates select="child::node()[1]" mode="#current">
				<xsl:with-param name="segments" select="$segments[position()&lt;=$text-node-count]"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:for-each-group select="$segments-inside" group-adjacent="matches(.,'^[\s&#x2800;]*$')">
			<xsl:choose>
				<xsl:when test="current-grouping-key()">
					<xsl:sequence select="current-group()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="segments" as="xs:string*" select="current-group()"/>
					<xsl:variable name="segments" as="xs:string*">
						<xsl:choose>
							<xsl:when test="position()=(1,2)">
								<xsl:sequence select="replace($segments[1],'^([\s&#x2800;]*)([^\s&#x2800;].*)$',concat('$1',$opening-mark,'$2'))"/>
								<xsl:sequence select="$segments[position()&gt;1]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="current-group()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="segments" as="xs:string*">
						<xsl:choose>
							<xsl:when test="(last() - position())=(0,1)">
								<xsl:sequence select="$segments[position()&lt;last()]"/>
								<xsl:sequence select="replace($segments[last()],'^(.*[^\s&#x2800;])([\s&#x2800;]*)$',concat('$1',$closing-mark,'$2'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="current-group()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:sequence select="$segments"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
		<xsl:apply-templates select="following-sibling::node()[1]" mode="#current">
			<xsl:with-param name="segments" select="$segments[position()&gt;$text-node-count]"/>
		</xsl:apply-templates>
	</xsl:template>
	
</xsl:stylesheet>
