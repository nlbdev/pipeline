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
         src/main/resources/hyph/alphabet \
         1 \
         1 \
         $HYPH_LEVEL \
         1 \
         9 \
         1 \
         1000 \
         1
}

DICTIONARY_FILE=target/pattmp.0
cat > $DICTIONARY_FILE

PATTERNS_FILE=src/main/resources/hyph/hyph_nb_NO_standard_base.pat

rm -f target/patgen.log
touch target/patgen.log

for level in 1 2; do
    PATOUT_FILE=target/generated-resources/hyph/hyph_nb_NO_standard.pat.$level
    patgen $level \
           $DICTIONARY_FILE \
           $PATTERNS_FILE \
           $PATOUT_FILE \
           >> target/patgen.log
    mv pattmp.$level target/
    DICTIONARY_FILE=target/pattmp.$level
    PATTERNS_FILE=$PATOUT_FILE
done

#cat $DICTIONARY_FILE | grep '\.[^0]\|-' >/dev/null && exit 1

# 10 bad hyphens
#cat $DICTIONARY_FILE | awk -F'.' '{print NF-1}' | paste -sd+ - | bc

# 788383 missed hyphens
#cat $DICTIONARY_FILE | awk -F'-' '{print NF-1}' | paste -sd+ - | bc

# ...of which 771951 inferred
#cat $DICTIONARY_FILE | awk -F'-0' '{print NF-1}' | paste -sd+ - | bc

# ...and 16432 not inferred
#cat $DICTIONARY_FILE | awk -F'-[^0]' '{print NF-1}' | paste -sd+ - | bc

# 841112 good hyphens
#cat $DICTIONARY_FILE | awk -F'*' '{print NF-1}' | paste -sd+ - | bc

# ...of which 282436 inferred
#cat $DICTIONARY_FILE | awk -F'*0' '{print NF-1}' | paste -sd+ - | bc

# ...and 558676 not inferred
#cat $DICTIONARY_FILE | awk -F'*[^0]' '{print NF-1}' | paste -sd+ - | bc

cat $PATTERNS_FILE
