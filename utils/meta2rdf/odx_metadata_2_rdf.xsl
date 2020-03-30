<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:odx="http://ondex.sourceforge.net/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:bk="http://knetminer.org/data/rdf/terms/biokno/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:fn="http://knetminer.org/data/rdf/xsl/functions/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"

	version="2.0">

	<!--
	  Does most of the XML -> RDF job run by meta2rdf.sh
	 -->

	<xsl:output method="xml" indent="yes" cdata-section-elements = "rdfs:label dcterms:description"/>

  <xsl:template match = "/odx:ondex">

  	<xsl:message>Matching Root <xsl:value-of select = "name(.)" /></xsl:message>

    <rdf:RDF
	    xmlns:odx="http://ondex.sourceforge.net/"
	    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	    xmlns:bk="http://knetminer.org/data/rdf/terms/biokno/"
	  	xmlns:dcterms="http://purl.org/dc/terms/"
      xmlns:owl="http://www.w3.org/2002/07/owl#"
      xml:base="http://knetminer.org/data/rdf/terms/biokno/knetminer_extensions/"
    >
	    <owl:Ontology rdf:about="http://knetminer.org/data/rdf/terms/biokno/knetminer_extensions/">
	        <owl:imports rdf:resource="http://knetminer.org/data/rdf/terms/biokno/"/>
	    </owl:Ontology>


			<!-- the XML omits these defs -->
			
			<owl:ObjectProperty rdf:about="http://knetminer.org/data/rdf/terms/biokno/conceptsRelation" />
			
	    <owl:AsymmetricProperty rdf:about="http://knetminer.org/data/rdf/terms/biokno/gives">
	     		<rdfs:subPropertyOf rdf:resource="http://knetminer.org/data/rdf/terms/biokno/conceptsRelation" />
	     		<owl:inverseOf rdf:resource="http://knetminer.org/data/rdf/terms/biokno/given_by" />
	    </owl:AsymmetricProperty>

      <xsl:apply-templates select = "odx:ondexmetadata/*/*" />

		</rdf:RDF>
	</xsl:template>


	<xsl:template match = "odx:conceptclasses/odx:cc[ not ( fn:is_ignored_cc ( odx:id ) )]">

		<xsl:message>Matching CC <xsl:value-of select = "odx:id" /></xsl:message>

		<owl:Class rdf:about = "{concat ( 'http://knetminer.org/data/rdf/terms/biokno/', ./odx:id )}">

			<bk:isOndexPreferred rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">true</bk:isOndexPreferred>
			<dcterms:identifier><xsl:value-of select = "./odx:id" /></dcterms:identifier>

			<xsl:if test="./odx:fullname != ''">
      		<rdfs:label xml:lang = 'en'><xsl:value-of select = "normalize-space( ./odx:fullname )" /></rdfs:label>
			</xsl:if>

			<xsl:if test="./odx:description != ''">
				<dcterms:description xml:lang = 'en'><xsl:value-of select = "normalize-space( ./odx:description )" /></dcterms:description>
			</xsl:if>

			<!-- Super-class -->
			<xsl:variable name="super_class_id">
				<xsl:choose>
					<xsl:when test = "not ( fn:is_ignored_cc ( odx:specialisationOf/odx:idRef ))">
						<xsl:value-of select = "odx:specialisationOf/odx:idRef" />
					</xsl:when>
					<xsl:when test = "not ( fn:is_ignored_cc ( odx:specialisationOf/odx:id ))">
						<xsl:value-of select = "odx:specialisationOf/odx:id" />
					</xsl:when>
					<xsl:otherwise>Concept</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<rdfs:subClassOf rdf:resource = "{concat( 'http://knetminer.org/data/rdf/terms/biokno/', $super_class_id )}" />

		</owl:Class>

	</xsl:template>



	<xsl:template match = "odx:relationtypes/odx:relation_type[not ( fn:is_ignored_relation ( odx:id ))]
	   | odx:relationtypes/odx:relation_type/specialisationOf[not ( fn:is_ignored_relation ( odx:id ))]
	 ">

		<xsl:message>Matching Relation <xsl:value-of select = "odx:id" /></xsl:message>


		<owl:ObjectProperty rdf:about = "{concat ( 'http://knetminer.org/data/rdf/terms/biokno/', ./odx:id )}">

			<bk:isOndexPreferred rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">true</bk:isOndexPreferred>
			<dcterms:identifier><xsl:value-of select = "./odx:id" /></dcterms:identifier>

			<xsl:if test="./odx:fullname != ''">
      		<rdfs:label xml:lang = 'en'><xsl:value-of select = "normalize-space( ./odx:fullname )" /></rdfs:label>
			</xsl:if>

			<xsl:if test="./odx:description != ''">
				<dcterms:description xml:lang = 'en'><xsl:value-of select = "normalize-space( ./odx:description )" /></dcterms:description>
			</xsl:if>

			<!-- Super-property -->
			<xsl:variable name="super_prop_id">
				<xsl:choose>
					<xsl:when test = "not ( fn:is_ignored_relation ( odx:specialisationOf/odx:idRef ) )">
						<xsl:value-of select = "odx:specialisationOf/odx:idRef" />
					</xsl:when>
					<xsl:when test = "not ( fn:is_ignored_relation ( odx:specialisationOf/odx:id ) )">
						<xsl:value-of select = "odx:specialisationOf/odx:id" />
					</xsl:when>
					<xsl:otherwise>conceptsRelation</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<rdfs:subPropertyOf rdf:resource = "{concat( 'http://knetminer.org/data/rdf/terms/biokno/', $super_prop_id )}" />


			<!-- Property nature -->
			<xsl:if test="odx:isReflexive = 'true'">
				<rdf:type rdf:resource = "http://www.w3.org/2002/07/owl#ReflexiveProperty" />
			</xsl:if>
			<xsl:if test="odx:isAntisymmetric = 'true'">
				<rdf:type rdf:resource = "http://www.w3.org/2002/07/owl#AsymmetricProperty" />
			</xsl:if>
			<xsl:if test="odx:isSymmetric = 'true'">
				<rdf:type rdf:resource = "http://www.w3.org/2002/07/owl#SymmetricProperty" />
			</xsl:if>
			<xsl:if test="odx:isTransitive = 'true'">
				<rdf:type rdf:resource = "http://www.w3.org/2002/07/owl#TransitiveProperty" />
			</xsl:if>


			<!-- Symmetric property -->
			<xsl:if test = "not ( fn:is_ignored_relation ( ./odx:inverseName ) )">
				<owl:inverseOf rdf:resource = "{concat ( 'http://knetminer.org/data/rdf/terms/biokno/', ./odx:inverseName )}" />
			</xsl:if>

		</owl:ObjectProperty>

		<!-- Not all of them are well defined, so let's state this and then we will remove redundant declarations -->
		<xsl:if test = "not ( fn:is_ignored_relation ( ./odx:inverseName ) )">
			<owl:ObjectProperty rdf:about="{concat ( 'http://knetminer.org/data/rdf/terms/biokno/', ./odx:inverseName )}">
				<rdfs:subPropertyOf rdf:resource="http://knetminer.org/data/rdf/terms/biokno/conceptsRelation" />
			</owl:ObjectProperty>
		</xsl:if>
	</xsl:template>


	<xsl:template match = "odx:attrnames/odx:attrname">

		<xsl:message>Matching Attribute <xsl:value-of select = "odx:id" /></xsl:message>

		<xsl:variable name="nrm_id" select="encode-for-uri( odx:id )" />

		<owl:DatatypeProperty rdf:about = "{concat ( 'http://knetminer.org/data/rdf/terms/biokno/attributes/', $nrm_id )}">

			<rdfs:subPropertyOf rdf:resource = "http://knetminer.org/data/rdf/terms/biokno/attribute" />

			<bk:isOndexPreferred rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">true</bk:isOndexPreferred>
			<dcterms:identifier><xsl:value-of select = "./odx:id" /></dcterms:identifier>

			<xsl:if test="./odx:fullname != ''">
      		<rdfs:label xml:lang = 'en'><xsl:value-of select = "normalize-space( ./odx:fullname )" /></rdfs:label>
			</xsl:if>

			<xsl:if test="./odx:description != ''">
				<dcterms:description xml:lang = 'en'><xsl:value-of select = "normalize-space( ./odx:description )" /></dcterms:description>
			</xsl:if>


			<!-- Datatype -->
			<xsl:variable name = "wtype" select = "concat ( '|', odx:datatype, '|' )" />
			<xsl:variable name ="xsd_type">
				<xsl:choose>
					<xsl:when test="contains ( '|java.lang.String|java.lang.Character|', $wtype )">string</xsl:when>
					<xsl:when test="odx:datatype = 'java.lang.Integer'">long</xsl:when>
					<xsl:when test="contains ( '|java.lang.Double|java.lang.Float|', $wtype )">double</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$xsd_type != ''">
				<rdfs:range rdf:resource="{concat ( 'http://www.w3.org/2001/XMLSchema#', $xsd_type )}"/>
			</xsl:if>
			
			<!-- Keeps track of the original datatype, in case we convert back from OWL -->
			<xsl:if test = "odx:datatype != ''">
				<bk:ondexRange><xsl:value-of select = "odx:datatype" /></bk:ondexRange>
			</xsl:if>
		</owl:DatatypeProperty>

	</xsl:template>


	<!-- 
		Data Sources and Evidences.
		
		TODO: units are still missing.  
	-->
	<xsl:template match = "odx:cvs/odx:cv|odx:evidences/odx:evidence">

		<xsl:variable name="mode">
			<xsl:choose>
				<xsl:when test = "local-name() = 'cv'">ds</xsl:when>
				<xsl:otherwise>ev</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:message>Matching <xsl:value-of select = "fn:if ( $mode = 'ds', 'CV/DataSource ', 'Evidence ' )" /> <xsl:value-of select = "odx:id" /></xsl:message>

		<owl:NamedIndividual rdf:about = "{concat ( 'http://knetminer.org/data/rdf/terms/biokno/', fn:if ( $mode = 'ds', 'dataSources', 'evidences' ), '/', ./odx:id )}">

			<bk:isOndexPreferred rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">true</bk:isOndexPreferred>
			<dcterms:identifier><xsl:value-of select = "./odx:id" /></dcterms:identifier>

			<xsl:if test="./odx:fullname != ''">
      		<rdfs:label xml:lang = 'en'><xsl:value-of select = "normalize-space( ./odx:fullname )" /></rdfs:label>
			</xsl:if>

			<xsl:if test="./odx:description != ''">
				<dcterms:description xml:lang = 'en'><xsl:value-of select = "normalize-space( ./odx:description )" /></dcterms:description>
			</xsl:if>

			<rdf:type rdf:resource = "{concat ( 'http://knetminer.org/data/rdf/terms/biokno/', fn:if ( $mode = 'ds', 'DataSource', 'EvidenceType' ))}" />

		</owl:NamedIndividual>

	</xsl:template>





  <xsl:template match="*">
		<xsl:message>Excluding <xsl:value-of select = "concat ( name(.), ' ', ./odx:id )" /></xsl:message>
	</xsl:template>



	<!-- Utility functions -->

	<!--
		Classical ternary operator, returning the second or third parameter, depending on the boolean value
		of the first parameter.
	-->
	<xsl:function name = "fn:if" >
		<xsl:param name="expr" />
		<xsl:param name="true" />
		<xsl:param name="false" />
		<xsl:choose>
			<xsl:when test="$expr"><xsl:value-of select = "$true" /></xsl:when>
			<xsl:otherwise><xsl:value-of select = "$false" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- 
		These concept classes are ignored since they don't make much sense in RDF/OWL
		When a template gets a true return value for this, it usually chooses a proper general entity
		for the one being ignored (e.g., 'Thing' as concept class => odx:Concept)
	-->
	<xsl:function name = "fn:is_ignored_cc" as="xs:boolean">
		<xsl:param name="id" />
		<xsl:value-of select = "fn:is_ignored ( '|Thing|UndefinedSemantics|', $id )" />
	</xsl:function>

	<!-- 
		These relations are ignored since they don't make much sense in RDF/OWL
		See above about general entities on the OWL side 
	-->
	<xsl:function name = "fn:is_ignored_relation" as="xs:boolean">
		<xsl:param name="id" />
		<xsl:value-of select = "fn:is_ignored ( '|relatedTo|r|undefined_semantics|none|', $id )" />
	</xsl:function>

	<!-- True if the second IF parameter is empty or in the list passed as first parameter (used above) -->
	<xsl:function name = "fn:is_ignored" as="xs:boolean">
		<xsl:param name="list" />
		<xsl:param name="id" />

		<!-- xsl:message>CHECK '<xsl:value-of select = "$id" />'</xsl:message -->

		<xsl:choose>
			<xsl:when test="normalize-space( $id ) = ''" >
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="wid" select = "concat ( '|', $id, '|' )" />
				<xsl:value-of select = "contains ( $list, $wid )" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<!-- WARN: never used! -->
	<xsl:function name="fn:encode_id">
		<xsl:param name="id" />

		<xsl:variable name="idnrm">
			<xsl:value-of select = "translate ( normalize-space ( $id ), ' -/', '___' )" />
		</xsl:variable>

	  <xsl:choose>
	  		<!-- it's all upper case or it's not camel-case (e.g. meSH) -->
	  		<xsl:when test="$idnrm = upper-case ( $idnrm ) or matches ( $idnrm, '[A-Z]{2,}' )">
	  			<xsl:value-of select="lower-case ( $idnrm )"/>
	  		</xsl:when>
	  		<xsl:otherwise>
	  			<!-- else, if it looks like camel-case, get the uncapitalized version -->
	  			<xsl:value-of select="concat ( lower-case ( substring ( $idnrm, 1, 1 ) ), substring( $idnrm, 2 ) )" />
	  		</xsl:otherwise>
	  </xsl:choose>

	</xsl:function>

</xsl:stylesheet>
