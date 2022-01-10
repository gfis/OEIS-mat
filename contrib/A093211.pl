use strict;
use integer;

my $divm = shift(@ARGV);
my $n = $divm;
my $last = 10**$n;
my %ssts = ();
my $debug = 0;

sub setgoodlist() {
  my ($len, $adiv) = @_;
  my @btmp = (1,1,1,1,1 ,1,1,1,1,1); # 0..9
  foreach my $i (0..9) {
    my $remain = ($adiv - $i * (10**($len - 1))) % $adiv;
    if (($adiv - 10 * $remain) % $adiv > 9) {
      $btmp[$i] = 0; # remove
    }
  } # for $i
  if ($debug >= 2) { print join(", ", @btmp) . "\n"; }
  return @btmp;
} # sub setgoodlist

sub dropdigs() {
  my ($k, $l) = @_;
  my $ktmp = ($k / $l) * $l;
  $ktmp --;
  while (($ktmp % $divm) != 0) {
    $ktmp --;
  }
  if ($debug >= 2) { print "dropdigs($k,$l) -> $ktmp\n"; }
  return $ktmp;
} # dropdigs

sub walking() {
  my ($k) = @_;
  my $aa = 0;
  my $kt = $k * 10;
  my $ktl = $kt % $last;
  if ((($ktl - 1) % $divm) + 10 < $divm) {
    return $aa;
  }
  my $a;
  if ($ktl % $divm == 0) {
    $a = $kt;
  } else {
    $a = $kt + ($divm - ($ktl % $divm));
  }

  my $al = $a % $last;
  if (! defined($ssts{$al})) {
    $ssts{$al} = 1;
    if ($a > $aa) {
      $aa = $a;
    }
    my $atmp = &walking($a);
    if ($atmp > $aa) {
      $aa = $atmp;
    }
    delete $ssts{$al};
  }
  if ($debug >= 4) {
    print "walking($k) -> $aa\n";
  }
  return $aa;
} # walking

for ($n = 2; $n < 12; $n ++) { # main loop
  my @goodlist = &setgoodlist($n, $divm);
  $last = 10**$n;
  my $beg = '9' x $n;
  my $end = '9' x ($n-1);
  if ($debug >= 2) { print "n=$n, beg=$beg, end=$end\n"; }
  my $i = $beg;
  while ($i % $divm != 0) {
    $i -= 1;
  }
  my $an = $i;
  my $oldan = $an;
  my $anlen = $n;
  while ($i > $end) {
    %ssts = ($i, 1);
    if ($i % 100000 == 0) {
      $anlen = length($an);
      if ($anlen > 2*$n) {
        $anlen = 2*$n - 1;
      }
    }
    my $wi = &walking($i);
    if ($wi > $an) {
      $an = $wi;
    }
    $i -= $divm;
    for (my $j = 0; $j < $anlen - $n + 1; $j ++) {
      my $jten = 10 ** ($n - $j - 1);
      if ($jten < 1) {
        last;
      }
      while ($goodlist[($i / $jten) % 10] == 0) {
        $i = &dropdigs($i, $jten);
      }
    } # for j
  } # while i
  print "$n $an\n";
} # main loop
