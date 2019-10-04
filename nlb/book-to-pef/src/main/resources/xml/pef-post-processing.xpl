<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="nlb:pef-post-processing" version="1.0"
                xmlns:nlb="http://www.nlb.no/ns/pipeline/xproc"
                xmlns:p="http://www.w3.org/ns/xproc"
                exclude-inline-prefixes="#all"
                name="main">
	
	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Analyze the PEF and add some metadata.</p>
	</p:documentation>
	
	<p:input port="source"/>
	<p:output port="result"/>
	
	<p:xslt name="report">
		<p:input port="source">
			<p:pipe step="main" port="source"/>
			<p:document href="../META-INF/maven/version.xml"/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="pef-post-processing.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
</p:declare-step>
