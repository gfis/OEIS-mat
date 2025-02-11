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

my ($aseqno, $callcode, $offset1, $postfix, $expon, $gfType, $formula);
my $polys;
my $line;
my $nok = "";
my $sep = ";";

while(<>) {
    s{\s*\Z}   {}; # chompr
    $line = $_;
    $nok = "";
    if ($line =~ m{\<\?}) {
        $nok = "syntax";
    }
    ($aseqno, $callcode, $offset1, $postfix, $expon, $gfType, $formula) = split(/\t/);
    if (length($nok) == 0) {
        $gfType =~ tr{oe}{01};
        $sep = substr($postfix, 0, 1);
        $postfix = substr($postfix, 1);
        $polys = "[[1]]";
        
        if ($expon ne "^1") {
            $expon =~ s{\A\^(\d+)}{\^1\/$1};
            $postfix .= "$sep$expon";
        }
    }
    if (length($nok) == 0) {
        print        join("\t", $aseqno, $callcode, $offset1, "\"$polys\"", "\"$postfix\"", 0, $gfType, $formula) . "\n";
    } else {
        print STDERR join("\t", $aseqno, $nok     , $offset1, "\"$polys\"", "\"$postfix\"", 0, $gfType, $formula) . "\n";
    }
} # while <>
#----
__DATA__
A107094	polyx	0	;;1;x;+;A(;A(;x;A);1;x;+;/;A);*;1;x;+;A(;x;A);+;/	^1	o	(1+x)*A(A(x)/(1+x))/(1+x+A(x))					0
A107096	polyx	0	;;x;A(;A(;x;A);2;^;x;/;A);*;1;x;+;/	^2	o	x*A(A(x)^2/x)/(1+x)					0
A107096	polyx	0	;;x;x;rev(;A(;x;A);2;^;x;/;rev);*;+	^1	o	x+x*rev(A(x)^2/x)					0
A107097	polyx	0	;;x;A(;x;A);rev(;A(;x;A);rev);*;+	^1	o	x+A(x)*rev(A(x))					0
A107588	polyx	0	;;1;x;A(;x;A);/;A(;x;A(;x;A);/;A);/;+	^1	o	1+(x/A(x))/A(x/A(x))					0

sub polish {
    my ($gf, $expr) = @_;
    my ($gf1, $gf2) = ("A", "\QA(x)\E"); # default
    if ($gf =~ m{\=}) { # "G.f. A = A(x) satis...
        ($gf1, $gf2) = split(/\=\:?/, $gf);
    } else { # no "G.f. A(x) :"
        if ($expr =~ m{\A([^\=]+)\=}) { # part before 1st "(" in expression
            $gf2 = $1;
            if ($gf2 =~ m{\A([^\(]+)}) { # part before "("
                $gf1 = $1;
            } else {
                $gf1 = "$1(x)";
            }
            # before 1st "("
        } # else take default
    } # no g.f.
    if ($gf1 =~ m{\(}) { # exchange, normalize to A = A(x)
        my $temp = $gf1; $gf1 = $gf2; $gf2 = $temp;
    }
    # $gf1 =~ s{([\(\)])}{\\$1}g;
    # $gf2 =~ s{([\(\)])}{\\$1}g;
    # $expr = "\Q$expr\E";
    $expr =~ s{\Q$gf1\E([^\(])}{\Q$gf2\E$1}g; # replace all A with A(x)
    $expr =~ s{\\}{}g;

    if ($expr =~ m{\A[Aygxtuq0-9\(\)\-\+\*\/\^\=]+\Z}) { # arithmetic expressions
        #          1         2
        $expr =~ s{([a-zA])\(([a-z])\)}{A\[$2\]}g;
        if ($expr =~ m{[a-zA]\(}) {
            $expr = "??1 $expr"; # void
        } else { 
            # make annihilator, imply ... = 0
            if (0) {
            } elsif ($expr =~ s{\A0\=}     {}         ) { # done
            } elsif ($expr =~ s{\=0\Z}     {}         ) { # done
            } elsif ($expr =~ s{\A([^\+\-]+)\=}{-$1\+}) { 
            } else {
                # $expr =~ s{\A}{#?? };
                $expr = "??2 $expr";  # void
            }
        }
    } else {
        $expr = "??3 $expr"; # void
    }
    $expr =~ tr{\[\]}{\(\)};
    $expr =~ s{A\(x\)}{A}g;
    $expr =~ s{(\d|\))([A-Za-z])}{$1\*$2}g;
    $expr =~ s{\+\-}{\-}g;
    if ($expr =~ m{y}) {
        $expr = "";
    }
    return $expr;
} # polish

