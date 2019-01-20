#!perl

# Prepare wget command lines for many sequences
# @(#) $Id$
# 2019-01-19, Georg Fischer
#
# usage:
#   perl aseq_wget.pl -n nseq -m (text|json) infile > outfile
#---------------------------------
use strict;
use integer;
use warnings;

my $TIMESTAMP = &iso_time(time());
# get options
my $action = "comp";
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $nseq   = 15;
my $mode   = "text";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-m}) {
        $mode   = shift(@ARGV);
    } elsif ($opt =~ m{\-n}) {
        $nseq   = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----
my $url_prefix = "https://oeis.org/search?q="; # https://oeis.org/search?q=id:A062882|id:A064680&fmt=text
my $buffer = "";
my $count = 0;
while (<>) {
    m{\A(A\d+)};
    my $aseqno = $1;
    $buffer .= "|id:$aseqno";
    $count ++;
    if ($count % $nseq == 0) {
        &print_buffer();
    }
} # while <>
&print_buffer();
#----
sub print_buffer {
    print "$url_prefix" . substr($buffer, 1) . "\&fmt=$mode\n";
    $buffer = "";
}
#----
sub iso_time {
    my ($unix_time) = @_;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
    return sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
} # iso_time
__DATA__
