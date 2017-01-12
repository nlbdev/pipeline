<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-diff" name="main"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
  exclude-inline-prefixes="px">

  <p:input port="source" sequence="true" primary="true"/>
  <p:input port="secondary" sequence="true">
    <p:empty/>
  </p:input>
  <p:output port="result"/>
  
  <p:option name="use-first-base" select="'true'"/>
  <p:option name="left-diff" select="'true'"/>
  
  <p:xslt template-name="join">
    <p:with-param name="method" select="if ($left-diff = 'true') then 'left-diff' else 'diff'">
      <p:empty/>
    </p:with-param>
    <p:with-param name="use-first-base" select="$use-first-base">
      <p:empty/>
    </p:with-param>
    <p:input port="source">
      <p:pipe port="source" step="main"/>
      <p:pipe port="secondary" step="main"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/fileset-join.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>
