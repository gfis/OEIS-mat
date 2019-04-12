#!make

# OEIS-mat/common - collection of database SELECTs and 'grep's
# @(#) $Id$
# 2019-04-12, Georg Fischer: exported from makefile
#---------------------------------
GITS=../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
SLEEP=16
DUMPS=../dumps
HEAD=8
PULL=../pull
COMMON=$(GITS)/OEIS-mat/common
JOEIS=../$(GITS)/gitups/joeis
LITE=$(GITS)/joeis
FISCHER=$(LITE)/internal/fischer
D=0
G=n
NMAX=150
CMAX=450
#-------------
all:
	# targets: new = prepare newseq archlist regen (in that order)
help:
	grep -E "^[a-z]" select.make
#-------------------------------
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
coxg: coxg1 coxg2
coxg1:
	grep "Number of reduced words of length n in Coxeter group " names \
	| perl -ne 'm{^(A\d+)\D+(\d+)\D+(\d+)}; print "$1\tcoxG\t$2\t$3\n"' \
	> $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
