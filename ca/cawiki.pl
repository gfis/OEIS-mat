#!perl

# Extract parameters for "inverse binomail transform of"
# 2021-12-19: ca2*
# 2021-12-14: also for Cellular1DAutomaton, WolframAutomata
# 2021-12-09, Georg Fischer: copied from invbinom.pl
#
#:# Usage:
#:#   wget "https://oeis.org/wiki/Index_to_Elementary_Cellular_Automata?action=raw" -O wikind1.raw
#:#   perl wiki_eval1.pl [-d debug] [-m gen] wikind1.raw > seq4.tmp
#:#   perl wiki_eval1.pl [-d debug] -m jpat -x {ElementaryCellularAutomaton|Cellular1DAutomatonCA1|WolframAutomata}
#:#     -d   debugging level (0=none (default), 1=some, 2=more)
#:#     -dim dimension: 1 or 2a, 2b, 2c
#:#     -m   gen  write parameters for all sequences in seq4 format (default); write file astarred.txt in addition
#:#     -m   jpat write jpat files for all applicable callcodes
#
# There are two tables with: spaces, list of rule numbers, A-number list.
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my $mode = "gen";
my $dim  = 1;
my $extends = "Cellular1DAutomaton";
my ($aseqno, $superclass, $callcode, $name, @rest);
my $qseqno = "A130595"; # this multiplied with some sequence as column would give the inverse binomial transform of that sequence
my $rseqno;
my $debug   = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-dim}) {
        $dim        = shift(@ARGV);
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-m}  ) {
        $mode       = shift(@ARGV);
    } elsif ($opt   =~ m{\-x}  ) {
        $extends    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
my @callcodes = qw(
    ca1triangle
    ca1stageb
    ca1staged
    ca1middle
    ca1middleb
    ca1middled
    ca1blackn
    ca1blacks
    ca1whiten
    ca1whites

    ca1lefthalf
    ca1righthalf

    ca2on
    ca2on2n1
    partsum
    diffseq

    ca2leftb
    ca2rightb
    ca2leftd
    ca2rightd

    ca2inb
    ca2outb
    ca2ind
    ca2outd
    );
# must be parallel to @callcodes
my @methods = qw(
    next
    nextStageB
    nextStageD
    nextMiddle
    nextMiddleB
    nextMiddleD
    nextBlackCount
    nextBlackSum
    nextWhiteCount
    nextWhiteSum

    nextLeftHalf
    nextRightHalf

    nextOn
    nextOn2n1
    partsum2
    diffseq2

    nextLeftOriginB
    nextOriginRightB
    nextLeftOriginD
    nextOriginRightD

    nextCornerOriginB
    nextOriginCornerB
    nextCornerOriginD
    nextOriginCornerD
    );
# offsets of callcodes/methods per $dim
my %dists = qw(
    1   0
    man 10
    2a  12
    2b  16
    2c  20
    );

my $rulelist;
my $anumlist;
my @rules;
my $rule0; # first rule number
my @anums; # A-numbers

if (0) {
#----------------
} elsif ($mode =~ m{\Ag}) { # gen
    my $starname = "starred.tmp";
    open (STAR, ">>", $starname) || die "cannot append to \"$starname\"\n";
    my $starcount = 0;
    while (<>) {
        s/\s+\Z//; # chompr
        my $line = $_;
        next if $line !~ m{A};
        $line =~ s{ *(\; *)+\Z}{\;};
        my @parts = split(/\;/, $line);
        if (scalar(@parts) >= 6 && ($parts[1] !~ m{A})) {
            $line = join(";", $parts[0], splice(@parts, 2));
        }
        $line =~ s{ (A\d+\*?)(\,\s*A\d+\*?)+}{$1}g;
        #                       1   2        2 134     5        54 3
        if (     $line =~ m{\A +(\d+(\,\s*\d+)*)((\;\s*(A\d+\*?|))+)\s*\Z}) {
            ($rulelist, $anumlist) = ($1, $3);
            @rules = split(/\, */, $rulelist);
            $rule0 = $rules[0];
            foreach my $starred ($anumlist =~ m{(A\d+)\*}g) {
                $starcount ++;
                $starred =~ s{\*}{}g;
                print STAR join("\t", $starred, "starred", 0), "\n";
            } # foreach $starred
            $anumlist =~ s{[\* ]}{}g; # remove spaces and asterisks
            $anumlist =~ s{\A\;}{};
            $anumlist =~ s{\;+\Z}{};
            @anums = split(/\;/, $anumlist);
            print "# " . join("\t", join(",", @rules), join(";", @anums)) . "\n";
            for (my $ian =0; $ian < scalar(@anums); $ian ++) {
                print join("\t", $anums[$ian], $callcodes[$dists{$dim} + $ian], $offset, $rule0, ""
                    , (($dim eq "2a") && $ian >= 2 ? "new $anums[0]()" : ""), ""). "\n";
            } # for $ian
        } elsif ($line =~ m{\A +(\d+(\, ?\d+)*)}) {
            print STDERR "#dim=$dim $line\n";
        } else {
            # print "#2 $line\n";
        }
    } # while <>
    close STAR;
    print STDERR "$starcount A-numbers appended to $starname\n";
#----------------
} elsif ($mode =~ m{\Aj}) { # jpat
    for (my $icc = 0; $icc < scalar(@methods); $icc ++) {
        my $file = "$callcodes[$icc].jpat";
        $extends = ($file =~ m{ca1}) ? "Cellular1DAutomaton" : "FiveNeighbor2DAutomaton";
        open(JPAT, ">", $file) || die "cannot write \"$file\"";
        print JPAT <<"GFis";
package irvine.oeis.\$(PACK);
// Generated by \$(GEN) \$(CALLCODE) at \$(DATE)

import irvine.math.z.Z;
import irvine.oeis.ca.$extends;

/**
 * \$(ASEQNO) \$(NAME)
 * \@author \$(AUTHOR)
 */
public class \$(ASEQNO) extends $extends {

  /** Construct the sequence. */
  public \$(ASEQNO)() {
    super(\$(PARM1));
  }

  \@Override
  public Z next() {
    return super.$methods[$icc]();
  }
}
GFis
        close(JPAT);
    } # for icc
#----------------
} else {
    print STDERR "invalid mode \"$mode\"";
}
__DATA__

:{{Table
| class = wikitable
| title = '''Elementary Cellular Automata Sequences in the OEIS'''
| style = + text-align: center;
| hdrsstyle = + vertical-align: middle;
| hdrs =
  Rule; Triangle; Stages(B); Stages(D); Middle; Middle(B); Middle(D); Black(n); Black(<math>\Sigma</math>); White(n); White(<math>\Sigma</math>); Other
| rows =
  0,8,32,40,64,72,96, 104,128,136,160,168, 192,200,224,232; A000007; A000007; A000007; A000007; A011557; A000079; A000007; A000012; A005408*; A005563; ;;
  1,33; A265718; A265720; A265721; A059841; A056830*; A000975*; A265722; A128918; A265723; A265724; ;;
  2,10,34,42,66,74,98, 106,130,138,162,170, 194,202,226,234; A010052; A098608; A000302; A000007; A011557; A000079; A000012; A000027; A005843; A002378; ;;
  3,35; A263428; A266068; A266069; A266070; A266071; A081253*; A266072; A247375; A266073; A266074; ;;
