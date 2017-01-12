<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-intersect" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:err="http://www.w3.org/ns/xproc-error"
  xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="err px">

  <p:input port="source" sequence="true"/>
  <p:output port="result"/>
  
  <p:option name="use-first-base" select="'false'"/>

  <p:xslt template-name="join">
    <p:with-param name="method" select="'intersect'">
      <p:empty/>
    </p:with-param>
    <p:with-param name="use-first-base" select="$use-first-base">
      <p:empty/>
    </p:with-param>
    <p:input port="stylesheet">
      <p:document href="../xslt/fileset-join.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>
