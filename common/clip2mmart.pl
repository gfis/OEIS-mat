#!perl

# Generate a MMA RecurrencTable call from the Windows clipboard 
# @(#) $Id$
# 2019-12-05, Georg Fischer
#
#:# Usage:
#:#   perl clip2mmart.pl 
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

my $offset = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{o}) {
        $offset = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $clip = `powershell -command Get-Clipboard`;
$clip =~ s{\s}{}g;
$clip =~ s{\.}{}g;
$clip =~ s{\=}{==}g;
my $brcount = $clip =~ s{a\(([^\)]+)\)}{a\[$1\]}g;
my $result = "RecurrenceTable\[\{$clip";
for my $ind (0..$brcount - 1) {
    $result .= ",a[$ind]=="
}
$result .= "\},a\[n\],\{n,0,10\}\]\n";
print $result;
__DATA__
