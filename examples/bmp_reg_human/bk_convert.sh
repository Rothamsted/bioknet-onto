export JENA_HOME="/Applications/local/dev/semantic_web/jena"
export FUSEKI_HOME="/Applications/local/dev/semantic_web/fuseki"

start_dir=$(pwd)
cd $(dirname "$0")
my_dir=$(pwd)

tdb="/tmp/bk_convert_tdb"

echo "Loading data into temp TDB $tdb"
rm -Rf "$tdb"
"$JENA_HOME/bin/tdbloader2" -l "$tdb" ../bioknet.owl ../bk_ondex.owl ./*.rdf ./*.owl

echo "Running CONSTRUCTs"
out_dir="./bkout"
mkdir -p "$out_dir"
rm -f "$out_dir/*"

sparql="$FUSEKI_HOME/bin/tdbquery"
for query in ./cvt_*.sparql
do
  qbase=$(basename "$query" '.sparql')
  "$sparql" --loc "$tdb" --query "query" >"$out_dir/{$qbase}.ttl"
done

echo "Putting output files together and loading into temp TDB"
cd "$out_dir"
cat *.ttl >all.ttl

"$JENA_HOME/bin/tdbloader" -l "$tdb" all.ttl

echo "The End"
