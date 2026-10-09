#!perl

# Extract parameters for of the form a(n) = aseqno(n) oper num
# @(#) $Id$
# 2026-10-05: copied from anopan.pl
# 2022-12-08, Georg Fischer: copied from dersimple.pl
#
#:# Usage:
#:#     grep ... jcat25.txt ... \
#:#     | perl roban0.pl [-d debug] > $@.tmp 2> $@.rest.tmp
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#:#     -f  file with aseqno, offset1, terms (default $(COMMON)/joeis_ofter.txt)
#:# Reads ofter_file for implemented jOEIS sequences with their offsets and first terms
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options
#----------------
my $aseqno;
my $line;
my $name;
my $cond;
# while (<DATA>) {
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    ($aseqno, $name) = split(/\t/, $line);
    $cond = "";
    $name = $name || "";
    $name =~ s{\Athe *}{};
    $name =~ s{\. \- \_.*}{}; # remove autor
    $name =~ s{[From[^\]]+\]}{}; # remove author
    if (0) {
    #                     1                            1  2  2
    } elsif ($name =~ s{ *(for|where|when|unless|if|iff) *(.*)}{}) {
        $cond = "$1 $2";            
    #                       1     1
    } elsif ($name =~ s{\, *(n *\>)}{}) {
        $cond = "for $1";
    }
    $name =~ s{[\,\.]? *\Z}{};
    $cond =~ s{[\,\.]? *\Z}{}; 
    if (length($name) > 4) {
        print join("\t", $aseqno, $name, $cond) ."\n"; 
    }
} # while
#----------------
__DATA__
A163563	J001462(n + 1) - 1
A385515	J002277(n - 12) for n >= 18
A166460	J002808(n-1)-1 for n>2
