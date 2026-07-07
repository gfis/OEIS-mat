#!make

# makefile for OEIS-mat/contrib/ri (Robert Israel)
# 2026-07-06: Georg Fischer

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
proofs:
	grep Israel $(COMMON)/jcat25.txt | grep -iP "proof|proven" | endirect | grep -P "^.. ."  | tee proofs.tmp
#----
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
#--------------------------------
