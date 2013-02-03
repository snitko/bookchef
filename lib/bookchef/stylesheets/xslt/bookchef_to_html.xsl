<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:code="code_prefix">
  <xsl:output indent="yes" omit-xml-declaration="yes"/>


  <!-- Identity template -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="/">
    <html>
      <xsl:apply-templates select="@* | node()" />
    </html>
  </xsl:template>


  <xsl:template match="book">
    <body>
      <xsl:apply-templates select="@* |node()" />
    </body>
  </xsl:template>


  <xsl:template match="title">
    <h1>
      <xsl:apply-templates select="@* |node()" />
    </h1>
  </xsl:template>


  <xsl:template match="chapter">
    <div class="chapter">
      <xsl:apply-templates select="@* |node()" />
    </div>
  </xsl:template>

  <xsl:template match="section">
    <div class="section">
      <xsl:apply-templates select="@* |node()" />
    </div>
  </xsl:template>



  <xsl:template match="footnotes">
    <div class="footnotes">
      <xsl:apply-templates select="@* |node()" />
    </div>
  </xsl:template>

  <xsl:template match="footnote">
    <div class="footnote">
      <xsl:apply-templates select="@* |node()" />
    </div>
  </xsl:template>


  <xsl:template match="references">
    <div class="references">
      <xsl:apply-templates select="@* |node()" />
    </div>
  </xsl:template>

  <xsl:template match="*[@reference]">
    <xsl:param name="href" select="./@reference"/>
    <span class="referenceSelection">
      <xsl:value-of select="."/>
      <xsl:text>#x20;</xsl:text><a href="{$href}">[<xsl:value-of select="./@number"/>]</a>
    </span>
  </xsl:template>


  <xsl:template match="*[@footnote]">
    <xsl:param name="href" select="./@reference"/>
    <span class="footnoteSelection">
      <xsl:value-of select="."/>
      <a href="{$href}"><sup><xsl:value-of select="./@number"/></sup></a>
    </span>
  </xsl:template>

  <xsl:template match="reference">
    <xsl:param name="id"   select="./@id"/>
    <xsl:param name="type" select="./@type"/>
    <xsl:param name="url"  select="./@url"/>
    <xsl:param name="gem_path">#{gem_path}</xsl:param>
    <div class="reference" id="{$id}">
      <img src="{$gem_path}/{$type}_link.png" />
      <a href="{$url}"><xsl:value-of select="."/></a>
    </div>
  </xsl:template>

  <xsl:template match="code|table">
    <p class="frameDescription"><xsl:value-of select="./@description"/></p>
    <xsl:element name="{name()}">
      <xsl:copy-of select="./*"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="code-inline">
    <span class="code inline"><xsl:apply-templates select="@* |node()" /></span>
  </xsl:template>
  

</xsl:stylesheet>
