#!perl

# Extract the callcodes from the jOEIS JSON extract
# @(#) $Id$
# 2020-11-21, Georg Fischer
#
#:# usage:
#:#   perl joeis_list.pl joeis_list1.all.tmp > outputfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug      = 0; # 0 (none), 1 (some), 2 (more)
if (0 and scalar(@ARGV) == 0) {
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

my $minterm = 0;
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if (0) {
    } elsif ($line =~ m{\/(A\d+)\.java\:\/\/\s*Generated\s*by\s*(.*)}) {
        my ($aseqno, $rest) = ($1, $2);
        my $pattern = "";
        my ($proc, @parts) = split(/\s+/, $rest);
        if (0) {
        } elsif ($proc =~ m{\Agen_seq4}) { 
            $pattern = $parts[0];
        } elsif ($proc =~ m{\Agen_pattern}) { 
            $pattern = "pattern";
        } elsif ($proc =~ m{\Agen_linrec}) { 
            $pattern = "linrec";
        } else {
        	$pattern = "???$proc";
        }
        print join("\t", $aseqno, $pattern) . "\n";
    } elsif ($line =~ m{\/(A\d+)\.java\:[^\@]+\@author\s*(\S*)}) {
        my ($aseqno, $name1) = ($1, $2);
        print STDERR join("\t", $aseqno, $name1) . "\n";
    }
} # while <>
#------------------------------------
__DATA__
../../gits/joeis/src/irvine/oeis/a180/A180964.java: * @author Sean A. Irvine
../../gits/joeis/src/irvine/oeis/a180/A180964.java:public class A180964 extends LinearRecurrence {
../../gits/joeis/src/irvine/oeis/a180/A180312.java:// Generated by gen_seq4.pl eulerxfm 0 at 2020-08-17 18:03
../../gits/joeis/src/irvine/oeis/a180/A180312.java: * @author Georg Fischer
../../gits/joeis/src/irvine/oeis/a180/A180312.java:public class A180312 extends EulerTransform {
../../gits/joeis/src/irvine/oeis/a180/A180016.java:// Generated by gen_seq4.pl holos [[0],[72,-108,36],[-48,60,-2],[0,0,1]] [1,1,7,19,109] 0 at 2019-12-06 18:14
../../gits/joeis/src/irvine/oeis/a180/A180016.java: * @author Georg Fischer
../../gits/joeis/src/irvine/oeis/a180/A180016.java:public class A180016 extends HolonomicRecurrence {
../../gits/joeis/src/irvine/oeis/a180/A180217.java:// Generated by gen_seq4.pl nthprime 2020-06-14 20:25
../../gits/joeis/src/irvine/oeis/a180/A180217.java: * @author Georg Fischer
../../gits/joeis/src/irvine/oeis/a180/A180217.java:public class A180217 extends A000040 {
../../gits/joeis/src/irvine/oeis/a180/A180853.java: * @author Sean A. Irvine
../../gits/joeis/src/irvine/oeis/a180/A180853.java:public class A180853 extends LinearRecurrence {
../../gits/joeis/src/irvine/oeis/a180/A180965.java: * @author Sean A. Irvine
../../gits/joeis/src/irvine/oeis/a180/A180965.java:public class A180965 extends LinearRecurrence {
../../gits/joeis/src/irvine/oeis/a180/A180597.java:// Generated by gen_seq4.pl padding 0 at 2020-08-22 18:36
../../gits/joeis/src/irvine/oeis/a180/A180597.java: * @author Georg Fischer