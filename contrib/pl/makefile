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
HERE=../contrib/pl
#----------------
all:
	grep -E "^[a-z]" makefile
	# parameter S=seqno SLEEP=$(SLEEP) SHIFT=$(SHIFT) WIDTH=$(WIDTH)
#================
pts: # partition transform search
pts1: # get the original sequences (no base, word etc.)
	$(DBAT) "SELECT b.aseqno, i.keyword, i.offset1, substr(b.data, 1, 256), n.name \
	  FROM bfdata b, asinfo i, asname n \
	  WHERE b.aseqno = i.aseqno \
	    AND i.aseqno = n.aseqno \
	    AND b.termno >= 19 \
	  ORDER BY 1" \
	| perl -ne 'my($$aseqno, $$keyword, $$offset1, $$data, @rest) = split(/\t/);'\
	' my @terms = split(/\,/, $$data); $$data = join(",", splice(@terms, 0, 9)); '\
	' if (scalar(@terms) >= 9 && ($$keyword !~ m{base|word|tabf|tabl|const|cofr|bref|dead|dump|obsc})) {'\
	' print join("\t", $$aseqno, "search", $$offset1, $$data, @rest); } '\
	| grep -vi "prime" \
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
ptsr_eval: # count the hits
	grep -P "\t\.\.a" ptsr.tmp \
	| cut -f1 | sort | uniq -c | sort -rn \
	| perl -ne 's{\A *}{}; s{\s+\Z}{}; my ($$count, $$aseqno) = split(/ /); print "$$aseqno\t$$count\n";'\
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
	cd $(COMMON); make seq2 LIST=$(HERE)/$@.tmp
ptsr_join: # join original and finding(s)
	perl ptsr_join.pl ptsr.tmp \
	| sort | uniq -w 7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
# https://cocalc.com/projects/f63cfcb5-46a2-4465-9491-c084ef52b42b/files/PartitionCheck.txt
# EXPECTED:  A002467 generates triangle A357586 with offset 0
check_extract: # get pairs from PL's file
	grep "generates triangle" PartitionCheck.txt \
	| perl -ne 'm{(A\d+) generates triangle (A\d+) with offset (\d)}; print join("\t", $$2, "partran", $$3, $$1) . "\n";'\
	| sort | uniq -w7 \
	| tee    $@.tmp
	wc -l    $@.tmp
