#!perl

# Prepare jcat25 program (PAIR, Maple, MMA, OEIS formula) for sorting
# @(#) $Id$
# 2023-09-01, Georg Fischer: copied from ../robot/expr_pari.pl
#
#:# Usage:
#:#   perl sortprep.pl jcat25.txt > output
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($code, $type, $aseqno, $callcode, $offset1, $name, @nums, $numlist, @asns, $asnlist, $nok);
my @parms;
$callcode = "sortprep";
$offset1 = 0;
my $line;

while (<>) {
    $line = $_;
    if ($debug >= 3) {
        print "# line=$line";
    }
    $line =~ s/\s+\Z//; # chompr
    $nok = 1; # assume failure
    if ($line =~ m{^([\#\%\?])([Fopt]) (A\d+) *(.*)}) {
        ($code, $type, $aseqno, $name) = ($1, $2, $3, $4 || "");
        if (0) {
        } elsif ($type eq "o") { # other - PARI
            if ($name =~ s{\(PARI[^\)]*\) *}{}) { # e.g. "A248705 (PARI: For b-file)"
                $name =~ s{\\\\.*}{}; # remove author
                $nok = 0;
            }
        } elsif ($type eq "p") { # Maple
            $name =~ s{\#.*}{}; # remove author comment
            $nok = 0;
        } elsif ($type eq "t") { # MMA
            $name =~ s{\(\*.*}{}; # remove author comment
            $nok = 0;
        } elsif ($type eq "F") { # OEIS formula
            if ($name =~ m{\.\.\.}) { # ellipsis - invalid
                $nok = "2/ellip";
            } else {
                $name =~ s{\.\.}{\,}g;
                $name =~ s{\. \- [\_A-Z].*}{}; # remove author comment
                $name =~ s{\..*}{}; # remove comment
                $nok = 0;
            }
        }
        $name =~ s/ //g; # remove all spaces
        @asns = ();
        foreach my $asn ($name =~ m{([aA]\d{6}|€\d{6})}g) {
            $name =~ s{$asn}{Annn};
            push(@asns, $asn);
        }
        @nums = ();
        foreach my $num ($name =~ m{(\d+)}g) {
            $name =~ s{$num}{\(\\d\+\)};
            push(@nums, $num);
        }
    } # 
    if ($nok eq "0") {
        print        join("\t", $code, $type, $aseqno, $name, join(",", @nums), join(",", @asns)) . "\n";
    } else {
    }
} # while <>

#--------------------------------------------
__DATA__
