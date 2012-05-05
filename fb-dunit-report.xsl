<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT Transformation for XML output of DUNIT (An XTreme testing
	framework for Delphi programs, see http://dunit.sourceforge.net)

	The contents of this file are subject to the Mozilla Public
	License Version 1.1 (the "License"); you may not use this file
	except in compliance with the License. You may obtain a copy of
	the License at http://www.mozilla.org/MPL/

	Software distributed under the License is distributed on an "AS
	IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
	implied. See the License for the specific language governing
	rights and limitations under the License.

	author: Laurent Laffont <llaffont@altaiire.fr>
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:param name="showstatus" select="0" />
  <xsl:param name="showwarnings" select="0" />
	<xsl:template match="/">
	<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="test-results">
	<html>
		<head>
			<title>Test Report</title>
			<link rel="stylesheet" type="text/css" href="fb-dunit-report.css" />
		</head>
		<body>
		<div id="header">
			<h1>DUnit - Test report</h1>
		</div>
		<div id="content">
			<blockquote>
				<table cellpadding="0" border="0" cellspacing="1" width="100%">
					<xsl:apply-templates/>
				</table>
			</blockquote>
		</div>
		</body>
	</html>
	</xsl:template>

	<xsl:template match="application">
		<tr class="tableheader">
			<td colspan="3"><xsl:value-of select="@name"/></td>
		</tr>
	</xsl:template>

	<!--
	<xsl:template match="test-results/test-suite[1]">
		<tr class="tableheader">
			<td colspan="3"><xsl:value-of select="@name"/></td>
			<xsl:choose>
				<xsl:when test="@result='Pass'">
					<td colspan="2" class="testpass"><xsl:value-of select="@result"/></td>
				</xsl:when>
				<xsl:when test="@result='Failure'">
					<td colspan="2" class="testfailure"><xsl:value-of select="@result"/></td>
				</xsl:when>
				<xsl:when test="@result='Error'">
					<td colspan="2" class="testerror"><xsl:value-of select="@result"/></td>
				</xsl:when>
			</xsl:choose>
		</tr>
		<tr></tr>
	</xsl:template>
 -->
	<xsl:template match="test-suite">
    <tr class="testsuite">
      <td colspan="5"><xsl:value-of select="@name"/></td>
    </tr>
		<xsl:apply-templates/>
  </xsl:template>

	<xsl:template match="results/test-case">
    <tr class="test">
      <xsl:choose>
				<xsl:when test="@result='Pass'">
					<td colspan="4"><xsl:value-of select="@name"/></td>
					<td class="testpass"><xsl:value-of select="@result"/></td>
				</xsl:when>

				<xsl:when test="@result='Failure'">
					<td><xsl:value-of select="@name"/></td>
					<xsl:apply-templates/>
					<td class="testfailure"><xsl:value-of select="@result"/></td>
				</xsl:when>

				<xsl:when test="@result='Error'">
					<td><xsl:value-of select="@name"/></td>
					<xsl:apply-templates/>
					<td class="testerror"><xsl:value-of select="@result"/></td>
				</xsl:when>
		</xsl:choose>
		</tr>
		<xsl:if test="$showstatus = '1'">
			<xsl:call-template name="status" />
		</xsl:if>
		<xsl:if test="$showstatus = '1'">
			<xsl:call-template name="warnings" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="failure">
		<td><xsl:apply-templates/></td>
	</xsl:template>

	<xsl:template match="Location">
		<td><xsl:apply-templates/></td>
	</xsl:template>

	<xsl:template match="message">
		<td colspan="2"><xsl:apply-templates/></td>
	</xsl:template>

	<xsl:template match="statistics">
		 <blockquote>
			 <table width="300px">
				 <tr>
		 <td colspan="2" class="statistics">Statistics</td>
	 </tr>
				 <xsl:apply-templates/>
			 </table>
		</blockquote>
	</xsl:template>

	<xsl:template match="stat">
		 <tr>
			 <td class="statname" width="50px"><xsl:value-of select="@name" /></td>
			 <td class="statvalue" width="50px"><xsl:value-of select="@value" /></td>
		 </tr>
	</xsl:template>
	<xsl:template name="status" match="status" >
		<xsl:if test="$showstatus = '1'">
			<xsl:for-each select="status">
			 <tr>
				<td></td>
				 <td colspan="4" ><xsl:value-of select="." /></td>
			 </tr>
		 </xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="warnings" match="warning" >
		<xsl:if test="$showwarnings = '1'">
			<xsl:for-each select="warning">
			 <tr>
				<td></td>
				 <td colspan="4" ><xsl:value-of select="." /></td>
			 </tr>
		 </xsl:for-each>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>


