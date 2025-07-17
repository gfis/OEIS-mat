#!perl

# holminit - In a seq4 record with CC=holos, update parm2 with the minimal list of initial terms for a list of A-numbers
# @(#) $Id$
# 2025-06-26, Georg Fischer
#
#:# Usage:
#:#   perl holminit.pl input.seq2 > updates.sql
#---------------------------------
use strict;
use integer;
use warnings;
# while (<DATA>) { 
while (<>) { 
    next if ! m{\AA\d{6}};
    my ($aseqno, $termlist, @rest) = split(/\s+/);
    my @terms = split(/\,/, $termlist);
    my $ix = 0;
    while ($ix < scalar(@terms)) {
      if ($terms[$ix] > 1 || length($terms[$ix]) > 1) {
          @terms = splice(@terms, 0, $ix + 1);
      }
      $ix++;
    } # while $ix 
    # print join("\t", $aseqno, join(",", @terms)) . "\n";
    print "UPDATE seq4 SET parm2 = \'" . join(",", @terms) . "\' WHERE aseqno = \'$aseqno\';\n";
} # while  
print "COMMIT;\n";
__DATA__
A049122	1,1,0,0,1,-1,-1,5
A049123	1,1,2,6,22,89,380,1679
A049124	1,1,2,6,20,71,264,1015
A049125	1,1,2,4,10,25,68,187
A049126	1,1,2,6,22,90,393,1789
A049127	1,1,2,6,22,88,369,1597
A049128	1,1,2,6,20,70,255,959
A049129	1,1,2,6,20,72,271,1055
A049130	1,1,2,4,10,26,73,211
A049131	1,1,2,4,10,24,65,171
A049132	1,1,0,0,2,2,3,19
A049133	1,1,2,4,8,14,15,-31
