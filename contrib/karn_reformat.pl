#!perl

# @(#) $Id$
# reformat Mathematica programs
# 2020-10-04, Georg Fischer

use strict;
use integer;
use warnings;

undef $/; # slurp mode
my $block = <>; # read whole file
$block =~ s{\s}{}g;
$block =~ s{\]\:\=}{\]\:\=\n  }g;
$block =~ s{\],}{\],\n    }g;
$block =~ s{\;}{\;\n}g;
print "$block\n";
__DATA__
