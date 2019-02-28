#!perl

# Run linhrec.jar through stripped
# 2019-02-18, Georg Fischer

use strict;
use integer; 

while (<>) {
    s{\s+\Z}{}; # chompr;
    next if ! m{^A\d};
    my ($aseqno, $list) = split(/\s+\,/, $_);
    $list =~ s{\,\Z}{}; # remove trailing comma
    my @terms = split(/\,/, $list);
    @terms = splice(@terms, 0, 16);
    $list = join(",", @terms);
    print "$aseqno: $list => " . `java -jar linhrec.jar \"$list\"`;
} # while <>
