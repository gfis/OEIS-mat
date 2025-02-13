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

my ($aseqno, $callcode, $offset1, $postfix, $expon, $gfType, $formula, $terms);
my $polys;
my $line;
my $name;
my $nok = "";
my $sep = ";";
my $debug = 0;
my $known_file = "polyx_known.txt";
my $ofter_file = "polyx3_ofter.tmp";

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{d}) {
        $debug      =  shift(@ARGV);
    } elsif ($opt   =~ m{k}) {
        $known_file =  shift(@ARGV);
    } elsif ($opt   =~ m{f}  ) {
        $ofter_file = shift(@ARGV);
    } else {
       print STDERR "# invalid option \"$opt\"\n";
    }
} # while options
my %known = ();
open(KNO, "<", $known_file) || die "cannot read $known_file";
while (<KNO>) {
    s{\W}{}g;
    $known{lc($_)} = 1;
} # while KNO
close(KNO);

my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    ($aseqno, $offset1, $terms) = split(/\t/);
    $terms = $terms || "";
    if ($offset1 < -1) { # offsets -2, -3: strange, skip these
    } else {
        $ofters{$aseqno} = "$offset1\t$terms";
    }
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";

while(<>) {
    s{\s*\Z}   {}; # chompr
    $line = $_;
    $nok = "";
    if ($line =~ m{\<\?}) {
        $nok = "syntax";
    }
    ($aseqno, $callcode, $offset1, $postfix, $expon, $gfType, $formula) = split(/\t/);
    if (length($nok) == 0) {
        $gfType  =~ tr{oe}{01};
        $sep     = substr($postfix, 0, 1);
        $postfix = substr($postfix, 1);
        $polys   = "[[1]]";
        ($offset1, $terms) = split(/\t/, $ofters{$aseqno});
        if ($offset1 != 0) {
            $terms =~ s{\,.*}{}; # keep 1st term only
            for (my $it = 0; $it < $offset1; $it ++) {
                 $terms = "0,$terms";
            }
            $polys = "[[$terms]]";
        }

        if (1) {# handle A(x)
            $postfix =~ s{A}{\#}g; # shield "A"
            $postfix =~ s{${sep}\#\(${sep}x${sep}\#\)${sep}}           {${sep}A${sep}}g; # A(x) -> A
            #              ;    1       12          2
            $postfix =~ s{${sep}(dif|log)(A|sub|log)\(${sep}}          {${sep}$1\(${sep}$2\(${sep}}g; # ;dif#(; -> ;dif(;#(;
            $postfix =~ s{${sep}(dif|log)(A|sub|log)\)${sep}}          {${sep}$2\)${sep}$1\)${sep}}g; # ;dif#); -> ;#);dif);
            while($postfix =~ s{${sep}\#\(${sep}([^\#]+)\#\)}          {${sep}sub(${sep}${1}sub\)}) { # A(...) -> sub(...)
                # try again
            }
            while($postfix =~ s{${sep}\#\(${sep}([^\#]+)\#\)}          {${sep}sub(${sep}${1}sub\)}) { # A(...) -> sub(...)
                # try again
            }
            if ($postfix =~ m{\#}) { # they should all be replaced
                $nok = "unA";
            }
        } # handle A(x)

        if (1) { # handle exponentiation
            # A295533	polyx	0	"[[1]]"	";1;x;A;3;^;*;+;x;2;^;A;7;^;/;-"	0	0	1+x*A(x)^3-x^2/A(x)^7
            #              ;    1 d 1 ;     ^                       ->      ;     ^d  ; 
            $postfix =~ s{${sep}(\d+)${sep}\^}                            {${sep}\^$1}g;
            # A281186	polyx	0	"[[1]]"	";1;A;/;A;8;3;/;^;int;*;exp"	0	1	exp(1/A(x)*int(A(x)^(8/3)))
            #              ;    1   1 ;    2 d 2 ;     / ;     ^    ->      ;     ^d  / d ;
            $postfix =~ s{${sep}(\d+)${sep}(\d+)${sep}\/${sep}\^}         {${sep}\^$1\/$2}g;
        }
        
        my @elems = grep {
            length($_) > 0
        } map {
            my $elem = $_;
            if (0) {
            } elsif ($elem eq ",") {
                $elem = "";
                $nok = "comma";
            #                   1   12      2
            } elsif ($elem =~ m{(\w+)([\(\)])\Z}) { # is a function
                $name = $1;
                my $bracket = $2;
                if (!defined($known{lc($name)})) {
                    $nok = "unfct";
                    print STDERR "# $nok $name\n";
                }
                if ($bracket eq "(") {
                    $elem = ""; # will be removed
                } else {
                    $elem = $name;
                }
                # function check
            } elsif ($elem =~ m{\A([a-zA-Z]\w*)\Z}) { # is a name
                $name = $1;
                if ($name !~ m{\A(A|x)\Z}) { # only "A", "x"
                    $nok = "un?$name";
                }
            }
            $elem # return value for 'map'
        } split(/$sep/, substr($postfix, 1)); # without the leading separator

        $postfix = "$sep" . join($sep, @elems);
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

