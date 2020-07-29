#!perl

use strict;
use integer;
use warnings;

my $base = shift(@ARGV);
while (<DATA>) {
    s{\s}{}g;
    my $line = $_;
    my @terms = map {
        my $num = $_; &to_base($num)
    } split(/\D+/, $line);
    print join("\t", @terms) . "\n";
} # while <DATA>
#--------
sub to_base { # convert from decimal to base
    my ($num)  = @_;
    my $result = "";
    while ($num > 0) {
        my $digit = $num % $base;
        $result =  $digit . $result;
        $num /= $base;
    } # while > 0
    return $result eq "" ? "0" : $result; 
} # to_base
__DATA__
    4;
    13,    13;
    40,   122,     40;
   121,  1042,   1042,    121;
   364,  8683,  23544,   8683,   364;
  1093, 72271, 510835, 510835, 72271, 1093;