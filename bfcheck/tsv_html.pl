#!perl

# Convert a tsv file into HTML
# @(#) $Id$
# 2019-01-06, Georg Fischer
#
# usage:
#   perl tsv_html.pl -m mode input.tsv > output.html
#---------------------------------
use strict;
use integer;

my $mode = "delseq";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{m}) {
        $mode      =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

print <<"GFis";
<html>
<body>
<pre>
GFis
my $count = 0;
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    $count ++;
    my @fields = split(/\t/, $line);
    if (0) {
    } elsif ($mode =~ m{delseq}) {
        $line = "<a href=\"https://oeis.org/$fields[0]\" target=\"_blank\">$fields[0]</a> $fields[1]";
    }
    print "$line\n";
} # while <>
print "$count records\n";
print <<"GFis";
</pre>
</body>
</html>
GFis
__DATA__
<li> <a href="http://oeis.org/A200220">A200220</a> (Luschny) withdrawn in favor of <a href="http://oeis.org/A070824">A070824</a> &#8212; R. J. Mathar, P. Luschny, Nov 16 2011</li>
<li> <a href="http://oeis.org/A200248">A200248</a> (Sloane) rifo <a href="http://oeis.org/A130911">A130911</a> &#8212; N. J. A. Sloane, Nov 16 2011</li>
<li> <a href="http://oeis.org/A200046">A200046</a> (Deleham) powers of 2 repeated &#8212; T. D. Noe, Nov 14 2011</li>
<li> <a href="http://oeis.org/A200045">A200045</a> (Deleham) Lucas numbers in an array &#8212; T. D. Noe, Nov 14 2011</li>
<li> <a href="http://oeis.org/A200089">A200089</a> (Borgo) same as <a href="http://oeis.org/A073002">A073002</a> &#8212; T. D. Noe, Nov 13 2011</li>
<li> <a href="http://oeis.org/A293925">A293925</a> (Rajarshi Maiti) NOGI — Editors, Nov 16 2017</li>
<li> <a href="http://oeis.org/A294152">A294152</a> (Halfdan Skjerning) NOGI &#8212; Editors, Nov 15 2017</li>
<li> <a href="http://oeis.org/A293687">A293687</a>, <a href="http://oeis.org/A294921">A294921</a> (A. W. Ferencz) rifo <a href="http://oeis.org/A007494">A007494</a>, <a href="http://oeis.org/A032766">A032766</a> &#8212; Editors, Nov 15 2017</li>
<li> <a href="http://oeis.org/A295086">A295086</a> (Burghard Herrmann) Duplicate of <a href="http://oeis.org/A190250">A190250</a> &#8212; Editors, Nov 15 2017</li>
<li> <a href="http://oeis.org/A294992">A294992</a> (M. F. Hasler) merged into <a href="http://oeis.org/A000194">A000194</a> - <a href="/wiki/User:N._J._A._Sloane" title="User:N. J. A. Sloane">N. J. A. Sloane</a> 03:11, 14 November 2017 (UTC)</li>
