#!perl

# Compare 3 sequences 
# @(#) $Id$
# 2022-04-14, Georg Fischer
#
#:# usage:
#:#   perl a103530.pl > outfile
#---------------------------------
use strict;
use integer;
use warnings;

my $basedir   = "../common/bfile";
my $debug     = 0; # none
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my %pow2;
for (my $ind = 3; $ind < 32; $ind ++) {
    $pow2{1 << $ind} = $ind - 2;
}
for (my $ind = 3; $ind < 32; $ind ++) {
    $pow2{1 << $ind} = 1 << ($ind - 3);
}
  
my @terms1 = &read_bfile("A103530", 3);
my @terms2 = &read_bfile("A263449", 0);
my @terms3 = &read_bfile("A182105", 0);
my $len1 = scalar(@terms1);
my $len2 = scalar(@terms2);
my $len3 = scalar(@terms3);
my $len = $len1;
if ($len > $len2) { $len = $len2; }
if ($len > $len3) { $len = $len3; } # minimum of 3 lengths
my $ind3 = 0;
for (my $ind = 0; $ind < $len; $ind ++) {
    my $diff1 = - $terms1[$ind] + $terms2[$ind];
#   if ($diff1 != 0 || $diff2 != 0 || $diff3 != 0) {
#       print join("\t", "$ind:", $diff1, $diff2, $diff3, "", $terms1[$ind], $terms2[$ind], $terms3[$ind]) . "\n";
#   }
    if ($diff1 != 0) {
        my $t2 = $pow2{$diff1};
        my $diff2 = $t2 - $terms3[$ind3 ++];
        print join("\t", "$ind:", $diff1, $pow2{$diff1}, "", $terms1[$ind], $terms2[$ind], $diff2) . "\n";
        print STDERR "$pow2{$diff1},"
    } else {
    #   print "$ind:\n";
    }
}
print STDERR "\n";
#----------------------
sub read_bfile {
    my ($aseqno, $skip) = @_;
    my $filename = "$basedir/b" . substr($aseqno, 1) . ".txt";
    open(FIL, "<", $filename) or die "cannot read $filename\n";
    my $read_len = 100000000;
    my $buffer;
    read(FIL, $buffer, $read_len); # 100 MB, should be less than 10 MB
    close(FIL);
    my @terms = ();
    my $index = 0;
    foreach my $line (split(/\n/, $buffer)) {
        if ($line =~ m{\A\s*(\-?\d+)\s(\-?\d+)}o) { # index space term
            my ($dummy, $term) = ($1, $2);
            $term = $term < 0 ? - $term : $term; # abs
            $index ++;
            if ($index > $skip) {
                push(@terms, $term);
            }
        } else { 
            # ignore comments and blank lines
        } # ignore
    } # foreach $line
    return @terms;
} # read_bfile
#----------------------
__DATA__
A103530 287     2,1,2,1,4,3,2,5,8,7,6,1,12,11,10,13,16,15,14,9,4,19,18,21
A263449 283     1,4,3,2,5,8,7,6,9,12,11,10,13,16,15,14,17,20,19,18,21,24,23,22,25,28,27,26,29,32,31,30
A174375 261     0,1,-2,-1,-4,-3,2,-5,-8,-7,-10,7,-12,5,-6,-13,-16,-15,-18,-17,12,13,-14,11,-24,9,-26,23,4