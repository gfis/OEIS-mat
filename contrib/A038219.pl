# from Remy Sigrist
$| = 1;

# Ehrenfeucht-Mycielski sequence in reverse order
my $sequence = "";

foreach my $n (1..10000000) {
	my $ext;
	if ($n==1) {
		$ext = "0";
	} elsif ($n==2) {
		$ext = "1";
	} elsif ($n==3) {
		$ext = "0";
	} else {
		foreach my $w (1..length($sequence)) {
			if (index($sequence, substr($sequence, 0, $w+1), 1)<0) {
				my $suffix = substr($sequence, 0, $w);
				my $last = index($sequence, $suffix, 1);
				if (substr($sequence, $last-1, 1) eq "0") {
					$ext = "1";
				} else {
					$ext = "0";
				}
				last;
			}
		}
	}
	print "$ext\n";
	$sequence = $ext . $sequence;
}
