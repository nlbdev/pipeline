# Standard hyphen in Norwegian Language

Words are collected from Norwegian national library https://www.nb.no/sprakbanken/show?serial=oai%3Anb.no%3Asbr-39&lang=en  and process it to get hyphenated words.

**standard_hyphen.txt**
Words are hyphenated according to hyphen occurrence of same word at different positions. e.g. "foron-siede" and "foronsie-de" to "for-on-siede".

**standard_hyphen_extended.txt** 
This is extension of standard_hyphen.txt.Hyphen are normalized by adding hyphenated words if the exist in long words. e.g. "sa-lig" and "saligaf-gang" to "sa-ligaf-gang".

**extended_plus.txt**
This is further extension of standard_hyphen_extended.txt in which hyphen are normalized by adding each hyphenation occurrences in all words. e.g.  "fe-pa-rate" and "fepa-ratcly" to "fe-pa-ratcly" 



**standard_hyphen_extended_extra.txt**  

**words.txt **