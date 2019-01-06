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
print STDERR sprintf("# $dir: %6d synthesized b-files removed, %6d user bfiles kept\n"
    , $count_rm, $count_ok);
__DATA__
# b00:  27002 ssynthesized b-files removed,  22997 user b-files kept
# b05:  32878 ssynthesized b-files removed,  17122 user b-files kept
# b10:  35195 ssynthesized b-files removed,  14805 user b-files kept
# b15:  29153 ssynthesized b-files removed,  20847 user b-files kept
# b20:  19586 ssynthesized b-files removed,  30414 user b-files kept
# b25:  17085 ssynthesized b-files removed,  32915 user b-files kept
# b30:  11220 ssynthesized b-files removed,   6763 user b-files kept
# b35:      0 ssynthesized b-files removed,      0 user b-files kept

