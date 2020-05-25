#!perl
# Divide all terms in the input lines by a common factor
# 2020-05-24, Georg Fischer
# 
use strict;
use warnings;
use integer;

my $divisor = shift(@ARGV);
while (<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    print join(",", map {$_ / $divisor} split(/\,/, $line)) . "\n";
} # while <>

