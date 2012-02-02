<?xml version="1.0" encoding="UTF-8"?>
<!-- # convert EAC XML to RDF 
[this file on google code](http://code.google.com/p/xtf-cpf/source/browse/cpf2html/xml2owl/xml2owl.xsl?name=xtf-cpf) 
 -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:skos="http://www.w3.org/2008/05/skos#"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:bio="http://purl.org/vocab/bio/0.1/"
  xmlns="urn:isbn:1-931666-33-4"
  xmlns:eax="urn:isbn:1-931666-33-4"
  xmlns:eac-cpf="http://archivi.ibc.regione.emilia-romagna.it/ontology/eac-cpf/"
  xmlns:viaf="http://viaf.org/ontology/1.1/#"
  xmlns:gn="http://www.geonames.org/ontology#"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  version="1.0">
<!--
Created by Silvia Mazzini, Regesta.exe, 2011

Copyright (c) 2011, Regesta.exe
All rights reserved.

Redistribution and use are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Eduserv nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

### Related Work

[EAC-CPF Ontology and Linked Archival Data](http://ceur-ws.org/Vol-801/paper6.pdf)
Proceedings of the 1st International Workshop on Semantic Digital Archives (SDA 2011)

[eac-cpf ontology browser](http://templates.xdams.net/RelationBrowser/genericEAC/RelationBrowserCIA.html)

[Epimorphics Linked Data API Implementation](http://code.google.com/p/elda/)  
a java implementation of the 
[Linked Data API](http://code.google.com/p/linked-data-api/)

-->
<!-- 

### Social Network and Archival Context
Modified by Brian Tingle for the [Social Networks and Archival 
Context Project](http://socialarchive.iath.virginia.edu/ )
Sponsored by the National Endowment for the Humanaties http://www.neh.gov/

-->
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <!-- supplied by XTF -->
  <xsl:param name="docId"/>

  <!-- root template -->
  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- I could not get this to work in the default namespace; 
       choose eax: for the xml; eac-cpf is the RDF's namespace ~bt -->
  <xsl:template match="eax:eac-cpf">
    <!-- root rdf element -->
    <rdf:RDF> 
      <xsl:variable name="entityType">
        <xsl:value-of select="eax:cpfDescription/eax:identity/eax:entityType"/>
      </xsl:variable>
      <xsl:element name="eac-cpf:{$entityType}">
        <xsl:attribute name="rdf:about">
          <xsl:text>http://socialarchive.iath.virginia.edu/xtf/view?docId=</xsl:text>
          <xsl:value-of select="$docId"/>
          <xsl:text>#entity</xsl:text>
        </xsl:attribute>
          <rdfs:label rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
            <xsl:value-of select="eax:cpfDescription/eax:identity/eax:nameEntry/eax:part"/>
      <!-- this definatly should be refactored -->
      <xsl:if test="eax:cpfDescription/eax:description/eax:existDates">, <xsl:value-of select="substring(eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate,1,4)"/>-<xsl:value-of select="substring(eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate,10,4)"/>
			</xsl:if>
    </rdfs:label>
<!-- `foaf:page, foaf:depiction, owl:sameAs per viaf, gn:Feature` -->
    <!-- dates -->
    <xsl:if test="eax:cpfDescription/eax:description/eax:existDates">
      <dc:date><xsl:value-of select="eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate"/></dc:date>
    </xsl:if>

    <!-- viaf --><!-- add dbpedia as well -->
    <!--
```
    <xsl:element name="owl:sameAs">
      <xsl:attribute name="rdf:resource">http://viaf.org/viaf/</xsl:attribute>
    </xsl:element>
```-->

    <!-- ## control -->
    <xsl:if test="eax:control">
      <eac-cpf:control><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><rdfs:label><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute><xsl:value-of select="eax:cpfDescription/eax:identity/eax:nameEntry/eax:part/text()"/></rdfs:label><eac-cpf:recordID><xsl:value-of select="eax:control/eax:recordId"/></eac-cpf:recordID><xsl:if test="eax:control/eax:otherRecordId">
          <xsl:for-each select="eax:control/eax:otherRecordId">
            <eac-cpf:otherRecordID><xsl:value-of select="."/></eac-cpf:otherRecordID>
          </xsl:for-each>
        </xsl:if><xsl:if test="eax:control/eax:maintenanceStatus">
          <eac-cpf:maintenanceStatus><xsl:value-of select="eax:control/eax:maintenanceStatus"/></eac-cpf:maintenanceStatus>
        </xsl:if><xsl:if test="eax:control/eax:publicationStatus">
          <eac-cpf:publicationStatus><xsl:value-of select="eax:control/eax:publicationStatus"/></eac-cpf:publicationStatus>
        </xsl:if><xsl:if test="eax:control/eax:maintenanceAgency">
          <eac-cpf:maintenanceAgency><xsl:value-of select="eax:control/eax:maintenanceAgency/eax:agencyName/text()"/></eac-cpf:maintenanceAgency>
        </xsl:if><xsl:if test="eax:control/eax:languageDeclaration">
          <eac-cpf:languageDeclaration><xsl:value-of select="eax:control/eax:languageDeclaration/eax:language/text()"/></eac-cpf:languageDeclaration>
        </xsl:if><xsl:if test="eax:control/eax:conventionDeclaration">
          <eac-cpf:conventionDeclaration><xsl:value-of select="eax:control/eax:conventionDeclaration/eax:citation/text()"/></eac-cpf:conventionDeclaration>
        </xsl:if><xsl:if test="eax:control/eax:sources">
          <xsl:choose>
            <xsl:when test="not(eax:control/eax:sources/eax:source/@xlink:href)">
              <xsl:for-each select="eax:control/eax:sources/eax:source">
                <eac-cpf:source><xsl:value-of select="eax:sourceEntry"/></eac-cpf:source>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="eax:control/eax:sources/eax:source[@xlink:href]">
                <dcterms:source><xsl:attribute name="rdf:resource">
                    <xsl:value-of select="@xlink:href"/>
                  </xsl:attribute></dcterms:source>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if></eac-cpf:control>
    </xsl:if>
    <!-- ## cpfDescription -->
    <xsl:if test="eax:cpfDescription">
      <eac-cpf:description><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><xsl:for-each select="eax:cpfDescription/eax:identity/eax:nameEntry">
          <eac-cpf:nameEntry><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><foaf:name><xsl:attribute name="xml:lang">
                <xsl:value-of select="@xml:lang"/>
              </xsl:attribute><xsl:value-of select="eax:part/text()"/></foaf:name><xsl:if test="eax:authorizedForm">
              <eac-cpf:authorizedForm><xsl:value-of select="eax:authorizedForm/text()"/></eac-cpf:authorizedForm>
            </xsl:if><xsl:if test="eax:alternativeForm">
              <eac-cpf:alternativeForm><xsl:value-of select="eax:alternativeForm/text()"/></eac-cpf:alternativeForm>
            </xsl:if><xsl:if test="@localType">
              <dcterms:conformsTo><xsl:value-of select="@localType"/></dcterms:conformsTo>
            </xsl:if></eac-cpf:nameEntry>
        </xsl:for-each><xsl:if test="eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate">
          <eac-cpf:existDates><xsl:value-of select="eax:cpfDescription/eax:description/eax:existDates/eax:date/@standardDate"/></eac-cpf:existDates>
        </xsl:if><xsl:if test="eax:cpfDescription/eax:description/eax:existDates/eax:dateRange">
          <eac-cpf:existDates><xsl:value-of select="eax:cpfDescription/eax:description/eax:existDates/eax:dateRange/eax:fromDate"/><xsl:if test="eax:cpfDescription/eax:description/eax:existDates/eax:dateRange/eax:toDate">/<xsl:value-of select="eax:cpfDescription/eax:description/eax:existDates/eax:dateRange/eax:toDate"/>
						</xsl:if></eac-cpf:existDates>
        </xsl:if><xsl:choose>
          <xsl:when test="eax:cpfDescription/eax:description/eax:localDescription[@localType='subject']">
            <xsl:for-each select="eax:cpfDescription/eax:description/eax:localDescription[@localType='subject']">
              <dc:subject><xsl:value-of select="eax:term/text()"/></dc:subject>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose><xsl:if test="eax:cpfDescription/eax:description/eax:places">
          <xsl:for-each select="eax:cpfDescription/eax:description/eax:places/eax:place">
            <xsl:choose>
              <xsl:when test="contains(eax:descriptiveNote/eax:p,'nascita')">
                <bio:Birth><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><bio:date><xsl:value-of select="substring-before(../../eax:existDates,'-')"/></bio:date><xsl:if test="eax:placeEntry">
                    <gn:Feature><xsl:attribute name="rdf:resource">
                        <xsl:value-of select="eax:placeEntry"/>
                      </xsl:attribute></gn:Feature>
                    <eac-cpf:place><xsl:attribute name="rdf:resource">
                        <xsl:value-of select="eax:placeEntry"/>
                      </xsl:attribute></eac-cpf:place>
                  </xsl:if></bio:Birth>
              </xsl:when>
              <xsl:when test="contains(eax:descriptiveNote/eax:p,'morte')">
                <bio:Death><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><bio:date><xsl:value-of select="substring-after(../../eax:existDates,'-')"/></bio:date><xsl:if test="eax:placeEntry">
                    <gn:Feature><xsl:attribute name="rdf:resource">
                        <xsl:value-of select="eax:placeEntry"/>
                      </xsl:attribute></gn:Feature>
                    <eac-cpf:place><xsl:attribute name="rdf:resource">
                        <xsl:value-of select="eax:placeEntry"/>
                      </xsl:attribute></eac-cpf:place>
                  </xsl:if></bio:Death>
              </xsl:when>
              <xsl:when test="eax:descriptiveNote/eax:p/text()='sede'">
                <xsl:if test="eax:placeEntry">
                  <gn:Feature><xsl:attribute name="rdf:resource">
                      <xsl:value-of select="eax:placeEntry"/>
                    </xsl:attribute></gn:Feature>
                  <eac-cpf:place><xsl:attribute name="rdf:resource">
                      <xsl:value-of select="eax:placeEntry"/>
                    </xsl:attribute></eac-cpf:place>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:if><xsl:if test="eax:cpfDescription/eax:description/eax:biogHist">
          <eac-cpf:biogHist><xsl:apply-templates select="eax:cpfDescription/eax:description/eax:biogHist"/></eac-cpf:biogHist>
        </xsl:if><xsl:if test="eax:cpfDescription/eax:description/eax:occupation">
          <xsl:for-each select="eax:cpfDescription/eax:description/eax:occupation">
            <eac-cpf:occupation><xsl:value-of select="term/text()"/></eac-cpf:occupation>
          </xsl:for-each>
        </xsl:if></eac-cpf:description>
      <xsl:if test="eax:cpfDescription/eax:relations">
        <xsl:for-each select="eax:cpfDescription/eax:relations/eax:cpfRelation">
          <eac-cpf:cpfRelation><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><xsl:choose>
              <xsl:when test="@cpfRelationType">
                <rdfs:label><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute><xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/><xsl:value-of select="@cpfRelationType"/><xsl:value-of select="eax:relationEntry/text()"/></rdfs:label>
                <eac-cpf:cpfRelationType><xsl:value-of select="@cpfRelationType"/></eac-cpf:cpfRelationType>
                <xsl:if test="eax:descriptiveNote/eax:p">
                  <dc:description><xsl:value-of select="eax:descriptiveNote/eax:p/text()"/></dc:description>
                </xsl:if>
              </xsl:when>
              <xsl:when test="@xlink:arcrole">
                <rdfs:label><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute><xsl:value-of select="../../eax:identity/eax:nameEntry[1]/eax:part"/><xsl:value-of select="@xlink:arcrole"/><xsl:value-of select="eax:relationEntry/text()"/></rdfs:label>
                <eac-cpf:cpfRelationType><xsl:value-of select="@xlink:arcrole"/></eac-cpf:cpfRelationType>
                <xsl:if test="eax:descriptiveNote/eax:p">
                  <dc:description><xsl:value-of select="eax:descriptiveNote/eax:p/text()"/></dc:description>
                </xsl:if>
              </xsl:when>
            </xsl:choose><dcterms:relation><xsl:attribute name="rdf:resource">http://archivi.ibc.regione.emilia-romagna.it/eac-cpf/<xsl:value-of select="eax:relationEntry/@localType"/></xsl:attribute></dcterms:relation><xsl:if test="date">
              <dc:date><xsl:value-of select="date"/></dc:date>
            </xsl:if></eac-cpf:cpfRelation>
        </xsl:for-each>
        <xsl:for-each select="eax:cpfDescription/eax:relations/eax:resourceRelation">
          <xsl:choose>
            <xsl:when test="@resourceRelationType">
              <eac-cpf:resourceRelation><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><rdfs:label><xsl:attribute name="rdf:datatype">
                     <xsl:text>http://www.w3.org/2001/XMLSchema#string</xsl:text>
                  </xsl:attribute><xsl:if test="@resourceRelationType='creatorOf'">
                    <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>
                    <xsl:text>  creator of </xsl:text>
                    <xsl:value-of select="eax:relationEntry/text()"/>
                  </xsl:if><xsl:if test="@resourceRelationType='other'">
                    <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>
                    <xsl:text>  in relation with </xsl:text>
                    <xsl:value-of select="eax:relationEntry/text()"/>
                  </xsl:if></rdfs:label><eac-cpf:resourceRelationType><xsl:value-of select="@resourceRelationType"/></eac-cpf:resourceRelationType><xsl:if test="eax:descriptiveNote/eax:p">
                  <dc:description><xsl:value-of select="eax:descriptiveNote/eax:p/text()"/></dc:description>
                </xsl:if><xsl:if test="eax:date">
                  <dc:date><xsl:value-of select="eax:date"/></dc:date>
                </xsl:if></eac-cpf:resourceRelation>
            </xsl:when>
            <xsl:when test="@xlink:arcrole">
              <eac-cpf:resourceRelation><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><rdfs:label><xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#string</xsl:text>
                  </xsl:attribute><xsl:value-of select="../../eax:identity/eax:nameEntry[1]/eax:part"/><xsl:value-of select="@xlink:arcrole"/><xsl:value-of select="eax:relationEntry/text()"/></rdfs:label><eac-cpf:resourceRelationType><xsl:value-of select="@xlink:arcrole"/></eac-cpf:resourceRelationType><xsl:if test="eax:descriptiveNote/eax:p">
                  <dc:description><xsl:value-of select="eax:descriptiveNote/eax:p/text()"/></dc:description>
                </xsl:if></eac-cpf:resourceRelation>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
<!-- controllare -->
        <xsl:for-each select="eax:cpfDescription/eax:relations/eax:functionRelation">
          <eac-cpf:functionRelation><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><rdfs:label><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute><xsl:if test="@functionRelationType='controls'">
                <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>  creator of 
                <xsl:value-of select="eax:relationEntry/text()"/>
              </xsl:if><xsl:if test="@functionRelationType='owns'">
                <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>  creator of 
                <xsl:value-of select="eax:relationEntry/text()"/>
              </xsl:if><xsl:if test="@functionRelationType='performs'">
                <xsl:value-of select="../../eax:identity/eax:nameEntry/eax:part[@localType='normal']"/>  creator of 
              <xsl:value-of select="eax:relationEntry/text()"/>
            </xsl:if></rdfs:label><eac-cpf:functionRelationType><xsl:value-of select="@functionRelationType"/></eac-cpf:functionRelationType><xsl:if test="eax:descriptiveNote/eax:p">
              <dc:description><xsl:value-of select="eax:descriptiveNote/eax:p/text()"/></dc:description>
            </xsl:if><xsl:if test="date">
              <dc:date><xsl:value-of select="date"/></dc:date>
            </xsl:if></eac-cpf:functionRelation>
        </xsl:for-each>
      </xsl:if>
<!-- not sure if we want this yet -->
      <skos:changeNote><xsl:attribute name="rdf:parseType">Resource</xsl:attribute><dc:date><xsl:value-of select="eax:control/eax:maintenanceHistory/eax:maintenanceEvent[child::eventType='create']/eax:eventDateTime/text()"/></dc:date><dc:creator/><rdf:value/></skos:changeNote>
      <dc:identifier><xsl:value-of select="eax:control/eax:recordId"/></dc:identifier>
      <dc:creator><xsl:value-of select="eax:control/eax:maintenanceHistory/eax:maintenanceEvent[child::eventType='create']/eax:agent"/></dc:creator>
    </xsl:if>

      </xsl:element>
    </rdf:RDF>
  </xsl:template>


  <!-- bioghist -->
  <xsl:template match="eax:cpfDescription/eax:description/eax:biogHist">
    <xsl:if test="eax:p">
      <xsl:apply-templates/>
    </xsl:if>
    <!-- refactor to apply templates -->
    <xsl:if test="eax:chronList">
      <xsl:for-each select="eax:chronList/eax:chronItem">
        <xsl:if test="eax:date">
          <xsl:value-of select="eax:date"/>
          <xsl:text>: </xsl:text>
        </xsl:if>
      </xsl:for-each>
        <xsl:value-of select="normalize-space(eax:event)"/>; 
    </xsl:if>
  </xsl:template>
  <xsl:template match="eax:p">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>
