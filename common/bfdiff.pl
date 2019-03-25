#!perl

# get 2 bf-files and compare them
# @(#) $Id$
# 2019-03-22, Georg Fischer
#
#:# usage:
#:#   perl bfdiff.pl seqno1 seqno2 > diff-listing
#---------------------------------
use strict;

if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
for my $i (1..2) {
	my $seqno = shift(@ARGV); 
	$seqno =~ s{\D}{}g; 
	my $bfile = sprintf("b%06d.txt", $seqno);
	print `wget -q -O - https://oeis.org/$bfile | grep -E \"^ *[0-9]\" | gawk \'{print \$2}\' > x$i.tmp`;
} # for $i
print `diff -y x1.tmp x2.tmp`
