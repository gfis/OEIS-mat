#!perl

# Search for duplicated terms in bflong_sort
# @(#) $Id$
# 2019-03-20, Georg Fischer: copied from ./extract_bflong.pl
#
#:# usage:
#:#   perl mine_bflong.pl inputfile > outputfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug      = 0; # 0 (none), 1 (some), 2 (more)
my $maxref     = 6;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-m}) {
        $maxref    = shift(@ARGV);
   } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

while (<>) {
    s/\s+\Z//; # chompr
    my $aseqno = substr($_, 0, 7);
    my $name   = substr($_, 8);
    my @rseqnos = ($name =~ m{(A\d{6})}g);
    if (scalar(@rseqnos) >= 3) {
    	my %hash = ();
    	foreach my $rseqno (@rseqnos) {
    		$hash{$rseqno} = 1;
    	}
    	my $count = scalar(%hash);
    	if ($count >= $maxref) {
    		print "$aseqno $count $name\n";
    	}
    }
} # while <>
#------------------------------------
__DATA__
