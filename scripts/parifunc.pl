#!perl

# Map PARI/GP function names to jOEIS equivalents
# @(#) $Id$
# 2024-11-15, Georg Fischer, copied from oeisfunc.pl; *EFF=3
#
#:# Usage:
#:#   perl parifunc.pl in.seq4 > out.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    }
    if($opt =~ m{\A\-d})    { 
        $debug = shift(@ARGV); 
    } else {
    }
} # while $opt

# istotient
# sqrtnint
# bitand
# bitor
# bittest
# bitxor
# isprime
# ispseudoprime
# bigomega        Functions.BIG_OMEGA.z
# binomial        BI
# eulerphi        Functions.PHI.z
# gcd             Functions.GCD.z
# hammingweight   Functions.DIGIT_SUM.z
# kronecker       Functions.KRONECKER.z
# lcm             LCM
# min             MIN
# max             MAX
# moebius         MU
# omega           Functions.OMEGA.z
# sigma           Functions.SIGMA1.z


my %hfuncs = qw(
ispolygonal     Predicates.POLYGONAL.is
ispower         Predicates.POWER.is
isprimepower    Predicates.PRIME_POWER.is
issquare        Predicates.SQUARE.is
issquarefree    Predicates.SQUARE_FREE.is
numbpart        partitions
numdiv          sigma0
precprime       prevprime
prod            prod
proddiv         proddiv
sqrtint         SQRT
sumdigits       digitsum
sum             sum
sumdiv          sumdiv
);
# floor(sqrt     F000196

#while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_; 
    next if ($line !~ m{\AA\d{6}});
    my ($aseqno, $callcode, $offset, $parm1, @rest) = split(/\t/, $line);
    my $nok = 0;
    if(0) {
    } elsif ($parm1 =~ m{\+ *O\(}) { # remove "+ O(n)"
        $nok = "O()";
    } elsif ($parm1 =~ m{\.\.\.})  { # remove "..."
        $nok = "3dots";
    } elsif ($parm1 =~ m{\[x\^})   { # remove "[x^n"
        $nok = "[x^n]";
    } else {
        #                         1           1 (
        my @afuncs = ($parm1 =~ m{([a-zA-Z]\w+)\(}g);
        if ($debug > 0) {
            print "# $aseqno, afuncs=" .join(",", @afuncs) . ", parm1=$parm1\n";
        }
        foreach my $func (@afuncs) {
            if (0) {
        #   } elsif ($func  =~ m{\^}) { # strange??? ignore these, too
            } elsif ($func  =~ m{\A[A-Z]\d{6}\Z}) { # ignore A-numbers
            } else {
                my $busy = 1;
                if ($func  =~ m{floor}i) { # either followed by "sqrt(", "log_2" or  "n/2"
                    if (0) {
                    } elsif ($parm1 =~ s{floor\(sqrt\(}{(SQRT\(}i) {
                        $busy = 0;
                    #                          (1                  | (                   )1 /2                  | (                   )2 )
                    } elsif ($parm1 =~ s{floor\(([a-z0-9\+\-\*\% ]+|\([a-z0-9\+\-\*\% ]+\))\/([a-z0-9\+\-\*\% ]+|\([a-z0-9\+\-\*\% ]+\))\)}{\($1\~$2\)}i) {
                        $busy = 0;
                    } else {
                        $busy = 1;
                    }
                }
                if ($busy > 0) {
                    my $lfunc = lc($func);
                    $lfunc =~ s{_}{}g; # remove underscores
                    if (defined($hfuncs{$lfunc})) {
                        my $fnnn = $hfuncs{$lfunc};
                        $parm1 =~ s{\b$func\(}{$fnnn\(};
                        if ($func eq "Omega") { # the only one with differing case: omega vs. Omega
                            $parm1 = "F001222(";
                        }
                    } else {
                    #   print STDERR join("\t", $aseqno, $func, $parm1) . "\n";
                    }
                }
            }
        } # foreach
    }
    if ($nok ne "0") {
        print STDERR join("\t", $aseqno, "$nok=$callcode", $offset, $parm1, @rest) . "\n";
    } else {
        print        join("\t", $aseqno, $callcode,        $offset, $parm1, @rest) . "\n";
    }
} # while <>
__DATA__
A077611	lambdan	0	(n-1)!*(2*n*(n-1)-(2*n-1)*(-1)^n-1)/8
A077612	lambdan	0	4!*(A099284 - X001620 - X073742 + 1)
A077641	lambdan	0	usigma(A188347(n))- 3
A077642	lambdan	0	Sum_{j=0..-1+10^n}binomial(mu(10^n + j))
A077643	lambdan	0	Sum_{j=0..n-1}abs(mu(n+j))
A077644	lambdan	0	Sum_{j|n} abs(mu(2^n + j))
A077645	lambdan	0	Product_{j=0..n-1}abs(mu(n+j))
A077646	lambdan	0	Product_{j|n} abs(mu(2^n + j))
A077647	lambdan	0	Binomial(n, k)
A077648	lambdan	0	Sum_{1..floor(n/2) <=p <=10^n, p prime}p 
A077649	lambdan	0	floor(sqrt(F000720(10^n)))- D007504(F000720(10^(n-1)))
A077657	lambdan	0	sopfr(n+1)+sopf(J045984(n+1))-n
A077691	lambdan	0	GPF(n)/n!
A077697	lambdan	0	POD(n+1)/ard(n)
A077699	lambdan	0	Fib(n+1)/lucas(n)
A175493	lambdan	0	prod(k=1, n, k^numdiv(k))
