#!make

# makefile for Gfis's OEIS contributions
# @(#) $Id$
# 2020-06-23: check, distrib
# 2019-10-27, Georg Fischer

GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
BFILE=$(COMMON)/bfile
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
OFFSET=0
#----------------
all:
	grep -E "^[a-z]" makefile
	# parameter S=seqno SLEEP=$(SLEEP) SHIFT=$(SHIFT) WIDTH=$(WIDTH)
#================
pts: # partition transform search
pts1: # get the original sequences (no base, word etc.)
	$(DBAT) "SELECT b.aseqno, i.keyword, i.offset1, substr(b.data, 1, 256) \
	  FROM bfdata b, asinfo i \
	  WHERE b.aseqno = i.aseqno \
	    AND b.termno >= 19 \
	  ORDER BY 1" \
	| perl -ne 'my($$aseqno, $$keyword, $$offset1, $$data, @rest) = split(/\t/);'\
	' my @terms = split(/\,/, $$data); $$data = join(",", splice(@terms, 0, 7)); '\
	' if (scalar(@terms) >= 6 && ($$keyword !~ m{base|word|tabf|tabl|const|cofr|bref|dead|dump|obsc})) {'\
	' print join("\t", $$aseqno, "search", $$offset1, $$data) . "\n"; } '\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
ptstest: # test A000108
	grep A000108 pts1.tmp \
	| perl ptsearch.pl \
	| tee    $@.tmp
ptstabl: # assemble all 'tabl' sequences
	$(DBAT) "SELECT b.aseqno, 'tabl', i.offset1, substr(b.data, 1, 256) \
	  FROM bfdata b, asinfo i \
	  WHERE b.aseqno = i.aseqno \
	    AND i.keyword like '%tabl%' \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
ptsr: # search for results in ptstabl.tmp
	cat pts1.tmp \
	| perl ptsearch.pl \
	| tee    $@.tmp
#--------