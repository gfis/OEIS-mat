#!perl
# Generate for A069378: n x 3 bin, path from top row to bottem
# 2022-02-01, Georg Fischer
use strict;
use warnings;
use integer;

my $count = 0;
for (my $row0 = 1; $row0 <= 7; $row0 ++) {
for (my $row1 = 1; $row1 <= 7; $row1 ++) {
for (my $row2 = 1; $row2 <= 7; $row2 ++) {
	if ((($row0 & $row1) != 0) && (($row2 & $row1) != 0)) {
		++$count;
	}
} # row2
} # row1
} # row0
print "count=$count\n";
__DATA__
result = 205
missing:
1x0
101
0x1 => 4

and 
0x1
101
1x0 => 4

205 - 8 = 197 is a(3)!
