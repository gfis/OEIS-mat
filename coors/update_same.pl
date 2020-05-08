#!perl

# Check whether all vertices of a tiling occur in the OEIS names
# https://oeis.org/A250120/a250120.html
# @(#) $Id$
# 2020-05-06, Georg Fischer
#
#:# usage:
#:#   make update_same
#:#   perl update_same.pl update_same.tmp > update_same.sql.tmp
#:#   $(DBAT) -f update_same.sql.tmp
#----
#---------------------------------


use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $debug = 0;
my $nmax = 16;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug = shift(@ARGV);
    } elsif ($opt  =~ m{n}) {
        $nmax = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $state  = "init";
my ($oseqno, $ogalid, $oseq) = ("", "", "");
my ($nseqno, $ngalid, $nseq) = ("", "", "");
#                        [0]       1        2       
#   $(DBAT) -x "SELECT c.aseqno, c.galid, c.sequence \
#     FROM coors c\
#     ORDER BY 3, 1" \
while (<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    ($nseqno, $ngalid, $nseq) = split(/\t/, $line);
    print "-- " . join("\t", ($nseqno, $ngalid, $nseq)) . "\n";
    if ($nseq eq $oseq) { # identical sequences
        if ($nseqno =~ m{\Aunk}) {
            $nseqno = $oseqno;
            print "UPDATE coors SET aseqno = \'$nseqno\' WHERE galid = \'$ngalid\';\n";
        }
    } # identical
    ($oseqno, $ogalid, $oseq) = ($nseqno, $ngalid, $nseq);
} # while <>
print "COMMIT;\n";
#-----
sub output {
} # output

__DATA__
A310246 Gal.3.1.1
A310769 Gal.3.1.2
A310693 Gal.3.1.3
A312065 Gal.3.10.1
A312901 Gal.3.10.2
A314677 Gal.3.10.3
A311508 Gal.3.11.1
A311855 Gal.3.11.2
A312284 Gal.3.11.3
A311494 Gal.3.12.1
A311807 Gal.3.12.2
A312247 Gal.3.12.3
A313110 Gal.3.13.1
A313510 Gal.3.13.3