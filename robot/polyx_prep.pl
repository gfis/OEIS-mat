#!perl

# Grep (differential) equations of the form "A(x)^d = ..." and prepare them for "jprep -cc post"
# @(#) $Id$
# 2025-02-11, Georg Fischer: copied from satis.pl
#
#:# Usage:
#:#   grep -P "A\(x\)(\^\d+)? *\=" $(COMMON)/jcat25.txt | grep -P "^\%[NF]" \
#:#   | perl polyx_prep.pl > output.seq4
#---------------------------------
use strict;
use integer;
use warnings;

my $line;
my $aseqno;
my $formula; 
my $expon;
my $gfType;

while(<>) {
    s{\.\s*\Z}   {}; # chompr
    s{\. \- _.*} {}; # remove author
    $line = $_;
    if (0) {
    #                         1     1       2  2
    } elsif ($line =~ m{A\(x\)(\^\d+)? *\= *(.*)}) {
        $expon = $1 || "^1";
        $formula = $2;
        if ($line =~ m{\A\%[NF] (A\d+)}) {
            $aseqno = $1;
        }
        $gfType = "o";
        if ($line =~ m{e\.g\.f\.}i) {
            $gfType = "e";
        }
        $formula =~ s{with A\(\d\).*}{}; # remove initial terms
        $formula =~ s{A\'\(x\)}{dif\(A\(x\)\)}g; # derivative
        if ($formula =~ s{Integral}{int\(}i) {
            $formula =~ s{dx}{\)}g;
        }
        $formula =~ s{ }{}g;  # remove spaces
        $formula =~ tr{\[\]}  # MMA
                      {\(\)}; #     -> normal brackets
        $formula =~ s{Series[_\-]Reversion}  {rev}ig;
        $formula =~ s{d\/dx}                 {dif}ig;
        if (defined($formula) && length($formula) >= 4) {
            print join("\t", $aseqno, "polyx", 0, ";$formula", $expon, $gfType, $formula) . "\n";
        }
    }
} # while <>
__DATA__
