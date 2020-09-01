#!perl

# Generate Mersenne prime numbers and a Wiki table for them
# @(#) $Id$
# 2019-03-19, Georg Fischer: copied from ../bfcheck/bfanalyze.pl
#
#:# usage:
#:#   perl mersenne.pl > table.wiki
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my %anum; # this is some manual work:
$anum{ 1} = "A000668"; # 2^2-1
$anum{ 2} = "A000668"; # 2^3-1
$anum{ 3} = "A000668"; # 2^5-1
$anum{ 4} = "A000668"; # 2^7-1, ancient greeks
$anum{ 5} = "A000668"; # 2^13-1, 1456 anonymous
$anum{ 6} = "A000668"; # 2^17-1, 1588 Pietro Cataldi
$anum{ 7} = "A000668"; # 2^19-1, 1588 Pietro Cataldi
$anum{ 8} = "A000668"; # 2^31-1, 1722 Leonhard Euler
$anum{ 9} = "A000668"; # 2^61-1
$anum{10} = "A000668"; # 2^89-1
$anum{11} = "A000668, A169684"; # 2^107-1, A169684 Decimal expansion of 2^107 - 1.
$anum{12} = "A000668, A169681"; # 2^127-1, A169681 Decimal expansion of 2^127-1
$anum{13} = "A000668, A169685"; # 2^521 - 1
$anum{14} = "A000668, A204063"; #
$anum{15} = "A000668, A248931"; #
$anum{16} = "A000668, A248932"; #
$anum{17} = "A000668, A248933"; #
$anum{18} = "A000668, A248934"; #
$anum{19} = "A248935"; #
$anum{20} = "A248936"; #
$anum{21} = "A275977"; #
$anum{22} = "A275979"; #
$anum{23} = "A275980"; # 2^11213 - 1
$anum{24} = "A275981"; # 2^19937 - 1
$anum{25} = "A275982"; #
$anum{26} = "A275983"; #
$anum{27} = "A275984"; #
$anum{39} = "A089065"; # Digits of the Mersenne prime 2^13466917 - 1.
$anum{40} = "A089578"; # Decimal expansion of the Mersenne prime 2^20996011 - 1.
$anum{41} = ""; #  
$anum{42} = ""; #  
$anum{43} = "A117853"; #  
$anum{44} = "";
$anum{45} = "";
$anum{46} = "";
$anum{47} = "A193864"; #  
$anum{48} = ""; # 57885161
$anum{49} = "A267875"; # ? 2^74207281 - 1.
$anum{50} = ""; # 77232917
$anum{51} = ""; # 82589933

my $head = 105; # print so many leading  digits 
my $tail = 105; # print so many trailing digits 
$head = 16;
$tail = $head;
if (! -r "b000043.txt") { # read all ranked Mersenne prime exponents
    print `wget https://oeis.org/A000043/b000043.txt`;
}
print <<"GFis";
{| class="wikitable" style="text-align:right"
GFis
print &table_head();

open(MP, "<", "b000043.txt") or die "cannot read b000043.txt";
while (<MP>) {
    next if m{\A\s*\#};
    next if m{\A\s*\Z};
    s/\s+\Z//; # chompr
    my ($rank, $exponent) = split;
    # print "$rank\t$exponent\n";
    if (1 <= $rank and $rank <= 65536 ) {
        &evaluate($rank, $exponent);
    }
} # while exponents
close(MP);
print <<"GFis";
|}
GFis
#-----------
sub evaluate {
    my ($rank, $exponent) = @_;
    my $filename = "prime.tmp";
    my $progname = "mersenne.gp.tmp";
    my $buffer;
    my $read_len = 100000000;
    `rm -vf $filename`;
    open(GP, ">", $progname) or die "cannot write $progname";
    print GP "write(\"$filename\", 2^$exponent-1); quit;\n";
    close(GP);
    print `gp -q --default parisize=100000000 $progname`;
    open(FIL, "<", $filename) or die "cannot read $filename\n";
    read(FIL, $buffer, $read_len); # 100 MB, should be less than 10 MB
    substr($buffer, -8) =~ s{\s}{}g;
    my $len = length($buffer); # + "\r\n" on Windows
    $buffer = substr($buffer, 0, $len);
    print "|-\n|" . join("||", $rank, $exponent, $anum{$rank}, $len
        , substr($buffer, 0, $head)
        , substr($buffer, - $tail)
        ) . "\n";
    close(FIL);
} # evaluate
#-----------
sub table_head {
	return "!" . join("!!"
	, "Rank"
	, "2^p-1 <br />A000043" 
	, "OEIS<br />A-number"
	, "# of digits <br />A028335"
	, "First $head digits <br />A135613, A138862, A138864"
	, "Last $head digits  <br />A080172, A080173, A138865"
	) . "\n"; 
} # table_head
#-----------
__DATA__
A080172 Final digit of n-th Mersenne prime A000668(n).
A080173 Final 2 digits of n-th Mersenne prime A000668(n).
A135613 Initial digit of Mersenne primes A000668.
A138841 Concatenation of initial and final digit of n-th Mersenne prime A000668(n).
A138862 First two digits of n-th Mersenne prime A000668(n).
A138863 Concatenation of first two digits and last two digits of n-th Mersenne prime A000668(n).
A138864 First 3 digits of n-th Mersenne prime A000668(n).
A138865 Last 3 digits of n-th Mersenne prime A000668(n).
A138866 Concatenation of first 3 digits and last 3 digits of n-th Mersenne prime A000668(n).
{| class="wikitable" style="text-align:center"
!Name     !! Mnemonic    !! Distance to root  !! Mapping                    !! Condition
|-
| d       || "down"      || -1                || n &#x21a6; n / 2           || n &#x2261; 0 mod 2
|}
A169685 Decimal expansion of 2^521 - 1.
A204063 Decimal expansion of 2^607 - 1, the 14th Mersenne prime A000668(14).
A248931 Decimal expansion of 2^1279 - 1, the 15th Mersenne prime A000668(15).
A248932 Decimal expansion of 2^2203 - 1, the 16th Mersenne prime A000668(16).
A248933 Decimal expansion of 2^2281 - 1, the 17th Mersenne prime A000668(17).
A248934 Decimal expansion of 2^3217 - 1, the 18th Mersenne prime A000668(18).
A248935 Decimal expansion of 2^4253 - 1, the 19th Mersenne prime A000668(19).
A248936 Decimal expansion of 2^4423 - 1, the 20th Mersenne prime A000668(20).
A267875 Decimal expansion of [49th?] Mersenne prime 2^74207281 - 1.
A275977 Decimal expansion of 2^9689 - 1, the 21st Mersenne prime A000668(21).
A275979 Decimal expansion of 2^9941 - 1, the 22nd Mersenne prime A000668(22).
A275980 Decimal expansion of 2^11213 - 1, the 23rd Mersenne prime A000668(23).
A275981 Decimal expansion of 2^19937 - 1, the 24th Mersenne prime A000668(24).
A275982 Decimal expansion of 2^21701 - 1, the 25th Mersenne prime A000668(25).
A275983 Decimal expansion of 2^23209 - 1, the 26th Mersenne prime A000668(26).
A275984 Decimal expansion of 2^44497 - 1, the 27th Mersenne prime A000668(27).

A089065 Digits of the [39th] Mersenne prime 2^13466917 - 1.
A089578 Decimal expansion of the [40th] Mersenne prime 2^20996011 - 1.
A117853 Decimal expansion of 2^30402457-1 [the 43th].
A193864 Decimal expansion of 2^43112609 - 1, the largest known prime number as of 2011.


