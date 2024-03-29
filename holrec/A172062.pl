#!perl
# Evaluate the recurrence group in A172062
# 2022-08-12, Georg Fischer
use strict;
use warnings;
use integer;

my @onums = ();
for (my $in = 0; $in < 64; $in ++) {
    $onums[$in] = 0;
}
while (<DATA>) {
    next if ! m{\A\*};
    my @nnums = ($_ =~ m{(\-?\d+)}g);
    for (my $in = 0; $in < scalar(@nnums); $in ++) {
        print "\t" . ($nnums[$in] - $onums[$in]);
        $onums[$in] = $nnums[$in];
    }
    print "\n";
} # while DATA

__DATA__
# with conjectured D-finite recurrences, all similar?
A091526	-2
A072547	-1
A026641	0
A014300	1
A014301	2
A172025	3
A172061	4
A172062	5
A172063	6
A172064	7
A172065	8
A172066	9
A172067	10

# A072547	-1	[[0],[14,-4],[19,-3],[-17,9],[2,-2]]	1,0,2,6
# A091526	-2	[[0],[24,-34,12],[48,-61,21],[0,14,-6]]	1,-1,1
# A026641	0	[[0],[2,-4],[4,-7],[0,2]]	1,1,4
# A014300	1	[[0],[20,-8],[38,-18],[-4,-3],[0,2]]	1,2,7,24
# A172067	10	[[0],[-1440,-896,-182,-12],[-2880,-1622,-317,-21],[0,340,94,6]]	1,11,79
# A014301	2	[[0],[-10,4],[-16,3],[8,-9],[0,2]]	0,1,3,11
# A172025	3	[[0],[-4,-10,-4],[-8,-17,-7],[0,6,2]]	1,4,16
# A172061	4	[[0],[-2,4],[14,19],[16,15],[-36,-13],[8,2]]	1,5,22,91,367
# A172062	5	[[0],[-120,-176,-82,-12],[-240,-317,-142,-21],[0,70,44,6]]	1,6,29
# A172063	6	[[0],[-80,-92,-34,-4],[-160,-166,-59,-7],[0,36,18,2]]	1,7,37
# A172064	7	[[0],[-420,-398,-122,-12],[-840,-719,-212,-21],[0,154,64,6]]	1,8,46
# A172065	8	[[0],[-672,-542,-142,-12],[-1344,-980,-247,-21],[0,208,74,6]]	1,9,56
# A172066	9	[[0],[-336,-236,-54,-4],[-672,-427,-94,-7],[0,90,28,2]]	1,10,67

? A026641	1	[[0],[ 0  , 0  ,18 ,-12],	[0  , 0  ,33  ,-21],	[0, 0,-6,6]]	1,1
* A014300	2	[[0],[ 0  , 4  ,-2 ,-12],	[0  ,7   ,-2  ,-21],	[0,-2, 4,6]]	1,2
* A014301	2	[[0],[ 0  ,-8  ,-22,-12],	[0  ,-14 ,-37 ,-21],	[0, 4,14,6]]	1,3
* A172025	3	[[0],[-12 ,-42 ,-42,-12],	[-24,-75 ,-72 ,-21],	[0,18,24,6]]	1,4
* A172061	4	[[0],[-48 ,-98 ,-62,-12],	[-96,-176,-107,-21],	[0,40,34,6]]	1,5
* A172062	5	[[0],[-120,-176,-82,-12],	[-240,-317,-142,-21],	[0,70,44,6]]	1,6
* A172063	6	[[0],[-240,-276,-102,-12],	[-480,-498,-177,-21],	[0,108,54,6]]	1,7
* A172064	7	[[0],[-420,-398,-122,-12],	[-840,-719,-212,-21],	[0,154,64,6]]	1,8
* A172065	8	[[0],[-672,-542,-142,-12],	[-1344,-980,-247,-21],	[0,208,74,6]]	1,9
* A172066	9	[[0],[-1008,-708,-162,-12],	[-2016,-1281,-282,-21],	[0,270,84,6]]	1,10
* A172067	10	[[0],[-1440,-896,-182,-12],	[-2880,-1622,-317,-21],	[0,340,94,6]]	1,11
* Annnnnn	11	[[0],[-1980,-1106,-202,-12],[-3960,-2003,-352,-21],	[0,418,104,6]]	1,12

120,240,420,672,1008,1440   

276,398,542,708,896          

240,480,840,1344,2016,2880,     

317,498,719,980,1281,1622