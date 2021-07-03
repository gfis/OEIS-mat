# Patch the initial terms for CC=binomin
# 2021-05-08, Georg Fischer: copied from binomin.pl
#
#:# Usage:
#:#   perl binomin_patch.pl [-d debug] binomin2.tmp > binomin3.tmp
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my ($aseqno, $callcode, $offset, @parms);
my $debug   = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) { # seq4 format
    next if ! m{\AA\d\d+}; # no aseqno
    s/\s+\Z//; # chompr
    $line = $_;
    ($aseqno, $callcode, @parms) = split(/\t/, $line);
    $offset = $parms[0];
    $parms[4] = "";
    $parms[2] = "[" . join(",", splice(@terms, 0, $ind + 2)) . "]";
    print join("\t", $aseqno, $callcode, @parms) . "\n"; 
} # while <>
__DATA__
a(n) = c^(n^2) + e*d^n
a(n) = f(c,n) + e*d^n
a(n-1) = f(c,n-1) + e*d^(n-1)
(a(n) - f(c,n)) / (e*d) = e*d^(n-1)
a(n-1) - f(c,n-1) = e*d^(n-1)
(a(n) - f(c,n)) / (e*d) = a(n-1) - f(c,n-1)
a(n) - f(c,n) = e*d*a(n-1) - e*d*f(c,n-1)
a(n) = e*d*a(n-1) - e*d*f(c,n-1) + f(c,n)

f(c,n-1) = c*f(c,n)/c^(2*n)
f(c,n) = f(c,n-1)*c^(2*n-1)
f(c,n-1) = f(c,n-2)*c^(2*n-3)

a(n) = e*d*a(n-1) - e*d*f(c,n-1) + f(c,n-1)*c^(2*n-1)
a(n) = e*d*a(n-1) + f(c,n-1)*(c^(2*n-1) - e*d)*
a(n-1) = e*d*a(n-2) + f(c,n-2)*(c^(2*n-3) - e*d)*
a(n) = e*d*a(n-1) + f(c,n-2)*c^(2*n-3)*(c^(2*n-1) - e*d)*

(a(n-1) - e*d*a(n-2))/(c^(2*n-3) - e*d)           = f(c,n-2)
(a(n) - e*d*a(n-1))/(c^(2*n-3)*(c^(2*n-1) - e*d)) = f(c,n-2)
(a(n) - e*d*a(n-1)) / (c^(2*n-3)*(c^(2*n-1) - e*d)) = (a(n-1) - e*d*a(n-2)) / (c^(2*n-3) - e*d)

(a(n) - e*d*a(n-1)) * (c^(2*n-3) - e*d) = (a(n-1) - e*d*a(n-2)) * (c^(2*n-3)*(c^(2*n-1) - e*d))


A120767	binom1	0	2^(n^2)+3^n	N								
A120767	binom2	0	2^(n^2)+3^n	t								
A120767	binom4	0	2^(n^2)+3^n	o								
A120773	binom1	0	2^(n^2)-3^n	N								
A120773	binom2	0	2^(n^2)-3^n	t								
A120798	binom1	0	3^(n^2)+2^n	N								
A120798	binom2	0	3^(n^2)+2^n	t								
A120798	binom4	0	3^(n^2)+2^n	o								
A120799	binom1	0	3^(n^2)-2^n	N								
A120799	binom3	0	3^(n^2)-2^n	t								
A120799	binom5	0	3^(n^2)-2^n	o								
A120800	binom1	0	3^(n^2)+2^(n^2)	N								
A120801	binom1	0	3^(n^2)-2^(n^2)	N								
A120801	binom2	0	3^(n^2)-2^(n^2)	t								
A120802	binom1	0	5^(n^2)+3^n	N								
A120802	binom3	0	5^(n^2)+3^n	t								
A120830	binom1	0	5^(n^2)-3^n	N								
A120830	binom2	0	5^(n^2)-3^n	t								
A120838	binom1	0	5^(n^2)+3^(n^2)	N								
A120838	binom2	0	5^(n^2)+3^(n^2)	t								
A120838	binom4	0	5^(n^2)+3^(n^2)	o								
A120840	binom1	0	5^(n^2)-3^(n^2)	N								
A120840	binom3	0	5^(n^2)-3^(n^2)	t								
A120840	binom5	0	5^(n^2)-3^(n^2)	o								
