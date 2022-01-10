#!perl

# 'obsc' A018189
# 2021-12-19, Georg Fischer: this sequences needs a definition.
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my @terms = (1, 2, 4, 6, 12, 16, 32, 44, 86, 98, 172, 196, 300, 302, 426, 474, 656, 704, 986, 956
   , 1180, 1230, 1562, 1530, 1918, 2000, 2622, 2638, 3294, 3244, 4048, 3876, 4970, 4886, 5680, 6072
   , 6406, 6590, 7590, 7434, 8134, 8404, 10154, 9938, 11958);
my $nterm = scalar(@terms);
my $gen = 0;
foreach my $term (@terms) {
  # print(sprintf("%024b\n", $term));
  # print(sprintf("%2d: %" . ($nterm - $gen) . "s%0" . ($gen + 2) . "b\n", $gen, " ", $term));
  print(sprintf("%2d: %b\n", $gen, $term));
  $gen ++;
} # foreach $term
__DATA__
#1 by N. J. A. Sloane at Wed Dec 11 03:00:00 EST 1996
NAME	
Population of "Triangle" cellular automaton at nth generation.
DATA	
1, 2, 4, 6, 12, 16, 32, 44, 86, 98, 172, 196, 300, 302, 426, 474, 656, 704, 986, 956, 1180, 1230, 1562, 1530, 1918, 2000, 2622, 2638, 3294, 3244, 4048, 3876, 4970, 4886, 5680, 6072, 6406, 6590, 7590, 7434, 8134, 8404, 10154, 9938, 11958
OFFSET	
0,2
REFERENCES	
LINKS	
<a href="http://www.msu.edu/user/dobrzele/DigitalPhysics">Digital Physics home page</a>
KEYWORD	
nonn
AUTHOR	
Joel Dobrzelewski (dobrzele@cvm.msu.edu)
STATUS	
approved
J. Dobrzelewski and P. Petrov, <a href="http://cvm.msu.edu/~dobrzele/dp/Automata/">Cellular Automata</a></a>