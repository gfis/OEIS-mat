#!make

# OEIS-mat/pull - synchronize local sequences and b-files with OEIS-server
# @(#) $Id$
# 2019-02-21: Georg Fischer: extracted from ../common
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb
SLEEP=16
COMMON=../common
DUMPS=../dumps

all: prepare draft bfdir_load bfdir_check 
	# targets: 
	grep -E "^[a-z]" makefile
#================================
newlog:
	echo # Started 2019-02-21 > prepare.log
prepare: prep1 prep2 prep3 # Download <code>bfilelist.gz</code>, <code>names.gz</code>, <code>stripped.gz</code>, 
	tail -16 prepare.log
prep1:
	rm -f stripped*
	wget https://oeis.org/stripped.gz
	ls -al strip*              >> prepare.log
	gzip -df stripped.gz
	mv stripped ../common/
	sleep $(SLEEP)
prep2:
	rm -f names*
	wget https://oeis.org/names.gz
	ls -al name*               >> prepare.log
	gzip -df names.gz
	mv names ../common/
	sleep $(SLEEP)
prep3:
	rm -f bfilelist*
	wget https://oeis.org/bfilelist.gz
	ls -al bfile*              >> prepare.log
	gzip -df bfilelist.gz
	mv bfilelist ../common/
#	sleep $(SLEEP)
#----------
bfdir_load: # Load the <code>bfilelist</code> into a db table
	perl $(COMMON)/bfdir.pl -c > bfdir.create.sql
	$(DBAT) -f                   bfdir.create.sql
	perl $(COMMON)/bfdir.pl -r   bfilelist \
	| $(DBAT) -m csv -s "\t" -r  bfdir
	$(DBAT) -4                   bfdir
	$(DBAT) -n                   bfdir
#----------
bfdir_check: # Compare <code>bfilelist</code> with local b-file sizes (maybe for draft)
	$(DBAT) "SELECT d.aseqno \
		, substr(d.created, 1, 16) AS oeis_time, substr(b.access, 1, 16) as local_time \
		, d.filesize AS oeis_size,  b.filesize AS local_size, b.message \
		FROM  bfdir d LEFT JOIN bfinfo b ON d.aseqno = b.aseqno  \
		WHERE d.filesize <> COALESCE(b.filesize, 1) \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------
draft: draft_get draft_load
draft_get:
	rm -f   draft1
	# file "draft1" will be created if there are no "older changes"
	# and the loop will be stopped
	make -s draft1 N=000
	make -s draft1 N=100
	make -s draft1 N=200
	make -s draft1 N=300
	make -s draft1 N=400
	make -s draft1 N=500
	make -s draft1 N=600
draft1:
	wget -O              draft.$(N).html https://oeis.org/draft?start=$(N)
	grep "older changes" draft.$(N).html > x.tmp || echo xxx: > draft1
	sleep $(SLEEP)
draft_load:
	grep -E "/draft/" draft.*.html \
	| sed -e "s/[^A0-9]/ /g" -e "s/  */ /g" \
	| cut -d" " -f3 | grep -E "^A" | sort \
	>     $@.tmp 
	wc -l $@.tmp
	perl $(COMMON)/draft.pl -c > draft.create.sql
	$(DBAT)       -f   draft.create.sql
	$(DBAT) -m csv -s "\t" -r draft < $@.tmp
	$(DBAT) -4 draft
	$(DBAT) -n draft
#----------

#----------------
seq: # parameter: $(INFO)
	$(DBAT) -f seq.create.sql
	cut -b1-7 $(INFO) | grep -E "^A" | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
delseq: seq # Delete aseqno's from a table; parameters: $(TAB) $(INFO)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#--------
history: # parameter: DATE
	make hist_kw DATE=`date +%Y-%m-%d` KEYWORD=new     MAX=490
	make hist_kw DATE=`date +%Y-%m-%d` KEYWORD=changed MAX=2020
	make hist_split
	# make hist_kw DATE=`date +%Y-%m-%d` KEYWORD=recycled   
hist_kw: # parameter MAX
	perl history.pl -k $(KEYWORD) -w $(SLEEP) -n $(MAX) hist.$(DATE)
	ls -al hist.$(DATE) | head -n 8
	ls -1  hist.$(DATE) | wc -l
hist_split:
	rm -rf temp
	mkdir temp
	mkdir temp/ajson
	mkdir temp/bfile
	find  hist.`date +%Y-%m-%d` -type f -iname "*.json" \
	| xargs -l -i{} perl split_json.pl  -o temp {}
#================================
