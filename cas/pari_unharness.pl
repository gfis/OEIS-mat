#!perl

# Remove trailing print commands, cut of comments and extract any author; double '' -> single '
# 2022-06-17, Georg Fischer
#:# Usage:
#:#   perl pari_unharness.pl input.seq4 > output.seq4
#:#
#:# input.seq4 has tab-separated:
#:# aseqno, callcode="pari_an", offset=bfimin, parm1=program, parm2=curno, parm3=bfimax, parm4=revision, parm5=created, parm6=author
#--------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec) . "z";
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my %months = qw(Jan 01 Feb 02 Mar 03 Apr 04 May 05 Jun 06 Jul 07 Aug 08 Sep 09 Oct 10 Nov 11 Dec 12);
my $debug    = 0; # 0 (none), 1 (some), 2 (more)
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $type, $offset, $code, $curno, $bfimax, $revision, $created, $author);
my $ok; # if record is to be repeated
while (<>) { # read seq4 format
    $nok = 0; # assume success
    s/\s+\Z//; # chompr
    if (m{\AA\d{4}\d+\s}) { # starts with A.number
        ($aseqno, $type, $offset, $code, $curno, $bfimax, $revision, $created, $author) = split(/\t/);
        &polish1();
        if ($nok eq "0") {
            #                       aseqno  callcode offset   parm1  parm2   parm3    parm4      parm5     parm6
            print        join("\t", $aseqno, $type,  $offset, $code, $curno, $bfimax, $revision, $created, $author) . "\n";
        } else {#                                                                                timeout
            print STDERR join("\t", $aseqno, "$nok", $offset, $code, $curno, $bfimax, $revision, $created, $author) . "\n";
        }
    } # starts with A-number
} # while seq4

sub polish1 { # global $type, $code, $created, $author
    my $sep   = substr($code, 0, 2);
    my @lines = map { s/\'\'/\'/g; $_ } split(/$sep/, $code, 4); # double '' -> single '
    my $len   = scalar(@lines);
    my $last  = $lines[$len - 1];
    # for(n=1,30,print1(a(n),", "))
    # for(n=1, 30, print1(a(n), ", "))
    # \\ _Lear Young_, Mar 01 2014
    if ($last =~ s{\\\\ *(_[^_]+_)\, *(\w\w\w) (\d\d) (\d\d\d\d)\s*}{}) {
        my ($auth, $mon3, $day, $year) = ($1, $2, $3, $4);
        $author = $auth;
        $created = "$year-" . $months{$mon3} . "-$day";
    }
    if ($last =~ s{\/\* *(_[^_]+_)\, *(\w\w\w) (\d\d) (\d\d\d\d)\s*\*\/\s*}{}) {
        my ($auth, $mon3, $day, $year) = ($1, $2, $3, $4);
        $author = $auth;
        $created = "$year-" . $months{$mon3} . "-$day";
    }
    $last =~ s{\A *for *\(n *\= *\d+\, *\d+\, *print1?\( *a\(n\)(\, *\"\, *\")?\)\) *\Z}{};
    if ($last =~ m{\A\s*\Z}) {
        splice(@lines, $len - 1, 1); # remove empty last line
    } elsif ($code =~ m{print|alarm|iferr}) {
        $nok = "priferr"; # sort it out
    } elsif ($code =~ m{(A\d{6}}) {
        $nok = "Annnnnn"; # sort it out
    } else {
        $lines[$len - 1] = $last;
    }
    $code = "$sep" . join($sep, @lines);
} # polish1
__DATA__
A057641	pari_an	1	~~~~a(n)={my(H=sum(k=1,n,1/k)); floor(exp(H)*log(H)+H) - sigma(n)}~~list_A057641(Nmax,H=0,S=1)=for(n=S,Nmax, H+=1/n; print1(floor(exp(H)*log(H)+H) - sigma(n),","))  \\ _M. F. Hasler_, Sep 09 2011	1	20000	59	2003-05-15 23:00:00.000	_N. J. A. Sloane_, Oct 12 2000			a(n) = floor(H(n) + exp(H(n))*log(H(n))) - sigma(n), where H(n) = Sum_{k=1..n} 1/k and sigma(n) (A000203) is the sum of the divisors of n.
A058058	pari_an	1	~~~~{a(n) = if (n <=7, 1, (3*a(n-1)*a(n-6) - 4*a(n-2)*a(n-5) + 4*a(n-3)*a(n-4))/a(n-7))};~~for(n=1, 30, print1(a(n), ", ")) \\ _G. C. Greubel_, Feb 21 2018	1	170	9	2003-05-15 23:00:00.000	_Robert G. Wilson v_, Nov 20 2000			Generalized Somos-7 sequence: a(n)*a(n+7) = 3*a(n+1)*a(n+6) - 4*a(n+2)* a(n+5) + 4*a(n+3)*a(n+4).
A060283	pari_an	1	~~~~a(n)=t=iferr(znorder(Mod(10,n)),E,0);d=(10^t-1)/n;s=t-#Str(d);if(s,d*10^s,d)~~forprime(i=1,1e2,print1(a(i)", ")) \\ _Lear Young_, Mar 01 2014	1	100	30	2003-05-15 23:00:00.000	_N. J. A. Sloane_, Mar 30 2001			Periodic part of decimal expansion of reciprocal of n-th prime (leading 0's moved to end).
A062962	pari_an	0	~~~~a(n)=if(n<2,n >= 0,a(n-1)^2*(1+1/a(n-2)));~~for(n=0,11,print1(numdiv(a(n)), ", "))	1	11	13	2003-05-15 23:00:00.000	_Jason Earls_, Jul 22 2001			Number of divisors of n-th term of sequence a(n+1) = a(n)*(a(0) + ... + a(n)) (A001697).
A063728	pari_an	0	~~~~a(n) = if(n<2,n+2,shift(a(n-1),a(n-3))); for(n=0,7,print(a(n)))	1	7	5	2003-05-15 23:00:00.000	_Jason Earls_, Aug 12 2001			a(n) = shift(a(n-1); a(n-3)), a(0)=2, a(1)=3.
A064174	pari_an	1	~~~~{a(n) = my(A=1); A = sum(m=0,n,x^m*prod(k=1,m,(1-x^(m+k-1))/(1-x^k +x*O(x^n)))); polcoeff(A,n)}~~for(n=1,60,print1(a(n),", ")) \\ _Paul D. Hanna_, Aug 03 2015	1	1000	66	2003-05-15 23:00:00.000	_Vladeta Jovovic_, Sep 20 2001			Number of partitions of n with nonnegative rank.
A064193	pari_an	1	~~~~a(n) = n^(numdiv(n)/2); {usigma(n, s=1, fac, i) = fac=factor(n); for(i=1,matsize(fac)[1], s=s*(1+fac[i,1]^fac[i,2]) ); return(s); } for(n=1,3000, if(issquare(a(n)) && issquare(usigma(n)),print1(n,",")))	1	1000	13	2003-05-15 23:00:00.000	_Jason Earls_, Oct 14 2001			Numbers whose product of divisors and sum of unitary divisors are both squares.
A064236	pari_an	0	~~~~a(n) = if(n<2,n+1,a(n-1)^2-a(n-2)^2); l(n) = ln=0; while(n,n=floor(n/10); ln++); return(ln); for(n=0,21,print(l(a(n))))	1	30	11	2003-05-15 23:00:00.000	_Jason Earls_, Sep 22 2001			Number of decimal digits in A001042.
A064798	pari_an	0	~~~~a(n) = (10^n-1)/9; {sopfr(n, s, fac, i) = fac=factor(n); for(i=1,matsize(fac)[1],s=s+fac[i,1]*fac[i,2]); return(s); } for(n=0,35,print1(sopfr(a(n)),","))	1	322	18	2003-05-15 23:00:00.000	_Jason Earls_, Oct 18 2001			Sum of primes dividing the repunit numbers (with repetition).
A066878	pari_an	1	~~~~a(n)=for(X=0,100,if(isprime(prime(X)^3-2),print(prime(X)^3-2)))	1	1000	8	2003-05-15 23:00:00.000	_Joseph L. Pe_, Jan 21 2002			Primes of the form p^3 - 2 where p is prime.
A068100	pari_an	1	~~~~{a(n)=if(n==1,1,(n-1)!*sumdiv(n-1,d,a(d)/d!))}~~for(n=1,25,print1(a(n),", ")) \\ _Paul D. Hanna_, Sep 04 2014	1	25	28	2003-05-15 23:00:00.000	_Leroy Quet_, Mar 22 2002			a(1) = 1; a(n+1) = n!*Sum_{k|n} a(k)/k!.
A072203	pari_an	1	~~~~a(n) = 1 - sum(i=1, n, (-1)^bigomega(i));~~for(n=1, 100, print1(a(n),", ")) \\ _Indranil Ghosh_, Mar 17 2017	1	10000	32	2003-05-15 23:00:00.000	Bill Dubuque (wgd(AT)zurich.ai.mit.edu), Jul 03 2002			(Number of oddly factored numbers <= n) - (number of evenly factored numbers <= n).
A072859	pari_an	1	~~~~a(n)=if(n<4,n==2,znorder(Mod(10, prime(n)))) ? for(n=1,100,if(isprime(a(n))==1,print1(prime(n),",")))	1	10000	19	2003-05-15 23:00:00.000	_Benoit Cloitre_, Jul 26 2002			Primes p for which the period length of 1/p is prime.
A073711	pari_an	0	~~~~a(n)=local(A=1); for(i=0,#binary(n), A=subst(A,x,x^2+x*O(x^n))+x*subst(A,x,x^2+x*O(x^n))^2); polcoeff(A,n)~~for(n=0,65,print1(a(n),", ")) \\ _Paul D. Hanna_, Dec 21 2012	1	10000	34	2003-05-15 23:00:00.000	_Paul D. Hanna_, Aug 05 2002			G.f. satisfies: A(x) = A(x^2) + x*A(x^2)^2.
A073712	pari_an	0	~~~~a(n)=local(A=1); for(i=0,#binary(n), A=subst(A,x,x^2+x*O(x^n))+x*subst(A,x,x^2+x*O(x^n))^2);polcoeff(A^2,n)~~for(n=0,65,print1(a(n),", ")) \\ _Paul D. Hanna_, Dec 21 2012	1	10000	31	2003-05-15 23:00:00.000	_Paul D. Hanna_, Aug 05 2002			Self-convolution of A073711.
A073776	pari_an	0	~~~~{a(n) = my(A=[1,1],F); for(i=1,n, A=concat(A,0); F=Ser(A); A = Vec(sum(m=1,#A, subst(x/F, x, x^m*F^m))) ); A[n+1]}~~for(n=0,50, print1(a(n),", ")) \\ _Paul D. Hanna_, Apr 19 2016	1	1000	35	2003-05-15 23:00:00.000	_Paul D. Hanna_, Aug 10 2002			a(n) = Sum_{k=1..n} -mu(k+1) * a(n-k), with a(0)=1.
