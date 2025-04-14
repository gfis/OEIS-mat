#!perl

# Check whether the terms in "stripped" all increase b at most 1.
# @(#) $Id$
# 2024-06-08, Georg Fischer, copied from highest_term1.pl
#
#:# usage:
#:#   perl slow_increase.pl stripped > outputfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug      = 0; # 0 (none), 1 (some), 2 (more)
if (0 and scalar(@ARGV) == 0) {
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

my $extreme = 0;
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    my ($aseqno, $termlist) = split(/ /, $line);
    my @terms = split(/\,/, substr($termlist, 1));
    my $busy = 1; # assume success
    my $prev = shift(@terms);
    next if $prev < 0;
    my $it = 0; 
    while ($busy && $it < scalar@terms) {
        my $term = $terms[$it];
        if (length($term) > 8) { # not interested in very large numbers
            $busy = 0;
            last;
        }
        my $diff = $term - $prev;
        if ($diff < 0 || $diff > 1) {
            $busy = 0;
        }
        $prev = $term;
        $it ++;
    } # while
    if ($busy >= 1) {
        print "$line\n";
    }
} # while <>
#------------------------------------
__DATA__
