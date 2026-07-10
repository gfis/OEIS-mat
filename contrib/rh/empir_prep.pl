#!perl

# prepare "Empirical" recurrence records
# @(#) $Id$
# 2026-07-09, Georg Fischer: copied from scripts/holinits.pl
#
#:# usage:
#:#   grep ...Empirical... jcat25.txt \
#:#   | perl empir_prep.pl > (aseqno, init_lim, recurrence).seq3
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
print "# processed by $0 at $utc_stamp\n";

my $MAX_LEN    = 3900; # cf. $(COMMON)/seq3.create.sql
my $gits       =  $ENV{'GITS'};
my $debug      = 0;
my $add        = 0;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $add       = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $cc, $offset, $recurrence, $init_lim, @rest, $dummy);
# while(<DATA>) {
while(<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if (m{\AA\d{6} }) { # valid A-number
        $line =~ s/ *Empirical[^\:]*\: */\t/; 
        $line =~ s/[\.\[].*//; 
        $line =~ s{ for n *\> *(\d+)}{\t\.\.$1};
        $line =~ s/ with/\twith\t/;
        ($aseqno, $recurrence, $init_lim) = split(/\t/, $line);
        $recurrence =~ s/ //g;
        if (length($recurrence) > $MAX_LEN) {
            print STDERR "# $aseqno: recurrence too long - " . length($recurrence) . "\n";
        } else {
            print join("\t", $aseqno, $init_lim, $recurrence) . "\n"; # switch for seq3 varchars
        }
    } # valid A-number
} # while <>
__DATA__
# processed by empir_prep.pl at 2026-07-09T06:32:22z
A174703	n>=30	a(n)=2*a(n-1)-a(n-2)+a(n-3)-a(n-4)+4*a(n-5)-6*a(n-6)+a(n-7)-2*a(n-8)+a(n-9)-5*a(n-10)+5*a(n-11)+a(n-12)+3*a(n-13)+a(n-14)+3*a(n-15)-a(n-16)-a(n-18)-a(n-19)-a(n-20)
A180754		a(n)=9*a(n-1)-26*a(n-2)+24*a(n-3)+47*a(n-4)-157*a(n-5)-43*a(n-6)+641*a(n-7)-643*a(n-8)-952*a(n-9)+3460*a(n-10)-2021*a(n-11)-2111*a(n-12)+2715*a(n-13)-1249*a(n-14)-4657*a(n-15)-1514*a(n-16)+1961*a(n-17)-1230*a(n-18)+6713*a(n-19)+8832*a(n-20)+10212*a(n-21)+1971*a(n-22)-6552*a(n-23)-2819*a(n-24)-2898*a(n-25)-973*a(n-26)+302*a(n-27)+433*a(n-28)+286*a(n-29)
A180765		a(n)=17*a(n-1)+136*a(n-2)-345*a(n-3)-4373*a(n-4)+71*a(n-5)+66879*a(n-6)+73663*a(n-7)-605750*a(n-8)-1149380*a(n-9)+3440076*a(n-10)+9495118*a(n-11)-11523196*a(n-12)-49881727*a(n-13)+14883216*a(n-14)+170573727*a(n-15)+56476212*a(n-16)-384039937*a(n-17)-365812542*a(n-18)+600541982*a(n-19)+912782329*a(n-20)-647992787*a(n-21)-1217873627*a(n-22)+831099316*a(n-23)+509861969*a(n-24)-535317645*a(n-25)-243113473*a(n-26)+146477582*a(n-27)+239475023*a(n-28)-56646215*a(n-29)-153066695*a(n-30)+13721643*a(n-31)+55901473*a(n-32)+8739700*a(n-33)-17235985*a(n-34)-7556526*a(n-35)+4435220*a(n-36)+2967912*a(n-37)-742411*a(n-38)-903018*a(n-39)+68146*a(n-40)+206458*a(n-41)+20454*a(n-42)-27768*a(n-43)-10964*a(n-44)+1696*a(n-45)+1408*a(n-46)
