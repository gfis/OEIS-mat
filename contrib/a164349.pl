my $ab = "10"; for (my $j = 1; $j < 30; $j++) { $ab .= $ab; substr $ab, -1, 1, ""; print "$ab\n"; }
