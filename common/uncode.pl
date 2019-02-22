#!perl

# Replace Unicodes by "normal" ASCII character
# @(#) $Id$
# 2019-01-26, Georg Fischer
#
#:# usage:
#:#     perl uncode.pl < input > output
#:# currently replaced are:
#:#   \u003c  <
#:#   \u003e  >
#:#   \"      "
#---------------------------------
use strict;
# binmode(STDOUT, ':utf8');
while (<>) {
    s/\\u([0-9a-fA-F]{4})/chr(hex($1))/eg;
    s{\\\"}{\"}g;
    s{\\\\}{\\}g;
    print;
}   
