#!perl

# Search for duplicated terms in bflong_sort
# @(#) $Id$
# 2019-03-20, Georg Fischer: copied from ./extract_bflong.pl
#
#:# usage:
#:#   perl mine_bflong.pl [-k knownfile] inputfile > outputfile
#:#       -k file with A-numbers of well-known sequences (to be eliminated)
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
my @known = (); # no sequences well-known so far
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-k}) {
        my $knownfile = shift(@ARGV);
        if (open(KNO, "<", $knownfile)) {
            while (<KNO>) {
                if (m{(A\d+)}) {
                    push(@known, $1);
                }
            } # while <KNO>
            close(KNO);
            print STDERR "# well-known sequences: " 
                . join(", ", @known) . "\n";
        } else {
            die "cannot read \"$knownfile\"\n";
        }
   } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

my  ($old_term, $old_aseqno, $old_index) = ("", "", "");
my  ($new_term, $new_aseqno, $new_index) = ("", "", "");
my  %alist = ();
$alist{$old_aseqno} = 1;
while (<>) {
    s/\s+\Z//; # chompr
    ($new_term, $new_aseqno, $new_index) = split(/\t/);
    if ($old_term eq $new_term) { # same group
    #   $old_aseqno .= " $new_aseqno/$new_index";
        if ($old_aseqno ne $new_aseqno) {
            $old_aseqno = $new_aseqno;
            $alist{$old_aseqno} = 1;
        } else {
        }
    } else { # start of new group
        &output();
    } # new group
} # while <>
&output();
#---------------------------
sub output {
    if (scalar(%alist) > 1) { # at least 2 in group
        my $is_unknown = 1;
        my $ikn = 0;
        while ($is_unknown == 1 and $ikn < scalar(@known)) {
            if (defined($alist{$known[$ikn]})) { # known occurs in list
                $is_unknown = 0;
            } 
            $ikn ++;
        } # while $ikn
        if ($is_unknown == 1) {
            my @aseqnos = sort(keys(%alist));
            my $len = scalar(@aseqnos);
            for (my $iseq = $len  - 1; $iseq >  0; $iseq --) { # each with each
            for (my $jseq = $iseq - 1; $jseq >= 0; $jseq --) {
                print join("\t", $aseqnos[$iseq], $aseqnos[$jseq]) . "\n";
            } # for $jseq
            } # for $iseq
        } # if $is_unknown
    } # at least 2
    ($old_term, $old_aseqno) = ($new_term, "$new_aseqno");
    %alist = ();
    $alist{$old_aseqno} = 1;
} # output
#------------------------------------
__DATA__
