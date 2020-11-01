#!perl

# Convert a triangle of antidiagonals (read from north-east to south-west) to an array
# @(#) $Id$
# 2020-08-01, Georg Fischer
#
#:# Usage:
#:#   perl triarray.pl [-a aseqno] [-b bfdir] [-d debug] > outfile
#:#       -a OEIS A-number
#:#       -b directory with b-files to be investigated
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (scalar(@ARGV) < 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $aseqno = "A285357";
my $bfdir = "../common/bfile";
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{a}) {
        $aseqno    = shift(@ARGV);
    } elsif ($opt  =~ m{b}) {
        $bfdir     = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @t; # triangular matrix
my $line;

my @terms = &read_bfile($aseqno);
if (1) {
    my $nterm = scalar(@terms);
    my $ind = 0;
    my $n = 0;
    my $k;
    my $busy = 1;
    while ($busy > 0 and $ind < $nterm) { # build an array T(n,k) with the triangle
        if ($ind + $n + 1 < $nterm) { # complete row still available
            for ($k = 0; $k <= $n; $k ++) {
                $t[$n][$k] = $terms[$ind ++];
            } # for $k
            $n ++;
        } else { # incomplete row
            $busy = 0;
        }
    } # while $ind
    my $nmax = $n - 1;
    my $ffind = $ind;
    
    # now print the rows for the array
    for ($k = 0; $k <= $n; $k ++) {
        for ($n = $k; $n <= $nmax; $n ++) {
            print sprintf("%9d", &get($n, $n - $k));
        } # for n
        print "\n";
    } # for k
} # if 1
#----
sub get { # n, k
    my ($n, $k) = @_;
    return ($k >= 0 and $k <= $n) ? ($t[$n][$k]) : 0;
} # get
#----
sub get_row { # n = row number
    my ($n) = @_;
    my $k;
    my @row = ();
    for ($k = 0; $k <= $n; $k ++) {
        push(@row, &get($n, $k));
    } # for k
    return @row;
} # get_row
#----
sub read_bfile {
    my ($aseqno) = @_;
    my $buffer;
    my $src_file = "$bfdir/b" . substr($aseqno, 1) . ".txt";
    open(FIL, "<", $src_file) or die "cannot read $src_file\n";
    read(FIL, $buffer, 100000000); # 100 MB
    close(FIL);
    my @terms = grep { m{\S} } # keep non-empty lines only
            map { 
                s{\#.*}{};      # remove comments
                s{\A\s+}{};     # remove leading whitespace
                s{\s+\Z}{};     # remove trailing whitespace
                s{\A\-?\d+\s+}{}; # remove index
                $_
            } split(/\n/, $buffer);
    print STDERR "# $src_file read with " . scalar(@terms) . " terms\n";
    return @terms;
} # sub read_bfile
#--------------------------------------------
__DATA__
A007318 1,1,1,1,2,1,1,3,3,1,1,4,6,4,1,1,5,10,10,5,1,1,6,15,20,15,6,1,1,7,21,35,35,21,7,1,1,8,28,56,70,56,28,8,1,1,9,36,84,126,126,84,36,9,1,1,10,45,120,210,252,210,120,45,10,1,1,11,55,165,330,462,462,330,165,55,11,1

