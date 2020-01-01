#!perl

# Grep generating functions with sqrt(1 +- 2*b*x +- d*x^2) and generate calls to HolonomicRecurrence
# @(#) $Id$
# 2019-12-30, Georg Fischer
# Cf. <https://cs.uwaterloo.ca/journals/JIS/VOL9/Noe/noe35.pdf>, Eq. 4
# <http://www.teherba.org/index.php/OEIS/Generating_Functions_and_Recurrences#1_.2F_Sqrt.281_-_2.2Ab.2Ax_.2B_d.2Ax.5E2.29>
# A098455: b=2; d=-36; 
# RecurrenceTable[{a[0]==1, a[1]==b, n*a[n]==(2*n-1)*b*a[n-1] - (n-1)*d*a[n-2]}, a[n], {n,0,8}]
# -> 1, 2, 24, 128, 1096, 7632, 60864, 461568, 3648096
# make runholo OFFSET=0 MATRIX="[[0],[36,-36],[2,-4],[0,1]]" INIT="[1,2]"
# new HolonomicRecurrence(0, "[[0],[-d,d],[b,-2*b],[0,1]]", "[1,b]", 0);
#
#:# Usage:
#:#   perl holsq2.pl $(COMMON)/cat25.txt > holsq2.gen
#---------------------------------
use strict;
use integer;
use warnings;

my $aseqno;
my $b;
my $d;
my $line;

while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    if (0) {
    #                              1        2                 34                      5                6                   7                          8
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?(([EO]\.)?G\.f\.\:?\s*)?(A\(x\)\s*\=\s*)?(\d+)\/\s*sqrt\(1\s*([\+\-]\s*\d*)\s*\*?\s*x\s*([\+\-]\s*\d*)\s*\*?\s*x\^2\)\s*\.}i) { 
        $aseqno = $1;
        $b = $7; 
        $d = $8; 
        &output();
    } # if
} # while <>
#----
sub output {
        $b =~ s{\s}{}g; 
        $d =~ s{\s}{}g; 
        $b = - $b / 2 + 0; # remove "+" sign
        if ($d =~ m{\A[\+\-]\Z}) { 
            $d = 1; 
        } else {
        	$d += 0; # remove "+" sign
        }
        my $bm2 = (-2)*$b; 
        my $dm = - $d; 
        print "# $line\n";
        print join("\t", $aseqno, "holos", 0, "[[0],[$dm,$d],[$b,$bm2],[0,1]]", "[1,$b]", 0, 1, "holsq2", "gfis") . "\n" 
} # output	
__DATA__
# %F A002426 G.f.: 1/sqrt(1 - 2*x - 3*x^2).
A002426 holos   0       [[0],[3,-3],[1,-2],[0,1]]       [1,1]   0       1       holsq2  gfis
# %N A006438 Expansion of e.g.f. 1/sqrt(1-8x+x^2).
A006438 holos   0       [[0],[-1,1],[4,-8],[0,1]]       [1,4]   0       1       holsq2  gfis
# %N A006442 Expansion of 1/sqrt(1-10*x+x^2).
A006442 holos   0       [[0],[-1,1],[5,-10],[0,1]]      [1,5]   0       1       holsq2  gfis
# %N A006453 Expansion of 1/sqrt(1-12x+x^2).
A006453 holos   0       [[0],[-1,1],[6,-12],[0,1]]      [1,6]   0       1       holsq2  gfis
# %N A012000 G.f.: 1/sqrt(1 - 4*x + 16*x^2).
A012000 holos   0       [[0],[-16,16],[2,-4],[0,1]]     [1,2]   0       1       holsq2  gfis
# %F A026375 G.f.: 1/sqrt(1-6*x+5*x^2). - _Emeric Deutsch_, Oct 26 2002
A026375 holos   0       [[0],[-5,5],[3,-6],[0,1]]       [1,3]   0       1       holsq2  gfis
# %F A084768 G.f.: 1/sqrt(1-14*x+x^2).
A084768 holos   0       [[0],[-1,1],[7,-14],[0,1]]      [1,7]   0       1       holsq2  gfis
# %F A084769 G.f.: 1/sqrt(1-18*x+x^2).
A084769 holos   0       [[0],[-1,1],[9,-18],[0,1]]      [1,9]   0       1       holsq2  gfis
# %F A098270 G.f.: 1/sqrt(1-20x+4x^2).
A098270 holos   0       [[0],[-4,4],[10,-20],[0,1]]     [1,10]  0       1       holsq2  gfis
# %N A098331 Expansion of 1/sqrt(1-2x+5x^2).
A098331 holos   0       [[0],[-5,5],[1,-2],[0,1]]       [1,1]   0       1       holsq2  gfis
