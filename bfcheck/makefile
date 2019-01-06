#!make

# OEIS-mat: b-file check
# @(#) $Id$
# 2019-01-05: Georg Fischer, copied from ../coincidence/database
#---------------------------------
BASE=b000001-b321800.tar

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
unpack:
	make bfall TARGET=unpack1
unpack1:
	mkdir      	b$(D1)$(D2)
	grep -vE  "^b$(D1)\[$(D2)" exclude_all.pat | tee exclude.tmp
	tar -C     	b$(D1)$(D2) --exclude-from=exclude.tmp -xvf $(BASE)
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
#=================
# old targets
news2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	cat archlist.tmp | xargs -l -i{} rm -vf ../store/{}.text
#------------
