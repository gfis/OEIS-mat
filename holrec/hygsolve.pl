#!perl

# Generate equations to be solved for hypergeometric parameters
# @(#) $Id$
# 2022-0715, Georg Fischer
#
#:# Usage:
#:#   perl hygsolve.pl -m {maple|mma|pari} vector
#---------------------------------
use strict;
use integer;
use warnings;

my $letters = "abcdefghijklmnopqrstuvwxyz"
            . "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
my $order = 2;
my $nmin = 3;
my $nmax = $nmin + 2*$order + 1;
my $debug = 0;
my $mode = "maple";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-m}) {
        $mode     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

my @a = (1, 2, 7, 30, 156, 960, 6840, 55440, 504000, 5080320, 56246400, 678585600, 8861529600);
my $varno = $order * 2 + 2;
my $n;

if (0) {
} elsif ($mode eq "maple") {
    print &gen_maple();
} elsif ($mode eq "mma") {
    print &gen_mma();
} elsif ($mode eq "pari") {
    print &gen_pari();
}
# end main
#----
sub gen_maple() {
    my $result = "sys :=";
    my $sep = "\n{";
    for ($n = $nmin; $n <= $nmax; $n ++) {
        $result .= "$sep " . &gen_equation() . " = 0";
        $sep = "\n,"
    }
    return $result . "\n};\nsolve( sys, {" . &varlist() . "});\n";
} # gen_maple
#--
sub gen_mma() {
    # Solve[x^2 + 2 y^3 == 3681 && x > 0 && y > 0, {x, y}, Integers]
    my $result = "Solve[";
    my $sep = "\n   ";
    for ($n = $nmin; $n <= $nmax; $n ++) {
        $result .= "$sep " . &gen_equation() . " == 0";
        $sep = "\n&& "
    }
    return $result . "\n, {" . &varlist() . "}, Integers]\n";
} # gen_mma
#--
sub gen_pari() {
    my $result = "sys :=";
    my $sep = "\n{";
    for ($n = $nmin; $n <= $nmax; $n ++) {
        $result .= "$sep " . &gen_equation();
        $sep = "\n,"
    }
    return $result . "\n};\nsolve( sys, {" . &varlist() . "});\n";
} # gen_pari
#--
sub gen_equation() {
    my $result = "";
    for (my $iv = 0; $iv <= $order; $iv ++) {
        $result .= "+". substr($letters, $iv, 1) . "*" . ($n**$iv) . "*" . $a[$n-1];
    }
    $result .= "  ";
    for (my $iv = 0; $iv <= $order; $iv ++) {
        $result .= "+". substr($letters, $iv + $order + 1, 1) . "*" . ($n**$iv) . "*" . $a[$n];
    }
    return $result;
} # gen_maple
#--
sub varlist {
    return join(",", split(//, substr($letters, 0, $varno)));
}
#--------
__DATA__
A066114 holos   0   [[0],[0,-1,-3],[-2,3]]  1,2 0   0   holon
#                         a  b  c   d  e
1, 2, 7, 30, 156, 960, 6840, 55440, 504000, 5080320, 56246400, 678585600, 8861529600
(0*1-1*n-3*n^2)*a(n-1) + (-2+3*n)*a(n) = 0
(a  +b*n+c*n^2)          ( d+e*n)

sys :=
{ (a + b*2 + c*2*2)*2 + (d + e*2)*7 = 0
, (a + b*3 + c*3*3)*7 + (d + e*3)*30 = 0
, (a + b*4 + c*4*4)*30 + (d + e*4)*156 = 0
, (a + b*5 + c*5*5)*156 + (d + e*5)*960 = 0
, (a + b*6 + c*6*6)*960 + (d + e*6)*6840 = 0
, (a + b*7 + c*7*7)*6840 + (d + e*7)*55440 = 0
, (a + b*8 + c*8*8)*55440 + (d + e*8)*504000 = 0
};
solve( sys, {a,b,c,d,e});
{a = 0, b = -1/3*e, c = -e, d = -2/3*e, e = e}


Solve[x^2 + 2 y^3 == 3681 && x > 0 && y > 0, {x, y}, Integers]

Solve[
    +a*1*7+b*3*7+c*9*7  +d*1*30+e*3*30+f*9*30 == 0
&&  +a*1*30+b*4*30+c*16*30  +d*1*156+e*4*156+f*16*156 == 0
&&  +a*1*156+b*5*156+c*25*156  +d*1*960+e*5*960+f*25*960 == 0
&&  +a*1*960+b*6*960+c*36*960  +d*1*6840+e*6*6840+f*36*6840 == 0
&&  +a*1*6840+b*7*6840+c*49*6840  +d*1*55440+e*7*55440+f*49*55440 == 0
&&  +a*1*55440+b*8*55440+c*64*55440  +d*1*504000+e*8*504000+f*64*504000 == 0
&&  d <= 0 && e <= 0 && f <= 0 && (d < 0 || e < 0 || f < 0), {a,b,c,d,e,f}, Integers]
