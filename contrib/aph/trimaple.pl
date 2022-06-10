#!perl

# Generate a triangle program from Maple
# @(#) $Id$
# 2022-05-09, Georg Fischer
#
#:# Usage:
#:#     perl trimaple.pl [-m {t|u}] [-a aseqno] [-d debug] [-i num] procb.tmp > aseqno.java 2> tricol.man
#:#         -a A-number to be generated
#:#         -d mode: debugging, 0=none, 1=some, 2=more
#:#         -i MemoryFunctionInt<i>
#:#         -m mode: t=Triangle, U=UpperLeftTriangle
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $mode = "t";
my $intb = 3; # MemoryFunctionInt3
my $aseqno = "A000000";
my $basedir   = "../../common";
my $litedir   = "../../../joeis-lite/internal/fischer";
my $namesfile = "$basedir/names";

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{a}) {
        $aseqno    = shift(@ARGV);
        $aseqno =~ s{\D*(\d+)}{$1};
        $aseqno = sprintf("A%06d", $aseqno);
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{i}) {
        $intb      = shift(@ARGV);
    } elsif ($opt  =~ m{[ut]}) {
        $mode      = $opt;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $pattern = <<'GFis'; # this program does not really work
package irvine.oeis.a075;

import irvine.math.MemoryFunctionInt2;
import irvine.math.factorial.MemoryFactorial;
import irvine.math.z.Binomial;
import irvine.math.z.Z;
import irvine.oeis.triangle.Triangle;

/**
 * A075196 Table T(n,k) by antidiagonals: T(n,k) = number of partitions of n balls of k colors.
 * @author Georg Fischer
 */
public class A075196 extends Triangle {

  /** Construct the sequence. */
  public A075196 () {
    super(1, 1, -1);
    hasRAM(true);
  }

  /* Maple:
  private final MemoryFunctionInt2<Z> mB = new MemoryFunctionInt2<Z>() {
    @Override
    protected Z compute(final int n, final int k) {
      if (n == 0) {
        return Z.ONE;
      }
      Z sum = Z.ZERO;
      for (int j = 1; j <= n; ++j) {
        sum = sum.add(get(n - j, k).multiply(Integers.SINGLETON.sumdiv(j, d -> Binomial.binomial(d + k - 1, k - 1).multiply(d))));
      }
      return sum;
    }
  };
 
  @Override
  protected Z compute(final int n, final int k) {
    return mB.get(n, k);
  }
}
GFis
# end of pattern

my $apack = lc(substr($aseqno, 0, 4));
my $tarfile = "$litedir/park/$aseqno.java";
open(TAR, ">", $tarfile) || die "cannot write \"$tarfile\"\n";
my $manfile = "$litedir/$aseqno.man";
open(MAN, ">", $manfile) || die "cannot write \"$manfile\"\n";
print MAN "# $timestamp dependants of $aseqno:\n";
# get the target's name
my $tarname = `grep -E \"^$aseqno\" $namesfile`;
$tarname =~ s{\s+}{ }g; # replace (multiple) whitespace by 1 space
$tarname =~ s{\s+\Z}{}; # chompr
$tarname =~ s{\&}{\&amp;}g; # HTML encoding
$tarname =~ s{\<}{\&lt;}g;
$tarname =~ s{\>}{\&gt;}g;
$tarname =~ s{\'}{\&apos;}g;
$tarname =~ s{\"}{\&quot;}g;

$pattern =~ s{package irvine\.oeis\.(a\d+)}{package irvine\.oeis\.$apack};
$pattern =~ s{\/\*\*[^\@]+\@}{\/\*\*\n \* $tarname\n \* \@};
$pattern =~ s{A075196}{$aseqno}g;
my $line;
my $maple = "";
my $xref = "";
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if ($line =~ m{\A\%(\w) $aseqno (.*)}) { # proper aseqno
        my ($type, $rest) = ($1, $2);
        if (0) { # switch type
        } elsif ($type eq "p") {
            $maple .= "    $rest\n";
        } elsif ($type eq "Y") {
            print MAN "# $line\n";
            $rest =~ s{\A([^A]*)}{};
            $xref = $1;
            my $comment = "",
            my $icol = 0;
            if ($xref =~ m{Columns *(\w *\= *)?(\d+)}) {
                $xref = "";
                $icol = $2;
            } else {
                $comment = "# ";
            }
            $xref =~ s{gives?}{};
            $xref =~ s{\s+\Z}{};
            foreach my $ano ($rest =~ m{(A\d+)}g) {
                print MAN join("\t", "$comment$ano", ($mode eq "t" ? "trionk" : "arronk"), 0, $aseqno, 0, "mN", $icol ++, $xref) . "\n",
            }
        } # type
    } # proper 
} # while

$maple =~ m{proc\((\w(\, *\w)*)*};
my @fparms = split(/\, */, $1);
$intb = scalar(@fparms);
$pattern =~ s{Int3}{Int$intb}g;

if ($maple =~ m{\WA *\:\=}) {
    $mode = "u";
}
if ($mode eq "u") {
    $pattern =~ s{Triangle}{UpperLeftTriangle}g;
    $pattern =~ s{public matrixElement}{protected compute};
}
$maple = "  /* Maple:\n$maple  \*\/\n";
$pattern =~ s{  \/\* Maple\:\n}{$maple};
print TAR $pattern;
close(TAR);
close(MAN);
print `cmd /c start \"C:\\Program Files (x86)\\Google\\Chrome\\Application\" https://oeis.org/$aseqno`;
print `uedit64 \"$manfile\" \"$tarfile\"`;
#--------------------------------------------
__DATA__
%p A318754 g:= proc(n, i, k) option remember; `if`(n=0, 1, `if`(i<1, 0, add(
%p A318754       binomial(g(i-1$2, k)+j-1, j)*g(n-i*j, i-1, k), j=0..min(k, n/i))))
%p A318754     end:
%p A318754 T:= (n, k)-> g(n-1$2, k) -`if`(k=0, 0, g(n-1$2, k-1)):
%p A318754 seq(seq(T(n, k), k=0..n-1), n=1..14);
%Y A318754 Columns k=0-10 give: A063524, A032305 (for n>1), A318817, A318818, A318819, A318820, A318821, A318822, A318823, A318824, A318825.
%Y A318754 Row sums give A000081.
%Y A318754 T(2n+2,n+1) give A255705.
%Y A318754 Cf. A318753.
%A A318754 _Alois P. Heinz_, Sep 02 2018
