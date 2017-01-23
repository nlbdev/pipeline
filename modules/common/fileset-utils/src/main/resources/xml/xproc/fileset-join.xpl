<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-join" name="main"
  xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc">

  <p:input port="source" sequence="true"/>
  <p:output port="result" primary="true"/>
  
  <p:option name="use-first-base" select="'false'"/>
  
  <p:xslt template-name="join">
    <p:with-param name="method" select="'join'">
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