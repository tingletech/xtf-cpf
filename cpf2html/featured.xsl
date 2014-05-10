<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   xmlns:session="java:org.cdlib.xtf.xslt.Session"
   xmlns:editURL="http://cdlib.org/xtf/editURL"
   xmlns=""
  xmlns:eac="urn:isbn:1-931666-33-4"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:tmpl="xslt://template"
   extension-element-prefixes="session"
   exclude-result-prefixes="#all"
   version="2.0">
   
   <!-- ====================================================================== -->
   <!-- Import Common Templates                                                -->
   <!-- ====================================================================== -->
   
   <xsl:import href="google-tracking.xsl"/>
   <xsl:include href="../style/crossQuery/resultFormatter/common/resultFormatterCommon.xsl"/>
   <!-- xsl:include href="../style/crossQuery/resultFormatter/default/searchForms.xsl"/ -->
   
   <!-- ====================================================================== -->
   <!-- Output                                                                 -->
   <!-- ====================================================================== -->

   <xsl:output encoding="UTF-8" media-type="text/html" indent="yes"
      method="xhtml" doctype-system="about:legacy-compat"
      omit-xml-declaration="yes"
      exclude-result-prefixes="#all"/>

    <xsl:param name="css.path" select="concat($xtfURL, 'css/default/')"/>
    <xsl:param name="icon.path" select="concat($xtfURL, 'icons/default/')"/>
    <xsl:param name="appBase.path"/>

   <xsl:param name="asset-base.value"/>
   <xsl:include href="data-xsl-asset.xsl"/> 
   
   <!-- ====================================================================== -->
   <!-- Local Parameters                                                       -->
   <!-- ====================================================================== -->
 
   <xsl:param name="docHits" select="/crossQueryResult/docHit"/>
   <xsl:param name="http.URL"/>
   <!-- xsl:param name="text"/ -->
   <!-- xsl:param name="keyword" select="$text"/ -->

   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->

  <!-- keep gross layout in an external file -->
  <xsl:variable name="layout" select="document('search.html')"/>
  <xsl:variable name="footer" select="document('footer.html')"/>
  <xsl:variable name="queryStringClean" select="replace($queryString,'http://.*/xtf/search','')"/>

  <!-- load input XML into page variable -->
  <xsl:variable name="page" select="/"/>

  <!-- apply templates on the layout file; rather than walking the input XML -->
  <xsl:template match="/">
    <xsl:apply-templates select="($layout)//*[local-name()='html']" mode="html-template"/>
    <xsl:comment>
        url: <xsl:value-of select="$http.URL"/>
        xslt: <xsl:value-of select="static-base-uri()"/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match='*[@tmpl:process-markup="sectionType"]|*[data-xsl="sectionType"]' mode="html-template">
    <xsl:element name="{name(.)}">
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <xsl:attribute name="title"><xsl:value-of select="@title"/></xsl:attribute>
      <xsl:for-each select="@name">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates mode="sectionType-selected"/>
      <xsl:if test="
        $sectionType='cpfdescription' 
        or editURL:remove(editURL:remove($queryStringClean,'facet-identityAZ'),'facet-entityType')=''
      ">
        <script>
  $("label.advancedSearch").hide();
  $("form.cpfSearch").hoverIntent(function () {
    $("label.advancedSearch").css("display", "inline");
  }, function () {
    if ($("label.advancedSearch select").val() === 'cpfdescription') {
      $("label.advancedSearch").fadeOut();
    }
  });
        </script>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*:select" mode="sectionType-selected">
    <xsl:element name="{name(.)}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates mode="sectionType-selected"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*:option" mode="sectionType-selected">
    <xsl:element name="{name(.)}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <!-- add selected attribute / default cpfdescription if no serach -->
      <xsl:if test="($sectionType = @value) 
		or ( $text='' and @value = 'cpfdescription')">
        <xsl:attribute name="selected" select="'selected'"/>
      </xsl:if>
      <xsl:apply-templates mode="html-template"/>
    </xsl:element>
  </xsl:template>

  <xsl:function name="tmpl:entityTypeLabel">
    <xsl:param name="entity"/>
    <xsl:value-of select="if ($entity='') then 'All' 
                     else if ($entity='person') then 'Person'
                     else if ($entity='family') then 'Family'
                     else if ($entity='corporateBody') then 'Organization'
                        else ''"/>
  </xsl:function>

  <!-- skips -->
  <xsl:template
    match="*[@data-xsl='top-facets']|*[@data-xsl='AZ']|*[@data-xsl='clear-search']|*[@data-xsl='result_summary']"
    mode="html-template">
  </xsl:template>

  <xsl:template match="*[@data-xsl='BW-facet']" mode="html-template">
    <div class="filternav">&#160;</div>
  </xsl:template>

  <xsl:template match="*[@data-xsl='browsenav']" mode="html-template">
               <div class="browsenav" data-xsl='browsenav'>
                  <ul>
                     <li class="active"><a href="">Featured</a></li>
                     <li> 
                        <a href="search?sectionType=cpfdescription">Name</a>
                     </li>
                     <li> 
                        <a href="search?sectionType=cpfdescription;browse-json=facet-occupation">Occupation</a>
                     </li>
                     <li> 
                        <a href="search?sectionType=cpfdescription;browse-json=facet-localDescription">Subject</a>
                     </li>
                  </ul>
               </div>
  </xsl:template>


  <!-- <form method="GET" action="/xtf/search"> -->
  <xsl:template match="form[@action='/xtf/search']" mode="html-template">
    <form method="GET" action="{$appBase.path}search">
      <xsl:apply-templates mode="html-template"/>
    </form>
  </xsl:template>

  <xsl:template match="*[@data-xsl='search']" mode="html-template">
    <!-- hidden search elements -->
    <xsl:apply-templates select="$page/crossQueryResult/parameters/param[matches(@name,'^f[0-9]+-')],$page/crossQueryResult/parameters/param[@name='facet-entityType']" mode="hidden-facets"/>
    <xsl:element name="{name()}">
      <xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
      <xsl:attribute name="value">
        <xsl:value-of select="$text"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[@data-snac-grid]" mode="html-template">
      <div style="padding: 1em; ">
  <a href=""><button type="button" class="btn btn-warning btn-lg">
    <span class="glyphicon glyphicon-refresh"></span>
    Explore featured records
    </button></a>

      </div>

      <div class="row list-comments">
      <xsl:apply-templates select="$page/crossQueryResult/docHit" mode="thumb">
        <xsl:sort select="meta/identity[1]"/>
      </xsl:apply-templates>
      </div>
  </xsl:template>

  <xsl:template match="docHit" mode="thumb">

<div class="thumbnail">
  <div style="float: none;">
    <a href="{meta/recordIds[1]}">
      <!-- img src="{meta/facet-wikithumb[1]/@thumb}" style="Min-width: 155px;" class="Img-responsive" alt=""></img -->
      <img src="{meta/facet-wikithumb[1]/@thumb}" alt=""></img>
    </a>
    <a href="{meta/facet-wikithumb[1]/@rights}" class="wikicreditlink">
      <p class="text-center" style="margin-top: -1.5em;"><span class="wikicredit">Image from Wikipedia</span></p>
    </a>
  </div>
  <div class="caption">
    <div class="text-muted"><xsl:value-of select="meta/count-ArchivalResource"/> related collections</div>
    <h4><a href="{meta/recordIds[1]}"><xsl:value-of select="meta/identity[1]"/></a></h4>
  </div>
</div>
  </xsl:template>

  <xsl:template match="facet-Location" mode="locations">
    <xsl:apply-templates/>
    <xsl:text>, </xsl:text>
  </xsl:template>

  <!-- identity transform copies HTML from the layout file -->

  <xsl:template match="*" mode="html-template sectionType-selected">
    <xsl:element name="{name(.)}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name(.)}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates mode="html-template"/>
    </xsl:element>
  </xsl:template>

   
</xsl:stylesheet>
   <!--
      Copyright (c) 2014, Regents of the University of California
      All rights reserved.
      
      Redistribution and use in source and binary forms, with or without 
      modification, are permitted provided that the following conditions are 
      met:
      
      - Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
      - Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in the 
      documentation and/or other materials provided with the distribution.
      - Neither the name of the University of California nor the names of its
      contributors may be used to endorse or promote products derived from 
      this software without specific prior written permission.
      
      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
      AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
      IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
      ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
      LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
      CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
      SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
      INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
      CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
      ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
      POSSIBILITY OF SUCH DAMAGE.
   -->
