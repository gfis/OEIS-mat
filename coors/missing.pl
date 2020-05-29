#!perl

# Find the missing Gal-ids of tilings
# @(#) $Id$
# 2020-05-27, Georg Fischer
#
#:# usage:
#:#   perl missing.pl input > output
#---------------------------------
use strict;
use integer;
use warnings;

# constant structures
my $tiling6 = 1248; # all up to 6-uniform
my @tiling_counts = (0, 11, 20, 61, 151, 332, 673, 1472); # = A068599 Number of n-uniform tilings

my %hash = ();
while (<>) {
    s{\s+\Z}{}; # chompr
    next if m{\A\s*(\#.*)?\Z}; # ignore comments end empty lines
    s{\.\d+\Z}{}; # remove ".v" of "Gal.u.t.v"
    $hash{$_} = $_;
} # while <>

for (my $u = 1; $u <= 6; $u ++) {
    for (my $t = 1; $t <= $tiling_counts[$u]; $t ++) {
        if (! defined($hash{"Gal.$u.$t"})) {
            print "Gal.$u.$t\n";
        }
    } # for t
} # for u
#--------------------------------
__DATA__
Gal.1.1
Gal.1.10
Gal.1.11
Gal.1.2
