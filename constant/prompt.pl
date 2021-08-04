#!perl

# @(#) $Id$
# 2021-08-02, Georg Fischer

use strict;
use warnings;

# use IO::Prompt;
# 
# my $key = prompt '', -1;
# print "\nPressed key: $key\n";

open(CON, "<", "CON:");
while (<CON>) {
	my $text = $_;
	$text =~ s{\s+\Z}{};
	`echo $text | clip`;
	print "\"$text\" -> clipboard\n";
}
close(CON);
