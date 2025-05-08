#!perl

# Modify records with A-numbers of known predicates -> initial letter "P"
# 2025-05-07, Georg Fischer
#
#:# Usage:
#:#   perl endirpre.pl [-d mod] [-f knopre_file] infile > outfile
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#:#     -f  known predicates file with (aseqno, lambda) (default: joeis-lite/internal/fischer/reflect/knopre.txt)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $pwd = `pwd`;
my $procname;
$pwd =~ m{(/gits/)};
my $gits = $`. "/gits"; # prematch
my $debug   = 0;
my $knopre_file = "$gits/joeis-lite/internal/fischer/reflect/knopre.txt"; # known predicates
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt    =~ m{\-d}  ) {
        $debug       = shift(@ARGV);
    } elsif ($opt    =~ m{\-f}  ) {
        $knopre_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my %knopre = ();
my ($aseqno, $lambda);
open (KNO, "<", $knopre_file) || die "cannot read $knopre_file\n";
while (<KNO>) {
    s{\s+\Z}{};
    ($aseqno, $lambda) = split(/\t/);
    $knopre{$aseqno} = 1; # lambda is not needed
} # while <KNO>
close(KNO);
print STDERR "# $0: " . scalar(%knopre) . " known predicates read from $knopre_file\n";
#----------------
my $line = "";
while (<>) {
#while (<DATA>) {
    s/\s+\Z//; # chompr
    $line = $_;
    my @anos = $line =~ m{([A-Z]\d{6})}g;
    foreach my $xseqno (@anos) {
        my $letter = substr($xseqno, 0, 1);
        my $seqno  = substr($xseqno, 1);
        if (defined($knopre{"A$seqno"})) {
            $line =~ s{$xseqno}{P$seqno}g;
        } 
#       else {
#           print "debug: xseqno=$xseqno, knopre=" . ($knopre{"A$seqno"} || "undef") . ", seqno=$seqno\n";
#       }
    } # foreach $xseqno
    print "$line\n";
} # while <>
__DATA__
A000040	48	The prime numbers.
A000959	20	Lucky numbers.
A001694	19	Powerful numbers, definition (1): if a prime p divides n then p^2 must also divide n (also called squareful, square full, square-full or 2-powerful numbers).
A001567	17	Fermat pseudoprimes to base 2, also called Sarrus numbers or Poulet numbers.
A000290	15	The squares: a(n) = n^2.
A005349	13	Niven (or Harshad, or harshad) numbers: numbers that are divisible by the sum of their digits.
A014574	13	Average of twin prime pairs.
A025487	12	Least integer of each prime signature A124832; also products of primorial numbers A002110.
A002113	11	Palindromes in base 10.
A002473	11	7-smooth numbers: positive numbers whose prime divisors are all <= 7.
A005117	11	Squarefree numbers: numbers that are not divisible by a square greater than 1.
A001358	10	Semiprimes (or biprimes): products of two primes.
A000045	9	Fibonacci numbers: F(n) = F(n-1) + F(n-2) with F(0) = 0 and F(1) = 1.
A001043	9	Numbers that are the sum of 2 successive primes.
A001262	9	Strong pseudoprimes to base 2.
A002385	9	Palindromic primes: prime numbers whose decimal expansion is a palindrome.
A033950	9	Refactorable numbers: number of divisors of k divides k. Also known as tau numbers.
A001359	8	Lesser of twin primes.
A002997	8	Carmichael numbers: composite numbers k such that a^(k-1) == 1 (mod k) for every a coprime to k.
A005384	8	Sophie Germain primes p: 2p+1 is also prime.
A000043	7	Mersenne exponents: primes p such that 2^p - 1 is prime. Then 2^p - 1 is called a Mersenne prime.
A001235	7	Taxi-cab numbers: sums of 2 cubes in more than 1 way.
A001481	7	Numbers that are the sum of 2 squares.
