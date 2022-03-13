#!perl

# a055277.pl: Generate A055278-A055287.java
# @(#) $Id$
# 2022-03-13: with options
# 2022-03-04, Georg Fischer
#:# usage:
#:#   perl a055277.pl [-o offset] [-n noterms] [-gf {0|1}] > *.java
#:#       -r  A-number that computes the recurrence (denominator), default A055278
#:#       -gf type of generating function, 0 = o.g.f. (default), 1 = exponential g.f.
#--------------------------------
use strict;
use integer;
use warnings;

my $debug   = 0; # 0 (none), 1 (some), 2 (more)
my $gftype  = 0;
my $rseqno  = "A055278"; # or A055350 
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-gf}) {
        $gftype   = shift(@ARGV);
    } elsif ($opt =~ m{\-r}) {
        $rseqno   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
my @seqnos;
#                     0      1      2      3      4      5      6      7      8      9     10     11     12  leaves
my @ninits  = qw(     0      0      1      4     10     15     26     33     47     59     76     87    114);
   @seqnos  = qw(000000 000000 002620 055278 055279 055280 055281 055282 055283 055284 055285 055286 055287);
   @seqnos  = qw(000000 000000 000002 001399 055291 055292 055293 055294 055295 055296 055297 055298 055299);
#  @seqnos  = qw(000000 000000 055303 055304 055305 055306 055307 055308 055309 055310 055311 055312 055313);
#  @seqnos  = qw(000000 000000 000000 055315 055316 055317 055318 055319 055320 055321 055322 055323 055324);
#  @seqnos  = qw(000000 000000 000000 055328 055329 055330 055331 055332 055333);
#  @seqnos  = qw(000000 000000 000000 000000 055335 055336 055337 055338 055339);
   @seqnos  = qw(000000 000000 000000 055341 055342 055343 055344 055345 055346);
   @seqnos  = qw(000000 000000 000000 055350 055351 055352 055353 055354 055355); # psplit
#  @seqnos  = qw(000000 000000 000000 055357 055358 055359 055360 055361 055362);
#  @seqnos  = qw(000000 000000 000000 055364 055365 055366 055367 055368 055369); # qsplit
undef $/;
my $pattern = <DATA>;
# open (REC, "<", "recur.inc") or die "cannot read recur.inc\n";
my $recur = ""; # <REC>;
# close(REC);

for (my $ias = 0; $ias < scalar(@seqnos); $ias ++) {
    if ($seqnos[$ias] >= 55000) {
        my $aseqno = "A$seqnos[$ias]";
        my $offset = $ias + 1;
        my $name = `grep $aseqno ../../common/asname.txt`;
        $name =~ s{\t}{ }g;
        $name =~ s{[\r\n]}{}g;
        my $nin1  = $ninits[$ias] + 2;
        if ($rseqno eq "A055350") {
            $gftype = 1;
            $nin1 = $ias * 2;
        }
        my $inits = `perl ../data_bf.pl -to data -o $offset -n $nin1 ../../common/bfile/b$seqnos[$ias].txt`;
        $inits =~ s{\s}{}g;
        my $filename = "$aseqno.java";
        my $buffer = $pattern;
        open(JAVA, ">", $filename) || die "cannot write $filename\n";
        $buffer =~ s{\$\(ASEQNO\)}  {$aseqno}g;
        $buffer =~ s{\$\(NAME\)}    {$name}g;
        $buffer =~ s{\$\(OFFSET\)}  {$offset}g;
        $buffer =~ s{\$\(MATRIX\)}  {$rseqno.computeRecurrence\($ias\)}g;
        $buffer =~ s{\$\(GFTYPE\)}  {$gftype}g;
        $buffer =~ s{\n *setGfType\(0\)\;}{}; # keep GFTYPE=1 only
        $buffer =~ s{\$\(INITS\)}   {$inits}g;
        if ($ias < 0) {
            $buffer =~ s{\$\(RECUR\)}   {$recur}g;
        } else {
            $buffer =~ s{\$\(RECUR\)\s+}{}g;
        }
        print JAVA $buffer; 
        close(JAVA);
        print STDERR "$filename written\n";
    }
} # for $ias
__DATA__
package irvine.oeis.a055;

import irvine.oeis.HolonomicRecurrence;

/**
 * $(NAME)
 * @author Georg Fischer
 */
public class $(ASEQNO) extends HolonomicRecurrence {

  /** Construct the sequence. */
  public $(ASEQNO)() {
    super($(OFFSET), $(MATRIX), "$(INITS)");
    setGfType($(GFTYPE));
  }
$(RECUR)
}

