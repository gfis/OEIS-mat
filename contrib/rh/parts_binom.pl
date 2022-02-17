#!perl

# Convert partitions into counting formulas with binomials
# @(#) $Id$
# 2022-02-16, Georg Fischer
#
#:# usage:
#:#    grep ... \
#:#    | perl partition5.pl \
#:#    | perl parts_binom.pl -d debug -m mode > output.seq4
#:#    -m z (joeis.Z expressions), mp (Maple seq), hol (for bincoef.mpat)
#--------------------------------
use strict;
use warnings;
use integer;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $mode = "z";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

print "# OEIS-mat/contrib/rh/parts_binom.pl $timestamp\n";
my @partList; # of $n

while (<>) {
    s/\s+\Z//; # chompr
    if (m{\AA\d+\t}) {
        my ($aseqno, $callcode, $offset, @parms) = split(/\t/);
        my $num   = shift(@parms);
        my $parts = shift(@parms);
        my $newParts = &generate($num, $parts);
        $newParts =~ s{ }{}g;
        $newParts =~ s{\A\+}{};
        $callcode = "binomlo";
        print join("\t", $aseqno, $callcode, $offset
        #   , $num
            , $newParts, $parts, @parms) . "\n";
    } else {
        print "$_\n";
    }
} # while <>

sub generate () { # convert the partitions into a binomial expression
    my ($num, $parts) = @_;
    my $oldList = $parts;
    my $newList = "";
    my $sepPlus = "";
    my $sepTim = "";
    my $newParts = "";
    foreach my $parts (split(/ *\= */, $oldList)) { # a single partition
        my $count = 0;
        $sepTim = "";
        $newParts = "";
        if (0) {
        } elsif ($mode =~ m{m.?p}i) {
        } elsif ($mode =~ m{z}i   ) {
            foreach my $part (split(/ *\+ */, $parts)) { # occurrences of summand
                my ($occ, $summand) = split(/\*/, $part);
                if ($occ > 1) {
                    $newParts .= "$sepTim" . "C(n^2" . ($count > 0 ? "-$count" : "") . ",$occ)";
                } else {
                    if ($count > 0) {
                        $newParts .= "$sepTim" . "(n^2-$count)";
                    } else {
                        $newParts .= "$sepTim" . "n^2";
                    }
                }
                $count += $occ;
                $sepTim = "*";
            } # foreach $part
            $newList .= "$sepPlus$newParts";
            $sepPlus = "+";
        }
    } # foreach $parts
    return $newList;
} # generate

__DATA__
# A159355   4 = 4*1 = 1*4
A159355 binom   0   4   4*1 = 1*4
# A159359   5 = 5*1 = 1*4 + 1*1
A159359 binom   0   5   5*1 = 1*4 + 1*1
# binomin(A159359, 2, proc(n) binomial(n^2,1)*binomial(n^2-1,1) + binomial(n^2,5) end, [12]);
