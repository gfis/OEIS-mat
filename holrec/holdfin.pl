#!perl

# Extract recurrences from %F records
# @(#) $Id$
# 2021-06-01, Georg Fischer
#
#:# Usage:
#:#     grep -iE "^%F" $(COMMON)/jcat25.txt | grep "inite with recurrence "| grep -vI "conject|empiric" \
#:#     | perl holdfin.pl -m dfin > output 
#:#   or:
#:#     perl holdfin.pl -m arec input > output
#---------------------------------
use strict;
use integer;
use warnings;

my $mode = "dfin";
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug   = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my $aseqno;
my $callcode = "holos";
my $offset;
my $ok;
my $rec;
my $orgrec;
my $cond;
my $inits;
my @rest;
my $line;
while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    $ok = 1;
    $cond = "";
    if (0) {
    } elsif ($mode eq "dfin") {
        $aseqno = substr($line, 3, 7);
        if ($line =~ m{finite with recurrence[ \:]+([^\.\_]+)}i) { 
            $rec  = $1;
            if (0) {
            } elsif ($aseqno eq "A071357") {
                $rec = "(n+3)*a(n) = (6*n+8)*a(n-1) - (4*n-4)*a(n-2) - (8*n-16)*a(n-3)";
            } elsif ($aseqno eq "A094941") {
                $rec = "a(n) = (2*n-2) + a(n-2)";
            } elsif ($aseqno eq "A096121") {
                $rec = "a(n) = (n-1)*n*(a(n-1) + a(n-2))";
            } elsif ($aseqno eq "A217275") {
                $rec = "(n+2)*a(n)=(2*n+1)*a(n-1)+(4*7-1)*(n-1)*a(n-2)";
            } elsif ($aseqno eq "A278070") {
                $rec = "a(n) = ((8*n^2-16*n+4)*a(n-1)+(2*n-1)*a(n-2))/(2*n-3)";
            } elsif ($aseqno eq "A303790") {
                $rec = "18*n^2*a(n) = 216*(5-27*n+27*n^2)*a(n-1) + 216^2*(5-3*n)*(-1+3*n)*a(n-2)";
            } elsif ($aseqno eq "A342912") {
                $rec = "a(n) = (2*a(n - 1) + 3*a(n - 2))*(n + 1)/(n + 3)";
            } elsif ($aseqno eq "A344564") {
                $rec = "n*a(n)=2*(n+4)*a(n-1)";
            }
            
            if ($rec =~ s{( for | with |[\,\;])(.*)\Z}{}) {
                $cond = $2;
            }
            &arec();
            if ($ok <= 1) {
                print        join("\t", $aseqno, "holos"  , 0, $rec, $cond, 0, 0, "Recurrence: $orgrec") . "\n"; 
            } else {
                print STDERR join("\t", $aseqno, "rest$ok", 0, $rec, $cond, 0, 0, "Recurrence: $orgrec") . "\n"; 
            }
        } # finite with recurrence ...
    } elsif ($mode eq "arec") {
        if ($line =~ m{\AA\d}) {
            ($aseqno, $callcode, $offset, $rec, $inits, @rest) = split(/\t/, $line);
            &arec($rec);
            push(@rest, "", "", "");
            $rest[2] = "Recurrence: $orgrec";
            if ($ok <= 1) {
                print join("\t", $aseqno, $callcode, $offset, $rec, $inits, @rest) . "\n"; 
            } else {
                print STDERR join("\t", $aseqno, "rest$ok", $offset, $rec, $inits, @rest) . "\n"; 
            }
        }
    } else {
        print STDERR "# ?? invalid mode \"$mode\"\n";
    }
} # while <>
#----
sub arec {
    $rec =~ s{ }{}g;
    $orgrec = $rec;
    if (length($orgrec) >= 1000) {
        $orgrec = substr($orgrec, 0, 1000) . "...";
    }
    $rec =~ s{(\d|\))([a-zA-Z]|\()}{$1\*$2}g;
    $rec =~ s{(n)(\()}{$1\*$2}g;
    if (0) {
    } elsif($line =~ m{conject|empiric|satisf}i) {
        $ok = 4;
    } elsif ($rec =~ s{([A-Z\.b-m\.o-z])}{$1\?}g) { # allow a,n only
        $ok = 5;
    } else {
        $rec =~ s{\=0\Z}{};
        $rec =~ s{\A0\=}{};
        if ($rec =~ m{\=}) { # resolve equation
            my ($recl, $recr) = split(/\=/, $rec);
            if ($recr =~ s{\/([n\d\+\-\*\^\(\)]+)\Z}{}) {
                my $factor = $1;
                $rec = "-$factor*($recl)+$recr";
            } else {
                $rec =         "-($recl)+$recr";
            }
        } # with "="
        $rec =~ s{\+0\Z}{};
        $rec =~ s{\A\-0\+}{};
        $rec =~ s{\+\-}{\-}g;
        $rec =~ s{\+\+}{\+}g;
        $rec =~ s{\+\*}{\+}g; # for A338965
        if ($rec =~ m{a\(n\+}) { # some positive: shift all into negative
            $rec =~ s{a\(n\)}{a\(n\+0\)}g;
            my @dists = sort {$a>$b} ($rec =~ m{a\(n\+(\d+)\)}g);
            my $shift = $dists[0];
            $rec =~ s{a\(n\+(\d+)\)}{"A\^" . ($1-$shift)}eg;
            $rec =~ s{n}{\(n-$shift\)}g;
        } else { # are all negative
            $rec =~ s{a\(n\)}{a\(n\-0\)}g;
            $rec =~ s{a\(n\-(\d+)\)}{A\^$1}g;
        }
    }
    if ($ok <= 1 and ($rec =~ s{([a-mo-z])}{$1\?}g)) {
        $ok = 3;
    }
#   return $rec;
} # arec
__DATA__
%F A334562 D-finite with recurrence a(n) +(n-1) +2*(n-1)*a(n-2) +3*(n-1)*(n-2)*a(n-3)=0. - _R. J. Mathar_, May 07 2020
%F A334569 D-finite with recurrence a(n) +a(n-1) +(n-1)*a(n-2) +(n-1)*(n-2)*a(n-3)=0. - _R. J. Mathar_, May 07 2020
%F A334670 P-finite with recurrence a(n) = 4*n*a(n-1) - (2*n-1)^2 * a(n-2) for n>1.