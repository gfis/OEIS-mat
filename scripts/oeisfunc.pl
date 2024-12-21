#!perl

# Map OEIS function names to Fnnnnn sequence numbers of jOEIS Functions.*.z
# @(#) $Id$
# 2024-07-20, Georg Fischer
#
#:# Usage:
#:#   perl oeisfunc.pl in.seq4 > out.seq4
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

my %hfuncs = qw(
abs             ABS
antisigma       D024816
ard             F003415
bell            F000110
bigomega        F001222
binom           BI
binomial        BI
cat             F000108
catalan         F000108
catalannumber   F000108
chowla          F048050
ceil            CEIL
ceiling         CEIL
core            F007913
cototient       F051953
delta           D055034
digsum          F007953
digitsum        F007953
factorial       F000142
fallfac         F008279
fib             F000045
fibonacci       F000045
floor           FLOOR
gcd             GCD
gpf             F006530
hammingweight   F000120   
jacobi          Functions.JACOBI.z
kronecker       Functions.KRONECKER.z
lah             F008297
lcm             LCM
lpf             F020639
lucas           F000032
makeodd         F000265
max             MAX
mertens         F002321
min             MIN
mod             MOD
mobius          F008683
moebius         F008683
mu              F008683
nextprime       F007918
omega           F001221
parity          F000035
partitions      F000041
euler_phi       F000010
eulerphi        F000010
phi             F000010
eulerphi        F000010
pi              F000720
pod             F007955
previousprime   F007917
prevprime       F007917
prime           F000040
primepi         F000720
primorial       F034386
psi             F001615
rad             F007947
rev             F004086
reverse         F004086
reversal        F004086
divisorsigma    F000203
s1              S1
s2              S2
sig             SIGN
sign            SIGN
signum          SIGN
sigma           F000203
sigma0          F000005
sigma1          F000203
sigma2          F001157
sigma3          F001158
sopf            F008472
sopfr           F001414
spf             F020639
sqrt            F000196
stirling1       S1
stirling2       S2
stirling_1      S1
stirling_2      S2
stirlings1      S1
stirlings2      S2
tau             F000005
totient         F000010
triangular      F000217
uphi            F047994
usigma          F034448
usigma0         F034444
usigma1         F034448
wt              F000120
);
# floor(sqrt     F000196

#while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_; #
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
        #                         1                       1 (
        my @afuncs = ($parm1 =~ m{([a-zA-Z][A-Za-z0-9_\.]+)\(}g); # with dots
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
                    my $fnnn = $hfuncs{$lfunc};
                    if (defined($fnnn)) {
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
