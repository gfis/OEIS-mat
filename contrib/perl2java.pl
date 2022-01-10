#!/usr/bin/perl

#------------------------------------------------------------------ 
# convert simple Perl programs to Java
# @(#) $Id: perl2java.pl 221 2009-08-11 06:08:05Z gfis $
# 2019-07-25, Georg Fischer: copied from perl2c.pl
# Usage: 
#   perl perl2java.pl perl-file > java-file
#------------------------------------------------------------------ 

use strict;

while (<>) {
    s[\#][\/\/];
    s{scalar\(\@ARGV\)\s*\>\s*0}{iarg \< args.length}g;
    s{shift\(\@ARGV\)}{args\[iarg \+\+\]}g;
    s[(\s*)my(\s)][${1}int$2]g;
    s[\s*use\s+strict\s*\;][public class Dummy \{];
    s[\&(\w+)][$1]g;
    s[\Asub\s+(\w+)][public int $1()];
    s[\sand\s][ \&\& ]g;
    s[\sor\s][ \|\| ]g;
    s[\seq\s][.equals(]g;
    s[\selsif\s][ else if ]g;
    s[if \(0\)][if (false)]g;
    s[\$][]g;
    s{\@(\w+)}{$1\[4095\]};
    s{int \%(\w+)}{HashMap<Integer, Integer> $1 = new HashMap<Integer, Integer>(2048)}g;
    s{\@(\w+)}{$1\[4095\]}g;
    s{(\w+)\s*\!\~\s*m\{([^\}]+)\}}{! $1.matches(\"$2\")}g;
    s{(\w+)\s*\=\~\s*m\{([^\}]+)\}}  {$1.matches(\"$2\")}g;
    s{!\s*defined\(([^\)]+)\)}{$1 == null}g;
    s{defined\(([^\)]+)\)}{$1 != null}g;
    s{(\w+)\{([^\}]+)\}}{$1.get($2)}g;
    s[print\s*([^\;]+)\;][System.out.print($1);]g;
    print;
} # while <>
print "}\n";
