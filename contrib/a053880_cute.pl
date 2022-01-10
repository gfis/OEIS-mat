#!perl

# A053880 ff.: Squares with 3 digits; here: 1 2 4
# 2022-01-09, Georg Fischer

use strict;
use integer;

my $sample  = "124"; # A053880
my $debug   = 0;
my $verbose = 0;
my $nozero  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-s}  ) {
        $sample     = shift(@ARGV);
    } elsif ($opt   =~ m{\-v}  ) {
        $verbose    = shift(@ARGV);
    } elsif ($opt   =~ m{\A\d}  ) {
        $sample     = shift(@ARGV);
    } elsif ($opt   =~ m{-z}  ) {
        $nozero     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @olds = ();
for (my $dig = 0; $dig < 10; $dig ++) {
    if ((($dig * $dig) % 10) =~ m{\A[$sample]+\Z}o) {
        push(@olds, $dig);
    }
}
print "# digits: $sample, start with " . join(",", @olds) . "\n";
my @news = ();
my $len = 1;
my $add1 = 10;
my $mod = 100;
my $index = 0;
for (my $exp = 0; $exp < 12; $exp ++) {
    my $add = $add1;
    foreach my $dig (1..9) {
      foreach my $n (@olds) {
          my $cand = $add + $n;
          my $cand2 = $cand * $cand;
          if (($cand2 % $mod) =~ m{\A[$sample]+\Z}o) {
              push(@news, $cand);
              if ($verbose) {
                  print "$cand $cand2";
                  if ($cand2  =~ m{\A[$sample]+\Z}o) {
                      print " **";
                  }
                  print "\n";
              } else {
                  if ($cand2  =~ m{\A[$sample]+\Z}o) {
                      ++$index;
                      print "$index $cand # $cand2\n";
                  }
              }
          }
      } # foreach $n
      $add += $add1;
    } # foreach $dig
    @olds = @news;
    @news = ();
    $add1 *= 10;
    $mod *= 10;
} # for $exp

