#!perl

# Extract unions of 2 or 3 sequences
# @(#) $Id$
# 2023-08-14, Georg Fischer; CC=67
#
#:# Usage:
#:#   perl nyi.pl -q union 
#:#   | perl union.pl [-d debug] > union.gen
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

my $line;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $callcode, $offset, $name) = split(/\t/, $line);
    my @parms   = ();
    if(0) { 
    } elsif ($name =~ m{ (A\d+) (and) (A\d+) and (A\d+)}  ) { 
        $callcode = "union3";
        push(@parms, map { "new " . $_ . "()" } ($1, $3, $4));
    } elsif ($name =~ m{ (A\d+) and (A\d+)}             ) { 
        $callcode = "union2";
        push(@parms, map { "new " . $_ . "()" } ($1, $2));
    } else {
    }
    if (scalar(@parms) > 0) {
        print        join("\t", $aseqno, $callcode, 1, @parms, $name) . "\n";
    } else {
        print STDERR join("\t", $aseqno, $callcode, 1, @parms, $name) . "\n";
    }
} # while <>
#--------------------------------------------
__DATA__
A329269 union2  0       Union of the triangular numbers A000217 and A005123.
A330533 union2  0       Union of A046986 and A046987. Complement of A046985 with respect to A007691.
A333635 union2  0       Union of A005574 and A085722.
A334393 union2  0       Union of A008578 and A053810.
A340840 union2  0       Union of the highly composite and superabundant numbers.
A347450 union2  0       Union of A028982 and A119899.
A347450 union2  0       Union of A028260 and A001105.
A350916 union2  0       Union of A350917, A350919, A350920, A350921, A350922, A350923, A103974, A350924, A350925, A350926.
A351863 union2  0       Union of A008864 and A100484.
A352403 union2  0       Union of A002878, A077444, A259131, A267797, etc., minus each sequence's first entry.
A354144 union2  0       Union of A000961 and A001358.
A354925 union2  0       Union of powers of primes and even semiprimes.
A354925 union2  0       Union of A000961 and A100484.
A355580 union2  0       Union of A151821, (A000244 \ {3}) and 36*A003586.