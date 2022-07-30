#!perl

# Prepare result of grep -E "[PCD]\-finite"
# @(#) $Id$
# 2022-07-29, Georg Fischer
#
#:# Usage:
#:#     perl df_prep.pl [-d debug] input.seq4 > output.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;

my $mode = "bf";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;
my ($aseqno, $recur, $callcode, $offset1, $name);
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $callcode, $offset1, $name) = split(/\t/, $line);
    $name =~ s{\A.*[PCD]\-finite (with )?[Rrecun]+\:? *}{};
    $name =~ s{Expansion satisfies }{};
    $name =~ s{\(of order \d+\)\:?}{};
    $name =~ s{[\.\;].*}{};
    $name =~ s{\*\*}{\*}g;
    $name =~ s{\,? (for|with|if|when) .*}{};
    $name =~ s{\,? *n *\\u.*}{};
    $name =~ s{ }{}g;
    $name =~ s{((a\(\d+\)\=)+\d+\,?)}{};
    $name =~ s{([\)\dn])([\(a])}{$1\*$2}g;
    $name =~ s{(\d+)([na\(])}{$1\*$2}g;
    $name =~ s{a\(n\)}{a\(n\+0\)}g;
    $name =~ s{\A([^\=]+)\=([^0])}{\-\($1\)\+$2}; # abcd = def -> -(abcd) + def
    $name =~ s{\=0\Z}{}; # abcd = def -> -(abcd) + def
    my ($min, $max) = (0, 0);
    my @dists = map {
        if ($_ < $min) { $min = $_; }
        if ($_ > $max) { $max = $_; }
        $_
        } ($name =~ m{a\(n([\+\-]\d+)\)}g);
    $min += 0; # remove "+" sign
    $max += 0;
    $name =~ s{a\(n([\+\-]\d+)\)}{"A\^" . (-$1 + $max)}eg;
    if ($max > 0) {
        $name =~ s{n}{\(n\-$max\)}g;
    }
    
    my $matrix = $name;
    my $init = $max - $min;
    print "# " . join("\t", $aseqno, "opehol", $offset1, $matrix, $init) . "\n";
    my $tempname = "opehol.tmp";
    open(GP, ">", $tempname) || die "cannot write \"$tempname\"\n";
    print GP <<"GFis";
read("../../holrec/opehol.gpi");
opehol($aseqno, $offset1, $matrix, $init);
quit;
GFis
    close(GP);
    my $result = `gp -fq $tempname`;
    $result =~ s{\, }{\,}g; # not s{\s}{}g !
    print $result;

} # while <>
#--------------------------------------------
__DATA__
ajson/A047665.json:             "D-finite with recurrence: n*(2*n-3)*a(n) = (2*n-1)*(7*n-10)*a(n-1) - (2*n-3)*(7*n-4)*a(n-2) + (n-2)*(2*n-1)*a(n-3). - _Vaclav Kotesovec_, Oct 08 2012",
ajson/A047749.json:             "Conjecture D-finite with recurrence: 8*n*(n+1)*a(n) + 36*n*(n-2)*a(n-1) - 6*(9n^2-18n+14)*a(n-2) - 27*(3n-7)*(3n-8)*a(n-3) = 0. - _R. J. Mathar_, Dec 19 2011",
ajson/A047781.json:             "D-finite with recurrence n*(2*n-3)*a(n) - (12*n^2-24*n+8)*a(n-1) + (2*n-1)*(n-2)*a(n-2) = 0. - _Vladeta Jovovic_, Aug 29 2004",
ajson/A047891.json:             "D-finite with recurrence: (n+2)*(n+3)*a(n+3) - 6*(n+2)^2*a(n+2) - 12*(n)^2*a(n+1) + 8*n*(n-1)*a(n) = 0. (End)",
