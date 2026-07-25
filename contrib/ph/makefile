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
	cp -v ../../holrec/listtorec.mp \
	         $@.tmp
	grep -h -P "^A[1-9]" phdata.tmp \
	| head -n$(MANY) \
	| gawk -e '{ print "guf(" $$1 ", [" $$3 "]);" }' \
	>>       $@.tmp
	wc -l    $@.tmp
	cp -v    $@.tmp $(GFUN)
	# cmaple -q $@.tmp | tee $@.log
gfun_guess3:
	cp -v ../../holrec/listtoalgeq.mp \
	         $@.tmp
	grep -h -P "^A[1-9]" phdata.tmp \
	| head -n$(MANY) \
	| gawk -e '{ print "guf(" $$1 ", [" $$3 "]);" }' \
	>>       $@.tmp
	wc -l    $@.tmp
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
#----
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
#----------------
stat:
	wc -l             phlist.tmp
	grep -vP "\tnull" phlist.tmp | wc -l
	grep  -P "\tnull" phlist.tmp | wc -l
#--------------------------------
