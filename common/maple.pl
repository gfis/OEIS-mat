#!perl

# Run a Maple program from the clipboard and print either a data list or a b-file
# @(#) $Id$
# 2020-03.08, Georg Fischer
#
#:# Usage:
#:#   perl maple.pl [-b] [-o offset] [-num] [-s aseqno] [-c | file ...]
#:#       -b    print a b-file (otherwise, default: data list)
#:#       -c    read from clipboard (default: from STDIN or files)
#:#       -num  prefix maple code with "with (numtheory):"
#:#       -s    A-number, b-number, or number only
#---------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my @parts = split(/\s+/, asctime(localtime(time)));  #  "Fri Jun  2 18:22:13 2000\n\0"
#                                             0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]);
my $basedir   = "../../OEIS-mat/common";
my $names     = "$basedir/names";     
my $stripped  = "$basedir/stripped";     

my $bfile = 1;
my $numtheory = 0;
my $data_limit = 260; # limit for DATA section length
my $offset = 0;
my $seqno = 0;
my $prog = ""; # try to read from clipboard, STDIN or files
my $from_clip = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{b}) {
        $bfile = 1;
    } elsif ($opt  =~ m{c}) {
        $from_clip = 1;
    } elsif ($opt  =~ m{num}) {
        $numtheory = 1;
    } elsif ($opt  =~ m{o}) {
        $offset = shift(@ARGV);
    } elsif ($opt  =~ m{s}) {
        $seqno  = shift(@ARGV);
        $seqno =~ s{\D}{}g; # remove non-digits
        $seqno += 0; # remove leading spaces
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
if ($numtheory) {
    $prog = "with (numtheory): " . $prog;
}
my $aseqno = sprintf("A%06d", $seqno);
# get the name
my $name = `grep -E \"^$aseqno\" $names`;
$name =~ s{\s+}{ }g;

my  $filename;
if ($from_clip == 0) {
    # read from STDIN or files
	while (<>) {
        $prog .= $_;
    }
} else {
    # get it from the clipboard
    $prog = `powershell -command Get-Clipboard`;
}

if (1) {
    $filename = "$aseqno.prog.tmp";
    open(OUT, ">", $filename) || die "cannot write to \"$filename\"";
    print OUT "$prog\n";
    close(OUT);
}

my $maple = "\"C:/Program Files/Maple 2019/bin.X86_64_WINDOWS/cmaple.exe\"";
my $cmd = "$maple -q clip.tmp";
my $result = `$cmd`;
$result =~ s{[\[\]]}{}g;
$result =~ s{\s+}{ }g;

my @terms  = split(/ ?\, */, $result);
my $bfimin = $offset;
my $bfimax = $bfimin + scalar(@terms) - 1;

if ($bfile) {
    my $comment_clip = $prog;
    $comment_clip =~ s{\r?\n}{\n\# }g;
    my $header = <<"GFis";
# $name
# Table of n, a(n) for n = $bfimin..$bfimax
# Generated with the following Maple program by Georg Fischer, $sigtime.
# $comment_clip
GFis
    $filename = "b" . substr($aseqno, 1) . ".txt";
    open(OUT, ">", $filename) || die "cannot write to \"$filename\"";
    print OUT $header;
    my $index = $offset;
    foreach my $term(@terms) {
        print OUT "$index $term\n";
        $index ++;
    }
    print OUT "\n\n"; # for Alois
    close(OUT);
} # bfile

if (1) { # 
    $filename = "$aseqno.data.tmp";
    open(OUT, ">", $filename) || die "cannot write to \"$filename\"";
    my $data_list = substr($result, 0, $data_limit);
    if (length($data_list) == $data_limit) {
        my $rcommapos = rindex($data_list, ",");
        $data_list = substr($data_list, 0, $rcommapos);
    }
    print OUT "$data_list\n";
    close(OUT);
}
if (1) { # 
    $filename = "$aseqno.gen.tmp";
    open(OUT, ">", $filename) || die "cannot write to \"$filename\"";
    my $term_list = $result;
    $term_list =~ s{\s}{}g; # remove spaces
    print OUT join("\t", $aseqno, "finifull", 0, $term_list) . "\n";
    close(OUT);
}
__DATA__
