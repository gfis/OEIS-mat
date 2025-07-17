#!perl

# Generate a seq4 record with CC=convprod from the parameters and append it to today's aman/date.man file
# @(#) $Id$
# 2025-07-17, Georg Fischer: copied from ratos_seq4.pl
#
#:# Usage:
#:#   perl convol_seq4.pl Q A $3 ...
#:#       Q  power/root
#:#       A  instances 
#:#       -n number of terms  
#:#       -t gftype (1 = exponential, 4/5=denominator)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
my $gits =  $ENV{'GITS'};
my $lite_aman =  "$gits/joeis-lite/internal/fischer/aman";
$lite_aman =~ s{\\}{\/}g;
my $makefile = "$gits/OEIS-mat/scripts/makefile";
$makefile =~ s{\\}{\/}g;

my $debug    = 0;
my $cc       = "convprod";
my $fraction = shift(@ARGV);
my $aseqnos  = shift(@ARGV);
my $options  = join(" ", @ARGV);
my $offset   = 0;
my $gftype   = 0;
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{-d}) {
        $debug    = shift(@ARGV);;
    } elsif ($opt =~ m{-o}) {
        $offset = shift(@ARGV);
    } elsif ($opt =~ m{-t}) {
        $gftype = shift(@ARGV);
    } else { # ignore -n
        shift(@ARGV);
    }
}
$fraction =~ s{\"}{}g; 
$aseqnos  =~ s{\"}{}g; 
my @anos = map {
        s{[A-Z](\d+)}{"A" . sprintf("%06d", $1)}eg;
        my $ano = $_;
        if ($ano !~ m{new}) {
            $ano = "new $ano\(\)";
        }
        $ano;
    } split(/\, */, $aseqnos);
my $seqno    = sprintf("%06d", &last_seqno());
my $record   = join("\t", "A$seqno", $cc, $offset, $fraction, join(", ", @anos), $gftype) . "\n";
print      $record;
my $file = "$lite_aman/$timestamp.man";
open (AMAN, ">>", $file) || die "# cannot write to $file\n";
print AMAN $record;
close(AMAN);
#----
sub last_seqno { # get aseqno from history.txt
    map {   #        1   1
            if (m{\/A(\d+)}) { # take the 1st
                return $1;
            }
        }
        split(/\n/, `make -f $makefile histoeis`);
    return "";
} # last_seqno
__DATA__
