#!perl

# Extract decimal expansion sequences for solutions of equations
# @(#) $Id$
# 2021-07-29, Georg Fischer
#
#:# Usage:
#:#   perl decsolv.pl [-d debug] $(COMMON)/joeis_names.txt > seq4-output
#--------------------------------------------------------
use strict;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $width = 4; # number of relevant digits for boundaries
my $ignore = 1;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{i}) {
        $ignore    = shift(@ARGV);
    } elsif ($opt  =~ m{w}) {
        $width     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
my $expr = "";
my $sign = "";
my $nok = -1;
while (<>) {
    my $line = $_;
    next if $line !~ m{\AA\d+};
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $superclass, $name, $keyword, $bfimxx, @rest) = split(/\t/, $line);
    if ($name =~ s{Decimal expansion of *}{}) {
        $nok = -1; # undecided
        $expr = "??";
        $sign = "";
        if ($name =~ s{(\, *|\()?negat.*}{}) {
            $sign = "n";
        }
        if (0) {
        } elsif ($name =~ m{x *([\<\=\>])+ *0 *having *([ \w\+\-\*\/\^\=\(\)]+)}) {
            # A198564 Decimal expansion of x>0 having 4*x^2-2x=sin(x).
            if ($1 eq "<") {
                $sign = "n";
            }
            $expr = $2;
            $nok = 0;
        } elsif ($name =~ m{satisf(ying|ies\:?) *([ \w\+\-\*\/\^\=\(\)]+)}) {
            # A202496 Decimal expansion of x satisfying x=e^(-x-2).
            # A099554 Decimal expansion of the constant x that satisfies: x = exp(1/sqrt(x)).
            $expr = $2;
            $expr =~ s{ and .*}{}; # and ...
            $nok = 0;
        } elsif ($name =~ m{(root|solution|zero) (x )?(of |to )(the )?(equation )? *([ \w\+\-\*\/\^\=\(\)]+)}) {
            #               1                    2    3        4      5             6
            $expr = $6;
            $expr =~ s{ and .*}{}; # and ...
            $nok = 0;
        } elsif ($name =~ m{(least|middle|greatest) x (such that |having )*([ \w\+\-\*\/\^\=\(\)]+)}) {
            #               1                         2                    3
            $expr = $3;
            $expr =~ s{ and .*}{}; # and ...
            $nok = 0;
        }
        
        if ($nok >= 0) {
            $expr =~ s{(sin|cos|tan|cot|sec|csc) +([\dx\*]*)}{$1\($2\)}g; # sin 5x -> sin(5x)
            $expr =~ s{(\d+)x}{$1\*x}g; # 5x -> 5*x
            $expr =~ s{ }{}g; # all spaces
            $expr =~ s{\.\Z}{}; # trailing dot
            $expr =~ s{\=0\Z}{}; # trailing "=0"
            $expr =~ s{\=(.+)\Z}{\-\($1\)}; # change "=expr" to "-(expr)"
            print "#2 nok=$nok, expr=$expr\n" if $debug >= 2;
            if (0) {
            } elsif ($expr !~ m{x}) {
                $nok = 2; # no variable x
            } elsif ($expr !~ m{[\+\-\*\^\/]}) {
                $nok = 3; # no operator
            } elsif ($expr =~ m{[\+\-\*\^\/]\Z}) {
                $nok = 4; # did not end properly
            }
            print "#3 nok=$nok, expr=$expr\n" if $debug >= 1;
            if ($nok == 0) {
                print        join("\t", $aseqno, "decsolv$sign" , $offset, "~~$expr", "") . "\n";
            } else { # ignore
                print STDERR join("\t", $aseqno, "nok=$nok",      $offset, $expr, $name) . "\n";
            }
            # having
        } else {
                print STDERR join("\t", $aseqno, "nok=$nok",      $offset, $expr, $name) . "\n";
        }
        # if Decimal expansion
    } else {
        print STDERR "#?? $line\n";
    }
} # while
#----
__DATA__
A197737 null    Decimal expansion of x<0 having x^2+x=cos(x).   nonn,cons,synth 1..99   nyi
A197738 null    Decimal expansion of x>0 having x^2+x=cos(x).   nonn,cons,synth 0..98   nyi
A197806 null    Decimal expansion of x>0 having x^2=2*cos(x).   nonn,cons,synth 1..99   nyi
A197807 null    Decimal expansion of x>0 having x^2=3*cos(x).   nonn,cons,synth 1..99   nyi
A202495 null    Decimal expansion of x satisfying x = e^(-2*Pi*x).  nonn,cons,changed,  0..10000    nyi
A202496 null    Decimal expansion of x satisfying x=e^(-x-2).   nonn,cons,synth 0..98   nyi
A202497 null    Decimal expansion of x satisfying x=e^(-2x-2).  nonn,cons,synth 0..98   nyi
A202498 null    Decimal expansion of x satisfying x=e^(-2x).    nonn,cons,synth 0..98   nyi
A202499 null    Decimal expansion of x satisfying x=e^(-3x).    nonn,cons,synth 0..98   nyi
A202500 null    Decimal expansion of x satisfying x=e^(-Pi*x).  nonn,cons,synth 0..98   nyi
A202501 null    Decimal expansion of x satisfying x=e^(-Pi*x/2).    nonn,cons,  0..2000 nyi
