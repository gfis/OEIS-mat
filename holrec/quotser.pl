#!perl

# Series of quotiens a(n)/a(n-1)
# @(#) $Id$
# 2024-12-10, Georg Fischer;
#
#:# Usage:
#:#   perl quotset.pl input.seq4 > output
#---------------------------------
use strict;
use integer;
use warnings;
use Math::BigInt;

my ($aseqno, $callcode, $offset1, $offset2, $termno, $data, @list);
my $rseqno;
my $ofter_file = "../common/joeis_ofter.txt";
my $debug   = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
while (<>) {
#while (<DATA>) {
    s{\s+\Z}{};
    my $line = $_;
    ($aseqno, $callcode, $offset1, $offset2, $termno, $data) = split(/\t/, $line);
    my $start = $offset2 + 2;
    my @terms = split(/\,/, $data);
    my $lastt = scalar(@terms) - 1;
    if ($lastt >= $start + 8 && length($terms[$lastt]) >= 6) {
        my $it = $lastt; 
        my $an = Math::BigInt -> new($terms[$it]);
        my @gcds = ();
        my @nums = ();
        my @dens = ();
        my $busy = 1;
        while ($busy && $it > $start) {
            $it --;
            my $an_1 = Math::BigInt->new($terms[$it]);
            my $gcd  = Math::BigInt->new($an);
            $gcd = $gcd->bgcd($an_1);
            if ($gcd->bgt(Math::BigInt->bone())) {
                my $num = Math::BigInt->new($an)->bdiv($gcd);
                #$num;
                my $den = Math::BigInt->new($an_1)->bdiv($gcd);
                #$den;
                if ($debug >= 1) {
                    print "it=$it, an=$an, an_1=$an_1, gcd=$gcd, num=$num, den=$den\n";
                }
                unshift(@gcds, $gcd);
                unshift(@nums, $num);
                unshift(@dens, $den);
                $an = $an_1;
            } else {
                $busy = 0;
            }
        } # while busy
        if ($busy > 0) {
            print join("\t", $aseqno, "quotseq", $start, join(",", splice(@terms,0,16))) . "\n";
            print join("\t", $aseqno, "quotgcd", $start, join(",", splice(@gcds ,0,32))) . "\n";
            print join("\t", $aseqno, "quotnum", $start, join(",", @nums)) . "\n";
            print join("\t", $aseqno, "quotden", $start, join(",", @dens)) . "\n";
        } # busy > 0
    } # if termno
} # while <>
#           0 1 2 3  4   5   6    7
__DATA__
A000141	quotser	0	2	10001	1,12,60,160,252,312,544,960,1020,876,1560,2400,2080,2040,3264,4160,4092,3480,4380,7200,6552,4608,8160,10560,8224,7812,10200,13120,12480,10104,14144,19200,16380,11520,17400,24960,18396,16440,24480,27200
A000142	quotser	0	3	101	1,1,2,6,24,120,720,5040,40320,362880,3628800,39916800,479001600,6227020800,87178291200,1307674368000,20922789888000,355687428096000,6402373705728000,121645100408832000,2432902008176640000,51090942171709440000,1124000727777607680000
A000145	quotser	0	2	10001	1,24,264,1760,7944,25872,64416,133056,253704,472760,825264,1297056,1938336,2963664,4437312,6091584,8118024,11368368,15653352,19822176,24832944,32826112,42517728,51425088,61903776,78146664,98021616
A259455	quotser	1	2	1000	1,30,270,1400,5250,15876,41160,95040,200475,393250,726726,1277640,2153060,3498600,5508000,8434176,12601845,18421830,26407150,37191000,51546726,70409900,94902600,126360000,166359375,216751626,279695430,357694120,453635400,570834000
A259457	quotser	0	1	20	3,66,1050,15300,220500,3245760,49533120,789264000,13172544000,230519520000,4229703878400,81315551116800,1636227552960000,34417989365760000,755835784704000000,17305616126582784000,412559358036553728000,10227311816872550400000,263309943217447526400000,7032029553158658048000000
A259458	quotser	0	1	18	18,750,20250,463050,9878400,205752960,4286520000,90561240000,1956122784000,43410118752000,992644715462400,23427803599200000,571192163942400000,14391113340764160000,374682915193466880000,10078235746321526784000,279950992953375744000000,8026706333564126208000000
A259459	quotser	0	2	16	1,18,360,9000,283500,11113200,533433600,30862944000,2121827400000,171160743600000,16020645600960000,1722947613266880000,211061082625192800000,29223842209642080000000,4542220046298654720000000,787620956028186728448000000
A259460	quotser	0	1	17	4,220,10500,535500,30870000,2044828800,156029328000,13673998800000,1369285948800000,155756276676000000,20005336176265440000,2884501462544301600000,464334381775424160000000,83021688624014300160000000,16408769917253890176000000000,3569104362241728159962112000000,850861011640079911341911040000000
A259462	quotser	0	2	15	1,30,1200,70000,5880000,691488000,110638080000,23471078400000,6454546560000000,2256222608640000000,985518035453952000000,529939925428193280000000,346227417946419609600000000,271655358696421539840000000000,253338025938605687439360000000000
A259463	quotser	0	1	14	5,550,61250,8330000,1440600000,318084480000,88994505600000,31196975040000000,13537335651840000000,7186069008518400000000,4614893517270516480000000,3548831033950800998400000000,3237226357799023349760000000000,3472842105575052965314560000000000
