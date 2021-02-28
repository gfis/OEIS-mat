#!/bin/make

# Continued fractions of sqrt(n)
# @(#) $Id$
# 2021-02-18: sqrt20k.txt; new directory OEIS-mat/cfsqrt
# 2019-06-30, Georg Fischer
#
GITS=../..
COMMON=$(GITS)/OEIS-mat/common
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
BFILE=$(COMMON)/bfile
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer

all:

#--------
sqrt20k: # list of periods of c.f. for sqrt(n), n=0..20000
	java -cp $(GITS)/ramath/dist/ramath.jar org.teherba.ramath.ContinuedFraction -sqrt2 0 20000 \
	| sed -e "s/\r//" \
	> $@.txt
#--------
check0: check01 check02
check01:
#	$(DBAT) -x "SELECT SUBSTR(data,3,128), aseqno FROM bfdata WHERE data LIKE '0,1,%'" >  $@.1.tmp
#	$(DBAT) -x "SELECT SUBSTR(data,1,128), aseqno FROM bfdata WHERE data LIKE '1,%'"   >  $@.2.tmp
	$(DBAT) -x "SELECT SUBSTR(data,3,1024), aseqno FROM bfdata"  >  $@.1.tmp
	$(DBAT) -x "SELECT SUBSTR(data,1,1024), aseqno FROM bfdata"  >  $@.2.tmp
	sort $@.1.tmp $@.2.tmp > $@.tmp 
check02:
	perl dupl01.pl check01.tmp > $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
#--------
signats: # get the signatures of the num./denominators of c.f. convergents to sqrt(n)
	# Numerators of continued fraction convergents to
	$(DBAT) -x "SELECT j.aseqno, 'signats', 0, SUBSTR(n.name, 49,20), i.signature \
	  FROM joeis j, lrindx i, asname n \
	  WHERE 'A' || i.seqno = j.aseqno \
	    AND j.aseqno = n.aseqno \
	    AND j.superclass LIKE 'Continu%' \
	    AND n.name LIKE 'Numerator%' \
	  ORDER BY 1 "\
	| perl -ne 's{sqrt\((\d+)\)\.}{$$1}; s{\r}{}; print; '\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--
signat1: # extract the signatures with a trailing ",1" instead of ",-1"
	perl -ne 'print if m{\,0\,1\r?\n};' signats.tmp \
	| tee    $@.tmp
	wc -l    $@.tmp
#----
b341862:
	perl a341862.pl $(FISCHER)/holref.gen \
	>        $@.tmp \
	2>       $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
#----
# Old targets
#
# Central element(s) in continued fraction expansion of sqrt(n) or 0 if no such element exists or -1 if n is a square
b308778:
	# nyi
#----
# First element of the period of the continued fraction expansion of sqrt(k), where the period has length 3
# 66	8;8,16
fper3:
	head -n 600  $(CFSQ) \
	| perl -ne 'if (m{\A\d+\s+\d+\;(\d+)\,\d+\s+\Z}) { print "$$1, ";}' \
	| tee $@.data

