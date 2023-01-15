#!perl

# Reformat Michael Somos' https://grail.cba.csuohio.edu/~somos/williams2.gp
# @(#) $Id$
# 2023-01-15, Georg Fischer
#----
use strict;
use integer;
use warnings;

while (<DATA>) {
    next if ! m{\AA\d+};
    s/\s+\Z//; # chompr
    my $line = $_;
    my ($aseqno, $etaprod, $num) = split(/\t/, $line);
    my $pqf   = "-1/1";
    my $inits = ", 1";
    print join("\t", $aseqno, "etaprod", 0, $etaprod, $pqf, $inits, "Acres&Broadhurst N=$num") . "\n"; 
    #                                       parm1     parm2 parm3   parm4
} # while DATA
__DATA__
Eta quotients and Rademacher sums
Kevin Acres, David Broadhurst
https://arxiv.org/pdf/1810.07478.pdf
Table 1, page 10

# 2 4096 η
# 24
# 2 η
# 24
# 1 A014103
A014103	[2,24;1,-24]	2
# 3 729 η
# 12
# 3 η
# 12
# 1 A121590
A121590	[3,12;1,-12]	3
# 4 256 η
# 8
# 4 η
# 8
# 1 A092877
A092877	[4,8;1,-8]	4
# 5 125 η
# 6
# 5
# η
# 6
# 1 A121591
A121591	[5,6;1,-6]	5
# 6 72 η2η
# 5
# 6
# η
# 5
# 1
# η3 A128638
A128638	[2,1;6,5;1,-5;3,-1]	6
# 7 49 η
# 4
# 7 η
# 4
# 1 A121593 
A121593	[7,4;1,-4]	7
# 8 32 η
# 2
# 2η
# 4
# 8 η
# 4
# 1η
# 2
# 4 A107035
A107035	[2,2;8,4;1,-4;4,-2]	8
# 9 27 η
# 3
# 9 η
# 3
# 1 A121589   
A121589	[9,3;1,-3]	9
# 10 20 η2η
# 3
# 10 η
# 3
# 1
# η5 A095846 
A095846	[2,1;10,3;1,-3;5,-1]	10
# 12 12 η
# 2
# 2η3η
# 3
# 12 η
# 3
# 1η4η
# 2
# 6 A187100
A187100	[2,2;3,1;12,3;1,-3;4,-1;6,-2]	12
# 13 13 η
# 2
# 13 η
# 2
# 1 A121597 
A121597	[13,2;1,-2]	13
# 16 8 η2η
# 2
# 16 η
# 2
# 1η8 A123655
A123655	[2,1;16,2;1,-2;8,-1]	16
# 18 6 η2η3η
# 2
# 18 η
# 2
# 1η6η9 A128129 
A128129	[2,1;3,1;18,2;1,-2;6,-1;9,-1]	18
# 25 5 η25 η1 
A092885	[25,1;1,-1]	25

