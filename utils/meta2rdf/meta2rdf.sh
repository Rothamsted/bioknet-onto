finput="$1";

if [ "$finput" = '' ]; then
  cat <<EOT


  Converts ondex_metadata.xml (in \$1) to extensions of the BioKNet ontology.
  Sends the output to \$2 (default is ../../bk_ondex.owl)
  It expects some variables to be initialised, see ../*init.sh

EOT
exit 1
fi

fout="$2"; : ${fout:=../../bk_ondex.owl}

otmpf=$(mktemp /tmp/meta2rdf_XXX.owl)
ntmpf=$(mktemp /tmp/meta2rdf_XXX.ttl)

echo Getting raw RDF from XML
java -jar "$SAX_JAR" -s:"$finput" -xsl:odx_metadata_2_rdf.xsl -o:"$otmpf"


echo -e "\n\n==== URI normalization 1/3\n"
"$JENA_HOME/bin/update" --data="$otmpf" --update=ondex_defs_new_uris.sparul --dump | sponge "$ntmpf"


echo -e "\n\n==== URI normalization 2/3\n"
"$JENA_HOME/bin/update" --data="$ntmpf" --update=ondex_defs_migrate_new_uris_complex.sparul --dump | sponge "$ntmpf"


echo -e "\n\n==== URI normalization 3/3\n"
"$JENA_HOME/bin/update" --data="$ntmpf" --update=ondex_defs_migrate_new_uris_simple.sparul --dump | sponge "$ntmpf"


# This goes at the end, cause there are multiple steps that can lead to this redundancy
echo -e "\n\n==== Redundant subproperty declarations\n"
"$JENA_HOME/bin/update" --data="$ntmpf" --update=ondex_defs_redundant_subprops.sparul --dump | sponge "$ntmpf"

echo -e "\n\n==== Conversion to RDF/XML encoding\n"
$JENA_HOME/bin/riot --formatted='RDF/XML' namespaces.owl "$ntmpf" >"$fout"

echo -e "\n\n==== The End\n"
