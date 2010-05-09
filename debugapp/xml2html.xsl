<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8" indent="yes"/>

<xsl:template match="/feed">
	<html>
		<head>
			<title>Results</title>
		</head>
		<body>
			<ul>
				<xsl:apply-templates select="entry"/>
			</ul>
		</body>
	</html>
</xsl:template>

<xsl:template match="entry">
	<xsl:variable name="userlink" select="user/profileUrl"/>
	<li>
		 (from <xsl:apply-templates select="service/name"/>)<br/>
		<b><xsl:apply-templates select="title"/></b><br/>
		- <a href="$userlink"><xsl:apply-templates select="user/nickname"/> (<xsl:apply-templates select="user/name"/>)</a><br/>
		<xsl:apply-templates select="published"/>
	</li>
</xsl:template>

</xsl:stylesheet>