#!perl

# Read rows from db table 'seq4' and generate corresponding Java sources for jOEIS
# @(#) $Id$
# 2023-09-21, Georg Fischer: copied from internal/fischer/gen_seq4.pl
#
#:# Usage:
#:#   perl readvcg.pl [-d debug] [-m mode] [-s sep] infile.vcg > output
#:#       -d debugging output: 0=none, 1=some, 2=more
#:#       -m mode "post"=postfix (default), "in"=infix, "pre"=prefix
#:#       -s separator for mode "post" (default ";")
#
# A node has no children if it is an operand, and
# an optional red child and a blue child if it is an operation.
#--------------------------------------------------------
use strict;
use integer;
use warnings;
use English; # PREMATCH

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min);
my $version_id  = "readvcg.pl V1.0";

my $indent  = 4;
my $debug   = 0;
my $mode    = "post"; # output mode
my $sep     = ";";    # separator for "post"
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     =  shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      =  shift(@ARGV);
    } elsif ($opt  =~ m{s}) {
        $sep       =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my %hedges = (); # red(1)/blue(2) edges ({1,2},source -> target)
my %hnodes = (); # nodes (title -> label)
my ($title, $label, $source, $target, $color);
my $root = "";
while (<>) { # read inputfile
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if (0) {
    #                                          1   1               2      2
    } elsif ($line =~ m{node\: *\{ *title\: *\"([^\"]*)\" *label\: *\"([^\"]*)\"}) {
        ($title, $label) = ($1, $2);
        $hnodes{$title} = $label;
        if (length($root) == 0 && $title > 1) {
            $root = $title;
        }
    #                                               1      1                    2      2                           3   3
    } elsif ($line =~ m{edge\: *\{ *sourcename\: *\"([^\"]*)\" *targetname\: *\"([^\"]*)\" *class\: *\w+ +color\: *(\w+)\}}) {
        ($source, $target, $color) = ($1, $2, $3);
        $hedges{($color eq "red" ? 1 : 2) . ",$source"} = $target;
    } else { # ignore
    }
} # while <>
if ($debug >= 2) {
    print "nodes:";
    foreach my $node (sort(keys(%hnodes))) {
        print " $node:$hnodes{$node}";
    }
    print "\n";
    print "edges:";
    foreach my $edge (sort(keys(%hedges))) {
        print " $edge:$hedges{$edge}";
    }
    print "\n";
    print "root=$root\n";
}
#----------------
my $output = "";
if (0) {
} elsif ($mode =~ m{^pre})  { # prefix:  op ( [red ,] blue )
    &prefix ($root);
} elsif ($mode =~ m{^in})   { # infix:   ( red ) op ( blue )
    &infix  ($root, &get_label($root));
} elsif ($mode =~ m{^post}) { # postfix: red ; blue ; op ;
    &postfix($root);
} else {
    die "readvcg.pl: invalid mode \"$mode\"\n";
}
print "$output\n";
#================================
sub get_label { # of a node
    my ($node) = @_;
    my $label = $hnodes{$node} || "";
    if ($label !~ m{^_[a-zA-Z]}) {
        $label =~ s{_}{}g;
    }
    if ($label =~ m{^bloc}) {
        $label =~ s{\(}{_};
        $label =~ s{\)}{};
    }
    $label =~ s{^Fassign}{\=};
    return $label;
} # get_label
#----
sub relevant { # test whether the label is relevant
    my ($label) = @_;
    return (length($label) > 0 && ($label eq "Fassign" || ($label !~ m{^(F|_[a-z]|def)}))) ? 1 : 0;
} # relevant
#----
sub prefix { # caution: recursive tree walking
    my ($parent) = @_;
    my $child;
    my $label = &get_label($parent);
    if (&relevant($label)) {
        $label =~ s{_}{}g;
        $output .= "$label";
        $child = $hedges{"1,$parent"} || "";
        if (length($child) > 0) {
            $output .= "(";
            &prefix($child);
            $child = $hedges{"2,$parent"} || "";
            if (length($child) > 0) {
                $output .= ",";
                &prefix($child);
                $output .= ")";
            }
        } else {
            $child = $hedges{"2,$parent"} || "";
            if (length($child) > 0) {
                $output .= "(";
                &prefix($child);
                $output .= ")";
            }
        }
    } else { # visit children, but no own output except for ","
        $child = $hedges{"1,$parent"} || "";
        if (length($child) > 0) {
            &prefix($child);
            $child = $hedges{"2,$parent"} || "";
            if (length($child) > 0) {
                $output .= ",";
                &prefix($child);
            }
        } else {
            $child = $hedges{"2,$parent"} || "";
            if (length($child) > 0) {
                &prefix($child);
            }
        }
    }
} # prefix
#----
sub relevant_child { # pass through irrelevant node "Flistarg" reached by blue (single) edges
    my ($parent, $child_no) = @_;
    if ($debug >= 2) {
        print "# relevant_child($parent, $child_no)\n";
    }
    my $child = "";
    my $label;
    my $busy = 1;
    if (length($child) == 0) { # no red edge
        $child = $hedges{"2,$parent"} || "";
        if (length($child) > 0) { # blue edge
            $label = &get_label($child);
            if ($label eq "Flistarg") {
                $child = $hedges{"$child_no,$child"} || "";
                $busy = 0;
            }
        }
    }
    if ($busy == 1) {
        $child = $hedges{"$child_no,$parent"} || "";
    }
    return $child;
} # relevant_child
#----

# bloc(0)((((a)+(b))+(c))/(((d)*(e))*(f))return)
sub infix { # caution: recursive tree walking
    my ($parent) = @_;
    my $child;
    my $label = &get_label($parent);
    if (&relevant($label)) {
        foreach my $child_no ((1, 2)) {
            $child = &relevant_child($parent, $child_no);
            if (length($child) > 0) {
                if (defined($hedges{"1,$child"}) || defined($hedges{"2,$child"})) { # non-atomar
                    $output .= "(";
                    &infix($child);
                    $output .= ")";
                } else { # atomar, without "( )"
                    &infix($child);
                }
            }
            if ($child_no == 1) {
                $output .= "$label";
            }
        }
    } else {
        $child = &relevant_child($parent, 1);
        if (length($child) > 0) {
            &infix($child);
        }
        $child = &relevant_child($parent, 2);
        if (length($child) > 0) {
            &infix($child);
        }
    }
} # infix
#----
sub postfix { # caution: recursive tree walking
    my ($parent) = @_;
    foreach my $ichild((1, 2)) { # visit both children
        my $child = $hedges{"$ichild,$parent"} || "";
        if ($debug >= 1) {
            print "parent=$parent, ichild=$ichild, child=\"$child\"\n";
        }
        if (length($child) > 0) {
            &postfix($child);
        }
    } # foreach child
    my $label = &get_label($parent);
    if (&relevant($label)) {
        $label =~ s{_}{}g;
        $output .= "$label$sep";
    }
} # postfix
#================================
__DATA__
graph: { title:"test"
xmax: 700 ymax: 700 x: 30 y: 30
layout_downfactor: 8
node: { title: "0" label: "GNIL" }
node: { title: "1" label: "GNOARG" }
node: { title: "1342" label: "def(init_abc)" }
edge: { sourcename: "1342" targetname: "1358" class:2 color: blue}
node: { title: "1358" label: "bloc(0)" }
edge: { sourcename: "1358" targetname: "1346" class:2 color: blue}
node: { title: "1346" label: "Fseq" }
edge: { sourcename: "1346" targetname: "1339" class:2 color:red}
node: { title: "1339" label: "Fseq" }
edge: { sourcename: "1339" targetname: "1338" class:2 color:red}
node: { title: "1338" label: "Fseq" }
edge: { sourcename: "1338" targetname: "1347" class:2 color:red}
node: { title: "1347" label: "_copyarg" }
edge: { sourcename: "1338" targetname: "1336" class:2 color:blue}
node: { title: "1336" label: "_initfunc" }
edge: { sourcename: "1339" targetname: "1335" class:2 color:blue}
node: { title: "1335" label: "_*_" }
edge: { sourcename: "1335" targetname: "1334" class:2 color: blue}
node: { title: "1334" label: "Flistarg" }
edge: { sourcename: "1334" targetname: "1332" class:2 color:red}
node: { title: "1332" label: "_+_" }
edge: { sourcename: "1332" targetname: "1331" class:2 color: blue}
node: { title: "1331" label: "Flistarg" }
edge: { sourcename: "1331" targetname: "1329" class:2 color:red}
node: { title: "1329" label: "a" }
edge: { sourcename: "1331" targetname: "1330" class:2 color:blue}
node: { title: "1330" label: "b" }
edge: { sourcename: "1334" targetname: "1333" class:2 color:blue}
node: { title: "1333" label: "c" }
edge: { sourcename: "1346" targetname: "1345" class:2 color:blue}
node: { title: "1345" label: "return" }
edge: { sourcename: "1345" targetname: "0" class:2 color: blue}
}
