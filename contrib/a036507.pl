# 
# nsmall = Table[Infinity, 20];
# For[i = 0, i <= 4*10^3, i++, n0 = Count[IntegerDigits[i^2], 0];
#   If[nsmall[[n0]] > i^2, nsmall[[n0]] = i^2]];
# ReplaceAll[nsmall, Infinity -> "?"]
# 

use strict;
my $digit = 0;
my $n = 0;
while (1) {
    my $square = $n**2;
    my $count = scalar($square =~ m{($digit)}g);
    if ($count == 
    print "$square, ";
  