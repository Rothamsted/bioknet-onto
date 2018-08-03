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

echo URI normalization
"$JENA_HOME/bin/update" --data="$otmpf" --update=ondex_defs_new_uris.sparul --dump | sponge "$ntmpf"

# This goes at the end, cause there are multiple steps that can lead to this redundancy
echo Redundant subproperty declarations
"$JENA_HOME/bin/update" --data="$ntmpf" --update=ondex_defs_redundant_subprops.sparul --dump | sponge "$ntmpf"

echo "Conversion to RDF/XML encoding"
$JENA_HOME/bin/riot --formatted='RDF/XML' namespaces.owl "$ntmpf" >"$fout"

echo "The End"
