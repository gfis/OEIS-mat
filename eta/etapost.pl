#!perl

# Generate Euler transform periods from expressions of Ramanujan's (th)eta functions
# @(#) $Id$
# 2023-01-12: copied from etaper.pl
# 2020-10-31, Georg Fischer
#
#:# Usage:
#:#   perl etapost.pl [-d mode] [-n noterms] [-x] "postfix"
#:#       -d    debugging mode: 0=none, 1=some, 2=more debugging output
#:#       -n    number of terms to be generated 
#:#       -x    execute java EuterTransformTest
#:#       "postfix" string for the polynomial of Ramanujan functions eta,phi,psi,chi,f,theta_3
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.0";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
# constant definitons
my $LITE = "../../joeis-lite/internal/fischer";
my $ETPT = "java -Doeis.big-factor-limit=1000000000 -Xmx4g " 
         . "-cp \"../../joeis-lite/dist/joeis-lite.jar;../../joeis/build.tmp/joeis.jar\""
         . " irvine.test.EulerTransformTest";
my %kfuncs  = 
    ("eta"    , "-1"
    ,"psi"    , "1,-1"
    ,"phi"    , "2,-3,2,-1"
    ,"f"      , "1,-2,1,-1"
    ,"theta_3", "1,-1"
    ,"theta_4", "-2,-1"
    );
     
# defaults for options
my $debug   = 0;
my $noterms = 64;
my $execett = 0;
my $postfix = "eta;eta;eta;2;^;*;*";

# get options
while (scalar(@ARGV) > 0 && ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{\-n}) {
        $noterms   = shift(@ARGV);
    } elsif ($opt  =~ m{\-x}) {
        $execett   = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

# get postfix string
if (scalar(@ARGV) == 0) {
    # die "trailing postfix string is missing\n";
    # take defaul
} else {
    $postfix = shift(@ARGV);
}
#----
# evaluate the postfix string and work with a stack
my @stack = ();
my @posts = split(/\;/, $postfix);
my (@per1, @per2, @result, $expon);
while (scalar(@posts) > 0) {
    my $post = shift(@posts);
    if (0) {
    } elsif ($post eq "*") {
        &adapt2();
        @result = ();
        for (my $ind = 0; $ind < scalar(@per1); $ind ++) {
            push(@result, $per1[$ind] + $per2[$ind]);
        }
        push(@stack, join(",", @result));
    } elsif ($post eq "/") {
        &adapt2();
        @result = ();
        for (my $ind = 0; $ind < scalar(@per1); $ind ++) {
            push(@result, $per1[$ind] - $per2[$ind]);
        }
        push(@stack, join(",", @result));
    } elsif ($post eq "^") {
        $expon = pop(@stack);
        @per1 = split(/\,/, pop(@stack));
        push(@stack, join(",", &pow($expon, @per1)));
    } elsif ($post =~ m{\A([A-Za-z]\w*)\Z}) { # function name
        if (defined($kfuncs{$post})) {
            my $pers = $kfuncs{$post};
            push(@stack, $pers);
        } else {
            die "# unknown function \"$post\"";
        }
    } elsif ($post =~ m{\A(\d+)\Z}) { # number
        push(@stack, $post);
    } else { 
        die "# invalid postfix operator: \"$post\"";
    }
} # while @posts
if (scalar(@stack) != 1) {
    print join("\n", "# remaining stack:", @stack) . "\n";
}
my $result = pop(@stack); # should be the only remaining element

print "# resulting ET period: $result\n";
if ($execett) {
    my $cmd = "$ETPT -n $noterms -p \"$result\"";
    print "$cmd\n";
    print `$cmd`;
} else {
}
#--------
sub adapt2 { # pop 2 stack elements, adjust their lengths to the LCM
    @per2 = split(/\,/, pop(@stack));
    @per1 = split(/\,/, pop(@stack));
    my $len1 = scalar(@per1);
    my $len2 = scalar(@per2);
    if ($len1 != $len2) { # must widen
        my $lcm = abs($len1 * $len2) / &gcd($len1, $len2);
        @per1 = &widen($lcm, @per1);
        @per2 = &widen($lcm, @per2);
    } # must widen
} # adapt2
#--------
sub widen {
    my ($lcm, @per) = @_;
    my @result = @per;
    while (scalar(@result) < $lcm) {
        push(@result, @per);
    }
    return @result;
} # widen
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
    my ($expon, @eps) = @_;
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
        
my @eps   = ();
my $epslen = scalar(@eps);
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
