#!perl

# Check whether all vertices of a tiling occur in the OEIS names
# https://oeis.org/A250120/a250120.html
# @(#) $Id$
# 2020-05-06, Georg Fischer
#
#:# usage:
#:#   make check2
#:#   perl check2.pl check2.tmp > output
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
my @otuple  = ("", "");
my @ntuple  = ("", "");
my $buffer = "#";
my $count  = 1;
my $fail   = 0;
while (<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    @ntuple = split(/\t/, $line);
    if (substr($ntuple[1], 0, length($ntuple[1]) - 2) ne
        substr($otuple[1], 0, length($otuple[1]) - 2)
       ) { # identical without vertex no
       @otuple = @ntuple;
       &output();
    } # identical
    $ntuple[1] =~ m{(Gal\.\d+\.\d+\.)(\d+)\Z};
    my $tileid = $1;
    my $galv   = $2;
    while ($count < $galv) {
        $buffer .= "$tileid$count/A...... ";
        print STDERR "$tileid$count\tmissing\n";
        $fail ++;
        $count ++;
    } # while
    $buffer .= "$ntuple[1]/$ntuple[0] ";
    $count ++;
} # while <>
&output();
#-----
sub output {
    $buffer =~ m{Gal\.(\d+)};
    my $uniord = $1;
    my $prefix = $fail == 0 ? "ok \t" : "???\t";
    print "$prefix $buffer\n";
    $buffer = "";
    $count = 1;
    $fail  = 0;
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