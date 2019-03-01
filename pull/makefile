#!make

# OEIS-mat/pull - fetch names.gz, stripped.gz, bfilelist.gz and drafts
# @(#) $Id$
# 2019-03-01: cleaned
# 2019-02-21: Georg Fischer: extracted from ../common
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb
SLEEP=16
COMMON=../common
DUMPS=../dumps
DATE=`date +%Y-%m-%d`

all:    prepare bfdir_load draft bfdir_check
remote: prepare draft_get draft_prep
bfdir:  prep3 bfdir_load bfdir_check
help:
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
	gzip -df bfilelist.gz
	perl      $(COMMON)/bfdir.pl -r  bfilelist \
	>         $(COMMON)/bfdir.tmp
	head -n 4 $(COMMON)/bfdir.tmp
	wc -l     $(COMMON)/bfdir.tmp
#	sleep $(SLEEP)
#=================================
bfdir_load: # Load the <code>bfilelist</code> into a db table
	perl $(COMMON)/bfdir.pl -c > bfdir.create.sql
	$(DBAT) -f                   bfdir.create.sql
	$(DBAT) -m csv -s "\t" -r    bfdir < $(COMMON)/bfdir.tmp
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
	>     $(COMMON)/$@.txt
	wc -l $(COMMON)/$@.txt
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
	rm -f   draft.*.html
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
#----------
