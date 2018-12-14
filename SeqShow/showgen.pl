#!perl

# Generate the files for the OEIS/music exhibition in Heidelberg, May 2018
# @(#) $Id$
# 2018-12-14, Georg Fischer
#
# usage:
#   perl showgen.pl  [options] < Music1.en_de.txt
#       -d      debug level, 0 (none), 1 (some), 2 (more)
#       -l      language: en, de
#       -c      number of columns
#
# file usage:
#   <  *.txt            a-numbers, titles, terms, comments
#   >  index.html       resulting output
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $commandline = join(" ", @ARGV);

# get options
my $action   = "gen"; # "prep"rocess for sort, "gen"erate HTML lists
my $debug    = 0; # 0 (none), 1 (some), 2 (more)
my $lang     = "en"; # default
my $ncols    = 3;
my %languages = qw(en english de german fr french);
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{\-c}) {
        $ncols  = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-l}) {
        $lang  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------------------------------------
# perform one of the actions
if (0) {
} elsif($action =~ m{^dum}) { # dummy
    while (<>) {
        next if m{\A\s*\#};
        s/\s+\Z//; # chompr
    } # while <>
    exit(0);
#----------------------
} elsif ($action =~ m{^in})   { # generate index.html from regen.data.log
    print <<"GFis";
GFis
#----------------------
} elsif ($action =~ m{^midi}) { # get midi files
    while (<>) {
        s/\s//g; # remove whitespace
        print "wget A123456\n";
    } # while <>
    exit(0);
#----------------------------------------------
} # else ($action =~ m{^gen}) { # generate

# print HTML header
	open(HTM, ">", "web/index.$lang.html") or die "cannot write HTML file\n";
	print HTM &get_html_head('Heidelberg 2019');
	print HTM <<"GFis";
<body>
<h3><a href="https://oeis.org" target="_blank">
<img border="0" width="400" align="left" 
	src="https://oeis.org/Luschny4.png" alt="On-Line Encyclopedia of Integer Sequences" title="OEIS" /></a>
GFis
	print HTM &get_i18n(<<"GFis"
&nbsp;&nbsp;&nbsp;at the <em>Music and Math exhibit</em><br />
GFis
		, <<"GFis"
&nbsp;&nbsp;&nbsp;in der Ausstellung <br />
&nbsp;&nbsp;&nbsp;<em>Musik und Mathematik</em><br />
GFis
		);
	print HTM <<"GFis";
&nbsp;&nbsp;&nbsp;Heidelberg 2019
</h3>
<table summary="Table of demo sequences">
<tr>
GFis
	my $iseq = 0;
    while (<>) { # read the descriptions
        next if m{\A\s*\#}; # skip comments
        next if m{\A\s*\Z}; # skip empty lines
        s/\s+\Z//; # remove newline
        my $line = $_;
        if (0) { # switch for line types
        } elsif ($line =~ m{^(A\d+)}) {
        	my $aseqn = $1;
        	if ($iseq > 0) { # not first
        		if ($iseq % $ncols == 0) {
        			print HTM "</td></tr>\n<!--****************-->\n<tr>\n";
        		} else {
        			print HTM "</td>\n";
        		}
        	} # not first
        	$iseq ++;
        	&proc_aseqn("xx", $aseqn);
        } elsif ($line =~ m{^Title\:\s*(.*)}i) {
        	&proc_title("en", &tag_a($1));
        } elsif ($line =~ m{^Titel\:\s*(.*)}i) {
        	&proc_title("de", &tag_a($1));
        } elsif ($line =~ m{^Terms\:\s*(.*)}i) {
        	&proc_terms("xx", &tag_a($1));
        } elsif ($line =~ m{^Comment\:\s*(.*)}i) {
        	&proc_commt("en", &tag_a($1));
        } elsif ($line =~ m{^Kommentar\:\s*(.*)}i) {
        	&proc_commt("de", &tag_a($1));
        } elsif ($line =~ m{^Music\:\s*(.*)}i) {
        	print HTM "<!-- Music: $1 -->\n";
        } else {
        	# print STDERR "unkown line type: \"$line\"\n";
        }
    } # while <>

	print HTM <<"GFis";
</td>
<!--****************-->
</tr>
</table>

<br />
GFis
	print HTM &get_i18n(<<"GFis"
Links to <a href="https://oeis.org">OEIS</a> content are included according to the
<a href="http://www.oeis.org/wiki/The_OEIS_End-User_License_Agreement">OEIS End-User License Agreement</a>.
GFis
		, <<"GFis"
Die Verweise auf die Inhalte der <a href="https://oeis.org">OEIS</a> unterliegen der
<a href="http://www.oeis.org/wiki/The_OEIS_End-User_License_Agreement">OEIS Benutzer-Lizenz</a>.
GFis
		);
	print HTM <<"GFis";

<hr /><!--********************************-->
<p class="comt"><em>For internal use:</em>
</p>
Generated at $TIMESTAMP by
<a href="mailto:dr.georg.fischer\@gmail.com">Georg Fischer</a>
</body>
</html>
GFis
	close(HTM);
	exit(0);
# End of main
#-------------------
sub proc_aseqn { # start of cell
	my ($plang, $aseqn) = @_;
	print HTM "<td id=\"seq$iseq\" class=\"bor\"";
	if ($iseq <= $ncols) {
		print HTM " width=\"" . int(100 / $ncols) . "%\"";
	}
	print HTM ">"
		. "<strong>"
		. "<a href=\"https://oeis.org/search?q=id:$aseqn\&language=$languages{$lang}\" target=\"_blank\">"
		. $aseqn
		. "</a></strong>\n";
		# the cell is continued by all other 'proc_*' subroutines
} # proc_aseqn
#-------------------
sub proc_title {
	my ($plang, $text) = @_;
	if ($plang eq $lang) {
		print HTM "<br />$text\n";
	}
} # proc_title
#-------------------
sub proc_terms {
	my ($plang, $text) = @_;
	if (1 or $plang eq $lang) {
		print HTM "<br />$text\n";
	}
} # proc_terms
#-------------------
sub proc_commt {
	my ($plang, $text) = @_;
	if ($plang eq $lang) {
		print HTM "<br />$text\n";
	}
} # proc_comte
#----------------------
sub tag_a { # replace [url anchor text] by <a href="url" target="_blank">anchor text</a>
	my ($text) = @_;
	while (($text =~ s{\[(\S+)\s+([^\]]+)\]}
		              {\<a href\=\"\1\" target\=\"_blank\"\>\2\<\/a\>}) > 0) {
	} # while replacing
	return $text;
} # tag_a
#----------------------
sub wget {
    my ($src_url, $tar_file) = @_;
    my $sleep = 1;
    if (! -r $tar_file) {
        print "sleeping $sleep s before wget $tar_file\n";
        sleep $sleep;
        print `wget -o log.tmp -O $tar_file $src_url`;
    }
    my $buffer;
    open(FIL, "<", $tar_file) or die "cannot read $tar_file\n";
    read(FIL, $buffer, 100000000); # 100 MB
    close(FIL);
} # wget
#-----------------------------
sub get_i18n {
	my @texts = @_;
	my $result = $texts[0];
	if ($lang eq "de") {
		$result = $texts[1];
	}
	return $result;
}
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
<title>$title</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/database/subseq.pl" />
<meta name="author"    content="Georg Fischer" />
<style type="text/css">
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ text-align: left; vertical-align:top; }
.arr    { background-color: white          ; color: black; }
.bor    { border-left  : 2px solid gray    ;
          border-top   : 2px solid gray    ;
          border-bottom: 2px solid gray    ;
          border-right : 2px solid gray    ;                                 }
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
GFis
} # get_html_head
#--------------------------------------
__DATA__
# Some sequences that sound pretty good, for the Music and Math exhibit in Heidelberg.

A000010
Title: [https://en.wikipedia.org/wiki/Euler%27s_totient_function Euler's totient function]
Titel: [https://de.wikipedia.org/wiki/Eulersche_Phi-Funktion Eulersche Phi-Funktion]
Terms; 1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, 4, 12, 6, 8, 8, 16, 6, 18, 8, 12, 10, 22, 8, ...
Comment: Number of numbers <= n and relatively prime to n.
Kommentar:  Sie gibt für jede natürliche Zahl <em>n</em> an, wie viele zu <em>n</em> teilerfremde natürliche Zahlen es gibt, die nicht größer als <em>n</em> sind
Music: Two midi files, the standard one, and one using Rate=40, Release Velocity=20, Duration offset=1, Instrument = 103 (FX7)

A000120
Title: Write <em>n</em> in base 2, count 1's.
Titel: Anzahl der Einsen in der binären Darstellung von <em>n</em>.
Terms; 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, ...
Comment: Fractal. Basic sequence in communication and computers.
Kommentar: Fraktal. Grundlegende Sequenz in der Kommunikations- und Computertechnik.
Music: Two midi files, the standard one, and one using Rate=150.

A001223
Title: Differences between primes
Titel: Differenzen zwischen Primzahlen
Terms; 1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, 2, 4, 6, 6, 2, 6, 4, 2, 6, 4, 6, 8, 4, 2, ...
Comment: The primes themselves grow too rapidly, but their difference sound great.
Kommentar: Die Primzahlen selbst wachsen zu schnell, aber ihre Differenzen hören sich gut an.
