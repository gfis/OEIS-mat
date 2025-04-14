#!perl

# Show terms of sequences in parallel
# 2024-04-04, Georg Fischer: copied from nyi.pl
#
#:# Usage:
#:#   perl parallel.pl -s start [-l len] A-numbers... 
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug      = 0;
my $start      = 1;
my $len        = 1;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if ($opt   =~ m{d}) {
        $debug = shift(@ARGV);
    } 
    if ($opt   =~ m{l}) {
        $len   = shift(@ARGV);
    } 
    if ($opt   =~ m{s}) {
        $start = shift(@ARGV);
    }
} # while $opt
my @anos = @ARGV;
#----------------
my $buffer = "";
my $aseqno;
my $rseqno;
if ($from_clip == 0) { # read from STDIN or files
    while (<>) {
        $buffer .= $_;
    }
} else { # get it from the clipboard
    $buffer = `powershell -command Get-Clipboard`;
}
my %hash = ();
foreach my $line (split(/\n/, $buffer)) {
    my %lasn;
    foreach $rseqno ($line =~ m{(A\d{6})}g) {
        $lasn{$rseqno} = 1;
    } # foreach $rseqno
    foreach $rseqno (keys(%lasn)) {
        if (length($query) > 0 || defined($ofters{$rseqno})) {
            $hash{$rseqno} = 1;
        } else {
            $line =~ s{$rseqno}{"€" . substr($rseqno, 1)}eg;
        }
    } # foreach $rseqno
    if (0) {
    } elsif ($print_it > 0) {
        $line =~ s{^€}{A}; # assume that the leading column is nyi anyway
        print "$line\n";
    } elsif (length($query) > 0) {
        $line =~ s{^.. [€A](\d+) *}{}; # assume that the leading column is nyi anyway
        my $seqno = $1;
        if ($line !~ m{€}) {
            print join("\t", "A$seqno", $query, 0, $line) . "\n";
        }
    } else {
        print "$line\n";
    }
} # $line
my $ari = 0;
my $nyi = 0;
if (length($query) == 0 && $print_it == 0) {
    foreach my $key (sort(keys(%hash))) {
        my $value = $hash{$key};
        if ($value == 0) {
            $nyi ++;
        } else {
            $ari ++;
        }
        if ($only_nyi) {
            if ($value <= 0) {
                print join("\t", $key, $value) . "\n";
            }
        } else {
                print join("\t", $key, $value, ($value <= 0) ? "**" : "") . "\n";
        }
    } # for $key
}
if (length($query) == 0) {
    print sprintf("# %4d not implemented in jOEIS\n", $nyi);
    print sprintf("# %4d already implemented\n"     , $ari);
}
#================
__DATA__
A004018	parmof2	0	A000144	2	Number of ways of writing n as a sum of 2 squares.
A005875	parmof2	0	A000144	3	Number of ways of writing n as a sum of 3 squares.
A000118	parmof2	0	A000144	4 	Number of ways of writing n as a sum of 4 squares;
A000132	parmof2	0	A000144	5 	Number of ways of writing n as a sum of 5 squares.
