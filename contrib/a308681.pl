#!perl

# a308681.pl.txt - Program to generate A308681 - International telephone calling codes
# 2019-06-17, Georg Fischer
#
# The program reads the list with "wget" from the current Wikipedia article in raw format into
#   b308681.raw
# It extracts the used prefixes, sorts them numerically, and (over)writes:
#   a308681.data for terms with up to about 260 characters
#   b306681.txt  the b-file with a dated header, and the countries in a comment behind the terms
# It relies somehow on the format of the Wikipedia list items, but it can be run
# at any time to update the list.
#----------------
use strict;
use integer;
use POSIX;

my $seqno = "308681";
my $author = "Georg Fischer";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\+01:00"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec, $isdst);
my @parts = split(/\s+/, POSIX::asctime($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst));
#  "Fri Jun  2 18:22:13 2000\n\0"
#   0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]); # "Jun 17 2019"
my %hash = (); # maps prefix numbers to country names
my ($prefix, $country);
print `wget \"https://en.wikipedia.org/wiki/List_of_country_calling_codes?action=raw\" -O b$seqno.raw`;
open(RAW, "<", "b$seqno.raw") or die "cannot read b$seqno.raw\n";
while (<RAW>) {
    my $line = $_;
    if ($line =~ m{\A\*\*?\s*\[\[[^\+]*\+([^\]]+)\][^\|]+\|([^\}]+)}) {
        ($prefix, $country) = ($1, $2);
        if (0 and ($prefix =~ m{\|\+(\d)+})) {
            $prefix = $1;
        }
        $prefix =~ s{\(.*}{}; # +44 United Kindom
        if ($country =~ m{^OCHA}) {
            $line =~ m{\[\[(\w+[^\]]+)};
            $country = $1;
        }
        $prefix =~ s{x}{}g;
        &store($prefix, $country);
     } elsif ($line =~ m{\A\*\*?\s*\'+\[\[[^\+]*\+([^\]]+)\][^\[]+\[\[([^\|\]]+)}) {
        ($prefix, $country) = ($1, $2);
        &store($prefix, $country);
    }
} # while <RAW>
close(RAW);

open(DAT, ">", "a$seqno.data") or die "cannot write a$seqno.data\n";
my @terms = sort { $a <=> $b } keys(%hash);
my $data = substr(join(", ", splice(@terms, 0, 47)), 0, 260);
$data =~ s{\,[ 0-9]*\Z}{}; # remove last inclomete prefix
print DAT "$data\n";
close(DAT);

open(BFI, ">", "b$seqno.txt") or die "cannot write b$seqno.txt\n";
my $noterms = scalar(%hash);
print BFI <<"GFis";
# A308681 International telephone country prefix codes in use as of $sigtime, in lexicographic order.
# Table of n, a(n) for n = 1..$noterms
# Generated with https://oeis.org/a$seqno.pl by $author at $sigtime
# from https://en.wikipedia.org/wiki/List_of_country_calling_codes
GFis
my $iterm = 1;
foreach my $pref(sort { $a <=> $b } keys(%hash)) {
    print BFI "$iterm $pref # $hash{$pref}\n";
    $iterm ++;
} # foreach
close(BFI);
#----
sub store {
    my ($prefix, $country) = @_;
    my @prefs = split(/\//, $prefix);
    my $ipre = 0;
    my $pref0 = $prefs[0];
    $pref0 =~ s{\s+.*}{}; # remove all behind first " "
    while ($ipre < scalar(@prefs)) {
        my $pref = $prefs[$ipre];
        if ($ipre > 0) {
            $pref = "$pref0$pref";
        }
        $pref =~ s{\s}{}g;
        if (! defined($hash{$pref})) {
            $hash{$pref} = $country;
        } else {
            $hash{$pref} .= ", $country";
        }
        $ipre ++;
    } # while ipre
} # store
#----
sub output {
    print join(" ", $prefix, "#", $country) . "\n";
} # output
__DATA__
Test data - extract of the relevant section:

The North American Numbering Plan includes:
* [[North American Numbering Plan|+1]] – {{flag|Canada}}
* [[North American Numbering Plan|+1]] – {{flag|United States}}, including United States territories:
** [[Area code 340|+1 340]] – {{flag|United States Virgin Islands}}
** [[Area code 670|+1 670]] – {{flag|Northern Mariana Islands}}
** [[Area code 671|+1 671]] – {{flag|Guam}}
** [[Area code 684|+1 684]] – {{flag|American Samoa}}
** [[Telephone numbers in Puerto Rico|+1 787 / 939]] – {{flag|Puerto Rico}}
* [[North American Numbering Plan|+1]] Many, but not all, [[Caribbean]] nations and some Caribbean Dutch and [[British Overseas Territories]]:
** [[Area code 242|+1 242]] – {{flag|Bahamas}}

** [[Area code 268|+1 268]] – {{flag|Antigua and Barbuda}}
** [[Area code 284|+1 284]] – {{flag|British Virgin Islands}}

** [[Area code 784|+1 784]] – {{flag|Saint Vincent and the Grenadines}}
** [[Telephone numbers in the Dominican Republic|+1 809 / 829 / 849]] – {{flag|Dominican Republic}}
** [[Area code 868|+1 868]] – {{flag|Trinidad and Tobago}}
** [[Area code 869|+1 869]] – {{flag|Saint Kitts and Nevis}}
** [[Area codes 876 and 658|+1 876 / 658]] – {{flag|Jamaica}}

{{anchor|Zone 2}}

===Zone 2: Mostly [[Africa]]===
(but also [[Aruba]], [[Faroe Islands]], [[Greenland]] and [[British Indian Ocean Territory]])
* [[+20]] – {{flag|Egypt}}
* +210 – ''unassigned''
* [[+211]] – {{flag|South Sudan}}
* [[+212]] – {{flag|Morocco}}
* [[+213]] – {{flag|Algeria}}
* +214 – ''unassigned''

* [[+44 (country code)|+44]] – {{flag|United Kingdom}}

* '''[[+878]] – [[Universal Personal Telecommunications]] services'''
* +879 – reserved for national non-commercial purposes
* [[Telephone numbers in Bangladesh|+880]] – {{flag|Bangladesh}}
* '''[[+881]] – [[Global Mobile Satellite System]]'''
* '''[[+882]] – [[International Networks (country code)|International Networks]]'''
* '''[[+883]] – [[International Networks (country code)|International Networks]]'''
