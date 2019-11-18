#!perl

# Keep only the first line from a group of like A-numbers
# @(#) $Id$
# 2019-11-17, Georg Fischer
#
#:# Usage:
#:#   perl uniq1.pl infile > outfile
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $old_aseqno = "";
while (<>) {
    my $line = $_;
    $line =~ m{\A(\w+)};
    my $aseqno = $1;
    if ($aseqno ne $old_aseqno) {
        print $line;
        $old_aseqno = $aseqno;
    } else {
        # ignore
    }
} # while <>
#--------------------
__DATA__
A000978 Yahoo PrimeForm community: <a href="http://groups.yahoo.com/group/primeform/messages">PrimeForm</a> [There is insufficient information to determine which posting to the forum was intended. Probably not worth pursuing. - ~~~~]
A001108 K. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/62">Generalized Proof re Square Triangular Numbers</a>
A001109 K. J. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/23">Relation of Mersenne Primes To Square Triangular Numbers</a> [edited by K. J. Ramsey, May 14 2011]
A001109 Kenneth Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/62">Generalized Proof re Square Triangular Numbers</a>
A001110 K. Ramsey, <a href="http://groups.yahoo.com/group/Triangular_and_Fibonacci_Numbers/message/62">Re_Generalized_Proof_re_Square_Triangular_Numbers</a>
A001605 David Broadhurst, <a href="http://groups.yahoo.com/group/primeform/files/LucasFib/">Fibonacci Numbers</a>
