#!perl

# A337663 - stepping stone puzzle solutions
# 2020-10-08, Georg Fischer

use strict;
use warnings;
use integer;

my $primex = 0;
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{p}) {
        $primex    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my %plane = ();
foreach my $pair (@ARGV) { # set ones
    $pair =~ s{[^\d\,\-]}{}g; # remove brackets, spaces etc.
    $plane{$pair} = 1;
} # set ones
&draw("initial ones set");

my $next = 2;
my @queue = &possible($next);
if ($debug >= 1) {
	print "possible 2: " . join("; ", @queue) . "\n";
	exit();
}
my $busy = 1;
while ($busy) { # the backtracking loop
	while (scalar(@queue) > 0) { # queue not empty
		my $assign = shift(@queue);
		my ($pair, $val) = split(/\=/, $assign);
		$plane{$pair} = $val;
	} # while queue not empty
} # while backtracking
#----
sub possible { # determine the possible positions for a number
	my ($num) = @_;
	my %empty = ();
	foreach my $pair (keys(%plane)) { # determine the surrounding empty fields
	    my ($x, $y) = split(/\,/, $pair);
        for (my $dx = -1; $dx <= 1; $dx ++) {
        	for (my $dy = -1; $dy <= 1; $dy ++) {
        		if ($dx != 0 || $dy != 0) {
        		    my $pos = ($x + $dx) . "," . ($y + $dy);
        	        if (! defined($plane{$pos})) {
					    if ($debug >= 2) {
	    					print "empty for $num: $pos; dx=$dx, dy=$dy, pair=$pair\n";
    					}
        		        $empty{$pos} = 1;
        	        }
        	    }
        	} # for $dy
        } # for $dx
    } # foreach $pair

    my @result = ();
    foreach my $pair (keys(%empty)) { # determine sum of fields surrounding the empty field
	    my ($x, $y) = split(/\,/, $pair);
        my $sum = 0;
        for (my $dx = -1; $dx <= 1; $dx ++) {
        	for (my $dy = -1; $dy <= 1; $dy ++) {
        		if ($dx != 0 || $dy != 0) {
        		    my $pos = ($x + $dx) . "," . ($y + $dy);
        	        if (defined($plane{$pos})) {
        		        $sum += $plane{$pos};
        	        }
        	    }
        	} # for $dy
        } # for $dx
        if ($sum == $num) {
        	push(@result, "$pair=$num");
        }
    } # foreach $pair
    return @result;
} # possible
#----
sub draw { # draw the configuration
	my ($text) = @_;
	print "-" x 32;
	print "\n$text\n";
	my @limx = (0,0);
	my @limy = (0,0);
	my @matrix = ();
	foreach my $pair (keys(%plane)) { # determine min and max x, y
		my ($x, $y) = split(/\,/, $pair);
		if ($x < $limx[0]) { $limx[0] = $x; } elsif ($x > $limx[1]) { $limx[1] = $x; }
		if ($y < $limy[0]) { $limy[0] = $y; } elsif ($y > $limy[1]) { $limy[1] = $y; }
    } # foreach min, max
    my $width  = $limx[1] - $limx[0] + 1;
    my $height = $limy[1] - $limy[0] + 1;
	foreach my $pair (keys(%plane)) { # determine min and max x, y
	    my ($x, $y) = split(/\,/, $pair);
		$matrix[$y - $limx[0]][$x - $limx[0]] = $plane{$pair};
    } # foreach min, max
    for (my $y = 0; $y < $height; $y ++) {
        for (my $x = 0; $x < $width;  $x ++) {
            print sprintf("%3s", defined($matrix[$y][$x]) ? $matrix[$y][$x] : ".");
        } # for x
        print "\n";
    } # for y
} # draw
__DATA__
