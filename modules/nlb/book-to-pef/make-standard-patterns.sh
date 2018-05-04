#!/usr/bin/env bash

set -e
set -x

CURDIR=$(cd $(dirname "$0") && pwd)

patgen() {
    local HYPH_LEVEL=$1
    local DICTIONARY_FILE=$2
    local PATTERN_FILE=$3
    local PATOUT_FILE=$4
    bash $CURDIR/patgen.sh \
         $DICTIONARY_FILE \
         $PATTERN_FILE \
         $PATOUT_FILE \
         $CURDIR/src/main/resources/hyph/alphabet \
         1 \
         1 \
         $HYPH_LEVEL \
         1 \
         7 \
         1 \
         100 \
         1
}

DICTIONARY_FILE=$CURDIR/target/pattmp.0
cat > $DICTIONARY_FILE

PATTERNS_FILE=$CURDIR/src/main/resources/hyph/hyph_nb_NO_standard_base.pat

rm -f $CURDIR/target/patgen.log
touch $CURDIR/target/patgen.log

for level in 1 2 3; do
    PATOUT_FILE=$CURDIR/target/generated-resources/hyph/hyph_nb_NO_standard.pat.$level
    patgen $level \
           $DICTIONARY_FILE \
           $PATTERNS_FILE \
           $PATOUT_FILE \
           >> $CURDIR/target/patgen.log
    mv pattmp.$level $CURDIR/target/
    DICTIONARY_FILE=$CURDIR/target/pattmp.$level
    PATTERNS_FILE=$PATOUT_FILE
done

# 688 bad and 346200 missed
#cat $DICTIONARY_FILE | grep '\.[^0]\|-' >/dev/null && exit 1

cat $PATTERNS_FILE
