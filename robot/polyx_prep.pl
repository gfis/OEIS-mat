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
my $oseqno = "A000000"; # old, for a group of A-numbers
my $formula; 
my $expon;
my $gfType;
my $nok = "";

while(<>) {
    s{\(End\)}   {}i;
    s{\.\s*\Z}   {}; # chompr
    s{\. \- .*}  {}; # remove author
    s{\,\Z}      {}; # trailing comma
    $line = $_;
    $nok = "";
    if (0) {
    #                         1     1       2  2
    } elsif ($line =~ m{A\(x\)(\^\d+)? *\= *(.*)}) {
        $expon   = $1 || "^1";
        $formula = $2;
        if ($line =~ m{\A\%[NF] (A\d+)}) {
            $aseqno = $1;
        }
        if ($aseqno eq $oseqno) { # in same group
            # keep gfType
        } else { # new group
            $gfType = ($line =~ m{e\.g\.f\.}i) ? 1 : 0;
        }
        $formula =~ s{(\, )?(with|where|for) .*}{};   # remove initial terms and conditions
        $formula =~ s{A\'\(x\)}{dif\(A\(x\)\)}g; # derivative A'(x)
        $formula =~ s{A\'\(}{difA\(}g;           # derivative A'(...
        if ($formula =~ s{Integral|intformal}{int\(}ig) {
            $formula =~ s{dx}{\)}g;
        }
        $formula =~ s{\A *\[x\^n\] *}{};          # allow for leading "[x^n]"
        if ($formula =~ s{\A *\[x\^[^\]]+\]}{}) { # disallow other leading "[x^...]"
            $nok = "[x^mn]";
        }
        $formula =~ s{ }{}g;  # remove spaces
        $formula =~ tr{\[\]}  # convert MMA square brackets
                      {\(\)}; #     -> normal brackets
        $formula =~ s{AGM}                   {agm}ig;
        $formula =~ s{(Series[_\-])?Reversion|serreverse}{rev}ig;
        $formula =~ s{d\/dx|diff|deriv}      {dif}ig;
        $formula =~ s{LambertW}              {lambertW}ig;
        $formula =~ s{Sqrt}                  {sqrt}ig;
        $formula =~ s{arc(sin|cos|tan)}      {a$1}ig;
        if (!defined($formula)) {
            $nok = "undef";
        }
        if (length($formula) < 4) {
            $nok = "len<4";
        }
        if (length($nok) == 0) {
            print        join("\t", $aseqno, "polyx", 0, ";$formula", $expon, $gfType, $formula) . "\n";
        } else {
            print STDERR join("\t", $aseqno, "$nok" , 0, ";$formula", $expon, $gfType, $formula) . "\n";
        }
    }
} # while <>
__DATA__
