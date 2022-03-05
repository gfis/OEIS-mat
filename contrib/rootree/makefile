#!make

# makefile for OEIS-mat/contrib/rootree - hol.rec. for rooted trees
# @(#) $Id$
# 2022-03-04, Georg Fischer

GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
BFILE=$(COMMON)/bfile
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar org.teherba.ramath
DOALL=perl -e 'print join("\n", @ARGV);' $(LIST) | xargs -i{}
#----------------
all:
	# call with one of the following targets:
	grep -E "^[a-z]" makefile
#----	
LIST=055278 055279 055280 055281 055282 055283 055284 055285 055286 055287
#----
java:
	perl a055277.pl
	wc -l *.java
	cp -v *.java $(FISCHER)/manual
#----
to_bfile: # copy all files generated with PARI 
	cp -v b0552??.txt $(COMMON)/bfile
list1:
	echo $(LIST) | xargs -d" " -i{} ls -al $(COMMON)/bfile/b{}.txt
list:
	$(DOALL) ls -al $(COMMON)/bfile/b{}.txt
save:
	mkdir -p savebf
save_old:
	rm -rvf savebf
	mkdir   savebf
	$(DOALL) cp -vp $(COMMON)/bfile/b{}.txt savebf
	ls -al savebf
#----
copy12:
	perl ../data_bf.pl -o 1 -to bf ../../../joeis-lite/internal/fischer/a12.txt | grep -v " 0" | tee b055287.txt
#----
prepbf:
	$(DOALL) make prepbf1 SEQNO={}
prepbf1:
	echo "#" `grep A$(SEQNO) $(COMMON)/asname.txt` > x.tmp
	echo "# Table n, a(n) generated with PARI in A055277 by Georg Fischer" `date "+%b %d %Y"` \
	                  >> x.tmp
	cat ./b$(SEQNO).txt >> x.tmp
	head -n4 x.tmp
	cp -v    x.tmp $(COMMON)/bfile/b$(SEQNO).txt
parts2:
	perl parts_binom.pl parts1.tmp \
	>        $@.tmp
	head -n8 $@.tmp
	wc   -l  $@.tmp
