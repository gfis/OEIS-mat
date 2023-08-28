#!perl

# Preprocess Mathematica "Table[" ... statements for expr_pari.pl (PARI)
# @(#) $Id$
# 2023-08-28, Georg Fischer: copied from expr_oeis.pl
#
#:# Usage:
#:#   perl expr_mma.pl input.cat25-type > output.cat25-type
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
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($line, $aseqno, $name, $orig_name, $range, @ranges, $expr, $var, $lo, $hi, $n, $d);
# while (<DATA>) {
while (<>) {
    my $nok = 1;
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $line =~ s{ *\(\*.*}{}; # remove trailing comment
    #               1    1         2  2
    if ($line =~ m{^(A\d+) +Table\[(.*)\]\Z}) {
        ($aseqno, $name) = ($1, $2);
        $orig_name = $name;
        $nok = 0;
        foreach my $word ($name =~ m{([A-Z][a-zA-Z0-9]+)}g) {
            if ($word !~ m{Sum|Product|Abs|BellB|Binomial|Divisor\b|DivisorSigma|EulerPhi|Fibonacci|Floor|GCD|If|KroneckerDelta|LCM|Max|Min|Mod|MoebiusMu|PrimeOmega|Sign|StirlingS[12]}) {
                $nok = "2/$word";
            }
        }
        if ($nok eq "0") {

            if ($debug >= 1) {
                print "# aseqno=$aseqno, name=\"$name\"\n";
            }
            @ranges = ();
            # A338548 Table[n^3 Sum[(-1)^(n/d + 1) MoebiusMu[d]/d^3, {d, Divisors[n]}], {n, 1, 42}]
            #                      {  1CCCCC  ,  C}C}C}C 2 ,  }}}}} 2 1   }
            while ($name =~ s[\, *\{ *([^\,]+\, *[^\}\,]+(\, *[^\}]+)?) *\}\s*][]) { # extract ranges from the beginning
                $range = $1;
                $range =~ s{ }{}g;
                #                 1dddddd1 ,         [2nnnnnn2 ]
                if ($range =~ m{\A([^\,]+)\,Divisors\[([^\]]+)\]\Z}i) {
                    my ($d, $n) = ($1, $2);
                    $range = "$n;$d";
                } else {
                    #             1      1  2      2
                    $range =~ s[\A([^\,]+)\,([^\,]+)\Z]       [$1\,1\,$2];
                    $range =~ s[\,]                           [\=]; # only first ","
                }
                unshift(@ranges, $range);
            } # while ranges
            if ($debug >= 1) {
                print "# ranges=" . join(" | ", @ranges) . "\n";
            }
            my $tabrange1 = shift(@ranges); # remove the range of "Table["
            if ($tabrange1 =~ m{\A([^\,]+)}) {
                $var = $1;
                if ($var ne "n") {
                    $name =~ s{\b$var\b}{n}g;
                }
            }
            foreach $range (@ranges) { # append range
                if ($range =~ s{\;}{\,}) {
                    $name =~ s{(Sum)\[}{sumdiv\($range\,};
                } else {
                    $name =~ s{(Sum|Product)\[}{$1\($range\,};
                }
            } # foreach appending ranges

            $name = lc($name);
            $name =~ tr{\[\]}
                       {\(\)};
            $name =~ s{[\)\!] *\(}          {\)\*\(}g;      # ) (
            $name =~ s{[\)\!] *(\w)}        {\)\*$1}g;      # ) a
            $name =~ s{(\b\w|\!) +\(}       {$1\*\(}g;      # a (
            $name =~ s{(\b\d) *([a-z])}     {$1\*$2}g;      # 2 a
            $name =~ s{(\w|\!) +(\w)}       {$1\*$2}g;      # a b
            
            $name =~ s{\s}{}g; # remove all whitespace
            $name =~ s{BellB}                                                               {bell}ig;
            $name =~ s{DivisorSigma\((\w+)\,([^\)]+)\)}                                     {sigma\($2\,$1\)}ig; # reorder the parameters
            $name =~ s{KroneckerDelta}                                                      {kronecker}ig;
            $name =~ s{MoebiusMu}                                                           {moebius}ig;
            $name =~ s{PrimeOmega}                                                          {bigomega}ig;
            $name =~ s{Prod(uct)?}                                                          {prod}ig;
            #                           1  1 
            $name =~ s{Stirling[a-zA-Z]*(\d)\(}                                             {stirling$1\(}ig;
            
        if (0) {
            while ($name =~ m{(Sum)_\{(\w) *\= *([^\.]+) *\.\. *([^\}]+)\} *(.*)}i          ) {
                ($var, $lo, $hi, $expr) = ($2, $3, $4, $5);
                $expr    =~ s/\..*//g; # remove tail
                $name    =~ s{(Sum)_\{(\w) *\= *([^\.]+) *\.\. *([^\}]+)\} *(.*)}           {sum\($var\=$lo\,$hi\,$expr\)}i;
            }
            #                     1   1    2  2      3      3        4      4    5  6
            while ($name =~ m{Prod(uct)?_\{(\w) *\= *([^\.]+) *\.\. *([^\}]+)\} *(.*)}i     ) {
                ($var, $lo, $hi, $expr) = ($2, $3, $4, $5);
                $expr    =~ s/\..*//g; # remove tail
                $name    =~ s{Prod(uct)?_\{(\w) *\= *([^\.]+) *\.\. *([^\}]+)\} *(.*)}      {prod\($var\=$lo\,$hi\,$expr\)}i;
            }
            #                 1   1   2  2  3  3    4  4
            while ($name =~ m{(sum)_\{(\w)\|(\w)\} *(.*)}i                                  ) {
                ($d, $n, $expr) = ($2, $3, $4);
                $expr    =~ s/\..*//g; # remove tail
                $name    =~ s{(sum)_\{(\w)\|(\w)\} *(.*)}                                   {sumdiv\($n\,$d\,$expr\)}i;
            }
        } # if 0
        
        } # if ok
    } # while sum
    if ($nok eq "0") {
        print "$aseqno a(n)=$name \\\\ $orig_name\n";
    } else {
        print STDERR "$nok\t$line\n";
    }
} # while <>
#--------------------------------------------
__DATA__
A364980 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(2*n-k+1,k)/( (2*n-k+1)*(n-k)! ).
A364981 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(3*n-2*k+1,k)/( (3*n-2*k+1)*(n-k)! ).
A364982 a(n) = (n!/(2*n+1)) * Sum_{k=0..n} k^(n-k) * binomial(2*n+1,k)/(n-k)!.
A364983 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(3*k+1,k)/( (3*k+1)*(n-k)! ) = n! * Sum_{k=0..n} k^(n-k) * A001764(k)/(n-k)!.
A364984 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(n+2*k+1,k)/( (n+2*k+1)*(n-k)! ).