#!make

# makefile for OEIS-mat/contrib/rh (R. Hardin)
# base k circular numbers ... difference at most d
# @(#) $Id$
# 2026-07-06: use recurrence-guess.gp from Kevin Ryde
# 2021-04-08, Georg Fischer

GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
BFILE=$(COMMON)/bfile
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
HERE=../contrib/rh
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
circdiff5: # extract aseqno,k,d
	cut -f1,4,5 $(FISCHER)/circdiff1.tmp \
	| tee    $@.tmp
	wc -l    $@.tmp
#----
prepbf: # generate b-files from originals
	perl circprep.pl -m bf circdiff5.tmp
	ls -al b*.txt | wc
movebf: # move b-files to local bfile directory
	mv -v b*.txt $(COMMON)/bfile
#----
circgen: circdiff1 circdiff2 circdiff
circdiff1: # write *.gen file for HolonomicRecurrence
	perl circprep.pl -m gen circdiff5.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
circdiff2:
	$(RAMATH).sequence.JoeisPreparer -f circdiff1.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
circdiff:
	grep -E "\[" circdiff2.tmp \
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
#	| sed -e "s/\tcircdiff/\tholos/" \
#
#----------------
hardall_old:
	grep Hardin $(COMMON)/asinfo.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
hardall0: # select Hardin's sequences
	$(DBAT) -x "SELECT i.aseqno, COALESCE(j.superclass, 'null'), 0, b.termno, b.data, n.name \
	    FROM asinfo i, asname n, bfdata b \
	    LEFT JOIN joeis j ON b.aseqno = j.aseqno \
	    WHERE i.aseqno = n.aseqno \
	      AND n.aseqno = b.aseqno \
	      AND i.author LIKE '%Hardin%' ORDER BY 1" \
	| head -n644444 \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
#--
# A009617	Sequence	0	9	1,116,202576,1557978176,34206677698816,1706222428480541696,167325183704890858786816,29168516299952885066683006976,8389219957754997383106354075467776
hardall1: # start at offset k
	cat hardall0.tmp \
	| perl -ne 's/\s+\Z//; my ($$aseqno, $$superclass, $$offset, $$termno, $$list, $$name) = split(/\t/, $$_); '\
	' if ($$termno >= 40) { my @terms = split(/\,/, $$list); '\
	' print join("\t", $$aseqno, $$superclass, $$offset, $$termno, join(",", splice(@terms, 8, 32)), $$name) . "\n"; } '\
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
#--
hardall2: # was fischer/eumapgf2
	perl $(COMMON)/callmaple.pl -t 4 -n 32 -p hardall2.mpat hardall1.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
hardall3: # count the non-FAIL
	grep -v FAIL hardall2.tmp | wc
hardall4: # sort the signatures by descending frequency
	grep -v FAIL hardall2.tmp | grep -E "^A" | cut -f5 | sort | sed -e "s/\,\[.*//" \
	| uniq -c | sort -rn > $@.tmp
#----
empir: empir1 empir2 empir3 empir4 empir5 # Empirical: = conjectured recurrences
empir1: # prepare for seq3 format
	grep -P "Empirical\: *a\(n\) *\= *[\-\+]?\d*\*?a\(n" $(COMMON)/jcat25.txt | endirect \
	| grep -P "^.. [A]" | cut -b4- \
	| grep -vP "^(A184123|A184132|A184140|A184141|A191006)" \
	| perl empir_prep.pl \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*tmp
empir2: # select Hardin's, and make seq4 format
	cd $(COMMON) ; make seq3 LIST=$(HERE)/empir1.tmp
	$(DBAT) -x "SELECT i.aseqno, 'bva', i.offset1, s3.info, CASE WHEN s3.pattern LIKE '..%' THEN '[' || i.offset1 || s3.pattern || ']' ELSE s3.pattern END \
	    , CASE WHEN length(i.program) > 0 THEN 'nyi=' || i.program ELSE '' END \
	    FROM asinfo i, seq3 s3 \
	    WHERE i.aseqno = s3.aseqno \
	      AND i.author LIKE '%Hardin%' \
	      ORDER BY 1" \
	| head -n644444 \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
empir3:
	$(JPREP) -f empir2.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	tail -n8 $@.tmp
	wc -l    $@*
empir4:
	holinits -a 0 empir3.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	tail -n2 $@.tmp
	wc -l    $@*
empir5:
	sed -e "s/\tholos/\tholoscj2/" empir4.tmp > $(FISCHER)/aman/empir.man
#----------------
LIST=rhdata.tmp
SPLICE=16
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
#----
proven: proven1 proven2 proven3
proven1: # load the guessed ones
	grep -P "^A" gp_guess.tmp | sed -e "s/ /\t/" > $@.tmp
	cd $(COMMON) ; make seq3 LIST=$(HERE)/$@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
proven2: # load Israel's proofs
	cd $(COMMON) ; make seq LIST=../contrib/ri/recurrence_proofs.man
proven3: # match guessed with proven
	$(DBAT) "SELECT s1.aseqno, s3.pattern, s3.info \
	    FROM seq s1 LEFT JOIN seq3 s3 ON s1.aseqno = s3.aseqno \
	    ORDER BY 1" \
	| tee    $@.tmp
	wc -l    $@.tmp
	make hmize TARGET=$@
rhdata: # select from bfdata for Hardin's sequences
	$(DBAT) -x "SELECT i.aseqno, d.termno, d.data, '', 'x' \
	    FROM asinfo i, bfdata d \
	    WHERE i.aseqno = d.aseqno \
	      AND i.author LIKE '%Hardin%' \
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
rhlist: # select Hardin's sequences
	$(DBAT) -x "SELECT i.aseqno, COALESCE(j.superclass, 'null ' || i.program), 0, b.bfimin || '..' || b.bfimax, n.name \
	    FROM asinfo i, asname n, bfinfo b \
	    LEFT JOIN joeis j ON b.aseqno = j.aseqno \
	    WHERE i.aseqno = n.aseqno \
	      AND n.aseqno = b.aseqno \
	      AND i.author LIKE '%Hardin%' \
	      AND i.keyword NOT LIKE '%tab%' \
	      AND i.aseqno >= 'A087000' \
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
