#!perl

# Convert a tsv file into HTML
# @(#) $Id$
# 2019-02-20: -m init, term
# 2019-01-19: -m strip, CSS
# 2019-01-06, Georg Fischer
#
#:# usage:
#:#   perl tsv_html.pl -m mode input.tsv > output.html
#:#       -m var      aseqno + variable number of fields
#:#       -m delseq   deleted sequences from wiki
#:#       -m strip    comparision with 'stripped'
#:#       -m init     write start of index file
#:#       -m term     write end   of index file
#:#---------------------------------
use strict;
use integer;
my $index_name = "check_index.html";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d"  #:%02d\+01:00"
        , $year + 1900, $mon + 1, $mday, $hour);     # , $min, $sec, $isdst);

my $mode = "var";
if (scalar(@ARGV) == 0) {
	print `grep -E "^#:#" $0 | cut -b3-`;
	exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{m}) {
        $mode      =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $target = "Check";
my $title  = "Check";
my $infile = shift(@ARGV);
if ($infile =~ m{^(\w+_check)}) {
    $target = "$1:";
    $title = `grep -i $target makefile`;
    $title =~ s{\s+\Z}{};
    $title =~ s{$target\s*\#\s*}{};
    $target =~ s{\W}{}g;
    # print $title;
}
open(INF, "<", $infile) or die "cannot read \"$infile\"\n";
#---------------
if (0) {
} elsif ($mode =~ m{init}   ) {
    print &get_html_head("Index of maintenance worksheets");
    print "<tr><th class=\"bor\">Name</th>"
    	. "<th class=\"bor\">Count</th>"
    	. "<th class=\"bor\">Description</th></tr>\n";

} elsif ($mode =~ m{term}   ) {
    print &get_html_tail();
    
} elsif ($mode =~ m{var}   ) {
    print &get_html_head($title);
    if ($_ = <INF>) { # first line with labels
        my $line = $_;
        $line =~ s{\s+\Z}{}; # chompr
        my @labels = split(/\t/, $line);
        print "<tr><th class=\"bor\">" . join("</th><th class=\"bor\">", @labels) 
            . "</th></tr>\n";
    } # first line with labels
    
} elsif ($mode =~ m{delseq}) {
    print &get_html_head("Deleted sequences in Wiki log");
    print "<tr><th class=\"bor\">Keyword</th>"
        . "<th class=\"bor\">Count</th>"
        . "<th class=\"bor\" width=\"80%\">Occurrences</th></tr>\n";

} elsif ($mode =~ m{strip} ) {
    print &get_html_head("Comparision of first terms with b-file");
    print "<tr><th class=\"bor\">" . join("</th><th class=\"bor\">"
            , "Sequence"
            , "Author<br />... of b-f."
            , "Message"
            , "Offs.<br />ind1"
            , "Range"
            , "Terms<br />b-file"
             ) . "</th></tr>\n";
             
} else { 
    die "invalid mode \"$mode\"\n";
}
#---------------
my $count = 0;
while (<INF>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    $count ++;
    if (0) {

    } elsif ($mode =~ m{var}   ) {
        my @rest = split(/\t/, $line);
        my $aseqno = shift(@rest);
        print "<tr><td class=\"bor\"><a href=\"https://oeis.org/$aseqno\" target=\"_blank\">$aseqno</a></td>"
            . "<td class=\"bor\">" . join("</td><td class=\"bor\">", @rest) . "</td></tr>\n";

    } elsif ($mode =~ m{delseq}) {
        my ($aseqno, $rest) = split(/\t/, $line);
        print "<tr><td class=\"bor\">" . join("</td><td class=\"bor\">"
            , "<a href=\"https://oeis.org/$aseqno\" target=\"_blank\">$aseqno</a> $rest"
            ) . "</td></tr>\n";

    } elsif ($mode =~ m{strip} ) {
        my ($aseqno, $bixmin, $bixmax, $offset, $strip, $binit, $mess, $buthor) = split(/\t/, $line);
            $strip =~ s{\,}{ }g;
            $binit =~ s{\,}{ }g;
        my $seqno = substr($aseqno, 1);
        print "<tr><td class=\"bor\">" . join("</td><td class=\"bor\">"
            , "<a href=\"https://oeis.org/$aseqno\" target=\"_blank\">$aseqno</a>&nbsp;"
              . "<a href=\"https://oeis.org/edit\?seq=$aseqno\" target=\"_blank\">Ed.</a><br />&nbsp;"
              . "<a href=\"https://oeis.org/$aseqno/b$seqno.txt\" target=\"_blank\">b-file</a>"
            , "&nbsp;<br />$buthor"
            , "$mess"
            , "&nbsp;$offset&nbsp;<br /><span class=\"" . ($offset == $bixmin ? "refp" : "err") . "\">&nbsp;$bixmin&nbsp;</span>"        
            , "<br />$bixmin..$bixmax"
            , "<span class=\"warn\">$strip<br />$binit</span>"
            ) . "</td></tr>\n";
    }
} # while <INF>
close(INF);

if ($mode !~ m{init|term}) {
    open(IDX, ">>", $index_name) or die "cannot append to \"$index_name\"\n";
    print IDX "<tr><td class=\"bor\"><a href=\"$target.html\">$target</a></td>"
        . "<td class=\"bor\" align=\"right\">$count</td>"
        . "<td class=\"bor\">$title</td></tr>\n";
    print STDERR sprintf("%-16s %6d  %-64s\n", $target, $count, $title);
    close(IDX);
    print get_html_tail();
}
#-----------------------------
sub get_html_tail {
    my $result = <<"GFis";
</table>
<p>
GFis
    if ($mode !~ m{init|term}) {
        $result .= "$count records\n";
    }
    $result .= <<"GFis";
<br />Generated: $timestamp 
<br />Questions, suggestions: email <a href="mailto:georg.fischer\@t-online.de">Georg Fischer</a>
<br /><a href="https://oeis.org/wiki/Clear-cut_examples_of_keywords" target="_blank">List of keywords in OEIS Wiki</a>
</p>
</body>
</html>
GFis
} # get_html_tail
#-----------------------------
sub get_html_head {
    my ($title) = @_;
    return <<"GFis";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" [
]>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$target</title>
<meta name="generator" content="https://github.com/gfis/OEIS-mat/blob/master/bfcheck/tsv_html.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ vertical-align: top; }
th      { text-align: left; }
.arr    { text-align: right; background-color: white; color: black; }
.bor    { border-left  : 1px solid gray    ; padding-left: 8px; padding-right: 8px; 
          border-top   : 1px solid gray    ;
          border-right : 1px solid gray    ;                                
          border-bottom: 1px solid gray    ;  }
.refp   { background-color: lightgreen;    } /* refers to the partner */
.warn   { background-color: yellow;        } /* no reference to the partner and newer */
.comt   { background-color: peachpuff;     } /* lightpink; #fff0f0; a lightred like in history, for conclusion */
.err    { background-color: red; color: white; } /* for errors */
.refn   { background-color: greenyellow;   } /* no reference to the partner */
.more   { color:white  ; background-color: blue;      }
.dead   { color:white  ; background-color: gray;      }
.fini   { color:black  ; background-color: turquoise; }
.narrow { font-size    : smaller;  }
.prefor { font-family  : monospace; white-space: pre;
          font-size    : large; font-weight: bold; }
.same   { background-color:lightyellow }
</style>
</head>
<body>
<h3><a href="check_index.html" target="_blank">OEIS-mat</a> - $target</h3>
<h4>$title</h4>
<table class="bor">
GFis
} # get_html_head
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
p = floor((n + 2) / 2) for n >= 4: if n even then a(n) = 2^p + 4 * (2^(p - 4) - 1); if n odd then a(n) = 2^p + 4 * (2^(p - 3) - 1).