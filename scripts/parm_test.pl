#!perl

# Test long shell parameter lists
# @(#) $Id$
# 2026-11-02, Georg Fischer
#
#:# Usage:
#:#   perl parm_test.pl $@
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $gits =  $ENV{'GITS'};
my $ip = 0;
my $line = join(" ", map {
    $ip++;
    "\$$ip=$_"
    } @ARGV);
print "$line\n";

