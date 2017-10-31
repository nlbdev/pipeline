<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:f="#"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:template match="/">
		<xsl:variable name="problematic-tables" as="element()*">
			<xsl:apply-templates mode="find-problematic-tables" select="*"/>
		</xsl:variable>
		<xsl:if test="exists($problematic-tables)">
			<html xmlns="http://www.w3.org/1999/xhtml">
				<h1>
					<xsl:text>Malformed tables</xsl:text>
				</h1>
				<p>
					<xsl:value-of select="count($problematic-tables)"/>
					<xsl:text> malformed table</xsl:text>
					<xsl:choose>
						<xsl:when test="count($problematic-tables) &gt; 1">
							<xsl:text>s were</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> was</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text> found.</xsl:text>
				</p>
				<ol>
					<xsl:for-each select="$problematic-tables">
						<li>
							<xsl:apply-templates mode="to-html" select="."/>
						</li>
					</xsl:for-each>
				</ol>
			</html>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="find-problematic-tables" match="dtb:table" as="element()?">
		<xsl:if test="not(f:is-table-well-formed(.))">
			<xsl:sequence select="."/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="find-problematic-tables" match="*">
		<xsl:apply-templates mode="#current" select="*"/>
	</xsl:template>
	
	<xsl:function name="f:is-table-well-formed" as="xs:boolean">
		<xsl:param name="table" as="element()"/> <!-- dtb:table -->
		<!--
		    1. group table cells by css:table-header-group, css:table-row-group, and css:table-footer-group
		    2. create implicit table cells "covered" by column- and row-span
		    3. group by row
		    4. check that there are no duplicate columns in a row
		    5. check that all rows have the same number of columns
		-->
		<xsl:variable name="well-formed" as="xs:boolean*">
			<xsl:for-each-group select="$table//*[@css:table-cell]" group-by="string(@css:table-header-group)">
				<xsl:for-each-group select="current-group()" group-by="string(@css:table-footer-group)">
					<xsl:for-each-group select="current-group()" group-by="string(@css:table-row-group)">
						<xsl:variable name="covered-cells" as="element()*">
							<xsl:for-each select="current-group()[@css:table-row-span or @css:table-column-span]">
								<xsl:variable name="row" as="xs:integer" select="xs:integer(@css:table-row)"/>
								<xsl:variable name="column" as="xs:integer"  select="xs:integer(@css:table-column)"/>
								<xsl:variable name="row-span" as="xs:integer" select="(@css:table-row-span/xs:integer(.),1)[1]"/>
								<xsl:variable name="column-span" as="xs:integer" select="(@css:table-column-span/xs:integer(.),1)[1]"/>
								<xsl:sequence select="for $x in 1 to $row-span return
								                      for $y in 1 to $column-span return
								                      if ($x &gt; 1 or $y &gt; 1)
								                      then f:covered-cell($row + $x - 1, $column + $y - 1)
								                      else ()"/>
							</xsl:for-each>
						</xsl:variable>
						<xsl:for-each-group select="(current-group(),$covered-cells)" group-by="string(@css:table-row)">
							<xsl:variable name="columns" as="xs:integer*" select="current-group()/xs:integer(@css:table-column)"/>
							<xsl:sequence select="count($columns)=count(distinct-values($columns))"/>
						</xsl:for-each-group>
						<xsl:variable name="column-counts" as="xs:integer*">
							<xsl:for-each-group select="(current-group(),$covered-cells)" group-by="string(@css:table-row)">
								<xsl:sequence select="count(current-group())"/>
							</xsl:for-each-group>
						</xsl:variable>
						<xsl:sequence select="every $c in $column-counts satisfies $c = $column-counts[1]"/>
					</xsl:for-each-group>
				</xsl:for-each-group>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:sequence select="every $w in $well-formed satisfies $w"/>
	</xsl:function>
	
	<xsl:function name="f:covered-cell" as="element()"> <!-- td -->
		<xsl:param name="row" as="xs:integer"/>
		<xsl:param name="column" as="xs:integer"/>
		<td css:table-cell="_" css:table-row="{$row}" css:table-column="{$column}"/>
	</xsl:function>
	
	<xsl:template mode="to-html" match="dtb:table">
		<xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="style" select="'border-collapse: collapse; background: red'"/>
			<xsl:apply-templates mode="#current" select="@*|node()"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template mode="to-html" match="dtb:td|dtb:th">
		<xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="style" select="'border: 1px solid black; background: white'"/>
			<xsl:apply-templates mode="#current" select="@*|node()"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template mode="to-html" match="dtb:tr|dtb:thead|dtb:tbody|dtb:tfoot">
		<xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
			<xsl:apply-templates mode="#current" select="@*|node()"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template mode="to-html" match="@*|node()">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:template mode="to-html" match="@css:*"/>
	<xsl:template mode="to-html" match="@style"/>
	
</xsl:stylesheet>
