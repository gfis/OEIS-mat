#!perl

my @months = qw(January February March April May June July August September October November December);
my @weekdays = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
my $letters = "abcdefghijklmnopqrstuvwxyz";
my %mc = ();
my %wc = ();

my $mo = join("", map { lc } @months);
my $we = join("", map { lc } @weekdays);

foreach my $key (split(//, $letters)) {
	$mc{$key} = 0;
} # foreach
map { my $letter = $_;
	$mc{$letter} ++;
} split(//, $mo);
foreach my $key (split(//, $letters)) {
	print "$mc{$key}, ";
} # foreach
print "\n";

foreach my $key (split(//, $letters)) {
	$mc{$key} = 0;
} # foreach
map { my $letter = $_;
	$mc{$letter} ++;
} split(//, $we);
foreach my $key (split(//, $letters)) {
	print "$mc{$key}, ";
} # foreach
print "\n";
