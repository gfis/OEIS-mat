#!perl

# Convert table of
# https://arxiv.org/pdf/q-alg/9412013.pdf
# into b-file
# 2020-08-23, Georg Fischer

use strict;
use warnings;
use integer;

my $primex = 0;
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{p}) {
        $primex    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

print <<'GFis';
# Table of n, a(n) for n=1..194
# A337094 a(n) = N(chi_n) for the irreducible characters chi_n of the Monster simple group (cf. comments).
# Table 1 at the end of the Harada-Lang article, converted to HTML and extracted by Georg Fischer, Aug 24 2020
GFis
my $count = 0;
while (<DATA>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if (0) {
    } elsif ($line =~ m{\A\s*\<tr}) {
    	$count = 0;
    } elsif ($line =~ m{\A\s*\<td}) {
    	$count ++;
    } elsif ($line =~ m{\<span lang\=EN\-US\>(\d+)}) { # relevant
        my $num = $1;
        if (0) {
        } elsif ($count == 1) {
        	print $num;
        } elsif ($count == 2) {
        	print " $num\n";
        	$count = 17;
        }
    } # relevant
} # while <DATA>
print "\n\n";
__DATA__
 <tr style='height:17.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:17.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:17.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2331309585756753201600</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:17.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19.23.29.31.41.47.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.25pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>11841091337275200</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19.23.29.31.41</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>437868837806400</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19.23.29.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>4</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>467584848090400</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19.23.41.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>5</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>38732026132800</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19.47.59</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>6</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>20350725595200</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19.31.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>7</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>87358471200</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>7.11.13.17.23.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>8</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>7820482269600</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>7.11.13.17.29.31.71</span></span></p>
  </td>
 </tr>
 <tr style='height:11.8pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>9</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>18526958049600</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.11.13.23.29.41.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>10</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>222987885120</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.7.11.13.19.23.59</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>11</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>8490081600</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.11.13.19.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.25pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>12</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>19445025600</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.11.13.19.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>13</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>9958865716800</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19.23.31</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>14</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>73513400</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.11.13.17</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>15</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2244077793757800</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19.23.29.41.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>16</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3749442460305984</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>13.23.29.31.41.47.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>17</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3749442460305984</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>13.23.29.31.41.47.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>18</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>726818400</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>7.11.19.23</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>19</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>9182927033280</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.7.11.13.19.29.41.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>20</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>35703027360</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.11.13.17.31.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>21</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>98066928960</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.7.11.13.17.23.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>22</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>22789166400</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>23</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>451392480</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.11.23.59</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>24</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>295495200</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>7.11.13.41</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>25</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>253955520</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.7.13.17.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>26</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>479256378753600</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.19.31.41.47.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>27</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>479256378753600</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.19.31.41.47.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>28</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>27003936960</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.11.13.17.19.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>29</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>81995760</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>5.7.11.17.29</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>30</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>69618669120</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.11.13.19.31.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>31</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>21416915520</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.11.13.17.19.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>32</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>214885440</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.7.11.17.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>33</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2882880</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.11.13</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>34</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>332640</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.11</span></span></p>
  </td>
 </tr>
 <tr style='height:11.8pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>35</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>786240</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.7.13</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>36</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>11147099040</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.11.23.31.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>37</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>331962190560</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.11.13.17.19.23.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>38</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>333637920</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.11.17.59</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>39</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>845013600</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>19.29.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>40</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>845013600</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>19.29.71</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>41</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>16676856385200</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>5<sup>2</sup>11.23.31.47.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>42</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>16676856385200</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>5<sup>2</sup>11.23.31.47.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>43</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>186902100</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>3</sup>5<sup>2</sup>7.11.29.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.35pt'>
  <td width=23 style='width:17.05pt;padding:0cm 0cm 0cm 0cm;height:12.35pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>44</span></span></p>
  </td>
  <td width=160 style='width:120.0pt;padding:0cm 0cm 0cm 0cm;height:12.35pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>46955594400</span></span></p>
  </td>
  <td width=253 style='width:189.95pt;padding:0cm 0cm 0cm 0cm;height:12.35pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2</span></span><span
  class=CharacterStyle1><span lang=EN-US>5</span><span lang=EN-US>3.5</span></span><span
  class=CharacterStyle1><span lang=EN-US>2</span><span lang=EN-US>11.13.41.47.71</span></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=EN-US style='font-size:12.0pt;font-family:"Times New Roman",serif'><br
clear=all style='page-break-before:always'>
</span>

<div class=WordSection2>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse'>
 <tr style='height:24.35pt'>
  <td width=36 valign=top style='width:26.65pt;padding:0cm 0cm 0cm 0cm;
  height:24.35pt'>
  <p class=Style2 style='text-autospace:ideograph-numeric ideograph-other'><img
  width=13 height=12 src="001_Harada_lang_9412013-Dateien/image002.png"
  align=left alt="Textfeld: 15"></p>
  </td>
  <td width=94 valign=top style='width:70.3pt;padding:0cm 0cm 0cm 0cm;
  height:24.35pt'>
  <p class=Style2 style='text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle2><span lang=EN-US style='font-family:"Arial",sans-serif'>&nbsp;</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:24.35pt'>
  <p class=Style2 align=right style='margin-right:12.55pt;text-align:right;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle2><b><span lang=EN-US style='font-size:6.5pt;font-family:
  "Arial",sans-serif;letter-spacing:1.0pt'>MCKAY-THOMPSON SERIES</span></b></span></p>
  </td>
 </tr>
 <tr style='height:17.25pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:17.25pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>45</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:17.25pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>46955594400</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:17.25pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3.5<sup>2</sup>11.13.41.47.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>46</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>54880846020</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>2</sup>5.7.11.13.17.19.23.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>47</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>105386400</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>7.17.41</span></span></p>
  </td>
 </tr>
 <tr style='height:11.8pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>48</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>105386400</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>7.17.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>49</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>49584815280</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>5.7.11.13.17.19.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>50</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>6404580</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>2</sup>5.7.13.17.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>51</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>12916800</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5<sup>2</sup>13.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>52</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>646027200</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.13.17.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>53</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>228731328</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>7.17.47.71</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>54</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>228731328</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>7.17.47.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>55</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>19044013248</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>13.23.29.31.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>56</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>10944013248</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>13.23.29.31.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>57</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>25077360</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3.5.7.11.23.59</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>58</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>198918720</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.7.11.13.23</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>59</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>19433872080</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>5.7.23.29.41.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>60</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>19433872080</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>5.7.23.29.41.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>61</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2784600</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>2</sup>5<sup>2</sup>7.13.17</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>62</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>245044800</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.11.13.17</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>63</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>57266969760</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.11.13.17.19.41</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>64</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>157477320</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>2</sup>5.7.11.13.19.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>65</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>818809200</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>2</sup>5<sup>2</sup>11.23.29.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>66</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>263877213600</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>7.11.13.19.41.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>67</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1588466880</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.11.13.19.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>68</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>33005280</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3.5.7.11.19.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>69</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>937440</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.31</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>70</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>32864832</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>7.11.13.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>71</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>182584514112</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.7.11.13.17.29.41.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>72</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>182584514112</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.7.11.13.17.29.41.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>73</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>982080</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.11.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>74</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>33542208</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>7.47.59</span></span></p>
  </td>
 </tr>
 <tr style='height:11.8pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>75</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>33542208</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>7.47.59</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>76</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>7650720</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.11.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>77</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>931170240</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.11.13.17.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>78</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>33754921200</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>2</sup>5<sup>2</sup>7.11.13.17.19.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>79</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>42325920</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.13.17.19</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>80</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>4969440</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.17.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>81</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>63126554400</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>7.13.23.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>82</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>63126554400</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>7.13.23.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>83</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>208304928</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>13.23.41.59</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>84</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>208304928</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>13.23.41.59</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>85</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>704223936</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>13.23.29.47</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>86</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>704223936</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>13.23.29.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>87</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1235520</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.11.13</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>88</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3967200</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>19.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>89</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>11737440</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.11.13.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>90</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>11737440</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.11.13.19</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>91</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2542811040</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.11.17.19.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>92</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>22102080</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5.7.11.13.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>93</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1441440</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.11.13</span></span></p>
  </td>
 </tr>
 <tr style='height:12.55pt'>
  <td width=36 style='width:26.65pt;padding:0cm 0cm 0cm 0cm;height:12.55pt'>
  <p class=Style1 align=center style='margin-left:0cm;text-align:center;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>94</span></span></p>
  </td>
  <td width=94 style='width:70.3pt;padding:0cm 0cm 0cm 0cm;height:12.55pt'>
  <p class=Style1 style='margin-left:5.3pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>879840</span></span></p>
  </td>
  <td width=193 style='width:145.05pt;padding:0cm 0cm 0cm 0cm;height:12.55pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.13.47</span></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=EN-US style='font-size:12.0pt;font-family:"Times New Roman",serif'><br
clear=all style='page-break-before:always'>
</span>

<div class=WordSection3>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse'>
 <tr style='height:24.35pt'>
  <td width=29 valign=top style='width:21.85pt;padding:0cm 0cm 0cm 0cm;
  height:24.35pt'>
  <p class=Style2 style='text-autospace:ideograph-numeric ideograph-other'><img
  width=13 height=12 src="001_Harada_lang_9412013-Dateien/image003.png"
  align=left alt="Textfeld: 16"></p>
  </td>
  <td width=331 colspan=2 style='width:248.15pt;padding:0cm 0cm 0cm 0cm;
  height:24.35pt'>
  <p class=Style2 align=right style='margin-right:13.8pt;text-align:right;
  text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle2><b><span lang=EN-US style='font-size:6.5pt;font-family:
  "Arial",sans-serif;letter-spacing:1.2pt'>KOICHIRO HARADA AND MONG LUNG LANG</span></b></span></p>
  </td>
 </tr>
 <tr style='height:17.25pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:17.25pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>95</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:17.25pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>16576560</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:17.25pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>2</sup>5.7.11.13.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>96</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>21677040</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>2</sup>5.7.11.17.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>97</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>5267201940</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>2</sup>5.7.11.13.23.31.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>98</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>7900200</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>3</sup>5<sup>2</sup>7.11.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>99</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1660401600</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5<sup>2</sup>11.13.41.59</span></span></p>
  </td>
 </tr>
 <tr style='height:11.8pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>100</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1660401600</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5<sup>2</sup>11.13.41.59</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>101</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>932769600</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5<sup>2</sup>7.17.23.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.25pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>102</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>7601451872175</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3<sup>3</sup>5<sup>2</sup>7.17.19.29.41.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>103</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>7601451872175</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3<sup>3</sup>5<sup>2</sup>7.17.19.29.41.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>104</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>6511680</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.17.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>105</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>5844589984800</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>7.19.31.47.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>106</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>5844589984800</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>7.19.31.47.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>107</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2434219200</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.19.31.41</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>108</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2434219200</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.19.31.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>109</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>280800</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>13</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>110</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>947520</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>111</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1016747424</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>7.11.17.29.31</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>112</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>386100</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>3</sup>5<sup>2</sup>11.13</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>113</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>6568800</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3.5<sup>2</sup>7.17.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>114</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1374912</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>7.11.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>115</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>151200</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>7</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>116</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>92400</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3.5<sup>2</sup>7.11</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>117</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>411840</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.11.13</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>118</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>19562400</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>11.13.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>119</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>12524852340</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>3</sup>5.7.11.13.17.29.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>120</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>41801760</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.11.13.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>121</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>75698280</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>3</sup>5.7.17.19.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>122</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>8148853440</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.13.17.31.59</span></span></p>
  </td>
 </tr>
 <tr style='height:11.8pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>123</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>864175548600</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>3</sup>5<sup>2</sup>7.13.17.31.47.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>124</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3456702194400</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>7.13.17.31.47.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>125</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3456702194400</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>7.13.17.31.47.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>126</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>119700</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>2</sup>5<sup>2</sup>7.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>127</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>13695552</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>13.31.59</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>128</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>752016096</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>13.23.41.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.25pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>129</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>752016096</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>13.23.41.71</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>130</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>19320840</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>2</sup>5.7.11.17.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>131</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1004683680</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.11.13.17.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>132</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>164160</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>133</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>14379596431200</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19.29.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>134</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>14208480</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.11.13.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>135</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>497653200</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>5<sup>2</sup>11.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>136</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>497653200</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>5<sup>2</sup>11.59.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>137</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>995276700</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>3</sup>5<sup>2</sup>11.23.31.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>138</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>5109369408</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>11.13.23.29.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>139</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>514080</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.17</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>140</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>59017104226080</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.11.13.17.19.29.31.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>141</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1151710560</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.11.13.17.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>142</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3767400</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>2</sup>5<sup>2</sup>7.13.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>143</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>7600320</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.13.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.55pt'>
  <td width=29 style='width:21.85pt;padding:0cm 0cm 0cm 0cm;height:12.55pt'>
  <p class=Style1 style='margin-left:2.4pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>144</span></span></p>
  </td>
  <td width=107 style='width:79.9pt;padding:0cm 0cm 0cm 0cm;height:12.55pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>11823840</span></span></p>
  </td>
  <td width=224 style='width:168.25pt;padding:0cm 0cm 0cm 0cm;height:12.55pt'>
  <p class=Style2 style='margin-left:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle2><b><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7.17.23</span></b></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=EN-US style='font-size:12.0pt;font-family:"Times New Roman",serif'><br
clear=all style='page-break-before:always'>
</span>

<div class=WordSection4>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse'>
 <tr style='height:24.35pt'>
  <td width=52 valign=top style='width:39.0pt;padding:0cm 0cm 0cm 0cm;
  height:24.35pt'>
  <p class=Style2 style='text-autospace:ideograph-numeric ideograph-other'><img
  width=13 height=13 src="001_Harada_lang_9412013-Dateien/image004.png"
  align=left alt="Textfeld: 17"></p>
  </td>
  <td width=112 valign=top style='width:83.75pt;padding:0cm 0cm 0cm 0cm;
  height:24.35pt'>
  <p class=Style2 style='text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle2><span lang=EN-US style='font-family:"Arial",sans-serif'>&nbsp;</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:24.35pt'>
  <p class=Style2 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle2><b><span lang=EN-US style='font-size:6.5pt;font-family:
  "Arial",sans-serif;letter-spacing:1.0pt'>MCKAY-THOMPSON SERIES</span></b></span></p>
  </td>
 </tr>
 <tr style='height:17.25pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:17.25pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>145</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:17.25pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>8558550</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:17.25pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2.3<sup>2</sup>5<sup>2</sup>7.11.13.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>146</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>664020</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>2</sup>5.7.17.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>147</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>4320</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5</span></span></p>
  </td>
 </tr>
 <tr style='height:11.8pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>148</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>655188534</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2.3<sup>3</sup>7.11.13.17.23.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>149</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>102240</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>150</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>157248</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>7.13</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>151</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>26489342880</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.11.13.17.23.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.25pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>152</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>93276960</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3.5.7.17.23.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>153</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>13137600</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5<sup>2</sup>7.17.23</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>154</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>428400</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>2</sup>5<sup>2</sup>7.17</span></span></p>
  </td>
 </tr>
 <tr style='height:12.25pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>155</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>18221280</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.25pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3.5.7.11.17.29</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>156</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>190072512</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>7.17.47.59</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>157</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>21176100</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>3</sup>5<sup>2</sup>11.23.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>158</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>37130940</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>3</sup>5.7.11.19.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>159</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>852390</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2.3<sup>3</sup>5.7.11.41</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>160</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>184363200</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.31.59</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>161</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>108803771818560</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.13.17.19.23.29.41.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>162</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1657656</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>2</sup>7.11.13.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>163</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>345290400</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5<sup>2</sup>7.13.17.31</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>164</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>90014400</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.19.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>165</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>30240</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.7</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>166</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>4032</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>7</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>167</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>4062240</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.13.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>168</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3204801600</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5<sup>2</sup>7.11.13.23.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>169</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>24196995900</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>2</sup>3<sup>2</sup>5<sup>2</sup>7.11.17.19.23.47</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>170</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>668304</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>7.13.17</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>171</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>73920</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5.7.11</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>172</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>6983776800</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5<sup>2</sup>7.11.13.17.19</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>173</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>32959080</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>3</sup>3<sup>2</sup>5.7.11.29.41</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>174</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3115200</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5<sup>2</sup>11.59</span></span></p>
  </td>
 </tr>
 <tr style='height:11.8pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>175</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>48163383908640</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.8pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.7.11.13.17.19.31.47.71</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>176</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>427211200</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>5<sup>2</sup>13.19.23.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>177</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>858816</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>7.71</span></span></p>
  </td>
 </tr>
 <tr style='height:11.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>178</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>21416915520</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.11.13.17.19.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>179</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>14400</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup></span></span></p>
  </td>
 </tr>
 <tr style='height:12.75pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>180</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>14400</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup></span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>181</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>154881891350</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2.3<sup>3</sup>5<sup>2</sup>11.13.19.29.31.47</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>182</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2009280</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5.7.13.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>183</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>6339168</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>11.23.29</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>184</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>26429760</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>5.7.19.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>185</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>32730048</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>3</sup>13.31.47</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>186</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>7425600</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3.5<sup>2</sup>7.13.17</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>187</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>8237275200</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5<sup>2</sup>7.11.17.19.23</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>188</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>15120</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>4</sup>3<sup>3</sup>5.7</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>189</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>54774720</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>6</sup>3<sup>2</sup>5.7.11.13.19</span></span></p>
  </td>
 </tr>
 <tr style='height:11.75pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>190</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>27989280</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:11.75pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>3</sup>5.11.19.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>191</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>34272</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>7.17</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>192</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3500640</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>2<sup>5</sup>3<sup>2</sup>5.11.13.17</span></span></p>
  </td>
 </tr>
 <tr style='height:12.0pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>193</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1049200425</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.0pt'>
  <p class=Style1 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>3<sup>3</sup>5<sup>2</sup>7.13.19.29.31</span></span></p>
  </td>
 </tr>
 <tr style='height:12.55pt'>
  <td width=52 style='width:39.0pt;padding:0cm 0cm 0cm 0cm;height:12.55pt'>
  <p class=Style3 style='margin-right:5.05pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>194</span></span></p>
  </td>
  <td width=112 style='width:83.75pt;padding:0cm 0cm 0cm 0cm;height:12.55pt'>
  <p class=Style1 style='margin-left:5.25pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle1><span lang=EN-US>1404480</span></span></p>
  </td>
  <td width=196 style='width:147.25pt;padding:0cm 0cm 0cm 0cm;height:12.55pt'>
  <p class=Style2 style='margin-left:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
  class=CharacterStyle2><b><span lang=EN-US>2<sup>6</sup>3.5.7.11.19</span></b></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=EN-US style='font-size:12.0pt;font-family:"Times New Roman",serif'><br
clear=all style='page-break-before:always'>
</span>

<div class=WordSection5>

<p class=Style2 align=center style='margin-top:14.4pt;text-align:center;
text-autospace:ideograph-numeric ideograph-other'><img width=483 height=13
src="001_Harada_lang_9412013-Dateien/image005.png" align=left
alt="Textfeld: 18   KOICHIRO HARADA AND MONG LUNG LANG"><span
class=CharacterStyle2><span lang=EN-US style='font-size:7.5pt'>REFERENCES</span></span></p>

<p class=Style2 style='margin-top:23.4pt;margin-right:0cm;margin-bottom:0cm;
margin-left:21.6pt;margin-bottom:.0001pt;text-indent:-14.4pt;line-height:112%;
text-autospace:ideograph-numeric ideograph-other'><span class=CharacterStyle2><b><span
lang=EN-US style='font-size:7.0pt;line-height:112%;font-family:"Arial",sans-serif;
letter-spacing:.65pt'>[1]<span style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></b></span><span
class=CharacterStyle2><b><span lang=EN-US style='font-size:7.0pt;line-height:
112%;font-family:"Arial",sans-serif;letter-spacing:.65pt'>J. H. Conway,
Understanding Groups like &#915;</span></b></span><span class=CharacterStyle2><span
lang=EN-US style='font-size:5.5pt;line-height:112%;font-family:"Arial",sans-serif;
letter-spacing:1.15pt'>0</span></span><span class=CharacterStyle2><b><span
lang=EN-US style='font-size:7.0pt;line-height:112%;font-family:"Arial",sans-serif;
letter-spacing:.65pt'>(</span></b></span><span class=CharacterStyle2><b><span
lang=EN-US style='font-size:7.0pt;line-height:112%;font-family:"Tahoma",sans-serif;
letter-spacing:1.15pt'>N</span></b></span><span class=CharacterStyle2><b><span
lang=EN-US style='font-size:7.0pt;line-height:112%;font-family:"Arial",sans-serif;
letter-spacing:.65pt'>), (preprint).</span></b></span></p>

<p class=Style5 style='text-autospace:ideograph-numeric ideograph-other'><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.65pt'>[2]<span
style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.35pt'>J. H.
Conway and S. P. Norton, Monstrous Moonshine, Bull. London Math. Soc. </span></span><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.85pt;font-weight:
normal'>11 </span><span lang=EN-US style='letter-spacing:.35pt'>(1979), </span><span
lang=EN-US style='letter-spacing:.2pt'>308-338.</span></span></p>

<p class=Style5 style='margin-top:3.6pt;text-autospace:ideograph-numeric ideograph-other'><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.65pt'>[3]<span
style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.35pt'>I. Frenkel,
J. Lepowsky and A. Meurman, Vertex Operator Algebras and the Monster, Aca­</span><span
lang=EN-US style='letter-spacing:.3pt'>demic Press, Inc. (1988).</span></span></p>

<p class=Style5 style='text-autospace:ideograph-numeric ideograph-other'><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.65pt'>[4]<span
style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.5pt'>K. Harada,
Modular Functions, Modular Forms and Finite Group, Lecture Notes at The </span><span
lang=EN-US style='letter-spacing:.45pt'>Ohio State University, (1987).</span></span></p>

<p class=Style5 style='text-autospace:ideograph-numeric ideograph-other'><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.65pt'>[5]<span
style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.3pt'>H. Helling,
On the Commensurablility Classes of Rational Modular Group, J. London Math. </span><span
lang=EN-US style='letter-spacing:.4pt'>Soc. </span></span><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.9pt;font-weight:
normal'>2 </span><span lang=EN-US style='letter-spacing:.4pt'>(1970), 67-72.</span></span></p>

<p class=Style5 style='text-autospace:ideograph-numeric ideograph-other'><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.65pt'>[6]<span
style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:.35pt'>J. McKay
and H. Strauss, The q-series of Monstrous Moonshine and the Decomposition of </span><span
lang=EN-US style='letter-spacing:.5pt'>the Head Characters, Comm. Alg. </span></span><span
class=CharacterStyle3><span lang=EN-US style='letter-spacing:1.0pt;font-weight:
normal'>18(1) </span><span lang=EN-US style='letter-spacing:.5pt'>(1990),
253-278.</span></span></p>

<p class=Style4 style='margin-top:9.0pt;margin-right:3.6pt;margin-bottom:0cm;
margin-left:0cm;margin-bottom:.0001pt;text-autospace:ideograph-numeric ideograph-other'><span
class=CharacterStyle3><span lang=EN-US style='font-size:8.5pt;line-height:122%;
letter-spacing:.7pt;font-weight:normal'>DEPARTMENT OF MATHEMATICS, THE OHIO
STATE UNIVERSITY, COLUM­</span></span><span class=CharacterStyle3><span
lang=EN-US style='font-size:8.5pt;line-height:122%;letter-spacing:.3pt;
font-weight:normal'>BUS, OHIO 43210, USA</span></span></p>

<p class=Style4 style='line-height:normal;text-autospace:ideograph-numeric ideograph-other'><span
class=CharacterStyle3><span lang=EN-US style='font-size:8.5pt;letter-spacing:
.35pt'>E-mail address: <u><span style='color:blue'><a
href="mailto:haradako@math.ohio-state.edu"><span style='color:blue'>haradako@math.ohio-state.edu</span></a></span></u></span></span></p>

<p class=Style4 style='margin-top:10.8pt;margin-right:3.6pt;margin-bottom:0cm;
margin-left:0cm;margin-bottom:.0001pt;text-autospace:ideograph-numeric ideograph-other'><span
class=CharacterStyle3><span lang=EN-US style='font-size:8.5pt;line-height:122%;
letter-spacing:.6pt;font-weight:normal'>DEPARTMENT OF MATHEMATICS, NITIONAL
UNIVERSITY OF SINGAPORE, </span></span><span class=CharacterStyle3><span
lang=EN-US style='font-size:8.5pt;line-height:122%;letter-spacing:.5pt;
font-weight:normal'>SINGAPORE 0511, REPUBLIC OF SINGAPORE</span></span></p>

<p class=Style4 style='line-height:115%;text-autospace:ideograph-numeric ideograph-other'><span
class=CharacterStyle3><span lang=EN-US style='font-size:8.5pt;line-height:115%;
letter-spacing:.3pt'>E-mail address: <u><span style='color:blue'><a
href="mailto:matlml@leonis.nus.sg"><span style='color:blue'>matlml@leonis.nus.sg</span></a></span></u></span></span></p>

</div>

</body>

</html>
