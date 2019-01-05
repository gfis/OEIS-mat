#!perl

# Remove synthesized b-files
# @(#) $Id$
# 2019-01-05, Georg Fischer
#
# Remove files which start with the following line
# # A300005 (b-file synthesized from sequence entry)
#
# usage:
#   perl rm_synthesized.pl filename
#---------------------------------
use strict;
use integer;
my ($count_ok, $count_rm) = (0, 0);
my $dir = shift(@ARGV);
foreach my $filename(glob("$dir/*")) {
    if (open(FIL, "<", $filename)) {
        my $line = <FIL>; # read 1st line
        close(FIL);
        # print $line;
        if ($line =~ m{\A\# A\d+\s+\(b\-file synthesized from sequence entry\)}) {
            # print "# remove $filename\n";
            unlink($filename);
            $count_rm ++;
        } else {
            $count_ok ++;
            if ($count_ok % 256 == 0) {
            	print "# keep $filename\n";
            }
        }
    } else { 
        print "cannot read \"$filename\"\n";
    }
} # foreach
print STDERR "# $count_rm files removed, $count_ok kept\n";
__DATA__
# keep b30/b321358.txt
# 11178 files removed, 6805 kept
