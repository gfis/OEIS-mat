use ntheory ":all";
my($n, $k, $i, @v)=(10000, 1, 0);
while (@v < $n) {
  push (@v, inverse_totient($k++));
}
$#v = $n-1;
for (@v) {
  ++$i;
  print "$i $_\n";
}
