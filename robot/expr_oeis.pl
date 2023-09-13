#!perl

# Preprocess FORMULA section lines for expr_pari.pl (PARI)
# @(#) $Id$
# 2023-08-27: was for sumpari.pl
# 2023-08-20, Georg Fischer; CC=67
#
#:# Usage:
#:#   perl expr_oeis.pl input.cat25-type > output.cat25-type
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

my ($line, $aseqno, $callcode, $offset1,  $name, $orig_name, $expr, $var, $lo, $hi, $n, $d);
# while (<DATA>) {
while (<>) {
    my $nok = 1;
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $line =~ s{ for .*|(\, )?where.*}{}; # remove conditions

    $nok = 0;
    ($aseqno, $callcode, $offset1, $name) = split(/\t/, $line);
    if ($debug >= 1) {
        print "# aseqno=$aseqno, name=$name\n";
    }
    $orig_name = $name;

    $name =~ s{^ *\(\d+\) +(.*)}{$2}; # remove formula numbering
    #               1    1              2  2
    if ($name =~ m{^ *a\(n\) *\= *(.*)}) {
        if ($name =~ m{(A\d{6})}) { # if there is a underlying sequence
            $nok = "2/$1";
        }
        if (1) { # from expr_mma.pl
            $name =~ tr{\[\]}
                       {\(\)};
            $name =~ s{[\)\!] *\(}          {\)\*\(}g;      # ) (
            $name =~ s{[\)\!] *(\w)}        {\)\*$1}g;      # ) a
            $name =~ s{(\b\w|\!) +\(}       {$1\*\(}g;      # a (
            $name =~ s{(\b\d) *([a-z])}     {$1\*$2}g;      # 2 a
            $name =~ s{(\w|\!) +(\w)}       {$1\*$2}g;      # a b
        }
        #          1 (       )1 $
        $name =~ s{(\([^\)]+\))\$}                                                      {swingingFactorial$1}g;
        $name =~ s{([i-n])\$}                                                           {swingingFactorial$1}g;
        $name =~ s{\bC\(}                                                               {binomial\(}g;
        $name =~ s{\bphi\(}                                                             {eulerphi\(}g;
        $name =~ s{\bprimePi\(|prime\#\(}                                               {primepi\(}g;
        #                           1  1 
        $name =~ s{Stirling[a-zA-Z]*(\d)\(}                                             {stirling$1\(}g;
        #                 1   1   2  2      3      3        4      4    5  5
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
    } # while sum
    if ($nok eq "0") {
        print join("\t", $aseqno, "lambda", 0, "$name \\\\ $orig_name") . "\n";
    } else {
        print STDERR "# $nok: $line\n";
    }
} # while <>
#--------------------------------------------
__DATA__
A364980 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(2*n-k+1,k)/( (2*n-k+1)*(n-k)! ).
A364981 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(3*n-2*k+1,k)/( (3*n-2*k+1)*(n-k)! ).
A364982 a(n) = (n!/(2*n+1)) * Sum_{k=0..n} k^(n-k) * binomial(2*n+1,k)/(n-k)!.
A364983 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(3*k+1,k)/( (3*k+1)*(n-k)! ) = n! * Sum_{k=0..n} k^(n-k) * A001764(k)/(n-k)!.
A364984 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(n+2*k+1,k)/( (n+2*k+1)*(n-k)! ).