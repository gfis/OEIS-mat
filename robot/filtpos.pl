#!perl

# Extract parameters for FilterPositionSequence ("Numbers k such that...", "Indices of ... in Annn")
# @(#) $Id$
# 2023-09-07, Georg Fischer: copied from anopan.pl
#
#:# Usage:
#:#     grep -P "such that A\d{6}\(\w\) is prime" $(CAT) | grep -P "^\%" | $(NYI) filtpos \
#:#     | perl filtpos.pl [-d debug] > $@.tmp 2> $@.rest.tmp
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $COMMON = "../common";
my $ofter_file = "$COMMON/joeis_ofter.txt";
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
} # while options
#----------------
my $aseqno;
my $offset = 1;
my $terms;
my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    ($aseqno, $offset, $terms) = split(/\t/);
    $terms = $terms || "";
    if ($offset < -1) { # offsets -2, -3: strange, skip these
    } else {
        $ofters{$aseqno} = $offset; # "$offset\t$terms";
    }
} # while <OFT>
close(OFT);
# print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";

my $line;
my ($callcode, $name, $predicate, $roffset);
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my $nok = "";
    ($aseqno, $callcode, $offset, $name) = split(/\t/, $line);
    $name =~ s{ an? }{ }g; # remove superfluous indefinite article
    my ($mul, $rseqno, $add, $predicate) = ("1", "", 0, "PRIME");
    if (0) {
    #                             1         1 2      2            3             3     4            4
    } elsif ($name =~ m{such that (\d+ ?\* ?)?(A\d{6})\(\w[^\)]*\)( *[\+\-] *\d+)? is ([^\.\,\;\:]+)}) {
        ($mul, $rseqno, $add, $predicate) = ($1 || 1, $2, $3 || 0, $4 || "");
        if ($predicate eq "") {
            $predicate = "0";
        }
        
    #                   1                 1    2     23      3
    } elsif ($name =~ m{(Positions|Indices) of ([^A]+)(A\d{6})}) {
        ($predicate, $rseqno) = ($2, $3);
        $predicate =~ s{ *in +\Z}{};
        
    }
    if ($nok eq "") {
        $mul =~ s{[ \*]}{}g;
        $add =~ s{ }{}g;
        $roffset = $ofters{$rseqno} || 1;
        if ($mul != 1 || $add != 0) {
            $rseqno = "new SimpleTransformSequence(new $rseqno(), t -> t";
            if ($mul != 1) {
                $rseqno .= ".multiply($mul)";
            }
            if ($add != 0) {
                $rseqno .= ".add($add)";
            }
            $rseqno .= ")";
        } else {
            $rseqno = "new $rseqno()";
        }

        if (0) {
        } elsif ($predicate =~ m{^in }) {
            $nok = "inAnnn";

        } elsif ($predicate =~ m{^(perfect +)?cube}) {
            $predicate = "CUBE";
        } elsif ($predicate =~ m{^(divisible by|multiple of) [i-n]\Z}) {
            $predicate = "DIVISIBLE_BY_INDEX";
        } elsif ($predicate =~ m{^even\b}) {
            $predicate = "EVEN";
        } elsif ($predicate =~ m{^not prime}) { # test before PRIME
            $predicate = "NONPRIME";
        } elsif ($predicate =~ m{^odd\b}) {
            $predicate = "ODD";
        } elsif ($predicate =~ m{^palindrom}) {
            $predicate = "PALINDROME";
        } elsif ($predicate =~ m{^power of (two|2)}) {
            $predicate = "POWER2";
        } elsif ($predicate =~ m{^prime}) {
            $predicate = "PRIME";
        } elsif ($predicate =~ m{^not squarefree}) { # test before SQUAREFREE
            $predicate = "NONSQUAREFREE";
        } elsif ($predicate =~ m{^(non|not )(zero\b|0)}) { # test before ZERO
            $predicate = "NONZERO";
        } elsif ($predicate =~ m{^semiprime}) {
            $predicate = "SEMIPRIME";
        } elsif ($predicate =~ m{^squarefree}) { # test before SQUARE
            $predicate = "SQUAREFREE";
        } elsif ($predicate =~ m{^(perfect +)?square}) {
            $predicate = "SQUARE";
        } elsif ($predicate =~ m{^triangular( number)?}) {
            $predicate = "TRIANGULAR";
        } elsif ($predicate =~ m{^(zero|0)}) {
            $predicate = "ZERO";
        } elsif ($predicate =~ m{^(one|1)}) {
            $predicate = "v -> v.equals(Z.ONE)";
        } elsif ($predicate =~ m{^(\-?\d+)}) {
            $predicate = "v -> v.equals(Z.valueOf($1))";

        } else {
            $nok = "unpred";
        }
    } else {
        $nok = "?";
    }
    if ($nok eq "") {
        print        join("\t", $aseqno, "filtpos", $offset, $roffset, "$rseqno", $predicate, substr($name, 0, 256)) . "\n"; 
    } else {
        print STDERR join("\t", $aseqno, "$nok"   , $offset, $roffset, "$rseqno", $predicate, substr($name, 0, 256)) . "\n";
    }
} # while <>
#----------------
__DATA__
A071186 filtpos 0 Numbers k such that A066066(k) is prime. - _Amiram Eldar_, May 19 2022
A073073 filtpos 0 Numbers m such that the minimal value of abs(2^m - 3^x) > 0 is prime (i.e., m such that A064024(m) is prime).
A105454 filtpos 0 Or, numbers n such that A152117(n) is prime. - _Zak Seidov_, Feb 05 2016
A111354 filtpos 0 Numbers n such that A007406(n) is prime.
A112881 filtpos 0 Indices of prime Perrin numbers; values of n such that A001608(n) is prime.