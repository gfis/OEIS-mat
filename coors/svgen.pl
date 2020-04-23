#!perl

# Generate SVG for tilings
# @(#) $Id$
# 2020-04-22, Georg Fischer
#
#:# usage:
#:#   perl svgen.pl [-a action] [-m max-lines] [-w width] lines.data > output.svg
#:#    -a "proc" process "#" lines; -a "java" writes SVG pre- and postlude
#:#    -n limits the numbers of <line> elements which are written
#:#    -w width, SVG x coordinate (default -16..+16) 
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $debug = 0;
my $nmax = 2961947;
my $w1 = 16;
my $action = "proc";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt    = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{a}) {
        $action = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt  =~ m{n}) {
        $nmax   = shift(@ARGV);
    } elsif ($opt  =~ m{w}) {
        $w1     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my $w2 = $w1 * 2;
my $head = <<"GFis";
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN"
 "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd" [
 <!ATTLIST svg xmlns:xlink CDATA #FIXED "http://www.w3.org/1999/xlink">
]>
<!--
    2020-04-22, Georg Fischer: test of tiling generation
-->
<svg width="192mm" height="192mm"
  viewBox="-$w1 -$w1 $w2 $w2" 
  xmlns="http://www.w3.org/2000/svg" 
  >
  <defs>
    <style type="text/css"><![CDATA[
      rect, line {
          stroke-width:0.1
      }
      .k0 { fill: crimson     ; stroke: crimson     }
      .k1 { fill: yellow      ; stroke: yellow      }
      .k2 { fill: orange      ; stroke: orange      }
      .k3 { fill: lime        ; stroke: lime        }
      .k4 { fill: turquoise   ; stroke: turquoise   }
      .k5 { fill: blue        ; stroke: blue        }
      .k6 { fill: darkblue    ; stroke: darkblue    }
      .k7 { fill: darkmagenta ; stroke: darkmagenta }
      .k8 { fill: black       ; stroke: black       }
    ]]></style>
  </defs>
<title>Tiling</title>
<g id="graph0" >
    <rect x="-$w1" y="-$w1" width="$w2" height="$w2" />
GFis
my $tail = <<'GFis';
</g>
</svg>
GFis
if (0) {
} elsif ($action eq "java") {
  print join("\n", map {
    my $line = $_;
    $line =~ s{\"}{\\\"}g;
    "          + \"$line\\n\""
    } split(/\r?\n/, $head . "\<\!\-\-=========\-\-\>\n" . $tail));
} else { # action = proc
  print $head;
  while (<>) {
      s{\s+\Z}{}; # chompr
      my $line = $_;
      if ($line =~ m{\A\#\s*line:\s*(\S*)}) {
          my $rest = $1;
          my ($class, @cos) = split(/\,/, $rest);
          print "<line class=\"$class\" x1=\"$cos[0]\" y1=\"$cos[1]\"  x2=\"$cos[2]\" y2=\"$cos[3]\" />\n";
          # e.g. <line x1="0" y1="0"  x2="8" y2="-8"  />
          $nmax --;
          last if $nmax <= 0;
      } 
  } # while <>
  print $tail;
} # switch action
__DATA__