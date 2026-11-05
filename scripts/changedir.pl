#!perl

# Change into some predefined directory, and set the window title
# @(#) $Id$
# 2026-11-02, Georg Fischer
#
#:# Usage:
#:#   perl changedir.pl short_dir
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $gits =  $ENV{'GITS'};
my $shell = $ENV{'SHELL'} || "undefined";
my $system = "win";
if ($shell =~ m{sh}) {
	$system = "unix";
}
print "GITS=$gits, SHELL=$shell, system=\"$system\"\n";
my %known_dirs =
    ( "aman"    , "$gits/joeis-lite/internal/fischer/aman"
    , "common"  , "$gits/OEIS-mat/common"
    , "lite"    , "$gits/joeis-lite/internal/fischer"
    , "robot"   , "$gits/OEIS-mat/robot"
    , "scripts" , "$gits/OEIS-mat/scripts"
    );
my $short_dir = shift(@ARGV);
my $path = $known_dirs{$short_dir};
if (defined($path)) {
    if ($system eq "win") {
        print "Windows here: $short_dir -> $path\n";
        $path =~ s{\/}{\\}g;
        chdir $path;
        print `title $short_dir`;
    } else {
        print "Unix here: $short_dir -> $path\n";
        print `cd $path`;
        print `title $short_dir`;
    }
} else {
    print "directory \"$short_dir\" is not yet listed in \'c\' command\n";
}

__DATA__
