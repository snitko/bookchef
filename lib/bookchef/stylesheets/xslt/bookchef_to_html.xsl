<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common">
  <xsl:output indent="yes" omit-xml-declaration="yes"/>

  <xsl:param name="gem_path">#{gem_path}</xsl:param>

  <!-- Identity template -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

 <xsl:template name="string-replace-all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:variable name="mdash"><xsl:text disable-output-escaping="yes"> <![CDATA[#mdash;]]> </xsl:text></xsl:variable>
    <xsl:call-template name="string-replace-all">
      <xsl:with-param name="text" select="." />
      <xsl:with-param name="replace" select='" - "'/>
      <xsl:with-param name="by" select='$mdash' />
    </xsl:call-template>
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
        <xsl:apply-templates select="node()" />
      </body>
    </html>
  </xsl:template>

  <xsl:template match="cover" mode="cover">
    <div class="cover"><xsl:apply-templates select="@* | node()" /></div>
  </xsl:template>
  <xsl:template match="cover">
  </xsl:template>

  <xsl:template match="InsertBookVersion">
    <xsl:value-of select="/book/@version" />
  </xsl:template>

  <xsl:template match="/book/settings">
  </xsl:template>

  <xsl:template match="section/title">
    <h1 id="{../@id}"><xsl:value-of select="." /></h1>
  </xsl:template>
  <xsl:template match="chapter/title">
    <h1 id="{../@id}">Глава <xsl:number count="chapter"/>. <xsl:value-of select="." /></h1>
  </xsl:template>

  <xsl:template match="li/title">
    <b><xsl:value-of select="." /></b>
  </xsl:template>

  <xsl:template match="chapter">
    <div class="chapter">
      <xsl:apply-templates select="@* |node()" />
    </div>
  </xsl:template>
  <xsl:template match="chapter/@id">
  </xsl:template>

  <xsl:template match="chapter" mode="table_of_contents">
    <li>Глава <xsl:number count="chapter"/>. <a href="#{@id}"><xsl:value-of select="./title"/></a></li> 
  </xsl:template>

  <xsl:template match="section">
    <div class="section">
      <xsl:apply-templates select="@* |node()" />
    </div>
  </xsl:template>
  <xsl:template match="section/@id">
  </xsl:template>

  <xsl:template match="pagebreak">
    <div class="insertPageBreak"></div>
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

  <xsl:template match="code">
    <p class="frameDescription"><xsl:value-of select="./@description"/><xsl:text> </xsl:text></p>
    <xsl:element name="{name()}">
      <xsl:copy-of select="./node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="table">
    <p class="frameDescription"><xsl:value-of select="./@description"/><xsl:text> </xsl:text></p>
    <table><xsl:apply-templates select="./node()" /></table>
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

  <xsl:template match="keyboard" >
    <span class="keyboard"><xsl:apply-templates select="@* |node()" /></span>
  </xsl:template>

  <xsl:template match="a[not(node())]">
    <xsl:param name="href"      select="./@href"/>
    <xsl:param name="reference" select="./@reference"/>

    <xsl:choose>
      <xsl:when test="$href != ''">
        <xsl:variable name="name"><xsl:value-of select='translate($href, "#", "")'/></xsl:variable>
        <a href="{$href}"><xsl:value-of select="//*[@id=$name]/title"/></a>
      </xsl:when>
      <xsl:when test="$reference != ''">
        <xsl:variable name="title"><xsl:value-of select='//reference[@id=$reference]'/></xsl:variable>
        <xsl:variable name="url"><xsl:value-of select='//reference[@id=$reference]/@url'/></xsl:variable>
        <a href="{$url}"><xsl:value-of select="$title"/></a>
      </xsl:when>
    </xsl:choose>

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
