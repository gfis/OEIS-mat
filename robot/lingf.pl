#!perl

# Extract o.g.f.s 
# @(#) $Id$
# 2024-12-28, Georg Fischer: copied from nopan.pl
#
#:# Usage:
#:#     perl lingf.pl input > out.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options
#----------------
my $aseqno;
my $offset = 1;
my $form;
my $line;
my $name;
my $callcode = "lingfcj";
my $nok;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    #           1        1
    $line =~ s{^([\#\?\%])[A-Za-z] }{}; # remove any OEIS record type
    my $type = $1;
    $callcode = "lingf" . ($type eq "?" ? "cj" : "");
    #                1    1  2  2
    if ($line =~ m{\A(A\d+) +(.*)}) {
        ($aseqno, $form) = ($1, $2);
        $nok = "";
        $form =~ s{\(?(conjecture[sd]?|empirical|apparently)\)?\:?}{}i;
        #                         1          1
        if ($form =~ m{g\.f\.\:? *([^\.\;\,]+)}i) {
            $form = $1;
            if (length($form) >= 6 && ($form =~ m{[\+\-\*]})) {
                $form =~ tr[\[\]]
                           [\(\)]; # normalize parentheses
                my %letters = ();
                map { $letters{$_} = 1; } ($form =~ m{([a-z])}g);
                if (scalar(keys(%letters)) == 1) { # only a single letter for the variable
                    foreach my $key (keys(%letters)) {
                        if ($key ne "x") {
                            $form =~ s{$key}{x}g; # normalize z -> x
                        }
                    }
                    $form =~ s{ }{}g; # remove spaces
                    $form =~ s{(\d)x}{$1\*x}g; # 9x -> 9*x
                    $form =~ s{\)\(}{\)\*\(}g; # )( -> )*(
                } else {
                    $nok = "letter<>1";
                }
            } else {
                $nok = "tooshort";
            }
        } else {
            $nok = "nogf";
        }
        if ($nok eq "") {
            print        join("\t", $aseqno, $callcode, 0, $form) . "\n";
        } else {
            print STDERR join("\t", $aseqno, $nok, $form) . "\n";
        }
    } else {
        # print "$line\n";
    }
} # while <>
#----------------
__DATA__
A006792	anopan	10	2,0,0,0,0,4,8,0,4	a(n) = A006799(n) - A185959(n). - _Andrew Howroyd_, Nov 27 2018
A320047 Conjectures from _Colin Barker_, Aug 03 2019: (Start)
A320047 G.f.: x*(5 + 6*x + 8*x^2 - 6*x^3 - x^4) / ((1 - x)^4*(1 + x)^4).
A320047 a(n) = (4 - 4*(-1)^n - 3*(-5+(-1)^n)*n - 3*(-3+(-1)^n)*n^2 + (1+(-1)^(1+n))*n^3) / 8.
A320047 a(n) = 4*a(n-2) - 6*a(n-4) + 4*a(n-6) - a(n-8) for n>8.
A320097 Conjecture: a(n) = 36*a(n-1) - 7*a(n-2) - 201*a(n-3) + 49*a(n-4) + 20*a(n-5) - 5*a(n-6) for all n > 6.
A320097 Empirical g.f.: x*(1 - 21*x - 70*x^2 + 10*x^3 + 14*x^4 - 3*x^5) / (1 - 36*x + 7*x^2 + 201*x^3 - 49*x^4 - 20*x^5 + 5*x^6). - _Colin Barker_, Oct 20 2018
A320099 Conjecture: a(n) = 103*a(n-1) + 1063*a(n-2) - 1873*a(n-3) - 20274*a(n-4) + 44071*a(n-5) - 10365*a(n-6) - 20208*a(n-7) + 5959*a(n-8) + 2300*a(n-9) - 500*a(n-10) for n > 10.
