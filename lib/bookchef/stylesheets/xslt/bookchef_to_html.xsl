<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common">
  <xsl:output indent="yes" omit-xml-declaration="yes"/>

  <xsl:param name="gem_path">#{gem_path}</xsl:param>

  <!-- Identity template -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/book">
    <html>
      <head>
        <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
        <link href="{$gem_path}/stylesheets/css/default.css" rel="stylesheet" type="text/css"/>
        <xsl:copy-of select="/book/settings/*"/>
      </head>
      <body>
        <xsl:apply-templates select="cover" mode="cover" />
        <div class="tableOfContents">
          <h2>Содержание</h2>
          <ul><xsl:apply-templates select="chapter" mode="table_of_contents" /></ul>
        </div>
        <xsl:apply-templates select="@* | node()" />
      </body>
    </html>
  </xsl:template>

  <xsl:template match="cover" mode="cover">
    <div class="cover"><xsl:apply-templates select="@* | node()" /></div>
  </xsl:template>
  <xsl:template match="cover">
  </xsl:template>

  <xsl:template match="/book/settings">
  </xsl:template>

  <xsl:template match="section/title">
    <h1><xsl:value-of select="." /></h1>
  </xsl:template>
  <xsl:template match="chapter/title">
    <h1>Глава <xsl:number count="chapter"/>. <xsl:value-of select="." /></h1>
  </xsl:template>

  <xsl:template match="li/title">
    <b><xsl:value-of select="." /></b>
  </xsl:template>

  <xsl:template match="chapter">
    <div class="chapter">
      <xsl:apply-templates select="@* |node()" />
    </div>
  </xsl:template>

  <xsl:template match="chapter" mode="table_of_contents">
    <li>Глава <xsl:number count="chapter"/>. <a href="#{@id}"><xsl:value-of select="./title"/></a></li> 
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
    <xsl:param name="id" select="./@id"/>
    <div class="footnote" id="{$id}">
      <sup><xsl:number count="footnote" level="single"/></sup><xsl:text> </xsl:text>
      <xsl:apply-templates select="node()"/>
    </div>
  </xsl:template>


  <xsl:template match="references">
    <div class="references">
      <xsl:apply-templates select="@* |node()" />
    </div>
  </xsl:template>

  <xsl:template match="reference">
    <xsl:param name="id"   select="./@id"/>
    <xsl:param name="type" select="./@type"/>
    <xsl:param name="url"  select="./@url"/>
    <div class="reference" id="{$id}">
      <img src="{$gem_path}/images/{$type}_link.png" />
      [<xsl:number count="reference" level="single"/>]<xsl:text> </xsl:text>
      <a href="{$url}"><xsl:value-of select="."/></a>
    </div>
  </xsl:template>

  <xsl:template match="code|table">
    <p class="frameDescription"><xsl:value-of select="./@description"/><xsl:text> </xsl:text></p>
    <xsl:element name="{name()}">
      <xsl:copy-of select="./node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="code-inline" >
    <span class="code inline"><xsl:apply-templates select="@* |node()" /></span>
  </xsl:template>

  <xsl:template match="name" >
    <span class="name"><xsl:apply-templates select="@* |node()" /></span>
  </xsl:template>

  <xsl:template match="filename" >
    <span class="filename"><xsl:apply-templates select="@* |node()" /></span>
  </xsl:template>

  <xsl:template match="a[not(node())]">
    <xsl:param name="href" select="./@href"/>
    <xsl:variable name="name"><xsl:value-of select='translate($href, "#", "")'/></xsl:variable>
    <a href="{$href}"><xsl:value-of select="//*[@id=$name]/title"/></a>
  </xsl:template>

  <xsl:template match="term" name="term">
    <i><xsl:apply-templates select="@* |node()"/></i>
  </xsl:template>

  <xsl:template match="*[@reference]" >
    <xsl:param name="href" select="./@reference"/>
    <xsl:choose>

      <xsl:when test="name() = 'span'">
        <span class="referenceSelection">
          <xsl:value-of select="."/>
        </span>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="reference_content">
          <xsl:element name="{name()}">
            <xsl:value-of select="."/>
          </xsl:element>
        </xsl:variable>
        <xsl:apply-templates select="exslt:node-set($reference_content)"/>
      </xsl:otherwise>

    </xsl:choose>

    <xsl:text> </xsl:text><a href="#{$href}">[<xsl:value-of select="./@number"/>]</a>

  </xsl:template>

  <xsl:template match="*[@footnote]" >
    <xsl:param name="href" select="./@footnote"/>

    <xsl:choose>
      <xsl:when test="name() = 'span'">
        <span class="footnoteSelection">
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="footnote_content">
          <xsl:element name="{name()}">
            <xsl:value-of select="."/>
          </xsl:element>
        </xsl:variable>
        <xsl:apply-templates select="exslt:node-set($footnote_content)"/>
      </xsl:otherwise>
    </xsl:choose>

    <a href="#{$href}"><sup><xsl:value-of select="./@number"/></sup></a>

  </xsl:template>

</xsl:stylesheet>
