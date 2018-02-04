# bioKNetOnto
The Bio Knowledge Network, which powers the [kNetMiner](http://knetminer.rothamsted.ac.uk/) project.

## Ontology Overview

bioKNetOnto is a lightweight ontology, aimed at representing biological-related knowledge networks.

At the most basic level, it provides simple modelling for very general entities, such as concepts, relationships and attributed-attached reified relationships. 

In addition to that, entities such as structured accessions, data sources and evidence-tracking predicates are defined. 

At a more specific level, [the core definitions](bioknet.owl) are extended with common biological entities, such as Protein, Gene, or the 'encodes' relation.

Suitable [mappings](bk_ondex.owl) are also given, in order to map the knowledge networks modelled by means of bioKNetOnto to common linked data standards, both general ones (e.g., SKOS, OWL) and life science-specific (e.g., [bioschemas](http://bioschemas.org/)).

We use/are using/plan to use bioKNetOnto in the kNetMiner project to perform various operations, ranging from data import/integration, to graph-based queries and building of APIs.

## The basics

The two main classes in bioKNetOnto are `bk:Concept` and `bk:Relation`. The latter is related to the RDF object property `bk:relatedConcept`, which of main sub-property is `bk:conceptsRelation`. 

Typically, the entities you want to talk about in a bioKNetOnto knowledge network are indirect (i.e., transitive) instances of `bk:Concept`, while Concepts are linked together by some sub-property of `bk:conceptsRelation`. 

A first instance about a biological pathway, taken from our [WikiPathway example](examples/bmp_reg_human/bkout):

```Turtle
<http://www.wikipathways.org/id1>
        # A pathway, a predefined class in bk_ondex.owl. This is a subclass of bk:Concept, which subclasses skos:Concept
        a            bk:Path ; 
        bk:evidence  bkev:IMDPD ; # Imported from database, a predefined constant on bk_ondex.owl
        # bk:prefName maps to skos-x:prefLabel
        bk:prefName  "Bone Morphogenic Protein (BMP) Signalling and Regulation"^^<xsd:string> .
        
bkr:TOB1  a                 bk:Protein ;
        dc:identifier       bkr:TOB1_acc ;
        # A simplified link, hiding BioPax pathwayComponent -> BioChemicalReaction|Complex -> Protein
        bk:participates_in  <http://www.wikipathways.org/id1> ;
        bk:prefName         "TOB1"^^<xsd:string> .
        
# Structured accession, allow for linking identifier and context.         
bkr:TOB1_acc  a             bk:Accession ;
        dcterms:identifier  "TOB1"^^<xsd:string> ;
        bk:dataSource       bkds:UNIPROTKB . # instance of bk:DataSource. We havea list of predefined data sources.
```

As you can see, we have predefined entities like `bk:Path`, subclassing core entities like `bk:Concept`. Moreover, the 
original link chains between pathways and proteins present in the BioPax data are simplified by means of the 
`bk:participates_in` relation.


## Concept attributes

Under the top-level `bk:attribute` property, bioKNetOnto provides a number of OWL datatype properties, which can be attached to concepts and relations. For instance:

```Turtle
bkr:20068231  a             bk:bkPub ;
        dc:identifier       bkr:20068231_acc ;
        bka:PMID            "20068231" ;
        bka:YEAR            "2010"^^xsd:gYear ;
        bka:abstractHeader  "Quantitative phosphoproteomics reveals widespread full phosphorylation site occupancy during mitosis." ;
        bk:evidence         bkev:IMPD , bkev:NAS ;
        bk:prefName         "20068231" .
```

Attributes can have any suitable range and we made sensible choices for the ranges of our predefine attributes.  


## Reified relations

Attributes can be associated to relations too. Since RDF structurally supports binary relations/statement only, attributed relations must be modelled through reification:

```Turtle
# For practical reasons, we always expect that the straight triple is asserted, with the reified version optionally added to it.
bkr:TOB1 bk:published_in    bkr:20068231.

bkr:citation_TOB1_15489334
        a              bk:Relation ;
        bk:relTypeRef  bk:published_in;        
        bk:relFrom     bkr:TOB1 ; # This is the protein in the examples above
        bk:relTo       bkr:15489334 ; # And this is the publication above
        bka:Score      0.95 ;
        bk:evidence    bkev:TM. Both attributes and object properties can be linked to a reified relation.
```

As you can see, a reified relation is an instance of `bk:Relation ` and its main properties are a pointer to the relation
type (which is the same object property appearing in the direct relation, and typically a sub-property of 
`bk:conceptsRelation`).

We require that a reified relation is asserted by means of both its "straight", common RDF statement version and as an instance of `bk:Relation`. That ease certain use cases. For instance, if one has to search for the existence of a given relation, independently on the possible attributes it might have, it's easier to search the straight version, without having to deal with both types.

