<!--

 OpenOffice2MediaWiki 0.3
 Copyright (C) 2006 Xiloynaha
 Last modification : 07 2006, Yann Coupin
 
 OpenOffice2MediaWiki is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 OpenOffice2MediaWiki is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

 Derived OOo2MediaWiki.xslt developed by Andrea Rossato
 (http://uniwakka.sourceforge.net/OpenOffice2UniWakka).
 Adapted to MediaWiki by Xiloynaha.
 Bug corrections, images and tables implementation by Yann Coupin.
-->

<!-- 

Supporte :
* niveaux de titre 1 à 8
* soulignement
* italique
* gras
* centrage (ne fonctionne que lorsque le texte est seulement centré, pas s'il est centré et gras par exemple)
* tableaux
* gestion des images : génération d'un fichier connexe avec lien automatique

Merci à Yann Coupin pour les deux derniers points.

Il reste des éléments de conversion propres à UniWakka, ça disparaitra (peut-être) au fur et à mesure de mes besoins.

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:office="http://openoffice.org/2000/office" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" xmlns:java="http://xml.apache.org/xalan/java">
	<xsl:output method="text" />
	<xsl:strip-space elements="*"/>
	<!-- Catch the non-content document sections -->
	<xsl:template match="/XML"/>
	<xsl:template match="/office:document/office:meta"/>
	<xsl:template match="/office:document/office:settings"/>
	<xsl:template match="/office:document/office:script"/>
	<xsl:template match="/office:document/office:font-decls"/>
	<xsl:template match="/office:document/office:document-styles"/>
	<xsl:template match="/office:document/office:automatic-styles"/>
	<xsl:template match="/office:document/office:styles"/>
	<xsl:template match="/office:document/office:master-styles"/>
	<!-- Formats the text sections according to the style name -->
	<xsl:template name="style-font">
		<xsl:param name="style"/>
		<xsl:variable name="font-style" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@fo:font-style"/>
		<xsl:variable name="font-weight" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@fo:font-weight"/>
		<xsl:variable name="font-underline" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@style:text-underline"/>
		<xsl:variable name="centered" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@fo:text-align"/>
		<xsl:variable name="indented" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@fo:margin-left"/>
		<xsl:variable name="supscript" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@style:text-position"/>
		<xsl:variable name="subscript" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@style:text-position"/>
		<xsl:variable name="linethrough" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@style:text-crossing-out"/>

<!-- debug style
		<xsl:text>[</xsl:text>
		<xsl:value-of select="$subscript"/><xsl:text>, </xsl:text>
		<xsl:value-of select="$supscript"/><xsl:text>, </xsl:text>
		<xsl:value-of select="$linethrough"/>
		<xsl:text>]</xsl:text>
-->
		<xsl:choose>
			<xsl:when test="$font-weight='bold' and $font-style='italic' and $font-underline='none'">&apos;&apos;&apos;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='bold' and $font-style='italic' and $font-underline='single'">&lt;u&gt;&apos;&apos;&apos;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='bold' and $font-style='normal' and $font-underline='single'">&lt;u&gt;&apos;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='normal' and $font-style='italic' and $font-underline='single'">&lt;u&gt;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='normal' and $font-style='normal' and $font-underline='single'">&lt;u&gt;</xsl:when>
			<xsl:when test="$font-weight='bold' and not($font-style) and not($font-underline)">&apos;&apos;&apos;</xsl:when>
			<xsl:when test="not($font-weight) and $font-style='italic' and not($font-underline)">&apos;&apos;</xsl:when>
			<xsl:when test="not($font-weight) and not($font-style) and $font-underline='single'">&lt;u&gt;</xsl:when>
			<xsl:when test="$font-weight='bold' and $font-style='normal' and not($font-underline)">&apos;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='normal' and $font-style='italic' and not($font-underline)">&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='bold' and $font-style='italic' and not($font-underline)">&apos;&apos;&apos;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='bold' and not($font-style) and $font-underline='single'">&apos;&apos;&apos;&apos;&apos;</xsl:when>
			<xsl:when test="not($font-weight) and $font-style='italic' and $font-underline='single'">&lt;u&gt;''</xsl:when>
			<xsl:when test="$centered='center'">&lt;center&gt;</xsl:when>
			<xsl:when test="contains($indented, 'cm')">
				<xsl:choose>
					<xsl:when test="translate($indented, 'cm', '') &gt; 0 and translate($indented, 'cm', '') &lt; 2">
					<xsl:text disable-output-escaping="yes">   </xsl:text>
					</xsl:when>
					<xsl:when test="translate($indented, 'cm', '') &gt; 2 and translate($indented, 'cm', '') &lt; 3.5">
					<xsl:text disable-output-escaping="yes">      </xsl:text>
					</xsl:when>
					<xsl:when test="translate($indented, 'cm', '') &gt; 3.5">
					<xsl:text disable-output-escaping="yes">         </xsl:text>
					</xsl:when>
					</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($indented, 'inch')">
				<xsl:choose>
					<xsl:when test="translate($indented, 'inch', '') &gt; 0 and translate($indented, 'inch', '') &lt; 0.5">
					<xsl:text disable-output-escaping="yes">   </xsl:text>
					</xsl:when>
					<xsl:when test="translate($indented, 'inch', '') &gt; 0.5 and translate($indented, 'inch', '') &lt; 1">
					<xsl:text disable-output-escaping="yes">      </xsl:text>
					</xsl:when>
					<xsl:when test="translate($indented, 'inch', '') &gt; 1">
					<xsl:text disable-output-escaping="yes">         </xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($supscript, 'sup')">&lt;sup&gt;</xsl:when>
			<xsl:when test="contains($subscript, 'sub')">&lt;sub&gt;</xsl:when>
			<xsl:when test="contains($linethrough, 'line')">--</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="style-font-close">
		<xsl:param name="style"/>
		<xsl:variable name="font-style" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@fo:font-style"/>
		<xsl:variable name="font-weight" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@fo:font-weight"/>
		<xsl:variable name="font-underline" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@style:text-underline"/>
		<xsl:variable name="centered" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@fo:text-align"/>
		<xsl:variable name="supscript" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@style:text-position"/>
		<xsl:variable name="subscript" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@style:text-position"/>
		<xsl:variable name="linethrough" select="//office:automatic-styles/style:style[@style:name=$style]/style:properties/@style:text-crossing-out"/>

<!-- style debug
		<xsl:text>[</xsl:text>
		<xsl:value-of select="$font-weight"/><xsl:text>, </xsl:text>
		<xsl:value-of select="$font-style"/><xsl:text>, </xsl:text>
		<xsl:value-of select="$font-underline"/>
		<xsl:text>]</xsl:text>
-->

		<xsl:choose>
			<xsl:when test="$font-weight='bold' and $font-style='italic' and $font-underline='none'">&apos;&apos;&apos;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='bold' and $font-style='italic' and $font-underline='single'">&apos;&apos;&apos;&apos;&apos;&lt;/u&gt;</xsl:when>
			<xsl:when test="$font-weight='bold' and $font-style='normal' and $font-underline='single'">&apos;&apos;&apos;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='normal' and $font-style='italic' and $font-underline='single'">&apos;&apos;&lt;/u&gt;</xsl:when>
			<xsl:when test="$font-weight='normal' and $font-style='normal' and $font-underline='single'">&lt;/u&gt;</xsl:when>
			<xsl:when test="$font-weight='bold' and not($font-style) and not($font-underline)">&apos;&apos;&apos;</xsl:when>
			<xsl:when test="not($font-weight) and $font-style='italic' and not($font-underline)">&apos;&apos;</xsl:when>
			<xsl:when test="not($font-weight) and not($font-style) and $font-underline='single'">&lt;/u&gt;</xsl:when>
			<xsl:when test="$font-weight='bold' and $font-style='normal' and not($font-underline)">&apos;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='normal' and $font-style='italic' and not($font-underline)">&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='bold' and $font-style='italic' and not($font-underline)">&apos;&apos;&apos;&apos;&apos;</xsl:when>
			<xsl:when test="$font-weight='bold' and not($font-style) and $font-underline='single'">&apos;&apos;&apos;&lt;/u&gt;</xsl:when>
			<xsl:when test="not($font-weight) and $font-style='italic' and $font-underline='single'">&apos;&apos;&lt;/u&gt;</xsl:when>
			<xsl:when test="$centered='center'">&lt;/center&gt;</xsl:when>
			<xsl:when test="contains($supscript, 'sup')">&lt;/sup&gt;</xsl:when>
			<xsl:when test="contains($subscript, 'sub')">&lt;/sub&gt;</xsl:when>
			<xsl:when test="contains($linethrough, 'line')">--</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Line breaks -->
	<xsl:template match="text:line-break">
	    <xsl:text>&lt;br /&gt;</xsl:text>
	</xsl:template>

	<!-- Text blocks -->
	<xsl:template match="//text:p">
		<xsl:variable name="cur-style-name">
			<xsl:value-of select="@text:style-name"/>
		</xsl:variable>
		<xsl:variable name="text" select="."/>
		<xsl:if test="$text!=''">
			<xsl:call-template name="style-font">
				<xsl:with-param name="style">
					<xsl:value-of select="$cur-style-name"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates/>
			<xsl:call-template name="style-font-close">
				<xsl:with-param name="style">
					<xsl:value-of select="$cur-style-name"/>
				</xsl:with-param>
			</xsl:call-template>
			<!-- these are all newline rules -->
			<xsl:choose>
				<!-- we shouldn't add a newline for elements inside a table -->
				<xsl:when test="ancestor::table:table-cell and not(following-sibling::text:p)">
				</xsl:when>
				<!-- but we would want a new between two text:p in a cell -->
				<xsl:when test="ancestor::table:table-cell and following-sibling::text:p">
				    <xsl:text disable-output-escaping="yes">&lt;br /&gt;</xsl:text>
				</xsl:when>
				<!-- we do want a single newline at the end of a list item -->
				<xsl:when test="ancestor::text:list-item and following::text:list-item">
					<xsl:text disable-output-escaping="yes"> 
</xsl:text>
				</xsl:when>
				<!-- and double at the end of the list-->
				<xsl:when test="preceding-sibling::text:ordered-list or preceding-sibling::text:unordered-list">
					<xsl:text disable-output-escaping="yes">

</xsl:text>
				</xsl:when>
				<xsl:when test="ancestor::text:align='center'">
					<xsl:text disable-output-escaping="yes">
					</xsl:text>
				</xsl:when>

				<xsl:otherwise>
					<xsl:text disable-output-escaping="yes">

</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$text=''">
			<xsl:text disable-output-escaping="yes">

</xsl:text>
		</xsl:if>
	</xsl:template>
	<!-- span formatting -->
	<xsl:template match="//text:span">
		<xsl:variable name="cur-style-name">
			<xsl:value-of select="@text:style-name"/>
		</xsl:variable>
		<xsl:variable name="text" select="."/>
		<xsl:if test="$text!=''">
			<xsl:call-template name="style-font">
				<xsl:with-param name="style">
					<xsl:value-of select="$cur-style-name"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates/>
			<xsl:call-template name="style-font-close">
				<xsl:with-param name="style">
					<xsl:value-of select="$cur-style-name"/>
				</xsl:with-param>
			</xsl:call-template>

		</xsl:if>
	</xsl:template>

	<!-- Tables -->
	<xsl:template match="//table:table|//table:sub-table">
		<!--<xsl:variable name="table-name" select="@table:name"/>-->
		<xsl:if test="name() = 'table:sub-table'">
		    <xsl:text>
</xsl:text>
		</xsl:if>
		<xsl:text disable-output-escaping="yes">{| border="1"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">
|}
</xsl:text>
	</xsl:template>

	<!-- Table header rows -->
	<xsl:template match="//table:table-header-rows">
	    <!--<xsl:text>
!</xsl:text>-->
		<xsl:apply-templates/>
                <xsl:if test="following-sibling::table:table-row">
		<xsl:text disable-output-escaping="yes">
|-</xsl:text>
	</xsl:if>
	</xsl:template>

	<!-- Table rows -->
	<xsl:template match="//table:table-row">
	    <!--
	    <xsl:text>
|</xsl:text>
-->
	    <xsl:apply-templates/>
	    <xsl:if test="following-sibling::table:table-row">
		<xsl:text disable-output-escaping="yes">
|-
</xsl:text>
	</xsl:if>
	</xsl:template>
	<!-- Table cells -->
	<xsl:template match="//table:table//table:table-row/table:table-cell">
	    <xsl:choose>
		<xsl:when test="../../table:table-header-rows">
	    <xsl:text disable-output-escaping="yes">
!</xsl:text>
		</xsl:when>

		<xsl:otherwise>
	    <xsl:text disable-output-escaping="yes">
|</xsl:text>
		</xsl:otherwise>
	    </xsl:choose>
	    <xsl:if test="@table:number-columns-spanned &gt; 1">
		<xsl:text> colspan=&quot;</xsl:text>
		<xsl:value-of select="@table:number-columns-spanned"/>
		<xsl:text>&quot; | </xsl:text>
	    </xsl:if>
	    <xsl:apply-templates/>
	    <xsl:if test="name(following-sibling::node()) = 'table:table-cell'">
	    </xsl:if>
	    <!--		<xsl:value-of select="name(following-sibling::node())"/> -->
	</xsl:template>
	<!-- Handles horizontally merged cells -->
	<xsl:template match="//table:covered-table-cell">
		<xsl:text disable-output-escaping="yes"></xsl:text>
	</xsl:template>
	<!-- Table of Contents -->
	<xsl:template match="//text:table-of-content">
		<xsl:text disable-output-escaping="yes">__TOC__
</xsl:text>
	</xsl:template>
	<!-- Headings -->
	<xsl:template match="//text:h[@text:level='1']">
		<xsl:text disable-output-escaping="yes">== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ==

</xsl:text>
	</xsl:template>
	<xsl:template match="//text:h[@text:level='2']">
		<xsl:text disable-output-escaping="yes">=== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ===

</xsl:text>
	</xsl:template>
	<xsl:template match="//text:h[@text:level='3']">
		<xsl:text disable-output-escaping="yes">==== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ====

</xsl:text>
	</xsl:template>
	<xsl:template match="//text:h[@text:level='4']">
		<xsl:text disable-output-escaping="yes">===== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> =====
</xsl:text>
	</xsl:template>
	<xsl:template match="//text:h[@text:level='5']">
		<xsl:text disable-output-escaping="yes">====== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ======

</xsl:text>
	</xsl:template>
	<xsl:template match="//text:h[@text:level='6']">
		<xsl:text disable-output-escaping="yes">======= </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> =======

</xsl:text>
	</xsl:template>
	<xsl:template match="//text:h[@text:level='7']">
		<xsl:text disable-output-escaping="yes">======== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ========

</xsl:text>
	</xsl:template>
	<xsl:template match="//text:h[@text:level='8']">
		<xsl:text disable-output-escaping="yes">========= </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> =========

</xsl:text>
	</xsl:template>
	<xsl:template match="//text:h[@text:level='9']">
		<xsl:text disable-output-escaping="yes">
</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">

</xsl:text>
	</xsl:template>
	<xsl:template match="//text:h[@text:level='10']">
		<xsl:text disable-output-escaping="yes">
</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">

</xsl:text>

	</xsl:template>
	<xsl:template match="//text:p[@text:style-name='Heading 1']">
		<xsl:text disable-output-escaping="yes">== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ==</xsl:text>
	</xsl:template>

	<xsl:template match="//text:p[@text:style-name='Heading 2']">
		<xsl:text disable-output-escaping="yes">=== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ===</xsl:text>
	</xsl:template>
	<xsl:template match="//text:p[@text:style-name='Heading 3']">
		<xsl:text disable-output-escaping="yes">==== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ====</xsl:text>
	</xsl:template>
	<xsl:template match="//text:p[@text:style-name='Heading 4']">
		<xsl:text disable-output-escaping="yes">===== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> =====</xsl:text>
	</xsl:template>
	<xsl:template match="//text:p[@text:style-name='Heading 5']">
		<xsl:text disable-output-escaping="yes">====== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ======</xsl:text>
	</xsl:template>
	<xsl:template match="//text:p[@text:style-name='Heading 6']">
		<xsl:text disable-output-escaping="yes">======= </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> =======</xsl:text>
	</xsl:template>
	<xsl:template match="//text:p[@text:style-name='Heading 7']">
		<xsl:text disable-output-escaping="yes">======== </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> ========</xsl:text>
	</xsl:template>
	<xsl:template match="//text:p[@text:style-name='Heading 8']">
		<xsl:text disable-output-escaping="yes">========= </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"> =========</xsl:text>
	</xsl:template>
	<xsl:template match="//text:p[@text:style-name='Heading 9']">
		<xsl:text disable-output-escaping="yes"></xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"></xsl:text>
	</xsl:template>
	<xsl:template match="//text:p[@text:style-name='Heading 10']">
		<xsl:text disable-output-escaping="yes"></xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes"></xsl:text>
	</xsl:template>


	<!-- Footnote -->
	<xsl:template match="//text:footnote-body">
		<xsl:text disable-output-escaping="yes">{{fn </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">}}</xsl:text>
	</xsl:template>
	<xsl:template match="//text:footnote-citation">
	</xsl:template>

	<!-- my styles -->
	<xsl:template match="//text:span[@text:style-name='emph']">
		<xsl:text disable-output-escaping="yes">''</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">''</xsl:text>
	</xsl:template>
	<xsl:template match="//text:span[@text:style-name='italic']">
		<xsl:text disable-output-escaping="yes">&apos;&apos;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">&apos;&apos;</xsl:text>
	</xsl:template>
	<xsl:template match="//text:span[@text:style-name='underline']">
		<xsl:text disable-output-escaping="yes">&lt;u&gt;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">&lt;/u&gt;</xsl:text>
	</xsl:template>
	<xsl:template match="//text:span[@text:style-name='textbf']">
		<xsl:text disable-output-escaping="yes">&apos;&apos;&apos;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">&apos;&apos;&apos;</xsl:text>
	</xsl:template>

	<xsl:template match="//text:span[@text:style-name='linethrough']">
		<xsl:text disable-output-escaping="yes">--</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">--</xsl:text>
	</xsl:template>
	<xsl:template match="//text:span[@text:style-name='subscript']">
	    <xsl:text disable-output-escaping="yes">&lt;sub&gt;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">&lt;/sub&gt;</xsl:text>
	</xsl:template>
	<xsl:template match="//text:span[@text:style-name='supscript']">
		<xsl:text disable-output-escaping="yes">&lt;sup&gt;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">&lt;/sup&gt;</xsl:text>
	</xsl:template>


	<!-- biblio citations -->

	<xsl:template match="//text:span[@text:style-name='bibliocit']">
		<xsl:text disable-output-escaping="yes">[[cite </xsl:text>
		<xsl:apply-templates/>
		<xsl:text disable-output-escaping="yes">]]</xsl:text>
	</xsl:template>

	<!-- links -->
	<xsl:template match="//text:a">
		<xsl:variable name="link">
			<xsl:value-of select="@xlink:href"/>
		</xsl:variable>
		<xsl:variable name="link-text">
			<xsl:value-of select="."/>
		</xsl:variable>
		<xsl:choose>
		<xsl:when test="$link = $link-text">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text disable-output-escaping="yes">[</xsl:text>
			<xsl:value-of select="$link"/>
			<xsl:text disable-output-escaping="yes"> </xsl:text>
			<xsl:apply-templates/>
			<xsl:text disable-output-escaping="yes">]</xsl:text>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- images -->
	<xsl:template match="draw:image">
	    <xsl:text disable-output-escaping="yes" >[[Image:</xsl:text>
	    <xsl:value-of select="@draw:name"/>
	    <xsl:text disable-output-escaping="yes" >]]</xsl:text>
	    <xsl:variable name="outfile" select="java:java.io.FileOutputStream.new(string(@draw:name))"/>
	    <xsl:variable name="b64decoder" select="java:sun.misc.BASE64Decoder.new()"/>
	    <xsl:variable name="write" select="java:write($outfile, java:decodeBuffer($b64decoder, office:binary-data))"/>
	    <xsl:variable name="close" select="java:close($outfile)"/>
	</xsl:template>

	<!-- lists -->
	<xsl:template match="//text:unordered-list/text:list-item">
		<xsl:variable name="level">
			<xsl:value-of select="count(ancestor::text:unordered-list | ancestor::text:ordered-list)"/>
		</xsl:variable>
		<xsl:if test="$level=1">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">   - </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=2">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">      - </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=3">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">         - </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=4">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">            - </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=5">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">               - </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=6">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">                  - </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=7">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">                     - </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="//text:ordered-list/text:list-item">
		<xsl:variable name="level">
			<xsl:value-of select="count(ancestor::text:ordered-list | ancestor::text:unordered-list)"/>
		</xsl:variable>
		<xsl:variable name="number-type" select="1"/>
		<xsl:variable name="num-type">
		<xsl:choose>
			<xsl:when test="../@text:style-name='upper-roman' or //office:automatic-styles/text:list-style[text:list-level-style-number[@text:level = $level and @style:num-format = 'I']]">
				<xsl:text>I</xsl:text>
			</xsl:when>
			<xsl:when test="../@text:style-name='lower-roman' or //office:automatic-styles/text:list-style[text:list-level-style-number[@text:level = $level and @style:num-format = 'i']]">
				<xsl:text>i</xsl:text>
			</xsl:when>
			<xsl:when test="../@text:style-name='upper-alpha' or //office:automatic-styles/text:list-style[text:list-level-style-number[@text:level = $level and @style:num-format = 'A']]">
				<xsl:text>A</xsl:text>
			</xsl:when>
			<xsl:when test="../@text:style-name='lower-alpha' or //office:automatic-styles/text:list-style[text:list-level-style-number[@text:level = $level and @style:num-format = 'a']]">
				<xsl:text>a</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		<xsl:if test="$level=1">
			<xsl:choose>
				<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
				</xsl:when>
				<xsl:otherwise>
					<xsl:text disable-output-escaping="yes">   </xsl:text>
					<xsl:value-of select="$num-type"/>
					<xsl:text disable-output-escaping="yes">) </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=2">

			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">

			</xsl:when>

			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">      </xsl:text>
				<xsl:value-of select="$num-type"/>
				<xsl:text disable-output-escaping="yes">) </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=3">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">

			</xsl:when>

			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">         </xsl:text>
				<xsl:value-of select="$num-type"/>
				<xsl:text disable-output-escaping="yes">) </xsl:text>
			</xsl:otherwise>
			</xsl:choose>

		</xsl:if>
		<xsl:if test="$level=4">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">            </xsl:text>
				<xsl:value-of select="$num-type"/>
				<xsl:text disable-output-escaping="yes">) </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=5">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">               </xsl:text>
				<xsl:value-of select="$num-type"/>
				<xsl:text disable-output-escaping="yes">) </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=6">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">                  </xsl:text>
				<xsl:value-of select="$num-type"/>
				<xsl:text disable-output-escaping="yes">) </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$level=7">
			<xsl:choose>
			<xsl:when test="not(following-sibling::text:list-item) and not(text:p | text:a)">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">                     </xsl:text>
				<xsl:value-of select="$num-type"/>
				<xsl:text disable-output-escaping="yes">) </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>
</xsl:stylesheet>
