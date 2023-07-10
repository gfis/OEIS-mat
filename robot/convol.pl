#!perl

# Extract parameters for convolution products and inverses
# @(#) $Id$
# 2023-07-10, Georg Fischer: copied from convprod.pl; *MB=66
#
#:# Usage:
#:#     perl convol.pl [-d mode] input.seq4 > output.seq4
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

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options

my $line;
my $name;
my $skip;   # asemble skip instructions here
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $callcode, $offset, $name) = split(/\t/, $line);
    # print "# $line: $name\n";
    my $nok = "";
    my $alist = "new A000041(), new A000041()";
    my $qlist = "1,1";
    $callcode = "convprod";
    if (0) {
    } elsif ($name =~ m{(Convolution of|Convolve) (A\d+) +(and|with) +(A\d+)}i) {
        $alist = "new $2(), new $4()";
    } elsif ($name =~ m{Convolution inverse of (A\d+)}i) {
        $alist = "new $1()";
        $qlist = "-1";
    } elsif ($name =~ m{Convolution (square )?root of (A\d+)}i) {
        $alist = "new $2()";
        $qlist = "1/2";
    } elsif ($name =~ m{Convolution square of (A\d+)}i) {
        $alist = "new $1()";
        $qlist = "2";
    } elsif ($name =~ m{Convolution cube of (A\d+)}i) {
        $alist = "new $1()";
        $qlist = "3";
    } else {
        $nok = "nok0";
    }
    if ($nok eq "") {
        $name = substr($name, 0, 128);
        print        join("\t", $aseqno, $callcode, 0, $qlist, $alist, $name) . "\n";
    } else {
        my @anos = ($name =~ m{(A\d{6})}g);
        $alist = join(", ", map { "new $_()" } @anos);
        print STDERR join("\t", $aseqno, $callcode, 0, $qlist, $alist, $name) . "\n";
    }
} # while <>
#----------------
__DATA__
A066897	convprod	0	Convolution of A000041 and A001227.
A066897	convprod	0	Convolution of A002865 and A060831.
A086717	convprod	0	Convolution of primes with partition numbers.
A086718	convprod	0	Convolution of sequence of primes with sequence sigma(n).
A086718	convprod	0	Convolution of A000040 and A000203.
A086718	convprod	0	Convolution of A054541 and A024916.
A086718	convprod	0	Convolution of the nonzero terms of A007504 and A340793.
A086733	convprod	0	Convolution of sigma(n) with phi(n).
