#!make

# OEIS-mat: b-file check
# @(#) $Id$
# 2019-01-05: Georg Fischer, copied from ../coincidence/database
#---------------------------------
BASE=b000001-b321800.tar
BASEZ=$(BASE).gz
SLEEP=8

all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#--------
bfall: u0 u1 u2 u3 
# parameter is $(TARGET)
u0:
	make $(TARGET) D1=0 D2=0
	make $(TARGET) D1=0 D2=5
u1:
	make $(TARGET) D1=1 D2=0
	make $(TARGET) D1=1 D2=5
u2:
	make $(TARGET) D1=2 D2=0
	make $(TARGET) D1=2 D2=5
u3:
	make $(TARGET) D1=3 D2=0
	make $(TARGET) D1=3 D2=5
#----
split: unpack pack count
unpack:
	make bfall TARGET=unpack1
unpack1:
	mkdir      	b$(D1)$(D2)
	grep -vE  "^b$(D1)\[$(D2)" exclude_all.pat | tee exclude.tmp
	tar -C     	b$(D1)$(D2) --exclude-from=exclude.tmp -xzvf $(BASEZ)
	# tar -C     	b$(D1)$(D2) --exclude-from=exclude.tmp -xvf $(BASE)
pack:
	make bfall 	TARGET=pack1
pack1:
	tar -czf   	b$(D1)$(D2).tgz b$(D1)$(D2)
#--------
count:
	make bfall 	TARGET=count1
count1:
	ls -1		b$(D1)$(D2)	| wc -l
#----
clean:
	rm -f clean.log
	make u0 u1 u2 u3 TARGET=clean1
clean1:
	perl rm_synthesized.pl b$(D1)$(D2) 2>> clean.log
#-----------------
bflink:
	perl bflink.pl ../broken_link/bigout1 > bflink.txt 2> bflink_strange.txt
	cat bflink_strange.txt
	wc -l bflink*.txt
#------------------
delseq: delseq1 delseq2
delseq1:
	wget https://oeis.org/wiki/Deleted_sequences      -O delseq.2018.tmp
	sleep $(SLEEP)
	wget https://oeis.org/wiki/Deleted_sequences/2017 -O delseq.2017.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2016 -O delseq.2016.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2015 -O delseq.2015.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2014 -O delseq.2014.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2013 -O delseq.2013.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2012 -O delseq.2012.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2011 -O delseq.2011.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2010 -O delseq.2010.tmp
	sleep $(SLEEP)
delseq2:
	rm -f delseq.tsv.txt
	find . -iname "delseq.*.tmp" | sort -r | xargs -l perl bfdelseq.pl >> delseq.tsv.txt
	wc -l delseq.tsv.txt
very_diff: 
	sed -e "s/^b/A/" -e "s/.txt//" Pedersen.very-different.234.txt > $@.tmp 
	grep -f $@.tmp delseq.tsv.txt | sort > delseq.$@.txt
	perl tsv_html.pl delseq.$@.txt > delseq.$@.html
#-----------------
deploy:
	scp delseq.tsv.txt delseq.very_diff.txt delseq.very_diff.html index.html \
		gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/bfcheck/
#=================
# old targets
news2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	cat archlist.tmp | xargs -l -i{} rm -vf ../store/{}.text
#------------
