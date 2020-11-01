#!perl

# Generate Euler transform periods from (th)eta functions
# @(#) $Id$
# 2020-10-31, Georg Fischer
#
#:# Usage:
#:#   perl etaper.pl [-gm[d] matrix] [-ep period] [-x]
#:#       -gm   (full) Gram matrix (default [[1,0],[0,1]])
#:#       -gmd  diagonal of Gram matrix
#:#       -ep   Euler transform period of base function ([2,-3,2,-1,...] for theta_3, [-1] for Ramanujan's eta)
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
my $diag    = 0;
my $execgmt = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{\-b}) {
        $bfile     = "-b ";
    } elsif ($opt  =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{\-ep}) {
        $eperiod   = shift(@ARGV);
    } elsif ($opt  =~ m{\-gm}) {
        $matrix_list  = shift(@ARGV);
        if ($opt   =~ m{\-gmd}) {
            $diag  = 1;
        } 
    } elsif ($opt  =~ m{\-n}) {
        $noterms   = shift(@ARGV);
    } elsif ($opt  =~ m{\-x}) {
        $execgmt   = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

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
__DATA__
