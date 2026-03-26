#!make

# OEIS-mat/pull - fetch names.gz, stripped.gz, bfilelist.gz and drafts
# @(#) $Id$
# 2026-03-26: revived - new update process for joeis, OEIS-mat/common and joeis-lite/reflect
# 2020-03-13: with de/encat25 
# 2019-03-01: cleaned
# 2019-02-21: Georg Fischer: extracted from ../common
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
SLEEP=16
COMMON=$(GITS)/OEIS-mat/common
HERE=$(GITS)/OEIS-mat/pull
CAT=$(COMMON)/jcat25.txt
DATE=`date +%Y-%m-%d`

all: help # get a list of the possible targets
xx:
	prepare bfdir_load draft bfdir_check
remote: prepare draft_get draft_prep
bfdir:  prep3 bfdir_load bfdir_check
help: # list all targets: 
	grep -E "^[a-z]" makefile
#================================
#----
bfimin: # get the minimal index for all b-files in ../common/bfile
	find $(COMMON)/bfile -name "b*.txt" |\
	perl bfimin.pl \
	>        $@.tmp
	tail -n2 $@.tmp
	wc -l    $@.tmp
bfhrec: # get the list of non-synthesized b-files (linked in %H records)
	grep -P "^.H" $(CAT) \
	| grep -P "\/b\d{6}\.txt\"" \
	| perl -ne 'if (m{\/b(\d{6})\.txt\"}) { print "A$$1\n"; }' \
	>        $@.tmp
	tail -n2 $@.tmp
	wc -l    $@.tmp
bfolst: # get the list of non-synthesized b-files from oeisdata/files
	find $(GITS)/oeisdata/files -name "b??????.txt" \
	| perl -ne 'if (m{\/b(\d{6})\.txt}) { print "A$$1\n"; }' \
	>        $@.tmp
	tail -n2 $@.tmp
	wc -l    $@.tmp 

bfnewer: # REF= pack all b-files that are newer than $(REF)
	cd $(COMMON) ; find bfile -iname "b*.txt" -newer $(REF)           | tee $(HERE)/$@.tmp
	cd $(COMMON) ; tar -czf $(HERE)/$@.`date +%Y-%m-%d.%H`.tgz --files-from=$(HERE)/$@.tmp
	tar               -tzvf $(HERE)/$@.`date +%Y-%m-%d.%H`.tgz
	wc -l    $@.tmp
#================================
# old targets
newlog:
	echo # Started 2019-02-21 > prepare.log
prepare: prep1 prep2 prep3 # Download <code>bfilelist.gz</code>, <code>names.gz</code>, <code>stripped.gz</code>, 
	tail -16 prepare.log
prep1:
	rm -f stripped*
	wget https://oeis.org/stripped.gz
	ls -al strip*              >> prepare.log
	gzip -df stripped.gz
	mv stripped $(COMMON)
	sleep $(SLEEP)
prep2:
	rm -f names*
	wget https://oeis.org/names.gz
	ls -al name*               >> prepare.log
	gzip -df names.gz
	mv names    $(COMMON)
	sleep $(SLEEP)
prep3:
	rm -f bfilelist*
	wget https://oeis.org/bfilelist.gz
	ls -al bfile*              >> prepare.log
	gzip -df  bfilelist.gz
	cp -pv    bfilelist $(COMMON)
	head -8   bfilelist
	ls -al bfile*              
prep4:
	perl $(COMMON)/bfdir.pl -r $(COMMON)/bfilelist > $(COMMON)/bfdir.tmp
#	sleep $(SLEEP)
#=================================
bfdir_load: # Load the <code>bfilelist</code> into a db table
	cd $(COMMON) ; make bfdir_load
#--
bfdir_check: # Compare <code>bfilelist</code> with local b-file sizes (maybe for draft)
	cd $(COMMON) ; make -f checks.make bfdir_check html_checks
#=================================
cat25: # Fetch the CAT25 file (internal format of all sequences). 
	# Replace the server filename in next line
	wget -O cat25.$(DATE).gz https://oeis.org/A123456/a123456.gz 
	cp -v   cat25.$(DATE).gz $(DUMPS)
	gzip -d cat25.$(DATE).gz
	mv -v   cat25.$(DATE) $(COMMON)/cat25.text
#=================================
draft: draft_get draft_prep draft_load
draft_get:
	rm -f   draft.*.html draftp drafte
	# files "draft?" will be created if there are no "older changes"
	# and makes will be skipped by the existance of that file
	echo proposed
	make -s draftp N=000
	make -s draftp N=100
	make -s draftp N=200
	make -s draftp N=300
	make -s draftp N=400
	make -s draftp N=500
	make -s draftp N=600
	echo editing
	make -s drafte N=000
	make -s drafte N=100
	make -s drafte N=200
	make -s drafte N=300
	make -s drafte N=400
	make -s drafte N=500
	make -s drafte N=600
draftp:
	wget -O              draft.$(N)p.html https://oeis.org/draft?start=$(N)
	grep "older changes" draft.$(N)p.html > x.tmp || echo xxx: > draftp
	sleep $(SLEEP)
drafte:
	wget -O              draft.$(N)e.html https://oeis.org/draft/editing?start=$(N)
	grep "older changes" draft.$(N)e.html > x.tmp || echo xxx: > drafte
	sleep $(SLEEP)
#----------
draft_prep:
	grep -E "/draft/" draft.*.html \
	| sed -e "s/[^A0-9]/ /g" -e "s/  */ /g" \
	| cut -d" " -f3 | grep -E "^A" | sort | uniq \
	>     draft_load.tmp 
	wc -l draft_load.tmp
	cp -v draft_load.tmp $(COMMON)/
#----------
draft_load:
	perl $(COMMON)/draft.pl -c > draft.create.sql
	$(DBAT)       -f   draft.create.sql
	$(DBAT) -m csv -s "\t" -r draft < draft_load.tmp
	$(DBAT) -4 draft
	$(DBAT) -n draft
#----------
draft_show:
	grep -E "(\<ins\>|\<del\>)" draft_A320518.html
#===============================
catcount:
	cut -b1-2 $(CAT25) | sort | uniq -c | tee $@.2.tmp
	grep -E "%" $@.2.tmp | cut -b9- | tee $@.1.tmp
PREFIX=19101
SUPP=--suppress-common-lines
DIR=subset
catsel:
	grep -E "^%. A$(PREFIX)" $(CAT25) > $@.tmp
	wc -l     $@.tmp
	cut -b1-2 $@.tmp | sort | uniq > $@.1.tmp
	diff -wy --suppress-common-lines catcount.1.tmp $@.1.tmp
encat:
	rm -f     $@.tmp
	find $(DIR) -iname "*.json" | sort | xargs -l \
	perl encat25.pl -m json >> $@.tmp
	diff -wy --suppress-common-lines  catsel.tmp       $@.tmp \
	>         $@.diff.tmp || :
	head -256 $@.diff.tmp
	wc -l     $@.diff.tmp
subs:
	rm -rf subset
	mkdir subset
	find $(COMMON)/ajson -iname "A$(PREFIX)*.json" | sort | xargs -l -i{} cp {} subset
	ls -1 subset | wc -l

