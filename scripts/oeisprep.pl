#!perl

# Polishing of PARI/GP program lines
# @(#) $Id$
# 2024-10-10: mod; *NJAS=85
# 2024-11-14, Georg Fischer: copied from oeisprep.pl
#
#:# Usage:
#:#   perl pariprep.pl {options} in.seq4 > out.seq4
#:#       with the following options:
#:#       -abs: |abs| -> ABS()
#:#       -bin: binomial, Stirling[12] -> BI, S1, S2
#:#       -fac: n! -> FA(n)
#:#       -fun: sigma( -> F000203 etc.
#:#       -gcd: gcd,lcm,min,max -> uppercase
#:#       -mod: mod -> % or MOD(
#:#       -mul: insert "*" in MMA notation "2n" etc.
#:#       -neg: leading "-" -> NEG(
#:#       -sum: Sum_{}, Prod_{} -> SU(, SD( ...
#:#       -z12: 2^ -> Z2(, (-1)^ -> Z_1(
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $debug = 0;
my $abs = 0;
my $bin = 0;
my $fac = 0;
my $fun = 0;
my $gcd = 0;
my $mod = 0;
my $mul = 0;
my $neg = 0;
my $sum = 0;
my $z12 = 0;
        $abs = 1;
        $bin = 1;
        $fac = 1;
        $fun = 1;
        $gcd = 1;
        $mod = 1;
        $mul = 1;
        $neg = 1;
        $sum = 1;
        $z12 = 1;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    }
    if ($opt =~ m{\A\-d})    { 
        $debug = shift(@ARGV); 
    } elsif ($opt =~ m{\A\-all})  {
        $abs = 1;
        $bin = 1;
        $fac = 1;
        $fun = 1;
        $gcd = 1;
        $mod = 1;
        $mul = 1;
        $neg = 1;
        $sum = 1;
        $z12 = 1;
    } else {
        if  ($opt =~ m{\bab}) { $abs = 1; }
        if  ($opt =~ m{\bbi}) { $bin = 1; }
        if  ($opt =~ m{\bfa}) { $fac = 1; }
        if  ($opt =~ m{\bfu}) { $fun = 1; }
        if  ($opt =~ m{\bgc}) { $gcd = 1; }
        if  ($opt =~ m{\bmo}) { $mod = 1; }
        if  ($opt =~ m{\bmu}) { $mul = 1; }
        if  ($opt =~ m{\bne}) { $neg = 1; }
        if  ($opt =~ m{\bsu}) { $sum = 1; }
        if  ($opt =~ m{\bz1}) { $z12 = 1; }
    }
} # while $opt

#while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    my ($aseqno, $callcode, $offset, $parm1, @rest) = split(/\t/, $line);
    my $nok = 0;
    if ($mod > 0) { # must be done before space removal!
        #           1     1
        $parm1 =~ s{([ \)])mod +}                                  {$1\%}g;
    }
    $parm1 =~ s{ }{}g; # remove spaces
    if ($abs > 0) {
    }
    if ($bin > 0) {
        $parm1 =~ s{binom(ial)?}                                   {BI}ig;
        $parm1 =~ s{stirling}                                      {S}ig;
    }
    if ($fac > 0) {
        if (index($parm1, "!!") >= 0) { 
        $parm1 =~ s{\(([^\)\(]+)\)\!\!}                            {DF\($1\)}g;
        $parm1 =~ s{(\w)\!\!}                                      {DF\($1\)}g;
        }
        if (index($parm1, "!") >= 0) { 
        $parm1 =~ s{\(([^\)\(]+)\)\!}                              {FA\($1\)}g;
        $parm1 =~ s{(\w)\!}                                        {FA\($1\)}g;
        }
        if (index($parm1, "\'") >= 0) { 
        $parm1 =~ s{\(([^\)\(]+)\)\'\'}                            {ARD\(ARD\($1\)\)}g;
        $parm1 =~ s{(\w)\'\'}                                      {ARD\(ARD\($1\)\)}g;
        $parm1 =~ s{\(([^\)\(]+)\)\'}                              {ARD\($1\)}g;
        $parm1 =~ s{(\w)\'}                                        {ARD\($1\)}g;
        }
    }
    if ($fun > 0) {
        $parm1 =~ s{\(([^\)\(]+)\)\!}                              {FA\($1\)}g;
        $parm1 =~ s{(\w)\!}                                        {FA\($1\)}g;
    }
    if ($gcd > 0) {
        $parm1 =~ s{\b(abs|gcd|gpf|lcm|max|min|mu|phi|rad|spf|tau)\(}  
                   {uc($1) . "\("}ieg;
    }
    if ($mul > 0) {
        $parm1 =~ s{\b(\d)([A-Za-z])}                              {$1\*$2}g; # insert "*"
        $parm1 =~ s{\b(\d)\(}                                      {$1\*\(}g; # insert "*"
        #            (1   1   +  2     2 )
        $parm1 =~ s{\((\d+) *\+ *([i-n])\)}                        {\($2\+$1\)}g; # (1+n) -> (n+1)
    }
    if ($z12 > 0) { # before neg!          
        $parm1 =~ s{2\^\(}                                         {Z2\(}g;
        $parm1 =~ s{2\^([i-n])}                                    {Z2\($1\)}g;
        $parm1 =~ s{\(\-1\)\^\(}                                   {Z_1\(}g;
        $parm1 =~ s{\(\-1\)\^([i-n])}                              {Z_1\($1\)}g;
    }
    if ($neg > 0) { 
        $parm1 =~ s{\A\-([i-n]|[0-9]+)\W}                          {NEG\($1\)};
        $parm1 =~ s{\(\-([i-n]|[0-9]+)\W}                          {\(NEG\($1\)}g;
        if ($parm1 =~ m{\A\-|\(\-}) {
            $nok = "neg";
        }
    }
    if ($sum > 0) {
        #                  1  1  2   2    3        3      4  4
        $parm1 =~ s{Sum_?\{(\w)\=(\w+)\.\.([^\}\,]+)[\}\,](.*)}        {SU($2, $3, $1 -> $4\)}i;
        #                  1  1  2  23        3      4  4
        $parm1 =~ s{Sum_?\{(\w)\|(\w)([^\}\,]*)[\}\,](.*)}             {SD($2, $1 -> $4\)}i;
        #               1     1   2  2  3   3    4        4      5  5
        $parm1 =~ s{Prod(uct_?)?\{(\w)\=(\d+)\.\.([^\}\,]+)[\}\,](.*)} {PR($3, $4, $2 -> $5\)}i;
        #               1     1   2  2  3  34        4      5  5
        $parm1 =~ s{Prod(uct_?)?\{(\w)\|(\w)([^\}\,]*)[\}\,](.*)}      {PD($3, $2 -> $5\)}i;
        if ($parm1 =~ m{(Sum|Prod(uct)?)_?}) {
            $nok = "sum";
        }
    }
    if ($nok ne "0") {
        print STDERR join("\t", $aseqno, "$nok=$callcode", $offset, $parm1, @rest) . "\n";
    } else {
        print        join("\t", $aseqno, $callcode,        $offset, $parm1, @rest) . "\n";
    }
} # while <>
__DATA__
A077611	lambdan	0	(n-1)!*(2*n*(n-1)-(2*n-1)*(-1)^n-1)/8
A077611	lambdan	0	4!*(A099284 - X001620 - X073742 + 1)
A077640	lambdan	0	-A188347(n)- 3
A077642	lambdan	0	Sum_{j=0..-1+10^n}abs(mu(10^n + j))
A077641	lambdan	0	Sum_{j=0..n-1}abs(mu(n+j))
A077643	lambdan	0	Sum_{j|n} abs(mu(2^n + j))
A077641	lambdan	0	Product_{j=0..n-1}abs(mu(n+j))
A077643	lambdan	0	Product_{j|n} abs(mu(2^n + j))
A077645	lambdan	0	Sum_{10^(n-1)<=p <=10^n, p prime}p 
A077645	lambdan	0	D007504(F000720(10^n))- D007504(F000720(10^(n-1)))
A077657	lambdan	0	J045984(n+1)+A077655(J045984(n+1))-n
A077691	lambdan	0	A076803(n)/n!
A077697	lambdan	0	A077696(n+1)/A077696(n)
A077699	lambdan	0	A077698(n+1)/A077698(n)
