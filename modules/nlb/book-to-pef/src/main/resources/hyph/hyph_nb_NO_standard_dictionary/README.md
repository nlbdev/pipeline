# Standard hyphenation in Norwegian Language

Words are collected from Norwegian national library https://www.nb.no/sprakbanken/show?serial=oai%3Anb.no%3Asbr-39&lang=en and process it to get hyphenated words.

**språkbanken-1.txt**
Words are hyphenated according to hyphen occurrence of same word at different positions. e.g. "foron-siede" and "foronsie-de" to "for-on-siede".

**språkbanken-2.txt**
This is extension of språkbanken-1.txt. Hyphen are normalized by adding hyphenated words if the exist in long words. e.g. "sa-lig" and "saligaf-gang" to "sa-ligaf-gang".

**språkbanken-2_extra.txt**
Words that were removed from språkbanken-2.txt because they can not be encoded in Latin 1 (e.g. "ha-n-fčrl-i-ga") or are too long for patgen to handle (e.g. "con-cédepro-pitiusvtcu-iusfolém-niacelebråmuseius").

**språkbanken-3.txt**
This is further extension of språkbanken-2.txt in which hyphen are normalized by adding each hyphenation occurrences in all words. e.g. "fe-pa-rate" and "fepa-ratcly" to "fe-pa-ratcly" 

**språkbanken-3_extra.txt**
Words that were removed from språkbanken-3.txt because they can not be encoded in Latin 1 or are too long for patgen to handle.


språkbanken-3_with_different_hyphen.txt
This is same as språkbanken-3.txt the difference is added hyphen are different from previous stage .Added hyphen on this stage is unicode U+2013


**words.txt**
This list came from http://no.speling.org.
