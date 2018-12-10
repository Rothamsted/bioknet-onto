#
# Converts a couple of files about WikiPathway examples to bioKNetOnto.
# Stores the results in bkout, as Turtle files, and also puts all the data (original and converted) into
# a temp TDB.
#
# Requires JENA_HOME, TARQL_HOME to be defined
#

start_dir=$(pwd)
cd $(dirname "$0")
my_dir=$(pwd)

echo -e "\n\n==== Cleaning out dir\n"
out_dir="./bkout"
mkdir -p "$out_dir"
rm -Rf "$out_dir"/*


tdb="/tmp/bk_convert_tdb"
echo -e "\n\n==== Loading already-RDF files into temp TDB '$tdb'\n"
rm -Rf "$tdb"
"$JENA_HOME/bin/tdbloader2" --loc="$tdb" \
	../../bioknet.owl ../../bk_ondex.owl input_data/*.{rdf,owl,ttl} input_data/bkonto/*.ttl


echo -e "\n\n==== Downloading external ontologies\n"
ext_dir="$out_dir/ext"
mkdir -p "$ext_dir"
for url in \
  http://www.biopax.org/release/biopax-level3.owl \
  http://www.w3.org/TR/skos-reference/skos.rdf
do
  base=$(basename "$url")
  wget -O "$ext_dir/$base" "$url"
done


echo -e "\n\n==== TDB Loading external ontologies\n"
"$JENA_HOME/bin/tdbloader" --loc="$tdb" "$ext_dir"/*


echo -e "\n\n==== Converting CSVs from DEG Example\n"
tarql_cmd="$TARQL_HOME/bin/tarql --tabs --quotechar '\"'"
for i in $(seq 2)
do
  fname="sample_degs_$i.tsv"
  echo "$fname"
  "$TARQL_HOME/bin/tarql" --tabs --quotechar '"' \
    cvt_sample_degs_$i.tarql "input_data/$fname" \
    >"$out_dir/sample_degs_$i.ttl"
done

echo -e "\n\n==== TDB Loading of converted CSVs\n"
"$JENA_HOME/bin/tdbloader" --loc="$tdb" "$out_dir/sample_degs_$i.ttl"


echo -e "\n\n==== Running CONSTRUCTs\n"
sparql="$JENA_HOME/bin/tdbquery"
for query in ./cvt_*.sparql
do
  echo "$query"
  qbase=$(basename "$query" '.sparql')
  "$sparql" --loc "$tdb" --query "$query" >"$out_dir/${qbase}.ttl"
done


echo -e "\n\n==== TDB Loading of CONSTRUCT results\n"
"$JENA_HOME/bin/tdbloader" --loc="$tdb" "$out_dir"/cvt_*.ttl


echo -e "\n\n==== Dumping all output onto all.ttl\n"
"$sparql" --loc "$tdb" --query "./dump.sparql" >"$out_dir/all.ttl"


echo -e "\n\n==== The End\n"
