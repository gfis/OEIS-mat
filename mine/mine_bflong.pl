#!perl

# Search for duplicated terms in bflong_sort
# @(#) $Id$
# 2019-03-20, Georg Fischer: copied from ./extract_bflong.pl
#
#:# usage:
#:#   perl mine_bflong.pl inputfile > outputfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug      =  0; # 0 (none), 1 (some), 2 (more)
my $maxlen     = 16;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
   } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

my  ($old_term, $old_aseqno, $old_index) = ("", "", "");
my  ($new_term, $new_aseqno, $new_index) = ("", "", "");
my  $group_count = 1;
while (<>) {
    s/\s+\Z//; # chompr
    ($new_term, $new_aseqno, $new_index) = split(/\t/);
    if ($old_term eq $new_term) { # same group
    #   $old_aseqno .= " $new_aseqno/$new_index";
        $old_aseqno .= ",$new_aseqno";
        $group_count ++;
    } else { # start of new group
        &output();
    } # new group
} # while <>
&output();
#---------------------------
sub output {
    if ($old_aseqno =~ m{ }) { # at least 2 in group
        print join("\t"
            , $old_aseqno
            , length($old_term)
            , $group_count
            , substr($old_term, 0, $maxlen) . "..." . substr($old_term, - $maxlen) 
            ) . "\n";
    } # at least 2
#   ($old_term, $old_aseqno) = ($new_term, "$new_aseqno/$new_index");
    ($old_term, $old_aseqno) = ($new_term, "$new_aseqno");
    $group_count = 1;
} # output
#------------------------------------
__DATA__
