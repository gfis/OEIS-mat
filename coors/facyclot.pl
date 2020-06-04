#!perl

# Replace factors by (x^k-1) and cyclotomic polynomials
# @(#) $Id$
# 2020-05-31, Georg Fischer: copied from denpoly.pl
# 
#:# Usage:
#:#   perl facyclot.pl inputfile ... > outputfile
#
# In a preliminary step, the g.f.'s denominator is simplified with 2 types of factors:
#   Pn  - (x^n-1)
#   Qn  - nth cyclotomic polynomial
# In the end, all Q's are expanded such that only P's remain.
#---------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
#----
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @cyclot = ();
my $ict = 0;
while (<DATA>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    if (0) {
    } elsif ($line =~ m{k\s*\:\=\s*(\d+)}) {
        $ict = $1;
    } elsif ($line =~ m{\Ax}) {
        $cyclot[$ict] = $line;
        # print "\$cyclot[$ict] = \"$cyclot[$ict]\";\n";
    }
} # while <DATA>
#----
while (<>) {
    next if ! m{\AGal};
    s{\s+\Z}{}; # chompr
    my $line = $_;
    my ($galid, $vertex, $factorlist) = split(/\t/, $line);
    my $ifact = 0;
    my @factors = map { 
        my $elem = ($ifact == 0 ? $_ : "($_");
        $ifact ++;
        $elem
        } split(/\*\(/, $factorlist); 
    for (my $ifact = 0; $ifact < scalar(@factors); $ifact ++) {
        my $elem = $factors[$ifact];
        if ($elem =~ m{\A\(([^\)]+)\)}) {
            my $fact = $1 || " ";
            $ict = 1;
            my $busy = 1;
            while ($ict < scalar(@cyclot)) {
                if ($fact eq ($cyclot[$ict] || " ")) {
                    $fact = "Q($ict)";
                    $busy = 0; # found
                }
                $ict ++;
            } # while ict
            if ($busy == 0) {
                $elem =~ s{\A\(([^\)]+)\)}{$fact};
            } else {
                $elem =~ s{\A\(1\+x\)}{Q\(2\)};
                $elem =~ s{\A\(x\^(\d+)\-1\)}{P\($1\)};
            }
            $elem =~ s{\AQ\(1\)}{P\(1\)};
        } # if (...)
        $elem =~ s{\A(.*)\^2\Z}{$1\*$1};
        $factors[$ifact] = $elem;
    } # for ifact
    my $result = join("*", reverse(sort(@factors)));
    $factorlist = $result;
    if ($result =~ m{Q}) {
        $result = &expand($result);
    } else {
        $result = join("*", map { $_ += 0; "P($_)" } reverse(sort(map { m{(\d+)}; sprintf("%03d", $1) } @factors)));
        $result .= "\t1";
    }
    print join("\t", $galid, $vertex, $factorlist, $result) . "\n";
} # while <>
#----
sub expand { # replace any Q's
    my ($list) = @_; 
    my @elems = split(/\*/, $list); # some Q's followed by P's
    my $ielem = 0;
    my @cyclos = (); # stores Q's only
    while ($ielem < scalar(@elems)) { # replace any P by its Q's
        my $elem = $elems[$ielem];
        $elem =~ m{\A(\w)\((\d+)\)};
        my $letter = $1;
        my $expon  = $2;
        if ($letter eq 'P') {
            push(@cyclos, &cyclist($expon));
        } else { # keep Q
            push(@cyclos, $expon);
        }
        $ielem ++;
    } # while $ielem
    $list = "";
    if ($debug > 0) {
        $list .= join("*", reverse(sort(map { "Q($_)" } @cyclos))) . "\t"; # leading zeroes for proper sorting
    }
    $list .= &shrink(@cyclos);
    return $list;
} # expand
#----
sub shrink { # replace any Q's
    my (@elems) = @_; 
    my @numers = (); # expansion of the g.f.'s numerator
    my @denoms = (); # g.f.'s denominator
    my %hash = ();
    my $ielem = 0;
    while ($ielem < scalar(@elems)) { # store the counts in a hash
        my $elem = sprintf("%03d", $elems[$ielem]); # leading zeroes for proper sorting
        if (! defined($hash{$elem})) {
            $hash{$elem} = 1;
        } else {
            $hash{$elem} ++;
        }
        $ielem ++;
    } # while hashing
    my @keys = reverse(sort(keys(%hash))); # now examine al Q's in descending order
    if ($debug > 0) {
        print "# hash:";
        foreach my $key(@keys) {
            print " $key->$hash{$key};";
        } # foreach
        print "\n";
    } # debug
    foreach my $key(@keys) {
        my $kcount = $hash{$key} || 0;
        while ($kcount > 0) { # this Q must be raised to "P($count)"
            my @divs = &cyclist($key + 0); # remove leading zeroes
            foreach my $div(@divs) { # for all divisors of this Q
                my $dkey = sprintf("%03d", $div);
                my $dcount = $hash{$dkey} || 0; 
                if ($dcount > 0) { # there is such a Qd available - remove it
                    $hash{$dkey} --;
                } else {
                    push(@numers, "Q($div)"); # this Q is no more available - assume it and expand the numerator with it
                }
            } # foreach div
            push(@denoms, "P(" . ($key + 0) . ")"); # raised result
            $kcount = $hash{$key} || 0;
        } # while kcount > 0
    } # foreach key
    return "" . join("*", @denoms) . "\t" . join("*", @numers);
} # shrink
#----
sub cyclist { # return the array of Q(d)'s for a P(n) for all divisors d in {1...n} of n, with descending d
    my ($num) = @_;
    my @result = ();
    for (my $div = $num; $div >= 1; $div --) {
        if ($num % $div == 0) {
            push(@result, $div);
        }
    } # for $div
    return @result;
} # cyclist
#--------------------------------
my $maple = << 'GFis';
k:= -1;
while k <= 64 do
  k:=k+1;
  numtheory[cyclotomic](k,x);
od;

interface(prettyprint=0);
interface(ansi=false);
with(numtheory):
Fact:= proc(p) local X, k, P, T, q;
  P:= p; T:= 1;
  X:= indets(p)[1];
  k:= degree(P,X);
  while k > 0 do
    if rem(P, X^k-1, X, 'q') = 0 then
       P:= q; T:= T*(X^k-1)
    else
       k:= k-1
    fi
  od;
  T * factor(P)
end proc;
P:=proc(n); (x^n-1); end proc;
Q:=proc(n); cyclotomic(n,x); end proc;
R:=proc(n); x^6+x^3+1; end proc;
GFis
__DATA__
k := 0
x
k := 1
x-1
k := 2
x+1
k := 3
x^2+x+1
k := 4
x^2+1
k := 5
x^4+x^3+x^2+x+1
k := 6
x^2-x+1
k := 7
x^6+x^5+x^4+x^3+x^2+x+1
k := 8
x^4+1
k := 9
x^6+x^3+1
k := 10
x^4-x^3+x^2-x+1
k := 11
x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 12
x^4-x^2+1
k := 13
x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 14
x^6-x^5+x^4-x^3+x^2-x+1
k := 15
x^8-x^7+x^5-x^4+x^3-x+1
k := 16
x^8+1
k := 17
x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 18
x^6-x^3+1
k := 19
x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 20
x^8-x^6+x^4-x^2+1
k := 21
x^12-x^11+x^9-x^8+x^6-x^4+x^3-x+1
k := 22
x^10-x^9+x^8-x^7+x^6-x^5+x^4-x^3+x^2-x+1
k := 23
x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 24
x^8-x^4+1
k := 25
x^20+x^15+x^10+x^5+1
k := 26
x^12-x^11+x^10-x^9+x^8-x^7+x^6-x^5+x^4-x^3+x^2-x+1
k := 27
x^18+x^9+1
k := 28
x^12-x^10+x^8-x^6+x^4-x^2+1
k := 29
x^28+x^27+x^26+x^25+x^24+x^23+x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 30
x^8+x^7-x^5-x^4-x^3+x+1
k := 31
x^30+x^29+x^28+x^27+x^26+x^25+x^24+x^23+x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 32
x^16+1
k := 33
x^20-x^19+x^17-x^16+x^14-x^13+x^11-x^10+x^9-x^7+x^6-x^4+x^3-x+1
k := 34
x^16-x^15+x^14-x^13+x^12-x^11+x^10-x^9+x^8-x^7+x^6-x^5+x^4-x^3+x^2-x+1
k := 35
x^24-x^23+x^19-x^18+x^17-x^16+x^14-x^13+x^12-x^11+x^10-x^8+x^7-x^6+x^5-x+1
k := 36
x^12-x^6+1
k := 37
x^36+x^35+x^34+x^33+x^32+x^31+x^30+x^29+x^28+x^27+x^26+x^25+x^24+x^23+x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 38
x^18-x^17+x^16-x^15+x^14-x^13+x^12-x^11+x^10-x^9+x^8-x^7+x^6-x^5+x^4-x^3+x^2-x+1
k := 39
x^24-x^23+x^21-x^20+x^18-x^17+x^15-x^14+x^12-x^10+x^9-x^7+x^6-x^4+x^3-x+1
k := 40
x^16-x^12+x^8-x^4+1
k := 41
x^40+x^39+x^38+x^37+x^36+x^35+x^34+x^33+x^32+x^31+x^30+x^29+x^28+x^27+x^26+x^25+x^24+x^23+x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 42
x^12+x^11-x^9-x^8+x^6-x^4-x^3+x+1
k := 43
x^42+x^41+x^40+x^39+x^38+x^37+x^36+x^35+x^34+x^33+x^32+x^31+x^30+x^29+x^28+x^27+x^26+x^25+x^24+x^23+x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 44
x^20-x^18+x^16-x^14+x^12-x^10+x^8-x^6+x^4-x^2+1
k := 45
x^24-x^21+x^15-x^12+x^9-x^3+1
k := 46
x^22-x^21+x^20-x^19+x^18-x^17+x^16-x^15+x^14-x^13+x^12-x^11+x^10-x^9+x^8-x^7+x^6-x^5+x^4-x^3+x^2-x+1
k := 47
x^46+x^45+x^44+x^43+x^42+x^41+x^40+x^39+x^38+x^37+x^36+x^35+x^34+x^33+x^32+x^31+x^30+x^29+x^28+x^27+x^26+x^25+x^24+x^23+x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 48
x^16-x^8+1
k := 49
x^42+x^35+x^28+x^21+x^14+x^7+1
k := 50
x^20-x^15+x^10-x^5+1
k := 51
x^32-x^31+x^29-x^28+x^26-x^25+x^23-x^22+x^20-x^19+x^17-x^16+x^15-x^13+x^12-x^10+x^9-x^7+x^6-x^4+x^3-x+1
k := 52
x^24-x^22+x^20-x^18+x^16-x^14+x^12-x^10+x^8-x^6+x^4-x^2+1
k := 53
x^52+x^51+x^50+x^49+x^48+x^47+x^46+x^45+x^44+x^43+x^42+x^41+x^40+x^39+x^38+x^37+x^36+x^35+x^34+x^33+x^32+x^31+x^30+x^29+x^28+x^27+x^26+x^25+x^24+x^23+x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 54
x^18-x^9+1
k := 55
x^40-x^39+x^35-x^34+x^30-x^28+x^25-x^23+x^20-x^17+x^15-x^12+x^10-x^6+x^5-x+1
k := 56
x^24-x^20+x^16-x^12+x^8-x^4+1
k := 57
x^36-x^35+x^33-x^32+x^30-x^29+x^27-x^26+x^24-x^23+x^21-x^20+x^18-x^16+x^15-x^13+x^12-x^10+x^9-x^7+x^6-x^4+x^3-x+1
k := 58
x^28-x^27+x^26-x^25+x^24-x^23+x^22-x^21+x^20-x^19+x^18-x^17+x^16-x^15+x^14-x^13+x^12-x^11+x^10-x^9+x^8-x^7+x^6-x^5+x^4-x^3+x^2-x+1
k := 59
x^58+x^57+x^56+x^55+x^54+x^53+x^52+x^51+x^50+x^49+x^48+x^47+x^46+x^45+x^44+x^43+x^42+x^41+x^40+x^39+x^38+x^37+x^36+x^35+x^34+x^33+x^32+x^31+x^30+x^29+x^28+x^27+x^26+x^25+x^24+x^23+x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 60
x^16+x^14-x^10-x^8-x^6+x^2+1
k := 61
x^60+x^59+x^58+x^57+x^56+x^55+x^54+x^53+x^52+x^51+x^50+x^49+x^48+x^47+x^46+x^45+x^44+x^43+x^42+x^41+x^40+x^39+x^38+x^37+x^36+x^35+x^34+x^33+x^32+x^31+x^30+x^29+x^28+x^27+x^26+x^25+x^24+x^23+x^22+x^21+x^20+x^19+x^18+x^17+x^16+x^15+x^14+x^13+x^12+x^11+x^10+x^9+x^8+x^7+x^6+x^5+x^4+x^3+x^2+x+1
k := 62
x^30-x^29+x^28-x^27+x^26-x^25+x^24-x^23+x^22-x^21+x^20-x^19+x^18-x^17+x^16-x^15+x^14-x^13+x^12-x^11+x^10-x^9+x^8-x^7+x^6-x^5+x^4-x^3+x^2-x+1
k := 63
x^36-x^33+x^27-x^24+x^18-x^12+x^9-x^3+1
k := 64
x^32+1
