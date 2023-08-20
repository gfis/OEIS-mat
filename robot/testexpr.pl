#!perl

use strict;
my   $expr = "(n-k)^(2*(n-k))";

if ($expr =~ m{([a-z]|\d+)\*}) {
	print "ok1\n";
}
if ($expr =~ m{([a-z]|\d+)\*\(([a-z]|\d+)([\+\-])}) {
	print "ok2\n";
}
if ($expr =~ m{([a-z]|\d+)\*\(([a-z]|\d+)([\+\-])([a-z]|\d+)\)}) {
	print "ok3\n";
}

    #          1     12         2    3         34      45         5
    $expr =~ s{([^\-])([a-z]|\d+)\*\(([a-z]|\d+)([\+\-])([a-z]|\d+)\)} {$1$2\*$3$4$2\*$5}g;	# k*(n-3) -> k*n-k*3
print "$expr\n";
