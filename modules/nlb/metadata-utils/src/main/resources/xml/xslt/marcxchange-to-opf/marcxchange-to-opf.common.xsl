<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:SRU="http://www.loc.gov/zing/sru/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:normarc="info:lc/xmlns/marcxchange-v1" xmlns:marcxchange="info:lc/xmlns/marcxchange-v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:DIAG="http://www.loc.gov/zing/sru/diagnostics/" xmlns:nlb="http://metadata.nlb.no/vocabulary/#" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf">

    <xsl:variable name="DAY_MONTH_YEAR" select="'\d+-\d+-\d+'"/>
    <xsl:variable name="FORMAT_245H_DAISY2_1" select="'(?i).*da[i\ss][si]y[\.\s]*.*'"/>
    <xsl:variable name="FORMAT_245H_DAISY2_2" select="'.*2[.\s]*0?2.*'"/>
    <xsl:variable name="FORMAT_245H_DTBOOK" select="'(?i).*dtbook.*'"/>
    <xsl:variable name="PSEUDONYM" select="'pse[uv]d.*'"/>
    <xsl:variable name="PSEUDONYM_REPLACE" select="'pse[uv]d.*?f.*?\s+(.*)$'"/>
    <xsl:variable name="FIRST_LAST_NAME" select="'^(.*\S.*)\s+(\S+)\s*$'"/>
    <xsl:variable name="YEAR" select="'.*[^\d-].*'"/>
    <xsl:variable name="YEAR_NEGATIVE" select="'.*f.*Kr.*'"/>
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
            <xsl:when test="matches($role,'reda') or $role='red' or $role='hovedred'">
                <xsl:value-of select="'dc:contributor.secretary'"/>
            </xsl:when>
            <xsl:when test="matches($role,'.*(redi|bearb|tilrett|edit|eds|instrukt|instruert|revid).*') or $role='ed'">
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
                <!-- Collaborator -->
                <xsl:value-of select="'dc:contributor.collaborator'"/>
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
                <xsl:value-of select="'dc:creator'"/>
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

</xsl:stylesheet>
