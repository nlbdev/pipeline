<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:output xml:space="default" media-type="text/html" indent="yes"/>
    
    <xsl:template match="/*">
        <div class="document-validation-report" id="{generate-id()}">
            <xsl:apply-templates select="d:document-info"/>
            <xsl:apply-templates select="d:reports"/>
            <hr/>
        </div>
    </xsl:template>
    
    <xsl:template match="d:document-info">
        <xsl:element name="d:data" namespace="http://www.daisy.org/ns/pipeline/data">
            <xsl:copy-of select="."/>
        </xsl:element>
        <div class="document-info">
            <xsl:apply-templates select="d:document-name"/>
            <xsl:apply-templates select="d:document-type"/>
            <xsl:apply-templates select="d:document-path"/>
            <xsl:choose>
                <xsl:when test="d:error-count/text() = '1'">
                    <p>1 issue found.</p>
                </xsl:when>
                <xsl:otherwise>
                    <p>
                        <xsl:if test="text() = '0'">
                            <xsl:attribute name="style" select="'background-color: #AAFFAA;'"/>
                        </xsl:if>
                        <xsl:value-of select="d:error-count/text()"/> issues found.
                    </p>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="d:properties"/>
        </div>
    </xsl:template>

    <!-- document info -->
    <xsl:template match="d:document-name">
        <h2 style="font-size: 2.25em;">
            <code>
                <xsl:value-of select="if (starts-with(text(),'file:')) then replace(text(),'.*/','') else text()"/>
            </code>
        </h2>
    </xsl:template>

    <xsl:template match="d:document-type">
        <p>Validated as <code><xsl:value-of select="text()"/></code></p>
    </xsl:template>

    <xsl:template match="d:document-path">
        <p>Path: <code><xsl:value-of select="text()"/></code></p>
    </xsl:template>
    
    <xsl:template match="d:properties">
        <xsl:if test="d:property">
            <table class="table table-condensed">
                <thead>
                    <tr>
                        <th>Property</th>
                        <th>Value</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="d:property"/>
                </tbody>
            </table>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="d:property">
        <tr>
            <td>
                <xsl:value-of select="@name"/>
            </td>
            <td>
                <xsl:if test="@content">
                    <xsl:value-of select="@content"/>
                </xsl:if>
                <xsl:if test="d:property">
                    <table class="table table-condensed">
                        <tbody>
                            <xsl:apply-templates select="d:property"/>
                        </tbody>
                    </table>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="d:reports">
        <div class="document-report">
            <xsl:apply-templates select="*|comment()"/>
        </div>
    </xsl:template>
    
    <xsl:template match="d:report">
        <ul>
            <xsl:if test=".//text()[contains(., 'lineNumber')]">
                <p>Note that line numbers tend to be offset by a couple of lines because the doctype and xml declarations are not counted as lines.</p>
            </xsl:if>
            <xsl:apply-templates select="*|comment()"/>
        </ul>
    </xsl:template>

    <xsl:template match="d:message | d:error">
        <xsl:variable name="severity" select="(@severity,local-name())[1]"/>
        <li class="message-{$severity}" style="padding-bottom: 1em;">
            <xsl:if test="$severity = ('error', 'fatal', 'exception')">
                <xsl:attribute name="style" select="string-join((@style, 'background-color: #f2dede;'),' ')"/>
            </xsl:if>
            <xsl:if test="$severity = ('warn', 'warning')">
                <xsl:attribute name="style" select="string-join((@style, 'background-color: #fcf8e3;'),' ')"/>
            </xsl:if>
            <p>
                <xsl:value-of select="./d:desc//text()/f:parse-desc(.)"/>
            </p>
            <div class="message-details">
                <xsl:choose>
                   <xsl:when test="$severity = ('error', 'fatal', 'exception')">
                       <xsl:attribute name="style" select="'display: table; border: gray thin solid; padding: 5px;'"/>
                   </xsl:when>
                   <xsl:when test="$severity = 'info'">
                       <xsl:attribute name="style" select="'display: none;'"/>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:attribute name="style" select="'display: table;'"/>
                   </xsl:otherwise>
               </xsl:choose>
                <xsl:if test="./d:file">
                    <pre style="display: table-cell;"><xsl:value-of select="./d:file"/></pre>
                </xsl:if>
                <xsl:if test="string-length(./d:location/@href) > 0">
                    <div style="display: table-row;">
                        <h3 style="font-size: 1.25em; display: table-cell; padding-right: 10px;">Location:</h3>
                        <pre class="box" style="display: table-cell;">
                        <xsl:choose>
                            <xsl:when test="./d:location/@href">
                                <xsl:value-of select="./d:location/@href"/>    
                            </xsl:when>
                            <xsl:otherwise>
                                <em>Line <xsl:value-of select="./d:location/@line"/>, Column <xsl:value-of select="./d:location/@column"/></em>
                            </xsl:otherwise>
                        </xsl:choose>
                        </pre>
                    </div>
                </xsl:if>
                <xsl:if test="./d:expected">
                    <div style="display: table-row;">
                        <h3 style="font-size: 1.25em; display: table-cell; padding-right: 10px;">Expected:</h3>
                        <pre class="prettyprint" style="display: table-cell;"><xsl:value-of select="./d:expected"/></pre>
                    </div>
                </xsl:if>
                <xsl:if test="./d:was">
                    <div style="display: table-row;">
                        <h3 style="font-size: 1.25em; display: table-cell; padding-right: 10px;">Was:</h3>
                        <pre class="prettyprint" style="display: table-cell;"><xsl:value-of select="./d:was"/></pre>
                    </div>
                </xsl:if>
            </div>
        </li>
    </xsl:template>
    
    
    <!-- non-standard report stuff -->
    
    <!-- failed asserts and successful reports are both notable events in SVRL -->
    <xsl:template match="svrl:failed-assert | svrl:successful-report">
        <!-- TODO can we output the line number too? -->
        <li class="error" style="padding-bottom: 1em;">
            <xsl:if test="starts-with(@location,'/*')">
                <xsl:attribute name="title" select="replace(replace(@location,'\*:',''),'\[namespace[^\]]*\]','')"/>
            </xsl:if>
            <p>
                <xsl:value-of select="svrl:text/text()/f:parse-desc(.)"/>
            </p>
        </li>
    </xsl:template>

    <!-- things to ignore.there are probably more than just these-->
    <xsl:template match="svrl:schematron-output">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="svrl:ns-prefix-in-attribute-values | svrl:active-pattern | svrl:fired-rule"/>
    <xsl:template match="text()"/>
    
    <xsl:function name="f:parse-desc">
        <xsl:param name="desc" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($desc,'org.xml.sax.SAXParseException')">
                <xsl:variable name="parts" select="tokenize($desc,'; ')"/>
                <xsl:variable name="filename" select="replace($parts[starts-with(.,'systemId:')][1],'.*/','')"/>
                <xsl:variable name="lineNumber" select="replace($parts[starts-with(.,'lineNumber:')][1],'[^\d]','')"/>
                <xsl:variable name="columnNumber" select="replace($parts[starts-with(.,'columnNumber:')][1],'[^\d]','')"/>
                <xsl:variable name="message"
                    select="string-join($parts[not(starts-with(.,'org.xml.sax.SAXParseException') or starts-with(.,'systemId:') or starts-with(.,'lineNumber:') or starts-with(.,'columnNumber:'))],'; ')"/>
                <xsl:value-of select="$filename"/>
                <xsl:if test="$lineNumber or $columnNumber">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="if ($filename) then '(' else ''"/>
                    <xsl:value-of select="if ($lineNumber) then concat('line: ',$lineNumber) else ''"/>
                    <xsl:value-of select="if ($lineNumber and $columnNumber) then ', ' else ''"/>
                    <xsl:value-of select="if ($columnNumber) then concat('column: ',$columnNumber) else ''"/>
                    <xsl:value-of select="if ($filename) then ')' else ''"/>
                </xsl:if>
                <xsl:value-of select="if ($filename or $lineNumber or $columnNumber) then ' ' else ''"/>
                <xsl:value-of select="$message"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$desc"/>$>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
