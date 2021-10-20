#!perl

# Extract parameters for triangles
# @(#) $Id$
# 2021-10-02, Georg Fischer: copied from ck/ck_guides.pl
#
#:# Usage:
#:#   perl tri_guides.pl [-d debug] [-a sel] > target.tmp
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $asel = "0-9a-zA-Z"; # select all possible TAB codes
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $asel      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my $offset = 0;
my @apowers = 
    ( "A000004" # all zeroes
    , "A000012" # all ones
    , "A000079" # 2^n
    , "A000244" # 3^n
    , "A000302" # 4^n
    , "A000351" # 5^n
    , "A000400" # 6^n
    );
my ($opt, $base, @ans, $callcode, $aseqno, @parms);
my %hash = ();
while (<DATA>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if ($line =~ m{\A\=(\w)\=}) {
        $opt = $1;
        # print "opt=$opt\n";
        if ($opt !~ m{[$asel]}) {
            # print "# no desired opt code $opt, ignore\n";
        } elsif ($opt =~ m{A}) { # A256890
            ($opt, @ans) = split(/\s+/, $line);
            $callcode = "pastrico";
            my $a = $ans[0];
            for (my $b = 1; $b < scalar(@ans); $b ++) {
            	$aseqno = $ans[$b];
                my $fk   = "$a*k + $b"; 
                my $fn_1 = "$a*(n - 1) + $b";
                ($fk, $fn_1) = map { 
                    s{\A1\*}{};
                    $_
                    } ($fk, $fn_1);
                @parms = (0);
                push(@parms, "new $apowers[$b]()", "new $apowers[$b]()", "new A000004()", "", "~~    ~~return get(k).multiply($fk).add(get(k - 1).multiply($fn_1));");
                &output($aseqno, "pastrico", @parms);
            } # for
        } else { # unknown -a
        }
    } # line with =opt=
} # while <DATA>
#----
sub output {
    my ($aseqno, $callcode, @parms) = @_;
    if ($aseqno ne "nnnn") {
        print join("\t", $aseqno, $callcode, @parms) . "\n";
    }
} # out
__DATA__
A256890		Triangle T(n,k) = t(n-k, k); t(n,m) = f(m)*t(n-1,m) + f(n)*t(n,m-1), where f(x) = x + 2.		24
1, 2, 2, 4, 12, 4, 8, 52, 52, 8, 16, 196, 416, 196, 16, 32, 684, 2644, 2644, 684, 32, 64, 2276, 14680, 26440, 14680, 2276, 64, 128, 7340, 74652, 220280, 220280, 74652, 7340, 128, 256, 23172, 357328, 1623964, 2643360, 1623964, 357328, 23172, 256, 512, 72076, 1637860, 10978444, 27227908, 27227908, 10978444, 1637860, 72076, 512 

a\b     1.......2.......3.......4.......5.......6
=A=	-1  A144431
=A=	0   A007318 A038208 A038221
=A=	1   A008292 A256890 A257180 A257606 A257607
=A=	2   A060187 A257609 A257611 A257613 A257615
=A=	3   A142458 A257610 A257620 A257622 A257624 A257626
=A=	4   A142459 A257612 A257621
=A=	5   A142460 A257614 A257623
=A=	6   A142461 A257616 A257625
=A=	7   A142462 A257617 A257627
=A=	8   A167884 A257618
=A=	9   A257608 A257619
The row sums of these, and similarly constructed number triangles, are shown in the following table:
a\b 1.......2.......3.......4.......5.......6.......7.......8.......9
0   A000079 A000302 A000400
1   A000142 A001715 A001725 A049388 A049198
2   A000165 A002866 A002866 A051580 A051582
3   A008544 A051578 A037559 A051605 A051607 A051609
4   A001813 A047053 A000407 A034177 A051618 A051620 A051622
5   A047055 A008546 A008548 A034300 A034325 A051688 A051690
6   A047657 A049308 A047058 A034689 A034724 A034788 A053101 A053103
7   A084947 A144827 A049209 A045754 A034830 A034832 A034834 A053105
8   A084948 A144828 A147626 A051189 A034908 A034910 A034912 A034976 A053115
9   A084949 A144829 A147630 A049211 A045756 A035013 A035018 A035021 A035023
10                                  A051262 A035265 A035273         A035277
11                                  A254322
12                                          A145448
The formula can be further generalized to: t(n,m) = f(m+s)*t(n-1,m) + f(n-s)*t(n,m-1), where f(x) = a*x + b. The following table specifies triangles with nonzero values for s (given after the slash).
a\ b  0           1           2          3
-2    A130595/1
-1
0
1     A110555/-1  A120434/-1  A144697/1  A144699/2
With the absolute value, f(x) = |x|, one obtains A038221/3, A038234/4,, A038247/5, 


T(n,k) = t(n-k, k); t(n,m) = f(m)*t(n-1,m) + f(n)*t(n,m-1), where f(x) = x + 2

restart:
f := proc(x): 1*x+2 end:
t := proc(n,m) option remember: if n < 0 or m < 0 then 0 else if n=0 and m=0 then 1 else f(m)*t(n-1,m) + f(n)*t(n,m-1) fi fi end:
seq(seq(t(n-k,k),k=0..n), n=0..8);
