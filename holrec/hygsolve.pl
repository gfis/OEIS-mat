#!perl

# Generate equations to be solved for hypergeometric parameters
# @(#) $Id$
# 2022-07-17, Georg Fischer; diam. Konfi
#
#:# Usage:
#:#   perl hygsolve.pl -c {maple|mma|pari} [-n order] inout.seq4 > output.seq4
#:#       -c CAS to be used (default: pari)
#:#       -n order of n (default: 4)
#:#       -s start number of first term (default: 3, counted from 1)
#:#       input:  parm1 = data terms
#:#       output: parm1 = solution vector of length 2 * order
#---------------------------------
use strict;
use integer;
use warnings;

my $letters = "abcdefghjklmnopqrstuvwxyz"  # no "i" for Maple
            . "ABCDEFGHJKLMNOPQRSTUVWXYZ";
my $order = 2;
my $debug = 0;
my $cas = "pari";
my $startn = 3;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-c}) {
        $cas      = shift(@ARGV);
    } elsif ($opt =~ m{\-n}) {
        $order    = shift(@ARGV);
    } elsif ($opt =~ m{\-s}) {
        $startn   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV;

my $nmin = $startn;
my $nmax = $nmin + 2*$order + 1;
my @a; # terms
my $varno = 2*$order + 2;
my $n;
my ($aseqno, $callcode, $offset, $termlist);
my $tempfile = "hygsolve.tmp";
while (<>) {
    s/\s+\Z//; # chompr
    next if ! m{\AA\d+};
    ($aseqno, $callcode, $offset, $termlist) = split(/\t/);
    @a = split(/\, */, $termlist);
    pop(@a); # last was perhaps truncated
    for (my $i = 0; $i < $offset; $i ++) {
        unshift(@a, 0); # for offset > 0 prefix with zero(es)
    } # for prefix
    my $increasing = 1;
    my $ia = 1; 
    while ($increasing && $ia < scalar(@a)) {
        if ($a[$ia - 1] >= $a[$ia]) {
            $increasing = 0;
        }
        $ia ++;
    } # while
    if (0 or $increasing) {
        my $prog;
        if (0) {
        } elsif ($cas eq "maple") {
            $prog = &gen_maple();
            print $prog;
        } elsif ($cas eq "mma") {
            $prog = &gen_mma();
            print $prog;
        } elsif ($cas eq "pari") {
            $prog = &gen_pari();
            open(PRO, ">", "$tempfile") || die "cannot write $tempfile";
            print PRO $prog;
            close(PRO);
            # print $prog;
            my $result = `gp -fq $tempfile`;
            if ($result =~ s{\[\[[0\,\s]+\]\~\, *\[}{}) {
                $result =~ s{\]\]\s+\Z}{}; #chompr
                if ($debug >= 3 && $result ne ";") {
                    print "# $aseqno $result\n";
                    # A322288 4449, 0, 0; -710, 4449, 0; 0, -710, 4449; 0, 0, -710; -5159, 0, 0; 710, -5159, 0; 0, 710, -5159; 0, 0, 710]] 0,6,12,56,100,144,188,521,1231
                }
                my @pair = &select_column($result);
                if (scalar(@pair) == 2) {
                    my $rlist = $pair[0];
                    my $llist = $pair[1];
                    $rlist =~ s{(\, *0)+\Z}{};
                    $llist =~ s{(\, *0)+\Z}{};
                    if  ($result ne ",") {
                        my $tlist = join(",", splice(@a, $offset, $startn + 2));
                        if ($debug >= 3 && $result ne ";") {
                            print "# $aseqno $result $tlist\n";
                            # A322288 4449, 0, 0; -710, 4449, 0; 0, -710, 4449; 0, 0, -710; -5159, 0, 0; 710, -5159, 0; 0, 710, -5159; 0, 0, 710]] 0,6,12,56,100,144,188,521,1231
                        }
                        print "make runholo OFF=$offset A=$aseqno MATRIX=\"[[0],[$llist],[$rlist]]\" INIT=\"$tlist\"\n";
                        print join("\t", $aseqno, "holos", $offset, "[[0],[$llist],[$rlist]]", $tlist, 0, 0), "\n";
                    } # plausible result
                } # scalar(pair) == 2
            }
        }
    } # if increasing
} # while <>
# end main
#----
sub select_column {
    my ($list) = @_;
    print 
    my @vector = ();
    my @pair = (); # pair of coefficients for a[n-1] and a[n-0]
    my @rows = split(/\; */, $list);
    my $nrow = scalar(@rows);
    if ($nrow > 0) { # at least 1 row
        if ($debug >= 2) {
            print "#= " . join("\t", $aseqno, 'vect', $nrow, "");
        }
        my $ncol = scalar(split(/\, */, $rows[0])) || 0;
        for (my $icol = $ncol - 1; $icol >= 0; $icol --) { # keep first vector
            @vector = ();
            for (my $irow = 0; $irow < $nrow; $irow ++) {
                my @row = split(/\, */, $rows[$irow]);
                push(@vector, $row[$icol]);
            } # for irow
            $pair[1] = join(",", splice(@vector, 0, $order + 1));
            $pair[0] = join(",", splice(@vector, 0, $order + 1));
            if ($debug >= 2) {
                print "$icol:$pair[1]/$pair[0]; ";
            }
        } # for icol
        if ($debug >= 2) {
            print "\n";
        }
        if ($pair[0] eq $pair[1]) {
            @pair = ();
        }
    } # at least 1 row
    return @pair;
} # select_column
#----
sub gen_maple() {
    my $result = "sys :=";
    my $sep = "\n{";
    for ($n = $nmin; $n <= $nmax; $n ++) {
        $result .= "$sep " . &gen_equation("+") . " = 0";
        $sep = "\n,"
    }
    my $vars = &varlist();
    $result .= <<"GFis";

};
sol := isolve(sys);
seq(coeff(op(2,sol[i]),_Z1,1),i=1..nops(sol));
GFis
    return $result;
} # gen_maple
#--
sub gen_mma() {
    # Solve[x^2 + 2 y^3 == 3681 && x > 0 && y > 0, {x, y}, Integers]
    my $result = "FindInstance[";
    my $sep = "\n   ";
    for ($n = $nmin; $n <= $nmax; $n ++) {
        $result .= "$sep " . &gen_equation("+") . " == 0";
        $sep = "\n&& "
    }
    $result .= "$sep (" .join(" || ", map {
        $_ . "!=0"
        } split(//, substr($letters, 0, $varno))) . ")";
    $result .= "\n, {" . &varlist() . "}]\n";
    return $result;
} # gen_mma
#--
sub gen_pari() {
    # M = [1,2;3,4;5,6];
    # B = [4,6,8]~; X = matsolve(M, B)
    my $result = "MAT = ";
    my $sep = "[";
    my @vecs = ();
    for ($n = $nmin; $n <= $nmax; $n ++) {
        my $eq = &gen_equation(",");
        $eq =~ s{[a-zA-Z]\*}{}g;
        my @elems = split(/\,/, $eq);
        push(@vecs, 0); # pop(@elems));
        $result .= "$sep " . join(",", @elems);
        $sep = ";"
    }
    $result .= "];\nVEC = [" . join(",", @vecs) . "]~;\n";
    $result .= "iferr(RES=matsolvemod(MAT,0,VEC,flag=1),E,RES=[]);\n";
    $result .= "print(RES); quit()\n";
    return $result;
} # gen_pari
#--
sub gen_equation() {
    my ($psep) = @_;
    my $result = "";
    my $sep = "";
    for (my $iv = 0; $iv <= $order; $iv ++) {
        $result .= $sep . substr($letters, $iv, 1) . "*" . ($n**$iv) . "*" . $a[$n-1];
        $sep = $psep;
    }
    $result .= "  ";
    for (my $iv = 0; $iv <= $order; $iv ++) {
        $result .= $sep . substr($letters, $iv + $order + 1, 1) . "*" . ($n**$iv) . "*" . $a[$n];
    }
    return $result;
} # gen_maple
#--
sub varlist {
    return join(",", split(//, substr($letters, 0, $varno)));
}
#--------
__DATA__
A066114	hygsolve	0	1, 2, 7, 30, 156, 960, 6840, 55440, 504000, 5080320, 56246400, 678585600, 8861529600
A093646	hygsolve	0	1,19,145,715,2695,8437,23023,56485,127270,267410,529958,999362,1805570,3142790,5293970

# A066114 holos   0   [[0],[0,-1,-3],[-2,3]]  1,2 0   0   holon
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
isolve( sys, {a,b,c,d,e});
{a = 0, b = -1/3*e, c = -e, d = -2/3*e, e = e}

v := {a = 0, b = -_Z1, c = -3*_Z1, d = -2*_Z1, e = 3*_Z1, f = 0}
seq(coeff(op(2,v[i]),_Z1,1),i=1..nops(v));
0, -1, -3, -2, 3, 0


Solve[x^2 + 2 y^3 == 3681 && x > 0 && y > 0, {x, y}, Integers]

Solve[
    +a*1*7+b*3*7+c*9*7  +d*1*30+e*3*30+f*9*30 == 0
&&  +a*1*30+b*4*30+c*16*30  +d*1*156+e*4*156+f*16*156 == 0
&&  +a*1*156+b*5*156+c*25*156  +d*1*960+e*5*960+f*25*960 == 0
&&  +a*1*960+b*6*960+c*36*960  +d*1*6840+e*6*6840+f*36*6840 == 0
&&  +a*1*6840+b*7*6840+c*49*6840  +d*1*55440+e*7*55440+f*49*55440 == 0
&&  +a*1*55440+b*8*55440+c*64*55440  +d*1*504000+e*8*504000+f*64*504000 == 0
&&  d <= 0 && e <= 0 && f <= 0 && (d < 0 || e < 0 || f < 0), {a,b,c,d,e,f}, Integers]

# A093646 holos   0   [[0],[-72,-89,-10],[0,-1,10]]   1,19    0   0   holon