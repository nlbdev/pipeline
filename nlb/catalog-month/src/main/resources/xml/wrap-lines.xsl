<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="http://www.example.org/" version="2.0">

    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="*">
                <xsl:variable name="e" select="."/>
                <xsl:for-each select="f:wrap-string(78,string-join($e/text(),' '))">
                    <xsl:element name="{$e/name()}" namespace="{namespace-uri($e)}">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="f:wrap-string">
        <xsl:param name="line-width"/>
        <xsl:param name="text"/>
        <xsl:variable name="words" select="tokenize($text,'\s+')"/>
        <xsl:choose>
            <xsl:when test="count($words)=1 and string-length($words) &lt;= $line-width">
                <xsl:sequence select="$words"/>
            </xsl:when>
            <xsl:when test="count($words)=1">
                <xsl:sequence select="(substring($text,1,$line-width) , f:wrap-string($line-width,substring($text,$line-width+1)))"/>
            </xsl:when>
            <xsl:when test="string-length(string-join($words,' ')) &lt;= $line-width">
                <xsl:sequence select="string-join($words,' ')"/>
            </xsl:when>
            <xsl:when test="string-length($words[1]) &gt; $line-width">
                <xsl:sequence select="(substring($words[1],1,$line-width) , f:wrap-string($line-width,string-join((substring($words[1],$line-width+1),$words[position()&gt;1]),' ')))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="split-position" select="(for $i in 1 to count($words) return if (string-length(string-join($words[position()&lt;$i],' ')) &lt;= $line-width) then $i else ())[last()]"/>
                <xsl:variable name="before" select="string-join($words[position()&lt;=$split-position],' ')"/>
                <xsl:variable name="after" select="string-join($words[position()&gt;$split-position],' ')"/>
                <xsl:sequence select="($before , f:wrap-string($line-width,$after))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
