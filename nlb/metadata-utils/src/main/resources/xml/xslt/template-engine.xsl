<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nlb="http://www.nlb.no/ns/" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">

    <!-- parameters formatted as "name=value,name=value" -->
    <xsl:param name="params" select="''"/>

    <xsl:template match="*|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{name()}" select="nlb:apply-templates(.)"/>
    </xsl:template>

    <xsl:template match="comment()">
        <xsl:comment select="nlb:apply-templates(.)"/>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="nlb:apply-templates(.)"/>
    </xsl:template>

    <xsl:function name="nlb:apply-templates">
        <xsl:param name="string"/>
        <xsl:variable name="split" select="tokenize($string,'\$')"/>
        <xsl:value-of select="$split[1]"/>
        <xsl:for-each select="subsequence($split,2)">
            <xsl:variable name="template" select="replace(.,'^\{([^}]*)\}.*$','$1')"/>
            <xsl:variable name="tail" select="replace(.,'^\{[^}]*\}(.*)$','$1')"/>
            <xsl:choose>
                <xsl:when test="string-length($template) &gt; 0 and not($template = .)">
                    <xsl:variable name="template-name" select="tokenize($template,':')[1]"/>
                    <xsl:variable name="template-param" select="string-join(tokenize($template,':')[position() &gt; 1],':')"/>
                    <xsl:choose>
                        <xsl:when test="$template-name='param'">
                            <xsl:value-of select="nlb:template-param($template-param)"/>
                        </xsl:when>
                        <xsl:when test="$template-name='uid'">
                            <xsl:value-of select="nlb:template-uid($template-param)"/>
                        </xsl:when>
                        <xsl:when test="$template-name='time'">
                            <xsl:value-of select="nlb:template-time($template-param, current-dateTime())"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('${',$template,'}')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="$tail"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="nlb:template-param">
        <xsl:param name="param-name"/>
        <xsl:value-of select="string-join(for $pair in tokenize($params,'\|') return (if (starts-with($pair,concat($param-name,'='))) then replace($pair,'^[^=]+=','') else ''),'')"/>
    </xsl:function>

    <xsl:function name="nlb:template-uid">
        <xsl:param name="null"/>
        <xsl:value-of select="concat('NLB-',nlb:template-time('Ymd-Hms-u', current-dateTime()))"/>
    </xsl:function>

    <xsl:function name="nlb:template-time">
        <!-- Implements an adapted version of the PHP date() function. (not all implemented yet) -->
        <xsl:param name="php-time"/>
        <xsl:param name="date-time"/>
        <xsl:variable name="dateTime"
            select="if ($date-time instance of xs:dateTime) then $date-time else
            xs:dateTime(
            if (matches($date-time,'-\d\d$')) then concat($date-time,'T00:00:00') else
            if (matches($date-time,'[\.:]\d+$')) then concat('1970-01-01T',$date-time) else
            $date-time
            )"/>
        <xsl:variable name="result">
            <xsl:for-each select="for $i in string-to-codepoints($php-time) return codepoints-to-string($i)">
                <xsl:choose>
                    <xsl:when test=".='d'">
                        <!-- d	Day of the month, 2 digits with leading zeros	01 to 31 -->
                        <xsl:variable name="day" select="day-from-dateTime($dateTime)"/>
                        <xsl:value-of select="if ($day &lt; 10) then concat('0',$day) else $day"/>
                    </xsl:when>
                    <xsl:when test=".='D'">
                        <!-- D	A textual representation of a day, three letters	Mon through Sun -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='j'">
                        <!-- j	Day of the month without leading zeros	1 to 31 -->
                        <xsl:value-of select="day-from-dateTime($dateTime)"/>
                    </xsl:when>
                    <xsl:when test=".='l'">
                        <!-- l (lowercase 'L')	A full textual representation of the day of the week	Sunday through Saturday -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='N'">
                        <!-- N	ISO-8601 numeric representation of the day of the week (added in PHP 5.1.0)	1 (for Monday) through 7 (for Sunday) -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='S'">
                        <!-- S	English ordinal suffix for the day of the month, 2 characters	st, nd, rd or th. Works well with j -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='w'">
                        <!-- w	Numeric representation of the day of the week	0 (for Sunday) through 6 (for Saturday) -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='z'">
                        <!-- z	The day of the year (starting from 0)	0 through 365 -->
                        <xsl:variable name="year" select="year-from-dateTime($dateTime)"/>
                        <xsl:variable name="month" select="month-from-dateTime($dateTime)"/>
                        <xsl:variable name="day" select="day-from-dateTime($dateTime)"/>
                        <xsl:variable name="leapYear" select="if (($year mod 4) = 0 and not($year mod 100 and not ($year mod 400))) then true() else false()"/>
                        <xsl:value-of
                            select="sum(($day,
                        if (1 &lt;= $month) then 31 else 0,
                        if (2 &lt;= $month) then (if ($leapYear) then 29 else 28) else 0,
                        if (3 &lt;= $month) then 31 else 0,
                        if (4 &lt;= $month) then 30 else 0,
                        if (5 &lt;= $month) then 31 else 0,
                        if (6 &lt;= $month) then 30 else 0,
                        if (7 &lt;= $month) then 31 else 0,
                        if (8 &lt;= $month) then 31 else 0,
                        if (9 &lt;= $month) then 30 else 0,
                        if (10 &lt;= $month) then 31 else 0,
                        if (11 &lt;= $month) then 30 else 0,
                        if (12 &lt;= $month) then 31 else 0))"
                        />
                    </xsl:when>
                    <xsl:when test=".='W'">
                        <!-- W	ISO-8601 week number of year, weeks starting on Monday (added in PHP 4.1.0)	Example: 42 (the 42nd week in the year) -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='F'">
                        <!-- F	A full textual representation of a month, such as January or March	January through December -->
                        <xsl:variable name="month" select="month-from-dateTime($dateTime)"/>
                        <xsl:value-of
                            select="
                        if ($month = 1) then 'Januar' else
                        if ($month = 2) then 'Februar' else
                        if ($month = 3) then 'Mars' else
                        if ($month = 4) then 'April' else
                        if ($month = 5) then 'Mai' else
                        if ($month = 6) then 'Juni' else
                        if ($month = 7) then 'Juli' else
                        if ($month = 8) then 'August' else
                        if ($month = 9) then 'September' else
                        if ($month = 10) then 'Oktober' else
                        if ($month = 11) then 'November' else
                        if ($month = 12) then 'Desember' else '?'
                        "
                        />
                    </xsl:when>
                    <xsl:when test=".='m'">
                        <!-- m	Numeric representation of a month, with leading zeros	01 through 12 -->
                        <xsl:variable name="month" select="month-from-dateTime($dateTime)"/>
                        <xsl:value-of select="if ($month &lt; 10) then concat('0',$month) else $month"/>
                    </xsl:when>
                    <xsl:when test=".='M'">
                        <!-- M	A short textual representation of a month, three letters	Jan through Dec -->
                        <xsl:variable name="month" select="month-from-dateTime($dateTime)"/>
                        <xsl:value-of
                            select="
                        if ($month = 1) then 'Jan' else
                        if ($month = 2) then 'Feb' else
                        if ($month = 3) then 'Mar' else
                        if ($month = 4) then 'Apr' else
                        if ($month = 5) then 'Mai' else
                        if ($month = 6) then 'Jun' else
                        if ($month = 7) then 'Jul' else
                        if ($month = 8) then 'Aug' else
                        if ($month = 9) then 'Sep' else
                        if ($month = 10) then 'Okt' else
                        if ($month = 11) then 'Nov' else
                        if ($month = 12) then 'Des' else '?'
                        "
                        />
                    </xsl:when>
                    <xsl:when test=".='n'">
                        <!-- n	Numeric representation of a month, without leading zeros	1 through 12 -->
                        <xsl:value-of select="month-from-dateTime($dateTime)"/>
                    </xsl:when>
                    <xsl:when test=".='t'">
                        <!-- t	Number of days in the given month	28 through 31 -->
                        <xsl:variable name="year" select="year-from-dateTime($dateTime)"/>
                        <xsl:variable name="month" select="month-from-dateTime($dateTime)"/>
                        <xsl:variable name="leapYear" select="if (($year mod 4) = 0 and not($year mod 100 and not ($year mod 400))) then true() else false()"/>
                        <xsl:value-of
                            select="
                        if (1 = $month) then 31 else
                        if (2 = $month) then (if ($leapYear) then 29 else 28) else
                        if (3 = $month) then 31 else
                        if (4 = $month) then 30 else
                        if (5 = $month) then 31 else
                        if (6 = $month) then 30 else
                        if (7 = $month) then 31 else
                        if (8 = $month) then 31 else
                        if (9 = $month) then 30 else
                        if (10 = $month) then 31 else
                        if (11 = $month) then 30 else
                        if (12 = $month) then 31 else 0"
                        />
                    </xsl:when>
                    <xsl:when test=".='L'">
                        <!-- L	Whether it's a leap year	1 if it is a leap year, 0 otherwise. -->
                        <xsl:variable name="year" select="year-from-dateTime($dateTime)"/>
                        <xsl:value-of select="if (($year mod 4) = 0 and not($year mod 100 and not ($year mod 400))) then 1 else 0"/>
                    </xsl:when>
                    <xsl:when test=".='o'">
                        <!-- o	ISO-8601 year number. This has the same value as Y, except that if the ISO week number (W) belongs to the previous or next year, that year is used instead. (added in PHP 5.1.0)	Examples: 1999 or 2003 -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='Y'">
                        <!-- Y	A full numeric representation of a year, 4 digits	Examples: 1999 or 2003 -->
                        <xsl:value-of select="year-from-dateTime($dateTime)"/>
                    </xsl:when>
                    <xsl:when test=".='y'">
                        <!-- y	A two digit representation of a year	Examples: 99 or 03 -->
                        <xsl:value-of select="replace(concat('',year-from-dateTime($dateTime)),'^(-?).*(\d\d)$','$1$2')"/>
                    </xsl:when>
                    <xsl:when test=".='a'">
                        <!-- a	Lowercase Ante meridiem and Post meridiem	am or pm -->
                        <xsl:value-of select="if (hours-from-dateTime($dateTime) &lt; 12) then 'am' else 'pm'"/>
                    </xsl:when>
                    <xsl:when test=".='A'">
                        <!-- A	Uppercase Ante meridiem and Post meridiem	AM or PM -->
                        <xsl:value-of select="if (hours-from-dateTime($dateTime) &lt; 12) then 'AM' else 'PM'"/>
                    </xsl:when>
                    <xsl:when test=".='B'">
                        <!-- B	Swatch Internet time	000 through 999 -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='g'">
                        <!-- g	12-hour format of an hour without leading zeros	1 through 12 -->
                        <xsl:variable name="hours" select="hours-from-dateTime($dateTime)"/>
                        <xsl:value-of select="if ($hours = 0) then 12 else if ($hours &gt; 12) then $hours - 12 else $hours"/>
                    </xsl:when>
                    <xsl:when test=".='G'">
                        <!-- G	24-hour format of an hour without leading zeros	0 through 23 -->
                        <xsl:value-of select="hours-from-dateTime($dateTime)"/>
                    </xsl:when>
                    <xsl:when test=".='h'">
                        <!-- h	12-hour format of an hour with leading zeros	01 through 12 -->
                        <xsl:variable name="hours" select="hours-from-dateTime($dateTime)"/>
                        <xsl:variable name="hours12" select="if ($hours = 0) then 12 else if ($hours &gt; 12) then $hours - 12 else $hours"/>
                        <xsl:value-of select="if ($hours12 &lt; 10) then concat('0',$hours12) else $hours12"/>
                    </xsl:when>
                    <xsl:when test=".='H'">
                        <!-- H	24-hour format of an hour with leading zeros	00 through 23 -->
                        <xsl:variable name="hours" select="hours-from-dateTime($dateTime)"/>
                        <xsl:value-of select="if ($hours &lt; 10) then concat('0',$hours) else $hours"/>
                    </xsl:when>
                    <xsl:when test=".='i'">
                        <!-- i	Minutes with leading zeros	00 to 59 -->
                        <xsl:variable name="minutes" select="minutes-from-dateTime($dateTime)"/>
                        <xsl:value-of select="if ($minutes &lt; 10) then concat('0',$minutes) else $minutes"/>
                    </xsl:when>
                    <xsl:when test=".='s'">
                        <!-- s	Seconds, with leading zeros	00 through 59 -->
                        <xsl:variable name="seconds" select="floor(seconds-from-dateTime($dateTime))"/>
                        <xsl:value-of select="if ($seconds &lt; 10) then concat('0',$seconds) else $seconds"/>
                    </xsl:when>
                    <xsl:when test=".='u'">
                        <!-- u	Microseconds (added in PHP 5.2.2)	Example: 654321 -->
                        <!-- modification: with leading zeros -->
                        <xsl:variable name="seconds" select="seconds-from-dateTime($dateTime)"/>
                        <xsl:variable name="microseconds" select="concat('',floor(($seconds - floor($seconds))*1000000))"/>
                        <xsl:value-of select="concat(string-join(for $i in (string-length($microseconds) to 6) return '0',''), $microseconds)"/>
                    </xsl:when>
                    <xsl:when test=".='e'">
                        <!-- e	Timezone identifier (added in PHP 5.1.0)	Examples: UTC, GMT, Atlantic/Azores -->
                        <xsl:value-of select="timezone-from-dateTime($dateTime)"/>
                    </xsl:when>
                    <xsl:when test=".='I'">
                        <!-- I (capital i)	Whether or not the date is in daylight saving time	1 if Daylight Saving Time, 0 otherwise. -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='O'">
                        <!-- O	Difference to Greenwich time (GMT) in hours	Example: +0200 -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='P'">
                        <!-- P	Difference to Greenwich time (GMT) with colon between hours and minutes (added in PHP 5.1.3)	Example: +02:00 -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='T'">
                        <!-- T	Timezone abbreviation	Examples: EST, MDT ... -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='Z'">
                        <!-- Z	Timezone offset in seconds. The offset for timezones west of UTC is always negative, and for those east of UTC is always positive.	-43200 through 50400 -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='c'">
                        <!-- c	ISO 8601 date (added in PHP 5)	2004-02-12T15:19:21+00:00 -->
                        <xsl:value-of select="$dateTime"/>
                    </xsl:when>
                    <xsl:when test=".='r'">
                        <!-- r	» RFC 2822 formatted date	Example: Thu, 21 Dec 2000 16:01:07 +0200 -->
                        <xsl:value-of select="'?'"/>
                    </xsl:when>
                    <xsl:when test=".='U'">
                        <!-- U	Seconds since the Unix Epoch (January 1 1970 00:00:00 GMT)	See also time() -->
                        <xsl:value-of select="( $dateTime - xs:dateTime('1970-01-01T00:00:00') ) div xs:dayTimeDuration('PT1S')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$result"/>
    </xsl:function>

</xsl:stylesheet>
