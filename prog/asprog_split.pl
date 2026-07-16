#!perl

# Split asprog records into single files
# @(#) $Id$
# 2026-07-14: Georg Fischer, copied from extraxt_asprog.pl; *CKZ=74
#
#:# usage:
#:#   perl asprog_split.pl [-d mode] [-s subdir] asprog.txt
#:#       -d mode    debug mode: none(0), some(1), more(2)
#:#       -s subdir  default: like type
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $program  = "";
my $prog_buffer;     # append program lines here
my $prog_sep = "~~"; # separator for program lines
my $debug    =  0;   # 0 (none), 1 (some), 2 (more)
my $subdir   = "pari";
my ($aseqno, $lang, $curno, $type, $program, @rest); # record fields

# get options
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-s}) {
        $subdir   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----
print `mkdir $subdir`;
my $line;
# while (<DATA>) {
while (<>) {
    s/\s+\Z//;
    next if !m{^A\d+\t};
    $line = $_;
    ($aseqno, $lang, $curno, $type, $program, @rest) = split(/\t/, $line);
    if ($debug >= 2) {
        print "# line=$line\n";
    }
    $program =~ s/$prog_sep/\n/g;
    $program = substr($program, 2) . "\n";
    my $filename = "$subdir/$aseqno.$curno.$lang";
    open(OUT, ">", $filename) || die "# cannot write $filename\n";
    print OUT $program;
    close(OUT);
} # while <>
#----
__DATA__
A367064	sagemath	1	type	~~~~~~def unitary_divisors(n):~~return [d for d in divisors(n) if gcd(n//d, d) == 1]~~def Un(n):~~un = unitary_divisors(n)~~M = matrix([[a*b//gcd(a,b)**2 for a in un] for b in un])~~return M.det()~~print([Un(n) for n in range(1, 44)])~~# Alternative:~~def detN(n):~~PD = set(prime_divisors(n))~~Sn = Subsets(PD)~~dn = 1~~for si in Sn:~~sj = PD.difference(si)~~Pi = prod(1 + p**valuation(n, p) for p in si)~~Pj = prod(1 - p**valuation(n, p) for p in sj)~~dn = dn*Pi*Pj~~return dn~~print([detN(n) for n in range(1, 44)])~~# Based on the extensions found by David A. Corneth and Chai Wah Wu:~~def uphi(n):~~return prod(p**(valuation(n,p))-1 for p in prime_divisors(n))~~def usigma(n):~~return sum(d for d in divisors(n) if gcd(n//d, d) == 1)~~def omega(n):~~return len(prime_divisors(n))~~def ddet(n):~~return (uphi(n)*usigma(n))**(2**(omega(n)-1))*(-1)**(omega(n))~~print([ddet(n) for n in range(1, 44)])
A367064	pari	1	type	~~~~~~a(n) = {~~my(d = divisors(n), m);~~  d = select(x->gcd(x, n/x)==1, d);~~  m = matrix(#d, #d, i, j, d[i]*d[j]/(gcd(d[i], d[j])^2));~~  matdet(m)~~} /* _David A. Corneth_, Nov 04 2023 */
A367064	pari	2	type	~~~~~~a(n) = {~~  my(f = factor(n), P = vector(#f~, i, f[i,1]^(2*f[i,2])), res = 1);~~  forsubset(#f~, s,~~    s = Set(s);~~    vs = vector(#s, i, 1 - P[s[i]]);~~    res*=vecprod(vs);~~  );~~  return(res);~~} /* _David A. Corneth_, Nov 04 2023 */
A367064	python	1	type	~~~~~~from math import prod~~from sympy import factorint~~def A367064(n):~~f = factorint(n)~~return prod(1-d**(e<<1) for d,e in f.items())**(1<<len(f)-1) if n>1 else 1~~# _Chai Wah Wu_, Nov 06 2023

# Caution, Python/SageMath need leading spaces!
