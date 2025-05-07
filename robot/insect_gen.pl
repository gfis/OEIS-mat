#!perl

# Modify seq4 records with CC=insect2 for intersections
# 2025-05-07, Georg Fischer
#
#:# Usage:
#:#   grep ... $(COMMON)/joeis_names.txt \
#:#   | perl insect_gen.pl [-d debug] [-f knopre] input.seq4 > output.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#:#     -f  known predicates file with (aseqno, lambda) (default: joeis-lite/internal/fischer/reflect/knopre.txt)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my ($aseqno, $callcode, @rest, $lambda, $rseqno);
my $debug   = 0;
my $offset = 0;
my $knopre_file = "../../joeis-lite/internal/fischer/reflect/knopre.txt"; # known predicates
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt    =~ m{\-d}  ) {
        $debug       = shift(@ARGV);
    } elsif ($opt    =~ m{\-f}  ) {
        $knopre_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my %knopre = ();
open (KNO, "<", $knopre_file) || die "cannot read $knopre_file\n";
while (<KNO>) {
    s{\s+\Z}{};
    ($aseqno, $lambda) = split(/\t/);
    $knopre{$aseqno} = $lambda;
} # while <KNO>
close(KNO);
print STDERR "# $0: " . scalar(%knopre) . " known predicates read from $knopre_file\n";
#----------------
my ($parms, $letter, $expr);
$callcode = "filter";
while (<>) {
#while (<DATA>) {
    s/\s+\Z//; # chompr
    $line = $_;
    my $nok = 0;
    if ($line =~ m{\tinsect2\t}) {
        my @aseqnos = $line =~ m{(A\d{6})}g;
        if (scalar(@aseqnos) == 3) {
            if (0) {
            } elsif (defined($knopre{$aseqnos[1]})) {
                $lambda = $knopre{$aseqnos[1]};
                $rseqno = $aseqnos[2];
            } elsif (defined($knopre{$aseqnos[2]})) {
                $lambda = $knopre{$aseqnos[2]};
                $rseqno = $aseqnos[1];
            } else {
                $nok = 1;
            }
        } else {
            $nok = 2;
        }
        if ($nok == 0) {
            print join("\t", $aseqnos[0], $callcode, 0, "new $rseqno()", $lambda) . "\n";
        }
    }
} # while <>
__DATA__
A077804	insect2	0	new A002378()	new A005100()
A078174	union2	0	new A000961()	new A070005()
A078512	insect2	0	new A002997()	new A013998()
A078649	union2	0	new A074262()	new A074263()
A080168	insect2	0	new A002145()	new A080166()
A087368	insect2	0	new A006450()	new A046034()
A087988	insect3	0	new A002113()	new A002778()	new A002780()
A088259	insect2	0	new A000045()	new A045718()
