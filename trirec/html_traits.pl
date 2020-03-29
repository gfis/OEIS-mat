#!perl

# Prepare traits for HTML page
# @(#) $Id$
# 2020-03-29: copied from prep_traits.pl, and merged with ../common/html_check-pl
# 2020-03-28: changes for Peter; Wolfgang = 73
# 2020-03-23, Georg Fischer
#
#:# Usage:
#:#   perl html_traits.pl traits4.tmp > traits5.tmp
#--------------------------------------------------------
use strict;
use integer;
use warnings;
use utf8;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $oeis_url   = "https://oeis.org/";
# $oeis_url      = "http://localhost/cgi-bin/oeis.pl?&aseqno=";
my $target = "Traits of Triangles";
my $clabor = " class=\"bor\"";
# $clabor = "";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

print &get_html_head("Traits of <a href=\"https://oeis.org\">OEIS</a> Triangles");
print "<thead><tr><th $clabor>"
    . join("</th><th $clabor>", "Trait", "\&Delta;", "Key", "Seq", "Key", "SeqName", "Author, Year", "Data")
    . "</th></tr></thead><tbody>\n";

my $oseqno = "A000000"; # old aseqno
my $count = 0;
my $seqcount = 0;
while (<>) {
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    if ($line =~ m{\A(A\d+)}) {
        $count ++;
        # last if $count > 256;
        # relates to a following line in trimore.pl 
        my ($aseqno, $trait, $tseqno, $tname, $termlist, $tkeyw, $author, $akeyw) = split(/\t/, $line);
        if ($aseqno eq $oseqno) {
            # $aseqno = "";
        } else {
            $oseqno = $aseqno;
            $seqcount ++;
        }
        if ($seqcount % 2 == 0) {
        	$aseqno = "<span class=\"pair\">$aseqno</span>";
        }
        $akeyw   = &keyword($akeyw);
        $tkeyw   = &keyword($tkeyw);
        $author  = $author || "";
        $tname   = $tname  || "";
        $author =~ s{[A-Z]\. }{}g;
        $author =~ s{ [A-Z][a-z][a-z] \d\d }{ };
        $author =~ s{\A\_([\wé]+\s+)?([\wé]+)\_}{$2}g;
        $author = substr($author, 0, 16);
        $termlist = substr($termlist, 0,16);
        $termlist =~ s{\,}{\, }g;
        print "<tr><td $clabor>";
        print map {
            s{(A\d\d\d\d+)}{\<a href\=\"$oeis_url$1\" target\=\"_blank\"\>$1\<\/a\>}g;
            $_
            } join("</td><td $clabor>"
            , $trait
            , $aseqno
            , $akeyw
            , $tseqno
            , $tkeyw
            , $tname
            , $author
            , $termlist
            ) . "\n";
        print "</td></tr>\n";
    } else {
        # ignore
    }
} # while <>
print get_html_tail();
#--------
sub keyword {
    my ($keyw) = @_;
    $keyw = $keyw   || "";
    $keyw =~ s{nonn|easy|sign|changed|tabl|full|synth}{}g;
    $keyw =~ s{more}{\<span class=\"warn\"\>more\<\/span\>};
    $keyw =~ s{nice}{\<span class=\"refp\"\>nice\<\/span\>};
    $keyw =~ s{core}{\<span class=\"refn\"\>core\<\/span\>};
    $keyw =~ s{\,+}{\,}g;
    $keyw =~ s{\A\,+}{};     
    $keyw =~ s{\,+\Z}{};     
    return $keyw;
} # keyw    
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
<meta name="generator" content="https://github.com/gfis/OEIS-mat/blob/master/trirec/html_traits.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
/*
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ vertical-align: top; }
th      { text-align: left; }
*/
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
.pair   { color:white  ; background-color: lightgray; }
.fini   { color:black  ; background-color: turquoise; }
.narrow { font-size    : smaller;  }
.prefor { font-family  : monospace; white-space: pre;
          font-size    : large; font-weight: bold; }
.same   { background-color:lightyellow }

a:hover {color: red;}
table.sortable tbody {
    color: black;
    column-width: 4em;
    border: 5px grey;
}
table.sortable thead {
    color: green;
    column-width: 16em;
}
table.sortable {
    border-collapse: collapse;
}
table.sortable td {
    border: 1px solid black;
    padding-right: 4px;
    padding-left: 4px;
}

</style>
<script src="../sorttable.js"></script>
</head>
<body>
<!--
<h3><a href="check_index.html" target="_blank">OEIS-mat</a> - $target</h3>
-->
<h3>$title</h3>
<table class="sortable">
GFis
} # get_html_head
#-----------------------------
sub get_html_tail {
    my $result = <<"GFis";
</tbody>
</table>
<p>
GFis
    $result .= "$count records\n";
    $result .= <<"GFis";
<br />Generated by <a href="https://github.com/gfis/OEIS-mat/blob/master/trirec/html_traits.pl">html_traits.pl</a>: $timestamp 
<br />Questions, suggestions: email <a href="mailto:georg.fischer\@t-online.de">Georg Fischer</a>
</p>
</body>
</html>
GFis
} # get_html_tail
#--------------------------------------------
__DATA__
Trait   A       Key.    Seq.    Key     SeqName Author, Year    Data
EvenSum A000012 core,mult,cofr,cons     A008619 nice    Positive integers repeat        Sloane  1, 1, 2, 2, 3, 3, 4, 4,
OddSum  A000012 core,mult,cofr,cons     A110654         a(n) = ceiling(n/2), or:        Zumkeller, 2005 0, 1, 1, 2, 2, 3, 3, 4,
AltSum  A000012 core,mult,cofr,cons     A331218 base,new        a(n) is the numbers of w        _R√©my Sigris   1, 0, 1, 0, 1, 0, 1, 0,
DiagSum A000012 core,mult,cofr,cons     A008619 nice    Positive integers repeat        Sloane  1, 1, 2, 2, 3, 3, 4, 4,
NegHalf A000012 core,mult,cofr,cons     A077925         Expansion of 1/((1-x)*(1        Sloane, 2002    1, -1, 3, -5, 11, -21
N0TS    A000012 core,mult,cofr,cons     A105339         a(n) = n*(n+1)/2 mod 102        Takeshita, 2005 0, 1, 3, 6, 10, 15, 21
Central A001404         A181984         INVERT transform of A028        Somos, 2012     1, 2, 5, 12, 28, 65
LeftSide        A001404         A167750         Row sums of triangle A16        Barry, 2009     1, 1, 2, 4, 9, 20, 45,
RowSum  A001477 core,mult       A027480 nice    a(n) = n*(n+1)*(n+2)/2. _Olivier G√©r   0, 3, 12, 30, 60, 105
