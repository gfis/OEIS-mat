#!perl

# Regenerate parameters for HolonomicRecurrence from jOEIS source files
# @(#) $Id$
# 2019-12-27: Generating with offset
# 2019-12-22, Georg Fischer
#
#:# Usage:
#:#   perl holregen.pl aseqnos.lst > holregen.tmp
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my %ZNUM = qw(
    ZERO    0
    ONE     1
    NEG_ONE -1
    TWO     2
    THREE   3
    FOUR    4
    FIVE    5
    SIX     6
    SEVEN   7
    EIGHT   8
    NINE    9
    TEN     10
    );
my $srcpath = "../../joeis/src/irvine/oeis";
my $debug  = 0;
my $ainit  = 0; # additional initial terms
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{a}) {
        $ainit  = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
    if (m{\A(A\d+)\s+(\w+)\s+(\d+)\s+(\d+)}) { # starts with A-number superclass
        my $aseqno     = $1;
        my $superclass = $2;
        my $offset1    = $3;
        my $offset2    = $4;
        &check($aseqno, $superclass, $offset1, $offset2);
    } # if starts with A-number
} # while <>

sub check {
    my ($aseqno, $superclass, $offset1, $offset2) = @_;
    my $group = lc(substr($aseqno, 0, 4));
    my $filename = "$srcpath/$group/$aseqno.java";
    open(SRC, "<", $filename) or die "cannot read \"$filename\"; superclass=$superclass, offset1=$offset1, offset2=$offset2\n";
    my @lines  = ();
    my $lstart = -1;
    my $super  = "";
    my $author = "";
    while (<SRC>) {
        my $line = $_;
        $line =~ s{\s+\Z}{}; # chompr
        push(@lines, $line);
        if (0) {
        } elsif ($line =~ m{super\s*\((.*)}) {
            $lstart = scalar(@lines) - 1;
            $super  = $1;
        } elsif ($line =~ m{\@author\s+(.*)}) {
            $author = $1;
        }
    } # while <SRC> 
    close(SRC);
    if (0) {
    } elsif ($author =~ m{Sean} ) {
        $author = "sair";
    } elsif ($author =~ m{Georg}) {
        $author = "gfis";
    } else { 
        $author = "undef";
    }
    while ($super !~ m{\;}) { # super() not terminated
        $lstart ++;
        $super .= $lines[$lstart];
    } # while $super
    if ($super !~ m{ring|polynomial|create|den}i) { # not manually modified
        $super =~ s{\s}{}g;
        $super =~ s{super\(}{};
        $super =~ s{\)\;}{};
        $super =~ s{new\s*(long|Z)\[\]\s*}{}g;
        $super =~ s{Z\.([A-Z_]+)}{$ZNUM{$1}}g;
        $super =~ s{L}{}g; # no long constants
        $super =~ s{Z\.valueOf\((\-?\d+)\)}{$1}g;
        $super =~ s{new\s*Z\(\"(\-?\d+)\"\)}{$1}g;
        if (0) { # switch for superclass
        } elsif ($superclass =~ m{^Cox} ) {
            $super =~ s{\s*\,\s*}{\t}g;
            $super = "$offset1\t$super\t0\t$offset2";
        } elsif ($superclass =~ m{^Gener}) {
            $super =~ s{\}\,\s*}{\t}g;
            $super =~ s{\,\s*\{}{\t}g;
            $super =~ s{[\{\}]}{}g;
            my @parms = split(/\t/, $super);
            # print "G.F.: \"" . join("\",\"", @parms) . "\"\n";
            if (scalar(@parms) == 2) { # without offset
                $super = "$offset1\t$super";
            }
            $super .= "\t0\t$offset2"; # offset1, nums, dens, dist, offset2
        } elsif ($superclass =~ m{^Holo}  ) {
            $super =~ s{\"\,\s*\"}{\t};
            $super =~ s{\,\s*\"}{\t};
            $super =~ s{\"\,\s*}{\t};
            $super .= "\t$offset2";
        } elsif ($superclass =~ m{^Linear}) {
            $super =~ s{\}\,\s*}{\t}g;
            $super =~ s{\,\s*\{}{\t}g;
            $super =~ s{[\{\}]}{}g;
            my @parms = split(/\t/, $super);
            if (scalar(@parms) == 3) { # preTerms at the end
                $parms[1] = "$parms[2],  $parms[1]"; # put them before the initTerms
            }
            my @sigs = split(/\,\s*/, $parms[0]); # joeis signatures are already reversed from OEIS signatures
            $super = join("\t"
                , $offset1
                , "[0," . join(",", @sigs) . ",-1]"
                , "[" . $parms[1] . "]"
                , 0
                , $offset2
                );
        }
        print join("\t", ($aseqno, "holos", $super, $superclass, $author)) . "\n";
    } # not manually modified
} # check
__DATA__
#---------------------------------
  /**
   * Constructor for a Coxeter group sequence.
   * This corresponds with the Mathematica routine <code>coxG</code>
   * defined in OEIS <a href="https://oeis.org/A169452">A169452</a>:
   * <pre>
   * coxG[{pwr_, c1_, c2_, trms_:20}]:=Module[{
   * num=Total[2t^Range[pwr-1]]+t^pwr+ 1,
   * den=Total[c2*t^Range[pwr-1]]+c1*t^pwr+1},
   * CoefficientList[ Series[ num/den, {t, 0, trms}], t]];
   * coxG[{33, 15, -5, 30}]
   *
   * G.f.: (t^33 + 2*t^32 + 2*t^31 + 2*t^30 + 2*t^29 + 2*t^28 + 2*t^27 + 2*t^26
   * + 2*t^25 + 2*t^24 + 2*t^23 + 2*t^22 + 2*t^21 + 2*t^20 + 2*t^19 + 2*t^18
   * + 2*t^17 + 2*t^16 + 2*t^15 + 2*t^14 + 2*t^13 + 2*t^12 + 2*t^11 + 2*t^10
   * + 2*t^9 + 2*t^8 + 2*t^7 + 2*t^6 + 2*t^5 + 2*t^4 + 2*t^3 + 2*t^2 + 2*t + 1)/
   * (15*t^33 - 5*t^32 - 5*t^31 - 5*t^30 - 5*t^29 - 5*t^28 - 5*t^27 - 5*t^26
   * - 5*t^25 - 5*t^24 - 5*t^23 - 5*t^22 - 5*t^21 - 5*t^20 - 5*t^19 - 5*t^18
   * - 5*t^17 - 5*t^16 - 5*t^15 - 5*t^14 - 5*t^13 - 5*t^12 - 5*t^11 - 5*t^10
   * - 5*t^9 - 5*t^8 - 5*t^7 - 5*t^6 - 5*t^5 - 5*t^4 - 5*t^3 - 5*t^2 - 5*t + 1).
   * </pre>
   * @param pwr largest exponent in the g.f. and of <code>(S_i S_j)</code> in the name,
   * @param c1 first coefficient in the denominator of the g.f.,
   * <code>= triangular(-c2) = binomial(-c2 + 1, 2)</code>
   * @param c2 second coefficient in the denominator of the g.f.,
   * = 2 - (numbers of generators in the name)
   */
  public CoxeterSequence(final int pwr, final Z c1, final Z c2) {

package irvine.oeis.a170;
// Generated by gen_pattern.pl - DO NOT EDIT here!

import irvine.oeis.CoxeterSequence;

/**
 * A170731 Number of reduced words of length n in Coxeter group on 50 generators <code>S_i</code> with relations <code>(S_i)^2 = (S_i S_j)^50 =</code> I.
 * @author Georg Fischer
 */
public class A170731 extends CoxeterSequence {

  /** Construct the sequence. */
  public A170731() {
    super(
      50,
      50);
  }
}
#---------------------------------
Conjectures from Colin Barker, Jan 20 2016 and Apr 17 2019: (Start)
a(n) = 3*a(n-1)+14*a(n-2)-48*a(n-3)+32*a(n-4) for n>4.
G.f.: (1-16*x^2+32*x^3-32*x^4) / ((1-x)*(1-2*x)*(1-4*x)*(1+4*x)).
(End)

1-3x-14x^2+48x^3-32x^4

package irvine.oeis.a263;
// Generated by gen_pattern.pl - DO NOT EDIT here!

import irvine.oeis.GeneratingFunctionSequence;

/**
 * A263806 Decimal representation of the n-th iteration of the "Rule <code>157"</code> elementary cellular automaton starting with a single ON (black) cell.
 * @author Georg Fischer
 */
public class A263806 extends GeneratingFunctionSequence {

  /** Construct the sequence. */
  public A263806() {
    super(0, new long[] {1, 0, -16, 32, -32},
      new long[] {1, -3, -14, 48, -32});
  }
}
#----------------------
package irvine.oeis.a116;
// Generated by gen_seq4.pl holos [0,-2,5,-4,1] [0,2,9,25] 0 at 2019-12-17 15:30
// DO NOT EDIT here!

import irvine.oeis.HolonomicRecurrence;

/**
 * A116454 Smallest m such that <code>A116452(m) = n</code>.
 * @author Georg Fischer
 */
public class A116454 extends HolonomicRecurrence {

  /** Construct the sequence. */
  public A116454() {
    super(1, "[0,-2,5,-4,1]", "[0,2,9,25]", 0);
  }
}
#---------------------------------
# A072478   0   -2,0,3,0    8,1,16,1}   0,2,2,4,2   LinearRecurrence    gfis

The signature in LinearRecurrence is the reverse of the OEIS signature (2,-1,2,-4,2,-1,2,-1).
# A038621 LinearRecurrence with 3 parameters (preTerms is 3rd)
# 1, 4, 10, 22, 46, 81, 129, 198, 284, 392, 530, 691, 883, 1114, 1374, 1674, 2022
# G.f. (x+1)*(2*x^8-4*x^7+3*x^6-x^5+6*x^4+2*x^3+2*x^2+x+1) / ((x-1)^4*(x^2+x+1)^2)
# NUM = 1 + 2*x + 3*x^2 + 4*x^3 + 8*x^4 + 5*x^5 + 2*x^6 - x^7 - 2*x^8 + 2*x^9 
# DEN = 1-2x+x^2-2x^3+4x^4-2x^5+x^6-2x^7+x^8
package irvine.oeis.a038;
// Generated by gen_linrec.pl - DO NOT EDIT here!

import irvine.oeis.LinearRecurrence;

/**
 * A038621 Growth function of an infinite cubic graph (number of nodes at distance &lt;=n from fixed node). 
 * @author Georg Fischer
 */
public class A038621 extends LinearRecurrence {

  /** Construct the sequence. */
  public A038621() {
    super(new long[] {-1L, 2L, -1L, 2L, -4L, 2L, -1L, 2L}, new long[] {10L, 22L, 46L, 81L, 129L, 198L, 284L, 392L}, new long[] {1L, 4L});
  } // constructor()
} // A038621
#---------------------------------
package irvine.oeis.a029;

import irvine.oeis.LinearRecurrence;

/**
 * A029239 Expansion of <code>1/((1-x^2)*(1-x^8)*(1-x^10)*(1-x^11))</code>.
 * @author Sean A. Irvine
 */
public class A029239 extends LinearRecurrence {

  /** Construct the sequence. */
  public A029239() {
    super(new long[] {-1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, -1, -1, 0, 0, 0, 0, -1, -1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0}, new long[] {1, 0, 1, 0, 1, 0, 1, 0, 2, 0, 3, 1, 3, 1, 3, 1, 4, 1, 5, 2, 6, 3, 7, 3, 8, 3, 9, 4, 10, 5, 12});
  }
}

C:\Users\User\work\gits\OEIS-mat\holrec>