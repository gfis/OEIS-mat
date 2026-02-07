#!perl

# Merge computed periods into signat_eval.tmp
# @(#) $Id$
# 2026-02-05: Georg Fischer, copied from signat_eval.pl
#
#:# Usage:
#:#   perl signat_merge.pl [-d debug] [-f period-file] signat_eval.tmp > signat.txt
#:#      -d mode 0=none, 1=some, 2=more
#:#      -f file with peridos computed by signat_period.pl
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug = 0;
my $sigfile = "signat_period.tmp";
# if (scalar(@ARGV) == 0) {
#     print `grep -E "^#:#" $0 | cut -b3-`;
#     exit;
# }
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{c}) {
        &create_sql();
        exit(0);
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{f}) {
        $sigfile   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my %sigs = ();
open(PER, "<", $sigfile) || die "cannot read $sigfile\n";
while (<PER>) {
    s/\s+\Z//; # chompr
    my ($signat, $period) = split(/\t/);
    $sigs{$signat} = $period;
} # while <PER>
close(PER);
#----
my ($line, $aseqno, $type25, $sigord, $longord, $wordord, $signature, $keyword);
while (<>) {
    s/\s+\Z//; # chompr
    ($aseqno, $type25, $sigord, $longord, $signature, $keyword) = split(/\t/);
    if (defined($sigs{$signature})) {
        my $signat = $sigs{$signature};
        if (0) {
        } elsif ($keyword eq "other") { 
            $keyword = $signat;
        } elsif ($keyword =~ m{^period}) { 
            $keyword = $signat;
        } else {
            $keyword .= ",$signat";
        }
    }
    print join("\t", $aseqno, $type25, $sigord, $longord, $signature, $keyword) . "\n";
} # while <>
# end main
#-------------------------------------------------
__DATA__
0,0,6	period=3*6
0,0,9	period=3*9
0,1	period=2
0,1,0,-1	period=6*-1
--
A000004	#	1	1	1	constant
A000007	#	1	1	1	constant
A000008	#	18	18	1,1,-1,0,1,-1,-1,1,0,1,-1,-1,1,0,-1,1,1,-1	other
A000012	#	1	1	1	constant
A000027	#	2	2	2,-1	binom=2
A000032	#	2	2	1,1	fibon
A000034	#	2	2	0,1	period=2
A000035	#	2	2	0,1	period=2
