<?xml version="1.0" encoding="utf-8"?>
<!-- 
  Copyright 2011 Regents of the University of California
  All rights reserved.  

  some portions of this file derived from 
  http://code.google.com/p/xml2json-xslt/source/browse/trunk/xml2json.xslt

  Copyright (c) 2006,2008 Doeke Zanstra
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, 
  are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer. Redistributions in binary 
  form must reproduce the above copyright notice, this list of conditions and the 
  following disclaimer in the documentation and/or other materials provided with 
  the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
  THE POSSIBILITY OF SUCH DAMAGE.

-->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
>
  <xsl:output indent="no" method="text" encoding="UTF-8" media-type="application/json"/>
  <xsl:strip-space elements="*"/>
  <xsl:param name="callback"/>

  <xsl:template match="/">
    <!-- regex on callback parameter to sanitize user input -->
    <!-- http://www.w3.org/TR/xmlschema-2/ '\c' = the set of name characters, those ·match·ed by NameChar -->
    <xsl:if test="$callback">
      <xsl:value-of select="replace(replace($callback,'[^\c]',''),':','')"/>
      <xsl:text>(</xsl:text>
    </xsl:if>
    <xsl:text>{"objset_total":</xsl:text>
    <xsl:variable name="totaldocs" select="normalize-space(//*[docHit]/@totalDocs)"/>
    <xsl:choose>
        <xsl:when test="$totaldocs=''">
            <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$totaldocs"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text>,"objset_start":</xsl:text>
    <xsl:variable name="objsetstart" select="normalize-space(//*[docHit]/@startDoc)"/>
    <xsl:choose>
        <xsl:when test="$objsetstart=''">
            <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$objsetstart"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text>,"objset_end":</xsl:text>
    <xsl:variable name="objsetend" select="normalize-space(//*[docHit]/@endDoc)"/>
    <xsl:choose>
        <xsl:when test="$objsetend=''">
            <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$objsetend"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text>,"results":[</xsl:text>
    <xsl:apply-templates select="/crossQueryResult//docHit/meta" mode="x"/>
    <xsl:text>]}</xsl:text>
    <xsl:if test="$callback">
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="meta" mode="x">
    <xsl:text>
{"item":{</xsl:text>
      <xsl:apply-templates select="identity[1]" mode="dc-json-element"/>
      <xsl:apply-templates select="fromDate[1]" mode="dc-json-element"/> 
      <xsl:apply-templates select="toDate[1]" mode="dc-json-element"/> 
      <xsl:apply-templates select="facet-entityType[1]" mode="dc-json-element"> 
        <xsl:with-param name="terminal" select="1"/>
      </xsl:apply-templates>
    <xsl:text>
}}
</xsl:text><!-- end of the record/object -->
    <xsl:if test="following::meta">
      <xsl:text>,
</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="dc-json-element">
    <xsl:param name="terminal"/>
        <xsl:text>
"</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>":</xsl:text>
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select=".[text()]"/>
    </xsl:call-template>
    <xsl:if test="number($terminal) != 1">
      <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:template>

  
  <!-- ignore document text -->
  <xsl:template match="text()[preceding-sibling::node() or following-sibling::node()]"/>

  <!-- string -->
  <xsl:template match="text()">
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="."/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Main template for escaping strings; used by above template and for object-properties 
       Responsibilities: placed quotes around string, and chain up to next filter, escape-bs-string -->
  <xsl:template name="escape-string">
    <xsl:param name="s"/>
    <xsl:text>"</xsl:text>
    <xsl:call-template name="escape-bs-string">
      <xsl:with-param name="s" select="$s"/>
    </xsl:call-template>
    <xsl:text>"</xsl:text>
  </xsl:template>
  
  <!-- Escape the backslash (\) before everything else. -->
  <xsl:template name="escape-bs-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'\')">
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-bs-string">
          <xsl:with-param name="s" select="substring-after($s,'\')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Escape the double quote ("). -->
  <xsl:template name="escape-quot-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'&quot;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="substring-after($s,'&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Replace tab, line feed and/or carriage return by its matching escape code. Can't escape backslash
       or double quote here, because they don't replace characters (&#x0; becomes \t), but they prefix 
       characters (\ becomes \\). Besides, backslash should be seperate anyway, because it should be 
       processed first. This function can't do that. -->
  <xsl:template name="encode-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <!-- tab -->
      <xsl:when test="contains($s,'&#x9;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'\t',substring-after($s,'&#x9;'))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- line feed -->
      <xsl:when test="contains($s,'&#xA;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'\n',substring-after($s,'&#xA;'))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- carriage return -->
      <xsl:when test="contains($s,'&#xD;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'\r',substring-after($s,'&#xD;'))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- number (no support for javascript mantissa) -->
  <xsl:template match="text()[not(string(number())='NaN' or
                       (starts-with(.,'0' ) and . != '0'))]">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- boolean, case-insensitive -->
  <xsl:template match="text()[translate(.,'TRUE','true')='true']">true</xsl:template>
  <xsl:template match="text()[translate(.,'FALSE','false')='false']">false</xsl:template>

  <xsl:template match="snippet|hit|term" mode="value dcel">
    <xsl:apply-templates mode="value"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="thumbnail">
    <xsl:text>{"src":"</xsl:text>
    <xsl:apply-templates select="../identifier[1]" mode="value"/>
    <xsl:text>/thumbnail"</xsl:text>
    <xsl:if test="@X!='' and @Y!=''">
      <xsl:text>,"x":</xsl:text>
      <xsl:value-of select="@X"/>
      <xsl:text>,"y":</xsl:text>
      <xsl:value-of select="@Y"/>
    </xsl:if>
    <xsl:text>}</xsl:text>
    <xsl:if test="following-sibling::thumbnail">
       <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="reference-image">
    <xsl:text>{"src":"http://ark.cdlib.org</xsl:text>
    <xsl:apply-templates select="@src"/>
    <xsl:text>","x":</xsl:text>
    <xsl:value-of select="@X"/>
    <xsl:text>,"y":</xsl:text>
    <xsl:value-of select="@Y"/>
    <xsl:text>}</xsl:text>
    <xsl:if test="following-sibling::reference-image">
       <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
