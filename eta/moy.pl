#!perl

# Reformat Table 2 in https://arxiv.org/pdf/1309.4320.pdf (Richard Moy)
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
    my ($aseqno, $epsig, $num) = split(/\t/, $line);
    my $pqf   = "-1/1";
    my $inits = ", 1";
    print join("\t", $aseqno, "etaprod", 0, $epsig, $pqf, $inits, "1",  "Moy Γ0($num)") . "\n"; 
    #                                       parm1   parm2 parm3   parm4 parm5
} # while DATA
__DATA__
# Some are Overlapping with Acres & Broadhurst!
A014103	[2,24;1,-24]	2
A099903	[3,12;1,-12]	3
A005798	[1,8;4,16;2,-24]	4
A121591	[5,6;1,-6]	5
A123653	[2,6;6,6;1,-6;3,-6]	6
A121593	[7,4;1,-4]	7
A107035	[2,2;8,4;1,-4;4,-2]	8
A121589	[9,3;1,-3]	9
A227213	[5,2;10,2;1,-2;2,-2]	10
A123647	[4,2;12,2;1,-2;3,-2]	12
A121597	[13,2;1,-2]	13
A123655	[2,1;16,2;1,-2;8,-1]	16
A128129	[2,1;3,1;18,2;1,-2;6,-1;9,-1]	18
A092885	[25,1;1,-1]	25

Γ0(2) η
24(2z)
η24(z)
Γ0(3) η
12(3z)
η12(z)
Γ0(4) η
8
(z)η
16(4z)
η24(2z)
Γ0(5) η
6
(5z)
η6(z)
Γ0(6) 
η(2z)η(6z)
η(z)η(3z)
6
Γ0(7) η
4
(7z)
η4(z)
Γ0(8) η
2
(2z)η
4
(8z)
η4(z)η2(4z)
Γ0(9) η
3
(9z)
η3(z)
Γ0(10) 
η(5z)η(10z)
η(z)η(2z)
2
Γ0(12) 
η(4z)η(12z)
η(z)η(3z)
2
Γ0(13) η
2
(13z)
η2(z)
Γ0(16) η(2z)η
2
(16z)
η2(z)η(8z)
Γ0(18) η(2z)η(3z)η
2
(18z)
η2(z)η(6z)η(9z)