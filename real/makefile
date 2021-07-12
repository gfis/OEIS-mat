#!make

# OEIS-mat/real: DecimalExpansion, Beatty, ContinuedFraction etc. of real constants
# @(#) $Id$
# 2020-10-31, Georg Fischer: copied from ../weidis
#---------------------------------
GITS=../..
COMMON=../common
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMJAR=$(GITS)/ramath/dist/ramath.jar 
RAMATH=java -cp  $(RAMJAR) org.teherba.ramath
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
NT=32
D=0 # debug mode
HERE=../../OEIS-mat/real

all:
	echo select specific target 
#===============================================
exact: exact1 exact2
exact1:
	$(DBAT) -x "SELECT i.aseqno, i.keyword, n.name \
	  FROM  asinfo i, asname n \
	  WHERE i.aseqno = n.aseqno \
	    AND i.keyword LIKE '%cons%' \
	    AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	    ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
exact2:
	cut -b1-7 exact1.tmp \
	| perl -ne 'm{\A(A\d+)}; my $$aseqno = $$1; print "../common/ajson/$$aseqno.json\n"; '\
	| xargs -l grep -iH "Exact value"
#================

