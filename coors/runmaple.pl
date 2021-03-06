#!perl

# Call Maple 
# @(#) $Id$
# 2020-05-11, Georg Fischer: copied from tilemaple.pl
# 
#:# Usage:
#:#   perl runmaple.pl [-n num] [-t timeout] infile ... > outfile
#:#       -n    number of lines to be processed b one Maple activation (default 64)
#:#       -t    timeout for Maple in s, default 4
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
#----
my $mapnum  = 64;
my $timeout = 16;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{n}) {
        $mapnum  = shift(@ARGV);
    } elsif ($opt  =~ m{t}) {
        $timeout = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my $pattern = <<'Gfis';
read "C:\\Program Files\\Maple 2019\\FPS.mpl":
interface(prettyprint=0):
with(gfun):

printf("%s\t%s\t%a\n", "$(ASEQNO)", "$(GALID)", timelimit($(TIMEOUT), [seq(coeff(series($(OGF), x, n+1), x, n), n = 0..256)]));
Gfis
my ($pat1, $pat5) = split(/\n\n/, $pattern);
#----
my $buffer = ""; # for $mapnum input lines
my $count = 0;
while (<>) {
    next if $_ !~ m{\AA\d\d+\t};
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    my ($aseqno, $callcode, $offset, $galid, $ogf, @rest) = split(/\t/, $line);
    my $copy = $pat5;
    $copy =~ s{\$\(TIMEOUT\)} {$timeout}g;
    $copy =~ s{\$\(ASEQNO\)}  {$aseqno}g;
    $copy =~ s{\$\(GALID\)}   {$galid}g;
    $copy =~ s{\$\(OGF\)}     {$ogf}g;
    $buffer .= "$copy";
    $count ++;
    if ($count % $mapnum == 0) {
        &execute($aseqno);
    }
} # while <>
if (length($buffer) > 0) {
    &execute();
}

sub execute {
    my ($aseqno) = @_;
    my $filename = substr($0, 0, index($0, ".")) . ".tmp";
    open(MPL, ">", $filename) || die "cannot write to \"$filename\"";
    print MPL "$pat1\n";
    print MPL "$buffer\n";
    $buffer = "";
    close(MPL);
    my $maple = "\"C:/Program Files/Maple 2019/bin.X86_64_WINDOWS/cmaple.exe\"";
    my $cmd = "$maple -q $filename";
    # print STDERR "starting with $aseqno\n";
    my $result = `$cmd`;
    $result =~ s{\r}{}g; # remove Maple's carriage returns
    print        "$result";
    print STDERR substr($result, 0, 64) . " ...\n";
} # execute
__DATA__
A008486	Gal.1.1.1	[-(x^2+x+1)/(-x^2+2*x-1), ogf]
A008576	Gal.1.2.1	[-(-x^4-2*x^3-2*x^2-2*x-1)/(x^4-x^3-x+1), ogf]
A072154	Gal.1.3.1	[-(x^6+2*x^5+2*x^4+2*x^3+2*x^2+2*x+1)/(-x^6+x^5+x-1), ogf]
A250122	Gal.1.4.1	[-(2*x^8-4*x^7+3*x^6-5*x^5+x^4-3*x^3-x^2-x-1)/(x^6-2*x^5+3*x^4-4*x^3+3*x^2-2*x+1), ogf]
A008574	Gal.1.5.1	[-(x^2+2*x+1)/(-x^2+2*x-1), ogf]
A008574	Gal.1.6.1	[-(x^2+2*x+1)/(-x^2+2*x-1), ogf]
A008579	Gal.1.7.1	[-(-2*x^5+3*x^4+6*x^3+6*x^2+4*x+1)/(-x^4+2*x^2-1), ogf]
A008706	Gal.1.8.1	[-(x^2+3*x+1)/(-x^2+2*x-1), ogf]
A219529	Gal.1.9.1	[-(-x^4-4*x^3-6*x^2-4*x-1)/(x^4-x^3-x+1), ogf]
A250120	Gal.1.10.1	[-(x^6+4*x^5+4*x^4+6*x^3+4*x^2+4*x+1)/(-x^6+x^5+x-1), ogf]
A008458	Gal.1.11.1	[-(x^2+4*x+1)/(-x^2+2*x-1), ogf]
A265035	Gal.2.1.1	[-(x^8-2*x^7+2*x^6-2*x^5-x^2-1)/(x^4-3*x^3+4*x^2-3*x+1), ogf]
A265036	Gal.2.1.2	[-(2*x^9-6*x^8+8*x^7-7*x^6+2*x^5+2*x^4-5*x^3+2*x^2-1)/(x^6-4*x^5+8*x^4-10*x^3+8*x^2-4*x+1), ogf]
A301287	Gal.2.2.1	[-(-2*x^8+2*x^7+x^6+4*x^5+2*x^4+2*x^3+4*x^2+2*x+1)/(-x^6+x^5-x^4+2*x^3-x^2+x-1), ogf]
A301289	Gal.2.2.2	[-(-2*x^9+6*x^8-4*x^7+6*x^6+3*x^4+4*x^3+2*x+1)/(-x^8+2*x^7-3*x^6+4*x^5-4*x^4+4*x^3-3*x^2+2*x-1), ogf]
