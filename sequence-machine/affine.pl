#!perl

# Select affine relations: A-left = b * A-right + c
# @(#) $Id$
# 2021-06-26: Georg Fischer
#
#:# Usage:
#:#     perl affine.pl seqdb.txt > output
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $subset  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-s} ) {
        $subset     = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my %nums = qw(
    0 ZERO
    1 ONE
    2 TWO
    3 THREE
    4 FOUR
    5 FIVE
    6 SIX
    7 SEVEN
    8 EIGHT
    9 NINE
   10 TEN
    ); 
my $aseqno;
#----------------
my ($si, $mt, $ix, $px, $rseqno);
while (<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    ($aseqno, $si, $mt, $ix, $px) = split(/\t/);
    if ($ix =~ m{\A(\d+)([\+\*\^])(A\d+)\((\d+\+n|n)\)([+\-]\d+)?\Z}) { # affine line
        my ($factor, $oper, $rseqno, $index, $add) = ($1, $2, $3, $4, $5 || "");
        my $parm3 = ""; # goes into the constructor
        my $next = "";
        if (0) {
        } elsif ($oper eq "*") {
            $next = "super.next().multiply" . (($factor eq "2") ? "2()" : "($factor)"); # stays int
        } elsif ($oper eq "+") {
            $factor = &numz($factor);
            $next = "super.next().add($factor)";
        } elsif ($oper eq "^") {
            $factor = &numz($factor);
            $next = "$factor.pow(super.next())";
        } else {
            print "# $line\n";
        }
        if ($add ne "") {
            $add =~ s{(\d+)}{};
            my $number = $1;
            $add =~ s{\+}{\.add\(};
            $add =~ s{\-}{\.subtract\(};
            $next .= "$add" . &numz($number) . ")";
        }
        if ($index =~ m{(\d+)}) {
            my $count = $1;
            $index = "";
            while ($count > 0) {
                $index .= "~~    ~~super.next();";
                $count --;
            } # while count
        } else {
            $index = "";
        }
        if ($next ne "") {
            print join("\t", $aseqno, $si, sprintf("%5d", $mt), , $rseqno, $next, $index, $ix) . "\n";
        }
    } # affine line
} # while <>
#----
sub numz {
    my ($number) = @_;
    my $result = $nums{$number};
    if (! defined($result)) {
        $result = "Z.valueOf($number)";
    } else {
        $result = "Z.$result";
    }
    return $result;
} # sub numz
#----------------
__DATA__
A178335 01  226 7*A003592(n)    7;n;A003592;*
A097254 01  100 7*A033045(n)    7;n;A033045;*
A097254 02  100 7*A037456(A005836(n))   7;n;A005836;A037456;*
A260637 09  1004    7*A087475(n)    7;n;A087475;*
A109048 13  57  7*A106608(n)    7;n;A106608;*
A109048 15  57  7*A106615(A022998(n))   7;n;A022998;A106615;*
A210645 19  38  7*A135453(1+n)  7;1;n;+;A135453;*
A260637 10  1004    7*A157507(n)%A141759(n) 7;n;A157507;n;A141759;%;*
A260637 20  48  7*A255845(n)%A114949(n) 7;n;A255845;n;A114949;%;*
