#!perl
# 2021-05-05, Georg Fischer

use strict;
use integer;

my $n = 0;

my $f1 = 2; 
my $f2 = 2; 
my $f3 = 1; 

for (my $n = 4; $n < 40; $n++) {
	print "$n " . &next_seq() . "\n";
}
sub next_seq() { 
	my $f = $f1 + $f2 / 2; 
	$f1 = $f2; 
	$f2 = $f3; 
	$f3 = $f; 
	return $f; 
}

__DATA__
int f1 = 2; int f2 = 2; int f3 = 1; int next_seq() { int f = f1 + f2/2; f1 = f2; f2 = f3; f3 = f; return f; }

f:= gfun:-rectoproc({a(n)=a(n-3) + floor(a(n-2)/2), 
a(1)=2, a(2)=2, a(3)=1}, a(n), remember): map(f, [$1..40]);
RecurrenceTable[{a[n] == a[n-3] + Floor[a[n-2]/2], a[1] == 2, a[2] == 2, a[3] == 1}, a, {n,1,70}] (* _Georg Fischer_, May 05 2021 *)
