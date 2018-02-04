# 
# Converts a couple of files about WikiPathway examples to bioKNetOnto.  
# Stores the results in bkout, as Turtle files, and also puts all the data (original and converted) into
# a temp TDB.
# 
# Requires JENA_HOME to be defined
#

start_dir=$(pwd)
cd $(dirname "$0")
my_dir=$(pwd)

tdb="/tmp/bk_convert_tdb"

echo "Loading data into temp TDB $tdb"
rm -Rf "$tdb"
"$JENA_HOME/bin/tdbloader2" --loc="$tdb" ../../bioknet.owl ../../bk_ondex.owl ./*.{rdf,owl,ttl}

echo "Running CONSTRUCTs"
out_dir="./bkout"
mkdir -p "$out_dir"
rm -f "$out_dir/*"

sparql="$JENA_HOME/bin/tdbquery"
for query in ./cvt_*.sparql
do
  echo "$query"
  qbase=$(basename "$query" '.sparql')
  "$sparql" --loc "$tdb" --query "$query" >"$out_dir/${qbase}.ttl"
done

echo "Putting output files together and loading into temp TDB"
cd "$out_dir"
cat *.ttl >all.ttl

"$JENA_HOME/bin/tdbloader" --loc="$tdb" all.ttl

echo "The End"
