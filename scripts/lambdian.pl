#!perl

# Convert callcode "lambdin" to "lambdan": move initial terms to a conditional expression in n
# @(#) $Id$
# 2024-09-22, Georg Fischer
#
#:# Usage:
#:#   perl lambdian.pl [-d debug] < infile.seq4 > outfile.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min);
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $aseqno;
my $xseqno;
my $callcode;
my @parms;
my @terms;
while (<>) { # read inputfile
    s{\s+\Z}{}; # chompr
    my $line = $_;
    if (0) {
    #                     1          1  2       2
    } elsif ($line =~ m{\A([A-Z]\d{6})\t(lambdin)\t}) { # our record: starts with "xseqno lambdin"
        ($xseqno, $callcode, @parms) = split(/\t/, $line); # split the seq4 record
        $aseqno = "A" . substr($xseqno, 1);
        $callcode = "lambdan";
        my $offset1 = $parms[0];
        my $lambda = $parms[1];
        my ($var, $expr) = split(/ *\-\> */, $lambda, 2);

        my $inits = $parms[2];
        $parms[2] = "";
        $inits =~ s{\"}{}g;
        my $prefix = "";
        @terms = split(/\, */, $inits);
        my $limit = $offset1 + scalar(@terms) - 1;
        my $same = &check_same();
        my @prog = &check_progression();
        if (0) {
        } elsif ($same > 0) {
            $prefix = "($var <= $limit) ? ZV($terms[0]) : ";
        } else { # more than 2 - use an array
            $prefix = "($var <= $limit) ? ZV(new int[] { $inits }[n" . ($offset1 == 0 ? "" : " - $offset1") . "]) : ";
            $parms[2] = "#" . (scalar(@terms) == 2 ? "2" : "n") . ":$inits/" . join("~", @prog) . "/";
        }
        if ($expr =~ m{\?}) { # contains another 3-way-expression -> shield it with "(...)"
            $expr = "($expr)";
        }
        $parms[1] = "$var -> $prefix$expr";
        print join("\t", $aseqno, $callcode, @parms) ."\n";
    } else { # copy other records unchanged
        print "$line\n";
    }
} # while <>
#----
sub check_same { # check whether all terms are identical
    my $result = 1; # assume identical terms
    my $it = 1; 
    while ($result > 0 && $it < scalar(@terms)) {
        if ($terms[$it] != $terms[0]) {
            $result = 0;
        }
        $it ++;
    } # while
    return $result
} # check_same
#----
sub check_progression { # check whether all terms are in an arithmetic progression; return (start, delta) or empty list
    my @empty = ();
    my $start = $terms[0];
    my $delta = 0; 
    my $busy  = 1; # assume success
    if (scalar(@terms) >= 2) {
       $delta = $terms[1] - $start;
       my $it = 2;
       while ($busy > 0 && $it < scalar(@terms)) {
          if ($terms[$it] - $terms[$it - 1] != $delta) {
              $busy = 0;
          }
          $it ++;
       } # while
    } # 2 ore more terms
    return $busy == 0 ? @empty : ($start, $delta);
} # check_same
__DATA__
A372442	lambdin	2	n -> D029837(n).-(E061395(n))	"1,0"		D029837(n)-E061395(n)	_	_	_		(Greatest binary index of n) minus (greatest prime index of n).
A372442	lambdin	2	n -> D029837(n).-(E061395(n))	"1,0"		a(n) = F070939(n) - E061395(n) = D029837(n) - E061395(n) for n > 1	_	_	_		(Greatest binary index of n) minus (greatest prime index of n).
A372442	lambdin	2	n -> D029837(n).-(E061395(n))	"1,0"		a(n) = F070939(n) - E061395(n) = D029837(n) - E061395(n) for n > 1	_	_	_		(Greatest binary index of n) minus (greatest prime index of n).
A372442	lambdin	2	n -> D029837(n).-(E061395(n))	n>=2	D029837(n)-E061395(n)	_	_				(Greatest binary index of n) minus (greatest prime index of n).
C:\Users\User\work\gits\joeis-lite\internal\fischer\reflect>sh C:\Users\User\work\gits/OEIS-mat/scripts/endirect  
E072639	lambdin	0	n -> SU(0, n-1, i -> Z2((Z2(i)).-(ZV(1))))	"0"		SU(0,n-1,i->Z2((Z2(i))-1))					a(0) = 0, a(n) = Sum_{i=0..n-1} 2^((2^i)-1).
E073137	lambdin	0	n -> (Z2(F000120(n).-(ZV(1)))).*((Z2(D023416(n)).+(ZV(1)))).-(ZV(1))	"0"		(Z2(F000120(n)-1))*(2^D023416(n)+1)-1					a(n) is the least number whose binary representation has the same number of 0's and 1's as n.
E073170	lambdin	1	n -> F000040(n-1).-(n+1)	"0,0"		F000040(n-1)-n+1	_	_	_		a(1) = a(2) = 0; for n>2, a(n) = prime(n-1)-n+1.

A067792 1       FAIL    ,2,3,5,7,7      computed:       ,3,5,5,11,7
A073170 3       FAIL    ,1,2,3  computed:       ,-1,0,1
A083242 3       FAIL    ,3,2    computed:       ,5,7
A093051 3       FATAL   Exception Division by zero.     , irvine.math.z.Div.divideAndRemainder(Unknown Source), irvine.m
A156296 2       FAIL    ,10,140,5740    computed:       ,140,5740,700280