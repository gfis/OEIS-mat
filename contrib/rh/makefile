#!make

# makefile for OEIS-mat/contrib/rh (R. Hardin)
# base k circular numbers ... difference at most d
# @(#) $Id$
# 2021-04-08, Georg Fischer

GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
BFILE=$(COMMON)/bfile
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar org.teherba.ramath
#----------------
all:
	grep -E "^[a-z]" makefile
	# parameter S=seqno SLEEP=$(SLEEP) SHIFT=$(SHIFT) WIDTH=$(WIDTH)
#================
fischer: # move from fischer/internal
	ls -al $(FISCHER)/circ*
#----
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
#----------------
rhlist: # select Hardin's sequences
	$(DBAT) -x "SELECT i.aseqno, COALESCE(j.superclass, 'null ' || i.program), 0, b.bfimin || '..' || b.bfimax, n.name \
	    FROM asinfo i, asname n, bfinfo b \
	    LEFT JOIN joeis j ON b.aseqno = j.aseqno \
	    WHERE i.aseqno = n.aseqno \
	      AND n.aseqno = b.aseqno \
	      AND i.author LIKE '%Hardin%' ORDER BY 1" \
	| head -n644444 \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
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
