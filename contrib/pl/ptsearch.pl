#!perl

# Evaluate 4 variants of the PartitionTransform 
# and search for the results in all sequences
# @(#) $Id$
# 2022-10-01, Georg Fischer
#
#:# Usage:
#:#   cut -f1,3 bfdata.txt \
#:#   | perl ptsearch.pl [-d debug] | tee output.tmp
#---------------------------------
use strict;
use integer;
use warnings;

my $tablname = "ptstabl.tmp";
my $debug  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my ($aseqno, $callcode, $offset, $data);
while(<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    ($aseqno, $callcode, $offset, $data) = split(/\t/, $line);
    my @terms = split(/\,/, $data);
#   my ($x1, $x2, $x3, $x4, $x5, $x6) = splice(@terms, 0, 6);
#   my @a1 = ($x1, $x2, $x1**2, $x3, 2*$x1*$x2, $x1**3, $x4, 2*$x1*$x3 + $x2**2, 3*$x1**2*$x2, $x1**4, $x5, 2*$x1*$x4 + 2*$x2*$x3, 3*$x1**2*$x3 + 3*$x1*$x2**2, 4*$x1**3*$x2, $x1**5
#       , $x6, 2*$x1*$x5 + 2*$x2*$x4 + $x3**2, 3*$x1**2*$x4 + 6*$x1*$x2*$x3 + $x2**3, 4*$x1**3*$x3 + 6*$x1**2*$x2**2, 5*$x1**4*$x2, $x1**6
#       );
    my ($a, $b, $c, $d, $e, $f, $g, $h) = splice(@terms, 0, 8);
    my @a1 = 
($a
,$b,$a**2
,$c,2*$a*$b,$a**3
,$d,2*$a*$c+$b**2,3*$a**2*$b,$a**4
,$e,2*$a*$d+2*$b*$c,3*$a**2*$c+3*$a*$b**2,4*$a**3*$b,$a**5
,$f,2*$a*$e+2*$b*$d+$c**2,3*$a**2*$d+6*$a*$b*$c+$b**3,4*$a**3*$c+6*$a**2*$b**2,5*$a**4*$b,$a**6
,$g,2*$a*$f+2*$b*$e+2*$c*$d,3*$a**2*$e+6*$a*$b*$d+3*$a*$c**2+3*$b**2*$c,4*$a**3*$d+12*$a**2*$b*$c+4*$a*$b**3,5*$a**4*$c+10*$a**3*$b**2,6*$a**5*$b,$a**7
,$h,2*$a*$g+2*$b*$f+2*$c*$e+$d**2,3*$a**2*$f+6*$a*$b*$e+6*$a*$c*$d+3*$b**2*$d+3*$b*$c**2,4*$a**3*$e+12*$a**2*$b*$d+6*$a**2*$c**2+12*$a*$b**2*$c+$b**4,5*$a**4*$d+20*$a**3*$b*$c+10*$a**2*$b**3,6*$a**5*$c+15*$a**4*$b**2,7*$a**6*$b,$a**8
);

#   my @a0 = ($x1, 0, $x2, $x1**2, 0, $x3, 2*$x1*$x2, $x1**3, 0, $x4, 2*$x1*$x3 + $x2**2, 3*$x1**2*$x2, $x1**4, 0, $x5, 2*$x1*$x4 + 2*$x2*$x3, 3*$x1**2*$x3 + 3*$x1*$x2**2, 4*$x1**3*$x2, $x1**5);
#   my @r1 = ($x1, $x1**2, $x2, $x1**3, 2*$x1*$x2, $x3, $x1**4, 3*$x1**2*$x2, 2*$x1*$x3 + $x2**2, $x4, $x1**5, 4*$x1**3*$x2, 3*$x1**2*$x3 + 3*$x1*$x2**2, 2*$x1*$x4 + 2*$x2*$x3, $x5);
#   my @r0 = ($x1, 0, $x1**2, $x2, 0, $x1**3, 2*$x1*$x2, $x3, 0, $x1**4, 3*$x1**2*$x2, 2*$x1*$x3 + $x2**2, $x4, 0, $x1**5, 4*$x1**3*$x2, 3*$x1**2*$x3 + 3*$x1*$x2**2, 2*$x1*$x4 + 2*$x2*$x3, $x5);
    &search("a1", @a1);
    # &search("a0", @a0);
    # &search("r1", @r1);
    # &search("r0", @r0);
} # while <>
#----
sub search {
    my ($code, @ax) = @_;
    my $alist = join(",", @ax);
    if ($debug >= 1) {
        print "# alist\t$alist\n";
    }
    return if $alist !~ m{[\-2-9]};
    # return if $alist eq "1,1,1,1,2,1,1,3,3,1,1,4,6,4,1,1,5,10,10,5,1";
    my $found = 0;
    foreach my $line (split(/\r?\n/, `grep -P \"\\t$alist\" $tablname`)) {
        $found ++;
        if ($found == 1) {
            print "========\n" if $code eq "a1";
            print join("\t", $aseqno, "--$code", 0, $alist) . "\n";
        }
        my ($rseqno, $dummy, $offset, $data) = split(/\t/, $line);
        print join("\t", $rseqno, "..$code", $offset, substr($data, 0, 64)) . "\n";
    }
} # while <>
__DATA__
# input:
A000001 search  0       0,1,1,1,2,1,2
A000002 search  1       1,2,2,1,1,2,1
A000003 search  1       1,1,1,1,2,2,1
A000004 search  0       0,0,0,0,0,0,0
# grep in:
A000369 tabl    1       1,3,1,21,9,1,231,111,18

# output:
========
A317710 --a1    0       1,2,1,3,4,1,4,10,6,1,5,20,21,8,1,6,35,56,36,10,1,7,56,126,120,55,12,1,8,84,252,330,220,78,14,1
A078812 ..a1    0       1,2,1,3,4,1,4,10,6,1,5,20,21,8,1,6,35,56,36,10,1,7,56,126,120,55
========
A317742 --a1    0       1,0,1,1,0,1,0,2,0,1,1,0,3,0,1,0,3,0,4,0,1,1,0,6,0,5,0,1,0,4,0,10,0,6,0,1
A168561 ..a1    0       1,0,1,1,0,1,0,2,0,1,1,0,3,0,1,0,3,0,4,0,1,1,0,6,0,5,0,1,0,4,0,10
