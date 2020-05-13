# BioKNO, The Biological Knowledge Network Ontology 


## Ontology Overview

**BIO**logical **KN**owledge Network **O**ntology (BioKNO, pronounced "bio-know") is a lightweight ontology, aimed at 
representing biological-related knowledge networks. We use it to power the 
[KnetMiner](http://knetminer.rothamsted.ac.uk/) project.

Further information on the ontology and where it fits in KnetMiner is available from our 
[IB2018 article](https://dx.doi.org/10.1515%2Fjib-2018-0023).

At the most basic level, it provides simple modelling for very general entities, such as concepts, relationships and 
attributed-attached reified relationships. 

In addition to that, entities such as structured accessions, data sources and evidence-tracking predicates are defined. 

At a more specific level, [the core definitions](bioknet.owl) are extended with common biological entities, such as 
Protein, Gene, or the 'encodes' relation.

Suitable [mappings](bk_ondex.owl) are also given, in order to map the knowledge networks modelled by means of BioKNO to 
common linked data standards, both general ones (e.g., SKOS, OWL) and life science-specific (e.g., 
[bioschemas](http://bioschemas.org/)).

We use/are using/plan to use BioKNO in the KnetMiner project to perform various operations, ranging from data 
import/integration, to graph-based queries and building of APIs.

## Web View
You can web-browse the ontology 
[here](https://cdn.rawgit.com/Rothamsted/bioknet-onto/ed070a8e/utils/to_lode/lode_bioknet.html), and mappings to our 
[KnetMiner](http://knetminer.rothamsted.ac.uk/)/[Ondex](https://github.com/Rothamsted/ondex-knet-builder) metadata 
[here](https://cdn.rawgit.com/Rothamsted/bioknet-onto/ed070a8e/utils/to_lode/lode_bk_ondex.html). Many thanks to the 
developers of [LODE](http://www.essepuntato.it/lode), which we uses for rendering these pages.

**WARNING**: *sometimes these views might be outdated with respect to the last versions of the original ontology files 
that they are based on.*

## The basics

The two main classes in BioKNO are `bk:Concept` and `bk:Relation`. The latter is related to the RDF object property 
`bk:relatedConcept`, which of main sub-property is `bk:conceptsRelation`. 

Typically, the entities you want to talk about in a BioKNO knowledge network are indirect (i.e., transitive) instances 
of `bk:Concept`, while Concepts are linked together by some sub-property of `bk:conceptsRelation`. 

A first instance about a biological pathway, taken from our [WikiPathway example](examples/bmp_reg_human/bkout):

```Turtle
<http://www.wikipathways.org/id1>
        # A pathway, a predefined class in bk_ondex.owl. This is a subclass of bk:Concept, which subclasses skos:Concept
        a            bk:Path ; 
        bk:evidence  bkev:IMPD ; # Imported from database, a predefined constant on bk_ondex.owl
        # bk:prefName maps to skos-x:prefLabel
        bk:prefName  "Bone Morphogenic Protein (BMP) Signalling and Regulation"^^<xsd:string> .
        
bkr:TOB1  a                 bk:Protein ;
        dc:identifier       bkr:TOB1_acc ;
        # A simplified link, hiding BioPax pathwayComponent -> BioChemicalReaction|Complex -> Protein
        bk:participates_in  <http://www.wikipathways.org/id1> ;
        bk:prefName         "TOB1"^^<xsd:string> .
        
# Structured accession, allow for linking of identifier and context.         
bkr:TOB1_acc  a             bk:Accession ;
        dcterms:identifier  "TOB1"^^<xsd:string> ;
        bk:dataSource       bkds:UNIPROTKB; # instance of bk:DataSource. We have a list of predefined data sources.
        bk:is_annotated_by obo:GO_0030014.
```


As you can see, we have predefined entities like `bk:Path`, subclassing core entities like `bk:Concept`. Moreover, the 
original link chains between pathways and proteins present in the BioPax data are simplified by means of the 
`bk:participates_in` relation.

Another example, about the gene ontology term referred by above:

```Turtle
obo:GO_0030014  a      bk:GeneOntologyTerms ;
        dc:identifier  obo:GO_0030014_acc ;
        bk:is_a        obo:GO_0044424 , obo:GO_0043234 ;
        bk:prefName    "CCR4-NOT complex" .

obo:GO_0044424  a      bk:GeneOntologyTerms ;
        dc:identifier  obo:GO_0044424_acc ;
        bk:is_a        obo:GO_0044464 ;
        bk:prefName    "intracellular part" .
        
obo:GO_0030015  a  bk:GeneOntologyTerms;
        dc:identifier  obo:GO_0030015_acc ;
        bk:is_a        obo:GO_0044424, obo:GO_0043234 ;
        bk:part_of 		obo:GO_0030014;
        bk:prefName    "CCR4-NOT core complex" .
```

As you can see, original URIs about external RDF data can be reused (in OWL-2, this is possible thanks to 
[punning](https://www.w3.org/2007/OWL/wiki/Punning)). Morever, relations like `bk:is_a`, `bk:part_of` are more informal 
than OWL/OBO relations, which might simplify the modelling. For instance, the fact that a CCR4-NOT core complex is part 
of a CCR4-NOT complex is a simple direct relation, where, in OWL terms must be an axiom like "part of some CCR-NOT 
complex.    


## Concept attributes

Under the top-level `bk:attribute` property, BioKNO provides a number of OWL datatype properties, which can be attached 
to concepts and relations. For instance:

```Turtle
bkr:20068231  a             bk:Publication ;
        dc:identifier       bkr:20068231_acc ;
        bka:PMID            "20068231" ;
        bka:YEAR            "2010"^^xsd:gYear ;
        bka:abstractHeader  "Quantitative phosphoproteomics reveals widespread full phosphorylation site occupancy during mitosis." ;
        bk:evidence         bkev:IMPD , bkev:NAS ;
        bk:prefName         "20068231" .
```


Attributes can have any suitable range and we made sensible choices for the ranges of our predefine attributes.  


## Reified relations

Attributes can be associated to relations too. Since RDF structurally supports binary relations/statement only, 
attributed relations must be modelled through reification:

```Turtle
# For practical reasons, we always expect that the straight triple is asserted, with the reified version optionally added to it.
bkr:TOB1 bk:published_in    bkr:20068231.

bkr:citation_TOB1_15489334
        a              bk:Relation ;
        bk:relTypeRef  bk:published_in;  # the same relations used for straight triples      
        bk:relFrom     bkr:TOB1 ; # This is the protein in the examples above
        bk:relTo       bkr:15489334 ; # And this is the publication above
        bka:Score      0.95 ;
        bk:evidence    bkev:TM. Both attributes and object properties can be linked to a reified relation.
```


As you can see, a reified relation is an instance of `bk:Relation ` and its main properties are a pointer to the 
relation
type (which is the same object property appearing in the direct relation, and typically a sub-property of 
`bk:conceptsRelation`).

We require that a reified relation is asserted by means of both its "straight", common RDF statement version and as an 
instance of `bk:Relation`. That ease certain use cases. For instance, if one has to search for the existence of a given 
relation, independently on the possible attributes it might have, it's easier to search the straight version, without 
having to deal with both types.
