#!perl

# Prepare traits for HTML page
# @(#) $Id$
# 2020-02-23, Georg Fischer
#
#:# Usage:
#:#   perl prep_traits.pl traits4.tmp > traits5.tmp
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

print join("\t", "A-number", "trait", "T-number", "Data...", "Author Year", "Keyword", "Name"). "\n";
while (<>) {
    my $line = $_;
    next if $line =~ m{\A\s*\#};
    $line =~ s{\s+\Z}{}; # chompr
    if ($line =~ m{\A(A\d+)\t(\w+)\t(\-?\d+)}) {
    # relates to the following line in trimore.pl:
    # print "SELECT \'$aseqno\', \'$title\', $offset, d.aseqno, SUBSTR(n.name, 1, 32), \'$termlist\',  i.keyword, i.author"
        my ($aseqno, $callcode, $offset, $tseqno, $name, $termlist, $keyword, $author) = split(/\t/, $line);
        $keyword = $keyword || "";
        $author  = $author  || "";
        $name    = $name    || "";
        $keyword =~ s{nonn|easy|sign|changed|base|full|synth}{}g;
        $keyword =~ s{\,+}{\,}g;
        $keyword =~ s{\A\,+}{};     
        $keyword =~ s{\,+\Z}{};     
        $author =~ s{[A-Z]\. }{}g;
        $author =~ s{ [A-Z][a-z][a-z] \d\d }{ };
        $author =~ s{\A\_(\w+\s+)?(\w+)\_}{$2};
        print join("\t", $aseqno, $callcode, $tseqno, substr($termlist, 0, 64)
                , $keyword, substr($author, 0, 16), $name) . "\n";
    } else {
        # ignore
    }
} # while <>
#--------------------------------------------
__DATA__
A298486 Sequence    55  A166352 0,0,1,0,1,2,0,1,2,3,0,1,2,3,4,0,1,2,3,4,5,0,1,2,3,4,5,6,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,8,0,1,2,3,4,5,6,7,8,9   base,easy,nonn,tabf,synth   _Rick L. Shepherd_, Oct 12 2009 Table read by rows where row n contains the sorted digits of the integers 0 through n.
A298486 RowSum  10  A107082 0,1,3,6,10,15,21,28,36,45   base,fini,full,nonn,    _Joshua Zucker_, May 11 2005    Put in lexicographic order and concatenate all sequences that start with 0 and have difference sequences that use the digits 1 through 9 in order.
A298486 RowSum  10  A130488 0,1,3,6,10,15,21,28,36,45   nonn,   _Hieronymus Fischer_, May 31 2007   a(n) = Sum_{k=0..n} (k mod 10) (Partial sums of A010879).
A298486 EvenSum 10  A110660 0,0,2,2,6,6,12,12,20,20 nonn,easy,  _Reinhard Zumkeller_, Aug 05 2005   Promic numbers repeated.
A298486 OddSum  10  A206919 0,1,1,4,4,9,9,16,16,25  nonn,base,synth _Hieronymus Fischer_, Feb 18 2012   Sum of binary palindromes <= n.
A298486 AltSum  10  A130472 0,-1,1,-2,2,-3,3,-4,4,-5    sign,easy,synth _Clark Kimberling_, May 28 2007 A permutation of the integers: a(n) = (-1)^n * floor( (n+1)/2 ).
A298486 LeftSide    10  A000007 one, zeroes 0,0,0,0,0,0,0,0,0,0
