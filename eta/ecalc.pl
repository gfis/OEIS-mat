#!perl

# Generate Euler transform periods from PARI/GP ecalc() calls in Michael Somos' monster3.gp
# @(#) $Id$
# 2020-11-05, Georg Fischer
#
#:# Usage:
#:#   perl ecalc.pl [-d debug[-b] ] [-m mode] [-n noterms] [-x] monster3.gp > eulerps.gen
#:#       -b    for b-file format (default: csv)
#:#       -d    0=none, 1=some, 2=more debugging output
#:#       -m    ecalc
#:#       -n    number of terms to be generated 
#:#       -x    execute java GramMatrixTest
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}

my $LITE = "../../joeis-lite/internal/fischer";
my $ETPT = "java -Doeis.big-factor-limit=1000000000 -Xmx4g " 
         . "-cp \"../../joeis-lite/dist/joeis-lite.jar;../../joeis/build.tmp/joeis.jar\""
         . " irvine.test.EulerTransformPeriodTest";
my $bfile   = "";
my $debug   = 0;
my $noterms = 64;
my $matrix_list = "[[1,0],[0,1]]";
my $eperiod = "[2,-3,2,-1]";
my $mode    = "ecalc";
my $execet  = 0;
my @eps     = (-1); # ET period of the base function; here: EiT(eta(q)) = [-1,...]
my $epslen  = scalar(@eps);
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{\-b}) {
        $bfile     = "-b ";
    } elsif ($opt  =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{\-m}) {
        $mode      = shift(@ARGV);
    } elsif ($opt  =~ m{\-n}) {
        $noterms   = shift(@ARGV);
    } elsif ($opt  =~ m{\-x}) {
        $execet    = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my %ehash = (); # map the ennx codes to their EulerTransform period
while (<>) {
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    if (0) {
    } elsif ($line =~ m{\A(\w+)\=ecalc\(\[([^\]]+)\]([^\)]+)\)\;\s*\\\\\s*(A\d+)}) {
        #                 1               2         3                     4
        # e4C2=ecalc([2,3;1,-1;4,-2],[1,8],2);                                 \\ A029845
        my ($code, $etaexp_list, $fexp_list, $aseqno) = ($1, $2, $3 || ",[1,1]", $4);
        my $orig = "$1=ecalc([$2}]$3);";
        $fexp_list =~ s{\A\,,}{\,\[1\,1\]\,};
        $fexp_list =~ s{\A\,}{}; # remove leading ","
        $fexp_list =~ s{\]\,.*}{\]}; # remove trailing parameters
        my $period = &get_period($etaexp_list, $fexp_list);
        $ehash{$code} = $period;
        #                                        parm1    parm2   parm3    parm4
        print join("\t", $aseqno, "eulerps", 0,  $period, 1,      ""     , $orig) . "\n";
    } elsif ($line =~ m{\A(\w+)\=(([\-\+]?\d+)\+)?symm\((\w+)\,(\-?\d+)\)\;\s*\\\\\s*(A\d+)}) {
        #                 1      23                     4      5                     6
        # f13A=symm(e13B,13);                        \\ A034318
        # T13A=2+symm(e13B,13);                      \\ A034319
        my ($code1, $add0, $code2, $factor, $aseqno) = ($1, $3 || 0, $4, $5, $6);
        my $orig = "$1=" . ($2 || "") . "symm($4,$5);";
        my $period = $ehash{$code2} || "unknown";
        #                                        parm1    parm2   parm3    parm4
        print join("\t", $aseqno, "etpsymm", -1, $factor, $add0,  $period, $orig) . "\n";
    } elsif ($line =~ m{\A(\w+)\=ecalc\(\[([^\]]+)}) {
        my ($code, $etapows, $rest, $aseqno) = ($1, $2, $3, $4);
    } # m ecalc
} # while <>
#--------
sub get_period {
    my ($etaexp_list, $fexp_list) = @_;
    my (@qexp, @etaexp, @fexp);
    foreach my $pair (split(/\;/, $etaexp_list)) {
        my ($qp, $etap) = split(/\,/, $pair);
        push(@qexp  , $qp  );
        push(@etaexp, $etap);
    } # foreach $pair
    @fexp = ($fexp_list =~ m{(\-?\d+)}g);
    my $fmult = $fexp[1];
    # now determine the LCM of the q-exponents
    my $ind = 0;
    my $lcm = $qexp[$ind ++]; # start with 1st element
    while ($ind < scalar(@qexp)) {
        my $exp = $qexp[$ind ++];
        my $factor = &gcd($lcm, $exp);
        $lcm = $exp * ($lcm / $factor);
    } # while ind
    # assemble the period
    my @periods = ();
    my $perlen = $lcm * $epslen;
    for (my $iper = 0; $iper < $perlen; $iper ++) { # preset with zeroes
        $periods[$iper] = 0;
    } # zeroes
    # add the enough copies of the individual subperiods
    for (my $ind = 0; $ind < scalar(@qexp); $ind ++) {
        my $exp = $qexp[$ind];
        my @subpers = &factor($qexp[$ind], $etaexp[$ind]);
        for (my $offset = 0; $offset < $perlen; $offset += scalar(@subpers)) {
            for (my $isub = 0; $isub < scalar(@subpers); $isub ++) {
                $periods[$offset + $isub] += $subpers[$isub];
            } # for isub
        } # for offset
    } # for ind
    for (my $iper = 0; $iper < $perlen; $iper ++) { # multiply with the overall power
        $periods[$iper] *= $fmult;
    } # multiply
    return join(",", @periods);
} # get_period
#--------
sub gcd { # from https://www.perlmonks.org/?node_id=109872
    my ($a, $b) = @_;
    ($a,$b) = ($b,$a) if $a > $b;
    while ($a) {
        ($a, $b) = ($b % $a, $a);
    }
    return $b;
} # gcd
#--------
sub factor { # return the ET period of an individual factor (eta(q^k))^m
    my ($k, $m) = @_;
    my @result = ();
    for (my $ibase = 0; $ibase < scalar(@eps); $ibase ++) {
        for (my $iexp = 1; $iexp < $k; $iexp ++) { # stretch, prefix with k - 1 zeroes
            push(@result, 0);
        } # for iexp
        push(@result, $eps[$ibase] * $m);
    } # for ibase
    return @result;
} # factor
__DATA__
#--------------------
e1b=ecalc([],,2);
e2B=ecalc([1,1;2,-1],[1,24]);                                        \\ A007191
e3B=ecalc([1,1;3,-1],[1,12]);                                        \\ A030182
e4A=ecalc([2,2;1,-1;4,-1],[1,24]);                                   \\ A097340
e4C1=ecalc([1,1;4,-1],[1,8],2);                                      \\ A124972
e4C2=ecalc([2,3;1,-1;4,-2],[1,8],2);                                 \\ A029845
e4D=ecalc([1,1;2,-1],[2,12]);                                        \\ A007249

e10B=ecalc([1,1;5,1;2,-1;10,-1],[1,4]);                              \\ A132040
,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1    eta(q)
, 0, 0, 0, 0,-1, 0, 0, 0, 0,-1    eta(q^5)
, 0,+1, 0,+1, 0,+1, 0,+1, 0,+1    1/eta(q^2)
, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1    1/eta(q^10)
------------------------------
,-1, 0,-1, 0,-2, 0,-1, 0,-1, 0 = A
,-4, 0,-4, 0,-8, 0,-4, 0,-4, 0 = A^4

e4A=ecalc([2,2;1,-1;4,-1],[1,24]);                                   \\ A097340
Expansion of (eta(q^2)^2 / (eta(q) * eta(q^4)))^24 in powers of q.
Euler transform of period 4 sequence [ 24, -24, 24, 0, ...].

, 0,-2, 0,-2    eta(q^2)^2
,+1,+1,+1,+1    1/eta(q)
, 0, 0, 0,+1    1/eta(q^4)
------------
, 1,-1, 1, 0    A
,24,-24,24,0    A^24
================================
f13A=symm(e13B,13);                        \\ A034318
T13A=2+symm(e13B,13);                      \\ A034319
