#!make

# makefile for OEIS-mat/contrib/aph
# @(#) $Id$
# 2022-05-06, Georg Fischer

GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
HERE=../contrib/aph
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
a239:
	grep -P "\%[Np] A23924[0-3]" $(COMMON)/jcat25.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
procb:
	grep -A16 -B8 -P "option remember|\# +_Alois P" $(COMMON)/jcat25.txt \
	| grep -P "^\%[pYA]" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	grep remember $@.tmp | wc -l
#----
procbno:
	cut -b4-10 procb.tmp | sort | uniq | wc -l
#----
proclist:
	cut -b4-10 procb.tmp | sort | uniq > $@.tmp
	wc -l $@.tmp
	cd $(COMMON) ; make seq LIST=$(HERE)/$@.tmp
#----
rh_check:
	$(DBAT) "SELECT s.aseqno, n.name FROM seq s, asname n \
	    WHERE s.aseqno IN (SELECT aseqno FROM asinfo WHERE author like '%Hardin%') \
	      AND s.aseqno = n.aseqno \
	    ORDER BY 1" > $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
	cp -v    $@.txt $(COMMON)
	cd $(COMMON) ; make -f checks.make -s html_check1 FILE=$@
#----
stat:
	wc -l procb.tmp
	wc -l proclist.tmp
#----
binom2:
	grep 'add(binomial(b((i-1)$$2, k$$2' procb.tmp
#----