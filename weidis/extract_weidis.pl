#!perl

# Read a text file (internal format) and write a b-file for the weight distribution
# @(#) $Id$
# 2020-07-15, Georg Fischer: copied from weight_dist.pl
#
#:# Usage:
#:#   perl extract_weidis.pl [-o tardir] infile 
#:#       -o target directory for b-files
#:#       (writes tardir/bnnn.txt)
#---------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my @parts = split(/\s+/, asctime(localtime(time)));  #  "Fri Jun  2 18:22:13 2000\n\0"
#                                             0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]);
#----
my $tardir  = "./bfilext";
my $debug   = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{o}) {
        $tardir    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my $infile = shift(@ARGV);
open(IN, "<", $infile) or die "cannot read \"$infile\"\n";
my @array = ();
my ($oldix, $newix) = (0, 0);
my $term;
my $delta = 1024; # very high
while (<IN>) {
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    next if $line !~ m{\A\%};
    $line =~ m{\A\%(\w)\s(A\d+)\s?(.*)};
    my ($code, $aseqno, $text) = ($1, $2, $3);
    $text = $text || "";
    if (0) {
    } elsif ($code eq "e" and ($text =~ m{\A(\d+) (\d+)\Z})) { # Example 
        ($newix, $term) = ($1, $2);
        if ($oldix != 0 and $newix != 0) {
            if ($newix - $oldix < $delta) {
                $delta = $newix - $oldix;
            }
        }
        $oldix = $newix;
        $array[$newix] = $term;
    } # %e
} # while <IN>
close(IN);

my $outfile = $infile;
$outfile =~ s{\A[^A]*A(\d+)\..*}{b$1\.txt};
$outfile = "$tardir/$outfile";
open(OUT, ">", $outfile) or die "cannot write \"$outfile\"\n";
my $bfix = 0;
$oldix = 0;
while ($oldix <= $newix) {
    if (defined($array[$oldix])) {
        print OUT "$bfix $array[$oldix]\n";
    } else {
        print OUT "$bfix 0\n";
    }
    $bfix ++;
    $oldix += $delta;
} # while 
close(OUT);
print STDERR "$bfix terms written to $outfile\n";
__DATA__
%I A151422
%S A151422 1,0,0,0,0,0,0,186944,19412204,1103839296,33723852288,579267441920,
%T A151422 5744521082944,33558415333632,117224663972352,247312085243776,
%U A151422 316992306111910,247312085243776,117224663972352,33558415333632
%N A151422 Weight distribution of [128,50,28] extended binary primitive BCH (or XBCH) code.
%C A151422 Taken from the Terada-Asatani-Koumoto web site.
%H A151422 M. Terada, J. Asatani and T. Koumoto, <a href="http://isec.ec.okayama-u.ac.jp/home/kusaka/wd/index.html">Weight Distribution</a>
%e A151422 The weight distribution is:
%e A151422 i A_i
%e A151422 0 1
%e A151422 28 186944
%e A151422 32 19412204
%e A151422 36 1103839296
%e A151422 40 33723852288
%e A151422 44 579267441920
%e A151422 48 5744521082944
%e A151422 52 33558415333632
%e A151422 56 117224663972352
%e A151422 60 247312085243776
%e A151422 64 316992306111910
%e A151422 68 247312085243776
%e A151422 72 117224663972352
%e A151422 76 33558415333632
%e A151422 80 5744521082944
%e A151422 84 579267441920
%e A151422 88 33723852288
%e A151422 92 1103839296
%e A151422 96 19412204
%e A151422 100 186944
%e A151422 128 1
%K A151422 nonn,fini
%O A151422 0,8
%A A151422 _N. J. A. Sloane_, May 14 2009


