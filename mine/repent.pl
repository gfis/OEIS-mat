#!perl

# replace entities
# @(#) $Id$
# 2019-03-22, Georg Fischer
#
#:# usage:
#:#   perl repent.pl inputfile > outputfile
#---------------------------------
use strict;
while (<>) {
    s{\&amp\;([a-z]+)(\d+)([VA])\;}
     {<span class=\"$1$2\">\&#xa0;\&#xa0;$3\&#xa0;\&#xa0;</span>}g;
    s{\&#xa0;V\&#xa0;}{\&#xa0;v\&#xa0;}g;
    s{\&#xa0;A\&#xa0;}{\&#xa0;\^\&#xa0;}g;
    print;
} # while <>
