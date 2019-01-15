#!perl

# List maximum length of lines
# @(#) $Id$
# 2019-01-12, Georg Fischer
#
# usage:
#	perl linelen.pl [-a] < input > output
#       -a  keep A-number 
#---------------------------------
use strict;
use integer;
# get options
my $with_anum = 0;
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-a}) {
        $with_anum = 1;
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------------------------------------
while (<>) {
	next if m{\A\s*\#};
    s/\s+\Z//; # chompr
    my $line = $_;
    my $len = length($line);
    if ($with_anum == 1) { # keep A-number
    	$line =~ s{(A\d{6}).*}{$1 $len};
    } else {
    	$line = $len;
    }
    print "$line\n";
} # while <>
exit(0);
#----------------------
__DATA__
%S A007079 1,2,24,2640,3230080,48251508480,9307700611292160,
%T A007079 24061983498249428379648,855847205541481495117975879680,
%U A007079 427102683126284520201657800159366676480,3035991776725501434069099002640396043332019814400,311112533558482034321687955029997989477274014274150137856000
%N A007079 Number of labeled regular tournaments with 2n+1 nodes.

C:\Users\User\work\gits\OEIS-mat\bfcheck>perl linelen.pl
60
66
161
65

C:\Users\User\work\gits\OEIS-mat\bfcheck>perl linelen.pl -a
%S A007079 60
%T A007079 66
%U A007079 161
%N A007079 65
