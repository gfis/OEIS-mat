#!perl

# Preprocess FORMULA section lines for expr_pari.pl (PARI)
# @(#) $Id$
# 2023-08-27: was for sumpari.pl
# 2023-08-20, Georg Fischer; CC=67
#
#:# Usage:
#:#   perl sum_oeis.pl input.cat25-type > output.cat25-type
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

#	| perl -ne 's{^(A\d+ )\(\d+\)\s+(.*)}{$1$3}; print;' \
#	| grep -P "^A\d+ *a\(n\) *\=" \
#	| grep -iP "Sum_\{\w *\=" | grep -viP "prime|partition|Numerator|Denominator|Moebius" \
#	| tee    $@.tmp

my $line;
# while (<DATA>) {
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $line =~ s{ for .*}{};
    $line =~ s{^(A\d+) +\(\d+\) +(.*)}{$1$2}; # remove formular numbering
    #                 1      1
    $line =~ s{floor\(([^\)]+)\)}{$1}g; # remove "floor(...)"
    #               1    1              2 2
    if ($line =~ m{^(A\d+) +a\(n\) *\= *(.*)}) {
        my ($aseqno, $rest) = ($1, $2);
        if ($debug >= 1) {
            print "aseqno=$aseqno, rest=$rest\n";
        }
        next if $rest =~ m{A\d{6}};
        #                    1              1        2      2    3  3
        if ($rest =~ m{Sum_\{(\w *\= *[^\.]+) *\.\. *([^\}]+)\} *(.*)}i) {
            my $prefix = $`;
            my ($min, $max, $form) = ($1, $2, $3);
            $prefix =~ s/ //g;
            $min    =~ s/ //g;
            $max    =~ s/ //g;
            $form   =~ s/\..*//g; # remove tail
        #   while ($form =~ s{(\=(.*))}{}) {
        #       print "$aseqno a(n)=${prefix}sum($min,$max,$2)\n"; # print 2nd formula
        #   }
            $form   =~ s{\=.*}{}; # remove 2nd, 3rd ... formula
            print "$aseqno a(n)=${prefix}sum($min,$max,$form)\n";
        }
    }
} # while <>
#--------------------------------------------
__DATA__
A364980 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(2*n-k+1,k)/( (2*n-k+1)*(n-k)! ).
A364981 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(3*n-2*k+1,k)/( (3*n-2*k+1)*(n-k)! ).
A364982 a(n) = (n!/(2*n+1)) * Sum_{k=0..n} k^(n-k) * binomial(2*n+1,k)/(n-k)!.
A364983 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(3*k+1,k)/( (3*k+1)*(n-k)! ) = n! * Sum_{k=0..n} k^(n-k) * A001764(k)/(n-k)!.
A364984 a(n) = n! * Sum_{k=0..n} k^(n-k) * binomial(n+2*k+1,k)/( (n+2*k+1)*(n-k)! ).