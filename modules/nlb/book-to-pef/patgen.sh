#!/usr/bin/env bash
if ! which patgen >/dev/null; then
    echo "patgen is required but not installed"
    exit 1
fi
if ! which timeout >/dev/null && ! which gtimeout >/dev/null; then
    echo "(g)timeout is required but not installed"
    exit 1
fi
DICTIONARY_FILE=${1}
PATTERN_FILE=${2}
PATOUT_FILE=${3}
TRANSLATE_FILE=${4}
LEFT_HYPHEN_MIN=${5}
RIGHT_HYPHEN_MIN=${6}
HYPH_LEVEL=${7}
PAT_START=${8}
PAT_FINISH=${9}
GOOD_WEIGHT=${10}
BAD_WEIGHT=${11}
THRESHOLD=${12}
cd $(dirname "$0")
FIFO=tmp
rm -f $FIFO
mkfifo $FIFO
$(which timeout || which gtimeout) 300 patgen $DICTIONARY_FILE $PATTERN_FILE $PATOUT_FILE $TRANSLATE_FILE <$FIFO &
echo $LEFT_HYPHEN_MIN $RIGHT_HYPHEN_MIN >$FIFO
echo $HYPH_LEVEL $HYPH_LEVEL >$FIFO
echo $PAT_START $PAT_FINISH >$FIFO
echo $GOOD_WEIGHT $BAD_WEIGHT $THRESHOLD >$FIFO
echo y >$FIFO
wait $!
ret=$?
rm -f $FIFO
rm pattmp.$HYPH_LEVEL
exit $ret
