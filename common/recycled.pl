#!perl

# Search missing A-numbers
# @(#) $Id$
# 2019-10-30, Georg Fischer
#
#:# usage:
#:#   perl holes.pl names > outputfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug      = 0; # 0 (none), 1 (some), 2 (more)
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
my $oseqno = 0;
while (<>) {
    s/\s+\Z//; # chompr
    next if m{\A\s*\#};
    my $nseqno = substr($_, 1, 6) + 0;
    while ($nseqno > $oseqno + 1) {
        $oseqno ++;
        print "$oseqno\n";
    }
    $oseqno = $nseqno;
} # while <>
#------------------------------------
__DATA__
