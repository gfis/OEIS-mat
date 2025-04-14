#!perl

# Poor translation of OEIS formulas into jOEIS
# @(#) $Id$
# 2024-06-22, Georg Fischer
#
#:# Usage:
#:#   perl poor.pl jcat25-format > seq4-format
#:#       -a: no infix arithmetic translation
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $debug = 0;
my $arith = 1;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $arith     = 0;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
    s/\s+\Z//; # chompr;
    # print "#" . substr($_, 1);
    my $line = $_;
    $line =~ s{\. \- _.*}                                         {}; # remove author
    $line =~ s{\.\Z}                                              {};
    $line =~ s{\. *\(End\)\Z}                                     {};
    $line =~ s{binom(ial)?}                                       {BI}ig;
    $line =~ s{stirling}                                          {S}ig;
    $line =~ s{(gcd|lcm|max|min)}                                 {uc($1)}ieg;
    #                1        1
    if ($line =~ m{\A([A-Z]\d+)\s+a\(n\) *\= *}) {
        my $aseqno = $1;
        #                                   1  1
        $line =~ s{\A[A-Z]\d+\s+a\(n\) *\= *(.*)}                 {$1};
        my $copy = $1;
        $line =~ s{Sum_?\{(\w)\=(\d+)\.\.([^\}\,]+)[\}\,]}        {SU($2, $3, $1 ->}ig;
        $line =~ s{Sum_?\{(\w)\|(\w)([^\}\,]*)[\}\,]}             {SD($2, $1 -> $3}ig;
        $line =~ s{Prod(uct_?)?\{(\w)\=(\d+)\.\.([^\}\,]+)[\}\,]} {PR($2, $3, $1 ->}ig;
        $line =~ s{Prod(uct_?)?\{(\w)\|(\w)([^\}\,]*)[\}\,]}      {PD($2, $1 -> $3}ig;
        $line =~ s{2\^\(}                                         {Z2\(}g;
        $line =~ s{2\^([i-n])}                                    {Z2\($1\)}g;
        $line =~ s{\(\-1\)\^\(}                                   {Z_1\(}g;
        $line =~ s{\(\-1\)\^([i-n])}                              {Z_1\($1\)}g;
        $line =~ s{\) *mod *\(}                                   {\)\.mod\(}g;
        $line =~ s{ *mod *([i-n0-9])}                             {.modZ\($1\)}g;
        #           (1        1 ) !
        $line =~ s{\(([^\)\(]+)\)\!}                              {FA\($1\)}g;
        $line =~ s{(\w)\!}                                        {FA\($1\)}g;
        $line =~ s{\b(\d)(i-n)\b}                                 {$1\*$2}g; # insert "*"
        if ($arith) {
          $line =~ s{\) *([\+\-\*\/\^]) *\(}                      {\)\.$1\(}g;
        }
        $line =~ s{ }                                             {}g;
        $line = "$aseqno\tlambdan\t0\tn \-\> $line\t$copy";
    }
    print "$line\n";
} # while