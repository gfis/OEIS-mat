#!make

# OEIS-mat/common - collection of database SELECTs and 'grep's
# @(#) $Id$
# 2019-04-12, Georg Fischer: exported from commn/makefile
#---------------------------------
GITS=../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
DUMPS=../dumps
HEAD=8
COMMON=$(GITS)/OEIS-mat/common
JOEIS=../$(GITS)/gitups/joeis
LITE=$(GITS)/joeis
FISCHER=$(LITE)/internal/fischer
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar org.teherba.ramath.symbolic.PolyFraction 
D=0
#----------------
all:
	# targets: new = prepare newseq archlist regen (in that order)
help:
	grep -E "^[a-z]" select.make
#================
isin_joeis:
	sed -s "s/^\(A[0-9]*\) /\1\t/" $(LIST) > $@.1.tmp
	make seq2 LIST=$@.1.tmp
	$(DBAT) -x "SELECT j.aseqno, j.superclass, s.info \
		FROM joeis j, seq2 s \
		WHERE j.aseqno = s.aseqno \
		ORDER BY 1" \
	| tee    $@.tmp
	wc -l    $@.tmp
#-----------------
coxg: coxgn1 coxf coxgj3 coxgj4
coxgn1: # get Coxeter sequence names
	# rm -f coxg*.tmp
	grep "Number of reduced words of length n in Coxeter group " names \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	sed -e "s/ .*/\t________/" $@.tmp > coxg_separ.tmp
#----
coxf: # get coxG calls from 'names' subset
	perl -ne 'm{^(A\d+)\D+(\d+)\D+(\d+)\D+(\d+)}; print "$$1\tcoxf\t$$4 $$2\n"' \
	coxgn1.tmp | sort > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	$(RAMATH) -f $@.tmp > $@.txt
#----
coxgj3: # get coxG calls from JSONs
	rm -f $@.tmp
	find ajson -name "A*.json" | xargs -l grep -iHE "\"coxg" >> $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp	
coxg_joeis:
	$(DBAT) -x "SELECT s.aseqno, 'joeis', j.superclass \
		FROM seq s, joeis j \
		WHERE s.aseqno = j.aseqno \
		ORDER BY 1" \
	>    $@.tmp
coxg_lrindx:
	$(DBAT) -x "SELECT s.aseqno, 'signat', i.signature \
		FROM seq s, LRINDX i \
		WHERE s.aseqno = 'A' || i.seqno \
		ORDER BY 1" \
	>    $@.tmp
coxg_terms:
	make -f makefile seq LIST=coxgn1.tmp
	$(DBAT) -x "SELECT s.aseqno, 'terms', a.terms \
		FROM seq s, ASINFO a \
		WHERE a.aseqno = s.aseqno \
		ORDER BY 1" \
	>    $@.tmp
coxg_sort: 
	sed -e "s/^ajson\///" -e "s/.json:\t*\"/ /" coxgj3.tmp > $@.1.tmp
	sort err.2019-04-09.19.log coxg_separ.tmp coxg_joeis.tmp coxg_lrindx.tmp coxg_terms.tmp $@.1.tmp coxf.tmp > $@.tmp
#----------------
