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
#----
#         4      5      6      7      8      9     10     11     12
HIST=055291 055292 055293 055294 055295 055296 055297 055298 055299
hsplit:
	make -s hsplit1 K=4  SEQNO=055291
	make -s hsplit1 K=5  SEQNO=055292
	make -s hsplit1 K=6  SEQNO=055293
	make -s hsplit1 K=7  SEQNO=055294
	make -s hsplit1 K=8  SEQNO=055295
	make -s hsplit1 K=9  SEQNO=055296
	make -s hsplit1 K=10 SEQNO=055297
	make -s hsplit1 K=11 SEQNO=055298
	make -s hsplit1 K=12 SEQNO=055299
	wc -l b05529*.txt
hsplit1:
	echo "#" `grep A$(SEQNO) $(COMMON)/asname.txt` > x.tmp
	echo "# Table n, a(n) generated with PARI in A055290 by Georg Fischer" `date "+%b %d %Y"` >> x.tmp
	sed -e "s/\]\, \[/\n/g"                      a055290.txt \
	| perl split290.pl $(K) >> x.tmp
	echo "" >> x.tmp
	echo "" >> x.tmp
	head -n6 x.tmp
	tail -n4 x.tmp
	cp -v    x.tmp $(COMMON)/bfile/b$(SEQNO).txt
	cp -v    x.tmp                 b$(SEQNO).txt
#----
psplit:
	make -s psplit1 K=3  SEQNO=055350
	make -s psplit1 K=4  SEQNO=055351
	make -s psplit1 K=5  SEQNO=055352
	make -s psplit1 K=6  SEQNO=055353
	make -s psplit1 K=7  SEQNO=055354
	make -s psplit1 K=8  SEQNO=055355
	wc -l b05535*.txt
psplit1:
	echo "#" `grep A$(SEQNO) $(COMMON)/asname.txt` > x.tmp
	echo "# Table n, a(n) generated with PARI in A055349 by Georg Fischer" `date "+%b %d %Y"` >> x.tmp
	sed -e "s/[^\-\,0-9]//g"                     a055349.txt \
	| perl split290.pl $(K) >> x.tmp
	echo "" >> x.tmp
	echo "" >> x.tmp
	head -n6 x.tmp
	tail -n4 x.tmp
	cp -v    x.tmp $(COMMON)/bfile/b$(SEQNO).txt
	cp -v    x.tmp                 b$(SEQNO).txt
#----
qsplit:
	make -s qsplit1 K=3  SEQNO=055364
	make -s qsplit1 K=4  SEQNO=055365
	make -s qsplit1 K=5  SEQNO=055366
	make -s qsplit1 K=6  SEQNO=055367
	make -s qsplit1 K=7  SEQNO=055368
	make -s qsplit1 K=8  SEQNO=055369
	wc -l b05536*.txt
qsplit1:
	echo "#" `grep A$(SEQNO) $(COMMON)/asname.txt` > x.tmp
	echo   "# Table n, a(n) generated with PARI in A055363 by Georg Fischer" `date "+%b %d %Y"` >> x.tmp
	sed -e "s/^[0-9]+\: *//g" -e "s/[^\-\,0-9]//g" a055363.txt \
	| perl split290.pl $(K) 1 >> x.tmp
	echo "" >> x.tmp
	echo "" >> x.tmp
	head -n6 x.tmp
	tail -n4 x.tmp
	cp -v    x.tmp $(COMMON)/bfile/b$(SEQNO).txt
	cp -v    x.tmp                 b$(SEQNO).txt
#----
java7:
	perl a055277.pl
	wc -l *.java
	cp -v *.java $(FISCHER)/manual
java9:
	rm -f *.java
	perl a055277.pl -r A055350
	wc -l *.java
	cp -v *.java $(FISCHER)/manual
	cp -v A055350.java.man $(FISCHER)/manual/A055350.java
