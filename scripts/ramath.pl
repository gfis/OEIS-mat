#!perl

# Process seq4 records with ramath.sequence.JoeisPreparer
# @(#) $Id$
# 2024-11-21, Georg Fischer: copied from parisums.pl
# Cf. https://stackoverflow.com/questions/449158/how-do-i-encode-http-get-query-strings-in-perl
#
#:# Usage:
#:#   perl ramath.pl [options] in.seq4 > out.seq4
#:#       -bva: process bva callcodes only, follow by | getinits -q
#:#       -ogf: process ogf callcodes only
#--------------------------------------------------------
use strict;
use integer;
use warnings;
use LWP::Simple;
use URI;

my $prefix = "http://localhost:8080/ramath/servlet";
my $debug = 0;
my $bva = 1;
my $ogf = 1;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\A\-d})    { 
        $debug = shift(@ARGV); 
    } elsif ($opt =~ m{\A\-bvall})  {
    } elsif ($opt =~ m{\A\-bvall})  {
    }
} # while $opt
my ($aseqno, $callcode, $offset1, $parm1, @rest);
my $nok;

#while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    if ($line =~ m{\AA\d{6}}) { # starts with A-number
        ($aseqno, $callcode, $offset1, $parm1, @rest) = split(/\t/, $line);
        $parm1 =~ s{ }{}g; # remove all spaces
        $nok = 0;
        if (0) {
        #--------
        } elsif ($callcode =~ m{\Abva}) { # convert a recurrence into a matrix
            my $response = &get_url($parm1);
            print "$response\n" if ($debug >= 1);
            my $parm2 = "";
            ($aseqno, $callcode, $offset1, $parm1, $parm2) = split(/\t/, $response);
            $callcode = "holos";
            $parm1 =~ s{\"}{}g; # remove quotes
            $rest[0] = "n>=$parm2"; 
            $rest[1] = 0;
            $rest[2] = 0;
        #--------
        } elsif ($callcode =~ m{\Abva}) {

        #--------
        } else {
            # ignore - pass through
        }
        # with A-number
        if ($nok eq "0") {
            print        join("\t", $aseqno, $callcode,        $offset1, $parm1, @rest) . "\n";
        } else {
            print STDERR join("\t", $aseqno, "$nok=$callcode", $offset1, $parm1, @rest) . "\n";
        }
    } else { # no A-number
        print "$line\n"; # pass through
    }
} # while <>
#----
sub get_url {
    my ($parm) = @_;
    my $uri_object = URI->new($prefix);
    $uri_object->query_form
        ( view       => 'joeis'
        , aseqno     => $aseqno
        , callcode   => $callcode
        , offset1    => $offset1 
        , parm1      => $parm
        , parm2      => ''
        , parm3      => ''
        , parm4      => ''
        );
    return get("$uri_object");
} # get_url
__DATA__
A364174	bva	0	108*(9*n - 1)*(9*n - 5)*(9*n - 7)*(9*n - 11)*(9*n - 13)*(9*n - 17)/(5*n*(n - 1)*(5*n - 1)*(5*n - 3)*(5*n - 7)*(5*n - 9))*a(n-2)			>= 2 			with a(0) = 1 and a(1) = 48.
