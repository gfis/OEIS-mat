#!make

# makefile for OEIS-mat/contrib/ph (Paul Hanna)
# @(#) $Id$
# 2026-07-24, Georg Fischer: copied from../rh/makefile

#ITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
BFILE=$(COMMON)/bfile
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
GFUN=$(GITS)/gfun
HERE=$(GITS)/OEIS-mat/contrib/ph
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar
JPREP=$(RAMATH)  org.teherba.ramath.sequence.JoeisPreparer
#----------------
all:
	grep -E "^[a-z]" makefile
	# parameter S=seqno SLEEP=$(SLEEP) SHIFT=$(SHIFT) WIDTH=$(WIDTH)
#================
fischer: # move from fischer/internal
	ls -al $(FISCHER)/circ*
#----
hmize: # TARGET= htmlize the result of a grep
	wc -l        $(TARGET).tmp
	grep -A10 -P "\A$(TARGET)\:" makefile > hmize.tmp
	perl $(FISCHER)/htmlize.pl $(TARGET).tmp \
	| perl $(COMMON)/html_append.pl > $(TARGET).html
	chmod 755    $(TARGET).html
	cmd /c start $(TARGET).html
	e            $(TARGET).tmp
#----
LIST=gfun_data.tmp
SPLICE=0
MANY=644444

gfun_guess: gfun_prep gfun_data gfun_guess1 gfun_guess2 # LIST= ; guess lin.rec.s with Maple's guessgf
gfun_prep:
	grep ogf $(GFUN)/gfun_guess2.log \
	>        $@.tmp
	cd $(COMMON) ; make seq LIST=$(HERE)/$@.tmp
gfun_data: # select from bfdata for Hanna's sequences
	$(DBAT) -x "SELECT i.aseqno, d.termno, d.data, '', 'x' \
	    FROM asinfo i, bfdata d, seq s \
	    WHERE i.aseqno = s.aseqno \
	      AND s.aseqno = d.aseqno \
	      ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
gfun_guess1:
	mkdir -p gfun
	gawk -e '{ print $$1 "\t" $$2 "\t\tx" }' gfun_data.tmp \
	| getinits -p 2 gfun_data.tmp \
	| perl $(COMMON)/splice.pl -s $(SPLICE) \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
gfun_guess2:
	cp -v ../../holrec/guf.mp \
	         $@.tmp
	grep -h -P "^A[1-9]" gfun_guess1.tmp \
	| head -n$(MANY) \
	| gawk -e '{ print "guf(" $$1 ", [" $$3 "]);" }' \
	>>       $@.tmp
	cp -v    $@.tmp $(GFUN)
	# cmaple -q $@.tmp | tee $@.log
gfun_eval:
	cat    $(GFUN)/gfun_guess3.log \
	| perl gfun_eval.pl \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
gfun_holos:
	$(JPREP) -f gfun_eval.tmp \
	2>       $@.rest.tmp \
	| sed -e "s/\tbva\t/\tholoscj\t/" \
	>        $@.tmp
	tail -n8 $@.tmp
	wc -l    $@*
	cp -v    $@.tmp $(FISCHER)/aman/$@.man
#----
gp_guess: # LIST= ; guess lin.rec.s with Kevin's recurrence-guess.gp
	mkdir -p guess
	gawk -e '{ print $$1 "\t" $$2 "\t\tx" }' $(LIST) \
	| getinits -p 2 $(LIST) \
	| perl $(COMMON)/splice.pl -s $(SPLICE) \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
	perl gp_guess.pl $@.tmp \
	| tee    $@.log
	grep -v "#" $@.log | wc -l
phdata: # select from bfdata for Hardin's sequences
	$(DBAT) -x "SELECT i.aseqno, d.termno, d.data, '', 'x' \
	    FROM asinfo i, bfdata d \
	    WHERE i.aseqno = d.aseqno \
	      AND i.author LIKE '%Hanna%' \
	      AND i.keyword NOT LIKE '%tab%' \
	      AND d.termno >= 32 \
	      AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	      ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
guessed_data: # select from bfdata for the ones that were previously guessed
	cd ../../common ; make seq LIST=rhguess.tmp
	$(DBAT) -x "SELECT i.aseqno, d.termno, d.data \
	    FROM seq i, bfdata d \
	    WHERE i.aseqno = d.aseqno \
	      ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
phlist: # select Hanna's sequences
	$(DBAT) -x "SELECT i.aseqno, COALESCE(j.superclass, 'null ' || i.program), 0, b.bfimin || '..' || b.bfimax, n.name \
	    FROM asinfo i, asname n, bfinfo b \
	    LEFT JOIN joeis j ON b.aseqno = j.aseqno \
	    WHERE i.aseqno = n.aseqno \
	      AND n.aseqno = b.aseqno \
	      AND i.author LIKE '%Hanna%' \
	      AND i.keyword NOT LIKE '%tab%' \
	      AND i.aseqno >= 'A086000' \
	      ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
mma_guess: mma_guess1 mma_guess2 # needs rhlist; guess with wolfram FindGeneratingFunction, prepare script only
mma_guess1:
	endirect rhlist.tmp | grep -P "^A" > $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
	cd $(COMMON) ; make seq LIST=$(HERE)/$@.tmp
	$(DBAT) -x "SELECT i.aseqno, d.termno, d.data \
	    FROM seq i, bfdata d \
	    WHERE i.aseqno = d.aseqno \
	      ORDER BY 1" \
	>        $@.tmp
	head -n2 $@.tmp
	wc   -l  $@.tmp
MODE=linrec
mma_guess2:
	grep -P "^A(08[7-9]|09|[1-9])" mma_guess1.tmp \
	| perl mma_guess.pl -m $(MODE) > mma_$(MODE).tmp
	head -n2 mma_$(MODE).tmp
	wc -l    mma_$(MODE).tmp
	scp      mma_$(MODE).tmp  pi@bluepi:~
stat:
	wc -l rhlist.tmp
	grep -vP "\tnull" rhlist.tmp | wc -l
	grep  -P "\tnull" rhlist.tmp | wc -l
#----------------
parts: parts1 parts2 # A159355 Number of n X n arrays of squares of integers summing to 4.
	mv -v parts2.tmp $@.tmp
parts1: # using partition4.pl
	cat hardname.tmp \
	| grep -v "with" \
	| perl -ne 'use strict; my $$line = $$_; $$line =~ s{\s+\Z}{}; '\
	' if ($$line =~ s{Number of n X n arrays of squares of integers summing to (\d+)}{$$1}) {'\
	' $$line =~ s{\d+\.\.\d+\t}{}; $$line =~ s{\t\w+\t0}{\tbinom\t0}; $$line =~ s{\.}{}g; print "$$line\n"; }'\
	| perl partition4.pl \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
parts2:
	perl parts_binom.pl parts1.tmp \
	>        $@.tmp
	head -n8 $@.tmp
	wc   -l  $@.tmp
#--------------------------------
# A151633	Sequence	0	1..200	Number of permutations of 3 indistinguishable copies of 1..n with exactly 3 adjacent element pairs in decreasing order.
A151633:
	grep -P "permutations of \d+ indist" rhlist.tmp | grep decreasing | grep -vP "circle|Holon" \
	| perl -ne 'use strict; my $$line = $$_; my $$aseqno = substr($$line, 0, 7); '\
	' if (m{(\d+) indistinguishable copies of 1\.\.n with exactly (\d+)}) {'\
	' my ($$copies, $$pairs) = ($$1, $$2); print join("\t", $$aseqno, "parmof3", 0, "A151633", $$copies, $$pairs) . "\n"; }'\
	| tee $@.tmp
	wc -l $@.tmp
#--------------------------------
