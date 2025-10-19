#!perl

# Copy the CAT25 file and replace all leading "%" characters by "#" for jOEIS sequences
# 2024-07-03: "Empirical for (row|column)" -> "?"
# 2023-09-28: nyi A-numbers -> "Ännnnnn"
# 2023-05-05: renamed from ../common/jcat25.pl
# 2023-05-01: App(e->a)rent, seem
# 2021-95-30: Conjecture (Start) ... (End)
# 2021-01-21, Georg Fischer
#
#:# Usage:
#:#   perl jcat28.pl [-f ofter_file] [-d debug] [-n nyi-char] cat28.txt > jcat28.txt 
#:#     -d debugging mode: 0=none, 1=some, 2=more
#:#     -n character that replaces the "A" in A-numbers that are not yet implemented in jOEIS, e.g. "€"
#:#     -f file with aseqno, offset1, terms (default $(COMMON)/joeis_ofter.txt)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my $ofter_file = "joeis_ofter.txt";
my $debug = 0;
my $sharp = "#";
my $nyia = "";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } elsif ($opt   =~ m{\-n}  ) {
        $nyia       = shift(@ARGV); # usually "€"
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my $terms;
my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    my ($aseqno, $offset, $terms) = split(/\t/);
    $terms = $terms || "";
    $ofters{$aseqno} = "$offset\t$terms";
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
foreach my $key (("A000001", "A000007", "A183652", "A400000")) {
    print STDERR "$key " . ($ofters{$key} || "undef") . "\n";
}
#----------------
my $oseqno = "";
my $otype  = "-";
my $state  = 0;
my $col1   = "%";

while (<>) { # CAT25 format
    next if length($_) < 11;
    $line = $_;
    my $atype  = substr($line, 1, 1);
    my $aseqno = substr($line, 3, 7); # $1 || "A000000";
    if ($atype ne $otype) {
        if ($state != 0) {
            if ($state != 2) {
                print STDERR "# Start-End overrun in $otype $oseqno\n";
            }
            $state = 0;
        }
        $otype = $atype;
    }
    if ($aseqno ne $oseqno) {
        $oseqno = $aseqno;
        if (defined($ofters{$aseqno})) {
            $col1 = "#";
        } else {
            $col1 = "%";
        }
    }
    $line =~ s{\A.}{$col1};
    if (0) {
    } elsif ($atype eq "F" && ($line =~ m{Empirical for (row|column)})) {
        $state = 2;
    } elsif ($atype eq "F" && ($line =~ m{Conjecture}i) && ($line =~ m{\(Start\)}i)) {
        $state = 1;
    } elsif ($state == 1   && ($line =~ m{\(End\)}i)) {
        $state = 0;
    } elsif ($state == 2   && ($atype ne "F")) {
        $state = 0;
    }
    if ($state >= 1 || ($line =~ m{[Cc]onject|Apparent|Appear|May be|Empiric|Seem})) {
        $line =~ s{\A.}{\?};
    }
    if ($nyia ne "") {
        #                      12 23     31
        substr($line, 11) =~ s{((A)(\d{6}))}{defined($ofters{"$1"}) ? "$1" : "$nyia$3"}eg;
    }
    print $line;
} # while <>
#================
__DATA__
012345678901234567
%A A389846 _Michel Marcus_, Oct 17 2025
%I A389847 #9 Oct 17 2025 09:57:54
%S A389847 1,0,0,6,72,720,8280,120960,2116800,41610240,903571200,21674822400,
%T A389847 571548700800,16417540339200,509709674073600,17011056372710400,
%U A389847 607616125788672000,23133198948507648000,935196923565557452800,40010432908461913497600,1806175046642174208000000
%N A389847 E.g.f. A(x) satisfies A(x) = exp(x^3 * A(x) / (1-x)^3).
%F A389847 E.g.f.: exp( -LambertW(-x^3 / (1-x)^3) ).
%F A389847 a(n) = n! * Sum_{k=0..floor(n/3)} (k+1)^(k-1) * binomial(n-1,n-3*k)/k!.
%o A389847 (PARI) a(n) = n!*sum(k=0, n\3, (k+1)^(k-1)*binomial(n-1, n-3*k)/k!);
%Y A389847 Cf. A367789, €389844.
%Y A389847 Cf. A361572, A387951.
%K A389847 nonn,new
%O A389847 0,4
%A A389847 _Seiichi Manyama_, Oct 17 2025
%I A389853 #12 Oct 18 2025 02:34:00
%S A389853 14,29,47,53,71,73,179,277,311,349,353,599,613,643,1117,1123
%N A389853 Numbers k such that both 2^k-1 and 2^k+1 are sphenic.
%e A389853 14 is a term: 2^14-1 = 16383 = 3*43*127 and 2^14+1 = 16385 = 5*29*113.
%p A389853 q:= n-> andmap(x-> ifactors(x)[2][.., 2]=[1$3], [2^n-1, 2^n+1]):
%p A389853 select(q, [$1..200])[];  # _Alois P. Heinz_, Oct 17 2025
%t A389853 Select[Range[180], AllTrue[2^# + {-1, 1}, And[SquareFreeQ[#], PrimeNu[#] == 3] &] &]
%Y A389853 Cf. A000051, A000225, A007304, A092558 (both 2^k-1 and 2^k+1 are semiprimes).
%Y A389853 Supersets: €262978, €389854.
%K A389853 nonn,hard,more,new
%O A389853 1,1
%A A389853 _Michael De Vlieger_, Oct 17 2025
%E A389853 a(8)-a(16) from _Amiram Eldar_, Oct 17 2025%C A000001 Also, number of nonisomorphic primitives of the combinatorial species Lin[n-1]. - _Nicolae Boicu_, Apr 29 2011