export JENA_HOME='/Applications/local/dev/semantic_web/jena'
export PATH="/Users/brandizi/bin:$PATH"

tmpf=$(mktemp /tmp/tocomm_XXX.nt)
"$JENA_HOME/bin/update" --data=../bioknet.owl --update=descr2comments.sparul --dump >$tmpf
"$JENA_HOME/bin/update" --data=$tmpf --update=note2comments.sparul --dump >lode_bioknet.nt
