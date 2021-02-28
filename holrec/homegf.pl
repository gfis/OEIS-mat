#!perl

# Prepare (E.)G.f. formulas for holmaple.pl
# 2021-01-31, Georg Fischer
#
#:# Usage:
#:#   perl homegf.pl [-d debug] input > homegf1.tmp 2> linrec.tmp
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $rest; # behind initterms

my $callcode = "egf";
my $offset = 0;
while (<>) {
    s/\s+\Z//;
    my $line = $_;
    if ($line =~ m{\A(A\d+)\s+(Expansion of )?(([Ee])\.)?[Gg]\.f\.\:?\s*(.*)}) {
        my ($gftype, $aseqno, $formula) = (lc($4 || "o"), $1, $5);
        $gftype =~ s{\.}{};
        next if $formula =~ m{\.\.\.};
        $formula =~ s{[\.\,](.*)}{}; # remove rest behind formula
        $formula =~ s{g\([t-z]\)\=}{}g;
        if ($formula !~ m{for|of|satis|where|column|even|reverse|int\[|[A-Zjklmy\!\;\:\|\{\}]|dn|dx|sn|cd|odd|psi|subs|t_|d\/dx|\^\^|e\^}) {
            foreach my $expr (split(/\=/, $formula)) {
                $expr =~ s{ }{}g;
                $expr =~ tr{\[\]}{\(\)};
                if ($expr !~ m{(\A|\W)[fg]\(|(\A|\W)[finqst]\W|tx|ox|osin|\([^\(\)]*\Z}) {
                    $expr =~ s{z}{x}g;
                    $expr =~ s{(\d|\))([a-z])}{$1\*$2}g;
                    $expr =~ s{\)\(}{\)\*\(}g;
                    $expr =~ s{(\d)\(}{$1\*\(}g;
                    $expr =~ s{xexp}{x\*exp}g;
                    $expr =~ s{sinhx}{sinh\(x\)}g;
                    $expr =~ s{sinx}{sin\(x\)}g;
                    if ($expr !~ m{x}) { # ignore if there is no "x"
                    } elsif ($expr =~ m{[a-wyz]|\^\(\-?\d+\/\d+}) { # holonomic
                        print        join("\t", $aseqno, $gftype . "gf", $offset, $expr, $gftype) . "\n";
                    } else { # linear recurrence
                        print STDERR join("\t", $aseqno, $gftype . "gf", $offset, $expr, $gftype) . "\n";
                    }
                }
            } # foreach $expr
        }
    }
} # while <>
