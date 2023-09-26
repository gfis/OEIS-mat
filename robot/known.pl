#!perl

# Derive simple transformations from known A-numbers
# @(#) $Id$
# 2023-09-25, Georg Fischer
#
#:# Usage:
#:#   perl known.pl input.seq4 > output.seq4
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

my $line;
my ($aseqno, $callcode, $offset, $name, $fseqno, $rseqno, $lambda, $dist);
my $headers = <DATA>;
my %fmap = (); # rseqno -> lambda
while (<DATA>) { # read mappings
    ($rseqno, $callcode, $offset, $lambda, $name) = split(/\t/, $_, 5);
    $fmap{$rseqno} = $lambda;
} # while DATA

while (<>) { # read infile(s)
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $line =~ s/  +/ /g; # only single spaces
    my ($aseqno, $callcode, $offset, $fseqno, $name) = split(/\t/, $line);
    $name =~ s{^ *a\(n\) *\= *}{}; # remove "a(n) = "
    #                      (1      1 ( 2    2  ) )
    if ($name =~ m{$fseqno\((A\d{6})\(n(\-\d)?\)\)}) { # always
        ($rseqno, $dist) = ($1, $2); # ignore dist at the momemt
        $callcode = "simtraf";
        $lambda = $fmap{$fseqno};
        if (defined($lambda) && $lambda ne "Z.") {
            print join("\t", $aseqno, $callcode, $offset, $fseqno, "new $rseqno()", "v -> $lambda", $name) . "\n";
        }
    }
} # while <>
exit();
my $dummy = <<"GFis";
A357852	knowna0	0	A003961	A003961(A003961(n)).
A233819	knowna0	0	A003961	A003961(A025487(n)). - _Amiram Eldar_, Jun 23 2019
A131822	knowna0	0	A003961	A003961(A036035(n-1)). - _R. J. Mathar_, Nov 11 2007
A359600	knowna0	0	A003961	A003961(A046523(n)).
A337471	knowna0	0	A003961	A003961(A108951(n)).
GFis
#--------------------------------------------
__DATA__
ANumber	knowna	count	lambda	Definition
A000720	knowna	78	Puma.primePiZ(v)		pi(n), the number of primes <= n. Sometimes called PrimePi(n) to distinguish it from the number 3.14159...
A000041	knowna	55	IntegerPartition.partitions(v)	a(n) is the number of partitions of n (the partition numbers).
A000040	knowna	54	Puma.primeZ()	The prime numbers.
A000005	knowna	47	Jaguar.factor(v).sigma0()	d(n) (also called tau(n) or sigma_0(n)), the number of divisors of n.
A007814	knowna	44	Z.valueOf(ZUtils.valuation(v, Z.TWO))	Exponent of highest power of 2 dividing n, a.k.a. the binary carry sequence, the ruler sequence, or the 2-adic valuation of n.
A000110	knowna	32	Bell.bell(v.intValueExact())	Bell or exponential numbers: number of ways to partition a set of n labeled elements.
A000217	knowna	29	v.multiply(v.add(1)).divide(2)	Triangular numbers: a(n) = binomial(n+1,2) = n*(n+1)/2 = 0 + 1 + 2 + ... + n.
A000265	knowna	29	v.makeOdd()	Remove all factors of 2 from n; or largest odd divisor of n; or odd part of n.
A001221	knowna	28	Z.valueOf(Jaguar.factor(v).omega())	Number of distinct primes dividing n (also called omega(n)).
A064989	knowna	28		Multiplicative with a(2^e) = 1 and a(p^e) = prevprime(p)^e for odd primes p.
A006530	knowna	27	Jaguar.factor(v).greatestPrimeFactor()	 greatest prime dividing n, for n >= 2; a(1)=1.
A055642	knowna	27	v.toString().length()	Number of digits in the decimal expansion of n.
A001222	knowna	25	Z.valueOf(Jaguar.factor(v).bigOmega())	Number of prime divisors of n counted with multiplicity (also called big omega of n, bigomega(n) or Omega(n)).
A000203	knowna	24	Jaguar.factor(v).sigma()	a(n) = sigma(n), the sum of the divisors of n. Also called sigma_1(n).
A000010	knowna	23	Euler.phi(v)	Euler totient function phi(n): count numbers <= n and prime to n.
A000142	knowna	21	MemoryFactorial.SINGLETON.factorial(v.intValueExact())	Factorial numbers: n! = 1*2*3*4*...*n (order of symmetric group S_n, number of permutations of n letters).
A000030	knowna	19	Z.valueOf(v.toString().charAt(0) - '0')	Initial digit of n.
A000108	knowna	19	{ int n = v.intValueExact(); return Binomial.binomial(2*n, n).divide(n + 1); }	Catalan numbers: C(n) = binomial(2n,n)/(n+1) = (2n)!/(n!(n+1)!).
A002487	knowna	19		Stern''s diatomic series (or Stern-Brocot sequence): a(0) = 0, a(1) = 1; for n > 0: a(2*n) = a(n), a(2*n+1) = a(n) + a(n+1).
A020639	knowna	19	Jaguar.factor(v).leastPrimeFactor()	Lpf(n): least prime dividing n (when n > 1); a(1) = 1. Or, smallest prime factor of n, or smallest prime divisor of n.
A002110	knowna	17	ZUtils.primorial(v.longValueExact())	Primorial numbers (first definition): product of first n primes. Sometimes written prime(n)#.
A151800	knowna	17	Puma.primeZ(Puma.primePi(v) + 1)	Least prime > n (version 2 of the "next prime" function).
A007504	knowna	16		Sum of the first n primes.
A003961	knowna	15		Completely multiplicative with a(prime(k)) = prime(k+1).
A007918	knowna	15		Least prime >= n (version 1 of the "next prime" function).
A000045	knowna	14	Fibonacci.fibonacci(v.intValueExact())	Fibonacci numbers: F(n) = F(n-1) + F(n-2) with F(0) = 0 and F(1) = 1.
A007949	knowna	14	Z.valueOf(ZUtils.valuation(v, Z.THREE))	Greatest k such that 3^k divides n. Or, 3-adic valuation of n.
A000001	knowna	13		Number of groups of order n.
A000035	knowna	13	v.modZ(2)	Period 2: repeat [0, 1]; a(n) = n mod 2; parity of n.
A000120	knowna	13	Z.valueOf(v.bitCount())	1''s-counting sequence: number of 1''s in binary expansion of n (or the binary weight of n).
A007947	knowna	13		Largest squarefree number dividing n: the squarefree kernel of n, rad(n), radical of n.
A010888	knowna	13		Digital root of n (repeatedly add the digits of n until a single digit is reached).
A003415	knowna	12		a(n) = n'' = arithmetic derivative of n: a(0) = a(1) = 0, a(prime) = 1, a(m*n) = m*a(n) + n*a(m).
A004001	knowna	12		Hofstadter-Conway $10000 sequence: a(n) = a(a(n-1)) + a(n-a(n-1)) with a(1) = a(2) = 1.
A048675	knowna	12		If n = p_i^e_i * ... * p_k^e_k, p_i < ... < p_k primes (with p_i = prime(i)), then a(n) = (1/2) * (e_i * 2^i + ... + e_k * 2^k).
A000009	knowna	11		Expansion of Product_{m >= 1} (1 + x^m); number of partitions of n into distinct parts; number of partitions of n into odd parts.
A000196	knowna	11	v.sqrt()	Integer part of square root of n. Or, number of positive squares <= n. Or, n appears 2n+1 times.
A001065	knowna	11		Sum of proper divisors (or aliquot parts) of n: sum of divisors of n that are less than n.
A008472	knowna	11		Sum of the distinct primes dividing n.
A000032	knowna	10	Fibonacci.lucas(v.intValueExact())	Lucas numbers beginning at 2: L(n) = L(n-1) + L(n-2), L(0) = 2, L(1) = 1.
A001358	knowna	10		Semiprimes (or biprimes): products of two primes.
A004086	knowna	10	ZUtils.reverse(v)	Read n backwards (referred to as R(n) in many sequences).
A005940	knowna	10		The Doudna sequence: write n-1 in binary; power of prime(k) in a(n) is # of 1''s that are followed by k-1 0''s.
A006577	knowna	10		Number of halving and tripling steps to reach 1 in ''3x+1'' problem, or -1 if 1 is never reached.
A007953	knowna	10	Z.valueOf(ZUtils.digitSum(v))	Digital sum (i.e., sum of digits) of n; also called digsum(n).
A121548	knowna	10		Triangle read by rows: T(n,k) is the number of compositions of n into k Fibonacci numbers (1 <= k <= n; only one 1 is considered as a Fibonacci number).
A000085	knowna	9		Number of self-inverse permutations on n letters, also known as involutions; number of standard Young tableaux with n cells.
A001055	knowna	9		The multiplicative partition function: number of ways of factoring n with all factors greater than 1 (a(1) = 1 by convention).
A032742	knowna	9		a(1) = 1; for n > 1, a(n) = largest proper divisor of n (that is, for n>1, maximum divisor d of n in range 1 <= d < n).
A049501	knowna	9		Major index of n, first definition.
A049502	knowna	9		Major index of n, 2nd definition.
A051903	knowna	9		Maximal exponent in prime factorization of n.
A056239	knowna	9		If n = Product_{k >= 1} (p_k)^(c_k) where p_k is k-th prime and c_k >= 0 then a(n) = Sum_{k >= 1} k*c_k.
A278222	knowna	9		The least number with the same prime signature as A005940(n+1).
A000188	knowna	8		(1) Number of solutions to x^2 == 0 (mod n). (2) Also square root of largest square dividing n. (3) Also max_{ d divides n } gcd(d, n/d).
A000796	knowna	8		Decimal expansion of Pi (or digits of Pi).
A002808	knowna	8		The composite numbers: numbers n of the form x*y for x > 1 and y > 1.
A010051	knowna	8	v.isProbablePrime() ? Z.ONE : Z.ZERO	Characteristic function of primes: 1 if n is prime, else 0.
A049084	knowna	8	Z.valueOf(Puma.primePi(v)).isProbalbelPrime() ? Z.ONE : Z.ZERO	a(n) = pi(n) if n is prime, otherwise 0.
A064097	knowna	8		A quasi-logarithm defined inductively by a(1) = 0 and a(p) = 1 + a(p-1) if p is prime and a(n*m) = a(n) + a(m) if m,n > 1.
A065547	knowna	8		Triangle of Salie numbers.
A151799	knowna	8	Puma.primeZ(Puma.primePi(v) - 1)	Version 2 of the "previous prime" function: largest prime < n.
