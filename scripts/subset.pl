#!perl

# subset.pl - extract all [A-Z]numbers from a file and produce a sequence of (//oeisdata.seq, joeis.java)
# @(#) $Id$
# 2026-07-07, Georg Fischer
#
#:# Usage:
#:#   perl subset.pl [infile] > outfile
#:#
#:#   If there is no input, the clipboard is examined for A-numbers.
#:#   Reads from $GITS/oeisdata/seq/Annn (with endirect) and from $GITS/joeis/src/ann.
#:#   Omits %D and %H records.
#---------------------------------
use strict;
use integer;
use warnings;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min);
my $gits        =  $ENV{'GITS'};
my $oeisdata    = "$gits/oeisdata/seq";
my $joeis       = "$gits/joeis/src/irvine/oeis";
my $vector_file = "$gits/joeis-lite/internal/fischer/reflect/vector.txt";
open(VEC, "<", $vector_file) || die "cannot read $vector_file";
my $line = <VEC>;
close(VEC);
my @vector = split(//, $line);
my $veclen = scalar(@vector);

my $debug  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $state = 0;
my %senos = (); # gather these seqnos
my @alist = ();

while(<DATA>) {
#while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    #                        1          1
    push(@alist, ($line =~ m{([A-Z]\d{6})}g));
} # while <>

if (scalar(@alist) == 0) { # nothing read
    my $clip = `powershell -command Get-Clipboard`;
    my $line = $clip;
    #                        1          1
    push(@alist, ($line =~ m{([A-Z]\d{6})}g));
}
# print join("\n", @alist) . "\n";
# exit;

foreach my $ano (@alist) {
    my $letter = substr($ano, 0, 1);
    my $seno   = substr($ano, 1);
    $senos{$seno} = $letter;
}
foreach my $seno (sort(keys(%senos))) {
    print "#----------------------------------------------------------------\n";
    print "#!queue\tA$seno\t0\t->\t0\t$vector[$seno]${seno}\tunk\n";
    open(OUT, "| endirect");
    if (open(SEQ, "<", "$oeisdata/A" . substr($seno, 0, 3) . "/A$seno.seq")) {
        while(<SEQ>) {
            if (!m{\A.[DH]}) { # omit %D, %H records
                print OUT "//$_"; # make Java comment
            }
        } # while <SEQ>
        close(SEQ);
    }
    close(OUT);
    print "//%--------\n";
    if (open(SRC, "<",    "$joeis/a" . substr($seno, 0, 3) . "/A$seno.java")) {
        while(<SRC>) {
            print "$_";
        } # while <SRC>
        close(SRC);
    }
} # foreach $seno
__DATA__
A000079 (b=1), A081294 (b=2), A007613 (b=3), A070775 (b=4), A070782 (b=5), A070967 (b=6), A094211 (b=7), A070832 (b=8), A094213 (b=9), A070833 (b=10).
