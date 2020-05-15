#!perl

# Call Maple with some pattern 
# @(#) $Id$
# 2020-05-14, Georg Fischer: copied from callmaple.pl
# 
#:# Usage:
#:#   perl callmma.pl [-n num] [-t timeout] [-p patternfile.tpat] inputfile ... > outputfile
#:#       -n    number of lines to be processed b one Maple activation (default 64)
#:#       -p    file with the pattern for Mathematica, maybe preceeded by a header and an empty line
#:#       -t    timeout for Mathematica in s (default 16)
#
# The pattern file may contain variables of the form $(PARM0), $(PARM1), $(PARM2) ...
# which correspond with the fields in the inputfile.
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
my $mmanum  = 64;
my $timeout = 16;
my $mma_server =  "pi\@piras";
my $pattern_file = "";
my $pattern = <<'Gfis';
(* <<SpecialFunctions` *)

Print["$(PARM0)\t$(PARM1)\t", InputForm[Simplify[$(PARM2)]]];
Gfis

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{n}) {
        $mmanum  = shift(@ARGV);
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
        if ($empty_line == 0) { # no empty line => prefix with header
            my $header = <<'GFis';
(* no header *)

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
my $buffer = ""; # for $mmanum input lines
my $count = 0;
while (<>) {
    next if ! m{\AA\d\d+\t};
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
    if ($count % $mmanum == 0) {
        &execute();
    }
} # while <>
if (length($buffer) > 0) {
    &execute();
}

sub execute {
    my $filename = substr($0, 0, index($0, ".")) . ".tmp"; # callmma.tmp
    open(MMA, ">", $filename) || die "cannot write to \"$filename\"";
    print MMA "$pat1\n";
    print MMA "$buffer\n";
    print STDERR substr($buffer, 0, 16) . "\n";
    $buffer = "";
    close(MMA);
    my $cmd = "scp $filename $mma_server: ; ssh $mma_server \'wolfram < $filename 2>\&1'";
    my @lines = split(/\n\s*/, `$cmd`);
    my $state = "init";
    my $buffer2 = "";
    my $result;
    foreach my $line (@lines) {
        if (0) {
        } elsif ($line =~ m{\AIn\[\d+\]\:\=\s*(.*)}) {
            $result = $1;
            if ($buffer2 ne "") {
                print "$buffer2\n";
            }
            $buffer2 = "$result";
        } elsif ($line =~ m{\A\>\s*(.*)}) {
            $result = $1;
            $buffer2 .= $result;
		} else { # ignore
		}
    } # foreach
    if ($buffer ne "") {
        print "$buffer\n";
    }
} # execute
__DATA__
A000000	Galdummy	(x^10-2*x^5+1)
A315411	Gal.4.78.4	(x^2+1)*(x^4+1)*(x-1)^2
A310559	Gal.4.79.1	(x^2+x+1)*(x^6+x^3+1)*(x^6-x^3+1)*(x^6+x^5+x^4+x^3+x^2+x+1)*(x-1)^2
A313830	Gal.4.79.2	(x^2+x+1)*(x^6+x^3+1)*(x^6-x^3+1)*(x^6+x^5+x^4+x^3+x^2+x+1)*(x-1)^2
A315076	Gal.4.79.3	(x^2+x+1)*(x^6+x^3+1)*(x^6+x^5+x^4+x^3+x^2+x+1)*(x-1)^2
A313638	Gal.4.79.4	(x^2+x+1)*(x^6+x^3+1)*(x^6-x^3+1)*(x^6+x^5+x^4+x^3+x^2+x+1)*(x-1)^2
A311237	Gal.4.80.1	(x^2+1)*(x^2+x+1)*(x^2-x+1)*(x-1)^2*(x+1)^2
A311515	Gal.4.80.2	(x^4+1)*(x^2+x+1)*(x^2-x+1)*(x-1)^2*(x+1)^2
A312065	Gal.4.80.3	(x^2+x+1)*(x^2-x+1)*(x-1)^2
A311943	Gal.4.80.4	(x^2+x+1)*(x^4+1)*(x-1)^2

Wolfram Language (Raspberry Pi Pilot Release)
Copyright 1988-2015 Wolfram Research
Information & help: wolfram.com/raspi

In[1]:= 
In[2]:= A000000 Galdummy    (-1 + x^5)^2

In[3]:= A315411 Gal.4.78.4  (-1 + x)^2*(1 + x^2)*(1 + x^4)

In[4]:= A310559 Gal.4.79.1  (-1 + x)^2*(1 + x + x^2)*(1 - x^3 + x^6)*(1 + x^3 + x^6)*
 
>    (1 + x + x^2 + x^3 + x^4 + x^5 + x^6)

In[5]:= A313830 Gal.4.79.2  (-1 + x)^2*(1 + x + x^2)*(1 - x^3 + x^6)*(1 + x^3 + x^6)*
 
>    (1 + x + x^2 + x^3 + x^4 + x^5 + x^6)

In[6]:= A315076 Gal.4.79.3  1 - x^7 - x^9 + x^16

In[7]:= A313638 Gal.4.79.4  (-1 + x)^2*(1 + x + x^2)*(1 - x^3 + x^6)*(1 + x^3 + x^6)*
 
>    (1 + x + x^2 + x^3 + x^4 + x^5 + x^6)

In[8]:= A311237 Gal.4.80.1  1 - x^4 - x^6 + x^10

In[9]:= A311515 Gal.4.80.2  (-1 + x^2)^2*(1 + x^2 + 2*x^4 + x^6 + x^8)

In[10]:= A312065    Gal.4.80.3  (-1 + x)^2*(1 - x + x^2)*(1 + x + x^2)

In[11]:= A311943    Gal.4.80.4  (-1 + x)^2*(1 + x + x^2)*(1 + x^4)

In[12]:= In[12]:= 

