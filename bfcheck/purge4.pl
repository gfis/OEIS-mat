#!perl

# Repair garbled b-files b288723/4/5
# @(#) $Id$
# 2019-01-16, Georg Fischer
#
# usage:
#   perl purge4.pl filename > output
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $filename = shift(@ARGV);
$filename =~ m{(b\d{6})};
my $bseqno = $1;
#----------------------------------------------
if (1) {
	print <<"GFis";
# $bseqno.txt 
# Table of n, a(n) for n = 1..2000
# recovered from garbled b-file by Georg Fischer $timestamp
GFis
    my $buffer;
    open(FIL, "<", $filename) or die "cannot read $filename\n";
    read(FIL, $buffer, 100000000); # 100 MB
    close(FIL);
    my $error = "";
    my @indexes = grep { m{\S} } # keep non-empty lines only
        map {
            s{\#.*} {};  # remove comments
            s{\A\s+}{};  # remove leading whitespace
            s{\s+\Z}{};  # trailing whitespace
            $_
        } split(/\n/, $buffer);
    my $ind  = 0; # index in @indexes
    my $sind = $indexes[$ind]; # sequence index
    my $find = $sind; # file index
    my $term;
    while ($ind < scalar(@indexes)) {
        $sind = $indexes[$ind    ];
        $term = $indexes[$ind + 1];
        $ind += 2;
        if ($sind != $find) {
        	print STDERR "# sequence problem ind=$ind, sind=$sind, find=$find, term=$term\n";
        	$find = $sind;
        }
        print "$find $term\n";
        $find ++;
    } # while $ind
}
#----------------------
__DATA__
1 2
2 2
3 2
4 3
5 1
6 1

7
 
2

8
 
2

9
 
3

10
 
3

11
 
3

12
 
1