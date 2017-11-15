# Converts some annotation properties in the ontology file $1
# into rdfs:comment annotations. This is necessary to render the file in LODE (http://www.essepuntato.it/lode),
# since it doesn't understand many other properties (https://github.com/essepuntato/LODE/issues/7).

# It expects JENA_HOME to be initialised, see ../*init.sh
#
input="$1"; : ${input:=../../bioknet.owl}

tmpf=$(mktemp /tmp/tocomm_XXX.nt)
"$JENA_HOME/bin/update" --data="$input" --update=descr2comments.sparul --dump >$tmpf
"$JENA_HOME/bin/update" --data=$tmpf --update=note2comments.sparul --dump | sponge $tmpf
"$JENA_HOME/bin/update" --data=$tmpf --update=aggregate_comments.sparul --dump | sponge $tmpf
"$JENA_HOME/bin/update" --data=$tmpf --update=delete_comments.sparul --dump >lode_bioknet.nt
