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

while (<>) {
    # e4C2=ecalc([2,3;1,-1;4,-2],[1,8],2);                                 \\ A029845
    #       1               2        3                     4
    if (0) {
    } elsif (m{\A(\w+)\=ecalc\(\[([^\]]+)\]([^\)]+)\)\;\s*\\\\\s*(A\d+)}) {
        my ($code, $aseqno, $etapows, $rest) = ($1, $4, $2, $3);
        print join("\t", $aseqno, "eulerps", 0, $code, $etapows, $rest) . "\n";
    } elsif (m{\A(\w+)\=ecalc\(\[([^\]]+)}) {
        my ($code, $aseqno, $etapows, $rest) = ($1, $4, $2, $3);
    } # m ecalc
} # while <>
__DATA__

sub old_code {
my @diags = ($matrix_list =~ m{(\-?\d+)}g);
my @eps   = ($eperiod     =~ m{(\-?\d+)}g);
my $epslen = scalar(@eps);
my $idiag = 0;
my $lcm = $diags[$idiag ++]; # start with 1st element
while ($idiag < scalar(@diags)) {
    my $term = $diags[$idiag ++];
    my $factor = &gcd($lcm, $term);
    $lcm = $term * ($lcm / $factor);
} # while idiag
if ($debug >= 1) {
  print "# diags=[" . join(",", @diags) . "]; lcm=$lcm\n";
}
my @period = ();
my $perlen = $lcm * $epslen;
for (my $iper = 0; $iper < $perlen; $iper ++) { # zeroes
    $period[$iper] = 0;
} # zeroes
for (my $idiag = 0; $idiag < scalar(@diags); $idiag ++) {
    my $exp = $diags[$idiag];
    my @subpers = &pow($exp);
    for (my $offset = 0; $offset < $perlen; $offset += scalar(@subpers)) {
        for (my $isub = 0; $isub < scalar(@subpers); $isub ++) {
            $period[$offset + $isub] += $subpers[$isub];
        } # for isub
    } # for offset
} # for idiag
my $result =  join(",", @period);
if ($execgmt) {
    my $cmd = "$ETPT $bfile -n $noterms -p \"$result\"";
    print "$cmd\n";
    print `$cmd`;
} else {
    print "$result\n";
}
} # old_code
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
sub pow { # return the ET period of a power of the base function
    my ($expon) = @_;
    my @result = ();
    for (my $ibase = 0; $ibase < scalar(@eps); $ibase ++) {
        for (my $iexp = 1; $iexp < $expon; $iexp ++) {
            push(@result, 0);
        } # for iexp
        push(@result, $eps[$ibase]);
    } # for ibase
    return @result;
} # pow
#--------------------
e1b=ecalc([],,2);
e2B=ecalc([1,1;2,-1],[1,24]);                                        \\ A007191
e3B=ecalc([1,1;3,-1],[1,12]);                                        \\ A030182
e4A=ecalc([2,2;1,-1;4,-1],[1,24]);                                   \\ A097340
e4C1=ecalc([1,1;4,-1],[1,8],2);                                      \\ A124972
e4C2=ecalc([2,3;1,-1;4,-2],[1,8],2);                                 \\ A029845
e4D=ecalc([1,1;2,-1],[2,12]);                                        \\ A007249

