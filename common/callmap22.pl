#!perl

# Call Maple 2022 with some pattern 
# @(#) $Id$
# 2022-11-06: 2022 changes
# 2020-06-01: name the temp file after the pattern
# 2020-05-11, Georg Fischer: copied from tilemaple.pl
# 
#:# Usage:
#:#   perl callmaple.pl [-n num] [-t timeout] [-p patternfile.mpat] inputfile ... > outputfile
#:#       -n    number of lines to be processed by one Maple activation (default 64)
#:#       -p    file with the pattern for Maple, maybe preceeded by a header and an empty line
#:#       -t    timeout for Maple in s (default 32)
#
# The pattern file may contain variables of the form $(PARM0), $(PARM1), $(PARM2) ...
# which correspond with the fields in the inputfile.
#---------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.2";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my @parts = split(/\s+/, asctime(localtime(time)));  #  "Fri Jun  2 18:22:13 2000\n\0"
#                                             0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]);
#----
my $mapnum  = 256;
my $timeout = 32;
my $maple   = "\"C:/Program Files/Maple 2022/bin.X86_64_WINDOWS/cmaple.exe\"";
my $pattern_file = "default.mpat";
my $pattern = <<'Gfis';
interface(prettyprint=0):
with(gfun):

printf("%s\t%s\t%a\n", "$(ASEQNO)", "$(GALID)", timelimit($(TIMEOUT), [seq(coeff(series($(OGF), x, n+1), x, n), n = 0..256)]));
Gfis

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{n}) {
        $mapnum  = shift(@ARGV);
    } elsif ($opt  =~ m{p}) {
        $pattern_file = shift(@ARGV);
        open(PAT, "<", $pattern_file) || die "cannot read \"$pattern_file\"\n";
        $pattern = "";
        my $empty_line = 0;
        while (<PAT>) {
            my $line = $_;
            $pattern .= $line;
            if ($line =~ m{\A\s*\Z}) {
                $empty_line = 1;
            }
        } # while <PAT>
        close(PAT);
        if (0 and $empty_line == 0) { # no empty line => prefix with header
            my $header = <<'GFis';
read "C:\\Program Files\\Maple 2019\\FPS.mpl":
interface(prettyprint=0):
with(gfun):

GFis
            $pattern = $header . $pattern;
        }
    } elsif ($opt  =~ m{t}) {
        $timeout = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my ($pat1, $pat5) = split(/\n\n/, $pattern);
#----
my $buffer = ""; # for $mapnum input lines
my $count = 0;
while (<>) {
    next if ! m{\AA\d\d+\t}; # does not start with A-number tab
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    my @parms = split(/\t/, $line);
    my $copy = $pat5;
    $copy =~ s{\$\(TIMEOUT\)} {$timeout}g;
    for (my $iparm = 0; $iparm < scalar(@parms); $iparm ++) {
    	$copy =~ s{\$\(PARM$iparm\)}  {$parms[$iparm]}g;
    }
    $buffer .= "$copy";
    $count ++;
    if ($count % $mapnum == 0) {
        &execute();
    }
} # while <>
if (length($buffer) > 0) {
    &execute();
}

sub execute {
    my $filename = "$pattern_file.tmp";
    open(MPL, ">", $filename) || die "cannot write to \"$filename\"";
    print MPL "$pat1\n";
    print MPL "$buffer\n";
    $buffer = "";
    close(MPL);
    my $cmd = "$maple -q $filename";
    # print STDERR "starting with $aseqno\n";
    my $result = `$cmd`;
    $result =~ s{\r}{}g; # remove Maple's carriage returns
    print        "$result";
    print STDERR substr($result, 0, 64) . " ...\n";
} # execute
__DATA__
for OGFtoHolRec.mpat:
A182892	nyi	0	1/( z^2+sqrt((1+z+z^2)*(1-3*z+z^2)) )	z	1, 1, 1, 3, 7, 15, 35, 83, 197, 473, 1145, 2787, 6819, 16759	Conjecture: n*a(n) +(n-2)*a(n-1) +2*(-9*n+16)*a(n-2) +5*(2*n-5)*a(n-3) +(10*n-33) *a(n-4) +2*(26*n-109)*a(n-5) +(13*n-37)*a(n-6) +(13*n-63) *a(n-7) +10*(-n+7) *a(n-8)=0
A182894	nyi	0	1/( z+z^2+sqrt((1+z+z^2)(1-3*z+z^2)) )	z	1, 0, 0, 2, 2, 4, 12, 24, 54, 130, 300, 706, 1686, 4028, 9686, 23426, 56866	Conjecture: n*a(n) +(-4*n+3)*a(n-1) +(n-3)*a(n-2) -3*a(n-3) +3*(5*n-14)*a(n-4) +6*(n-3)*a(n-5) +6*(n-4)*a(n-6) +4*(-n+6)*a(n-7)=0
