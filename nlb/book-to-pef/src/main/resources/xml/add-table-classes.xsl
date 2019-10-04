<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:f="f"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:param name="include-images" select="'true'"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="dtb:table[not(@class)]|
	                     html:table[not(@class)]">
		<xsl:variable name="table-class" as="xs:string">
			<xsl:choose>
				<!--
				    No content other than text, text-level elements or paragraphs (at most one) for matrix tables.
				-->
				<xsl:when test=".//*[local-name()=('td','th')]
				                    [*[not(local-name()='p') and not(f:is-text-level(.))]
				                     or (*[local-name()='p'] and count(*[local-name()='p']) &gt; 1)]">
					<xsl:sequence select="'table-linearized'"/>
				</xsl:when>
				<!--
				    Although it is supported, don't render tables with row or column span in matrix format for now.
				-->
				<xsl:when test=".//*[local-name()=('td','th')]
				                    [not(xs:integer((@colspan,'1')[1])=1) or
				                     not(xs:integer((@rowspan,'1')[1])=1)]">
					<xsl:sequence select="'table-linearized'"/>
				</xsl:when>
				<!--
				    At most 50 characters in each cell for matrix tables.
				-->
				<xsl:when test=".//*[local-name()=('td','th')]
				                    [string-length(normalize-space(string(.))) &gt; 50]">
					<xsl:sequence select="'table-linearized'"/>
				</xsl:when>
				<!--
				    If there are more than 3 columns...
				-->
				<xsl:when test="max(.//*[local-name()='tr']/count(*[local-name()=('td','th')])) &gt; 3">
					<xsl:choose>
						<!--
						    ...but not more than 3 rows, transpose the table.
						-->
						<xsl:when test="count(.//*[local-name()='tr']) &lt;= 3">
							<xsl:sequence select="'table-matrix-transposed'"/>
						</xsl:when>
						<!--
						    otherwise render in linearized format.
						-->
						<xsl:otherwise>
							<xsl:sequence select="'table-linearized'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="'table-matrix'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:copy>
			<xsl:attribute name="class" select="$table-class"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:function name="f:is-text-level" as="xs:boolean">
		<xsl:param name="element" as="element()"/>
		<xsl:apply-templates mode="is-text-level" select="$element"/>
	</xsl:function>
	
	<xsl:template mode="is-text-level" match="*">
		<xsl:sequence select="false()"/>
	</xsl:template>
	
	<xsl:template mode="is-text-level"
	              match=" dtb:span   |html:span
	                     |dtb:a      |html:a
	                     |dtb:em     |html:em
	                     |dtb:strong |html:strong
	                     |dtb:i      |html:i
	                     |dtb:b      |html:b
	                     |dtb:u      |html:u
	                     |dtb:sub    |html:sub
	                     |dtb:sup    |html:sup
	                     ">
		<xsl:sequence select="true()"/>
	</xsl:template>
	
	<xsl:template mode="is-text-level"
	              match="dtb:img|html:img">
		<xsl:sequence select="not($include-images='false')"/>
	</xsl:template>
	
</xsl:stylesheet>
