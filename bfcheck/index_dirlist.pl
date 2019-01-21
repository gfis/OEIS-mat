#!perl

# Insert a directory listing into index.html
# @(#) $Id$
# 2019-01-21, Georg Fischer
#
# usage:
#   perl index_dirlist.pl [-f index.html] [-u url_prefix] > index.html
#---------------------------------
use strict;
use integer;
use warnings;

my $TIMESTAMP = &iso_time(time());
# get options
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $nseq   = 15;
my $mode   = "text";
my $filename = "index.html";
my $url_prefix = "http://www.teherba.org/OEIS-mat/bfcheck";

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-f}) {
        $filename = shift(@ARGV);
    } elsif ($opt =~ m{\-u}) {
        $url_prefix = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
open(FIN, "<", $filename) or die "cannot read \$filename\"\n";
undef $/; # slurp mode
my $content = <FIN>;
close(FIN);

my $count = 0;
my $dirlist = "\n<pre>\n" . join ("\n"
    , grep { $count ++; $count > 3 } map {
		s{\s+\Z}{}; # chompr
	    # drwxr-xr-x+ 1 User Kein      0 Jan 21 13:08 .
	    # drwxr-xr-x+ 1 User Kein      0 Jan 21 13:07 ..
	    # -rwxr-xr-x+ 1 User Kein   4188 Jan 11 23:14 bextra.txt
	    # -rwxr-xr-x+ 1 User Kein 238349 Jan 20 21:49 bextra_combine.txt
		s{\A\S+\s+\S+\s+\S+\s+\S+}{}; # remove up to user group
	#	s{(\S+\s+\S+\s+\S+\s+\S+\s+)(\S+)}{$1 \<a href\=\"$url_prefix/$2\"\>$2\<\/a\>};
		s{(\S+\s+\S+\s+\S+\s+\S+\s+)(\S+)}{$1 \<a href\=\"$2\"\>$2\<\/a\>};
		$_
		} split (/\r?\n/, `ls -al`)
	) . "\n</pre>\n";	
#----
open(OUT, ">", $filename) or die "cannot read \$filename\"\n";
my $state = 1;
foreach my $line (split(/\n/, $content)) {
	$line =~ s/\s+\Z//; # chompr
	if (0) {
	} elsif ($line =~ m{\A\W+dirlist\@start}) {
		print OUT "$line\n";
		$state = 0;
	} elsif ($line =~ m{\A\W+dirlist\@end}  ) {
		$state = 1;
		print OUT "$dirlist\n";
		$line = <<"GFis"
Last update: $TIMESTAMP<br />
Questions -\&gt; EMail -\&gt; <a href="mailto:georg.fischer\@t-online.de">Georg Fischer</a>
GFis
		. $line;
	}
	if ($state == 1) {
		print OUT "$line\n";
	}
} # while <>
close(OUT);

#----
sub iso_time {
    my ($unix_time) = @_;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
    return sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
} # iso_time
__DATA__
