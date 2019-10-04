# Word frequencies in the norwegian language

**words.csv**

Words from all of NLBs books in norwegian that have been produced in full text have been counted.

This CSV-file lists all the words encountered, sorted by the number of occurrences of the word.
The first column contains the word, the second column contains the number of occurences,
and the third column contains a number from 0-9 representing the frequency of the word
(the logarithm of the number of occurences scaled to fit in the 0-9 range).

**sources.csv**

A list of all the source books that were used for counting words. The first column
is the book number used by NLB, the second column is the book title, and the third
column is the ISBN for the book.
