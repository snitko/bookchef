<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output indent="yes" omit-xml-declaration="yes"/>

  <xsl:param name="gem_path">#{gem_path}</xsl:param>

  <!-- Identity template -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
        <link href="{$gem_path}/stylesheets/css/default.css" rel="stylesheet" type="text/css"/>
      </head>
      <xsl:apply-templates select="@* | node()" />
    </html>
  </xsl:template>


  <xsl:template match="book">
    <body>
      <xsl:apply-templates select="@* |node()" />
    </body>
  </xsl:template>


  <xsl:template match="title">
    <h1><xsl:value-of select="." /></h1>
  </xsl:template>
  <xsl:template match="chapter/title">
    <h1>Глава <xsl:number count="chapter"/>: <xsl:value-of select="." /></h1>
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
      <xsl:text> </xsl:text><a href="{$href}">[<xsl:value-of select="./@number"/>]</a>
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
    <div class="reference" id="{$id}">
      <img src="{$gem_path}/images/{$type}_link.png" />
      <a href="{$url}"><xsl:value-of select="."/></a>
    </div>
  </xsl:template>

  <xsl:template match="code|table">
    <p class="frameDescription"><xsl:value-of select="./@description"/><xsl:text> </xsl:text></p>
    <xsl:element name="{name()}">
      <xsl:copy-of select="./node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="code-inline">
    <span class="code inline"><xsl:apply-templates select="@* |node()" /></span>
  </xsl:template>

  <xsl:template match="name">
    <span class="name"><xsl:apply-templates select="@* |node()" /></span>
  </xsl:template>

  <xsl:template match="filename">
    <span class="filename"><xsl:apply-templates select="@* |node()" /></span>
  </xsl:template>

</xsl:stylesheet>
