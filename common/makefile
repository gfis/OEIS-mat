#!make

# OEIS-mat/common - scripts and data common to all subprojects
# @(#) $Id$
# 2019-01-22: unpacking from ../dumps
# 2019-01-17: Georg Fischer
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb
SLEEP=16
DUMPS=../dumps
HEAD=8
DATABASE=../coincidence/database
D=0

all:
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#================================
list_dumps:
	tar -tzvf $(DUMPS)/b000001-b321800.tar.gz  | head -$(HEAD)  # 2019-01-05
	# tar -tjvf $(DUMPS)/bfiles-cleaned.tar.bz2  | head -$(HEAD) # 2019-01-06
	tar -tjvf $(DUMPS)/oeis-json.tar.bz2       | head -$(HEAD)  # 2019-01-20
	tar -tjvf $(DUMPS)/2019-01-21.tar.xz       | head -$(HEAD)  # 2019-01-21
#================================
unpack: 
	make -i unpack0 ECHO= 2>&1 > unpack.log
unpack0: 
	make unpack_start 
	make unpack_tusk
	make unpack_gfis
	make unpack_bulks
	make unpack_extract
unpack_start:
	$(ECHO) rm -rf ajson
	$(ECHO) rm -rf bfile
	mkdir ajson
	mkdir bfile
unpack_extract:
	make ajson_extract DIR=.
	make bfile_extract DIR=.
#--------------
unpack_tusk: \
	2019-01-05 \
	2019-01-06 \
	2019-01-20 \
	2019-01-21
2019-01-05:
	$(ECHO) rm -rf unpack.$@
	mkdir  unpack.$@
	mkdir  unpack.$@/bfile
	$(ECHO) tar -C unpack.$@/bfile --strip-components=0 -xzf $(DUMPS)/b000001-b321800.tar.gz
	find   unpack.$@/bfile -type f | xargs -l -i{} cp -p   {} bfile/
2019-01-06: 
	echo these are cleaned - do not use them
	# $(ECHO) rm -rf unpack.$@
	# mkdir  unpack.$@
	# mkdir  unpack.$@/bfile
	# $(ECHO) tar -C unpack.$@/bfile --strip-components=2 -xjf $(DUMPS)/bfiles-cleaned.tar.bz2
	# find   unpack.$@/bfile -type f | xargs -l -i{} cp -up  {} bfile/
2019-01-20:
	$(ECHO) rm -rf unpack.$@
	mkdir  unpack.$@
	mkdir  unpack.$@/ajson
	$(ECHO) tar -C unpack.$@/ajson --strip-components=2 -xjf $(DUMPS)/oeis-json.tar.bz2
	find   unpack.$@/ajson -type f | xargs -l -i{} cp -p   {} ajson/
2019-01-21:
	$(ECHO) rm -rf unpack.$@
	mkdir  unpack.$@
	mkdir  unpack.$@/ajson
	mkdir  unpack.$@/bfile
	$(ECHO) tar -C unpack.$@/ajson --wildcards --strip-components=3 -xjf $(DUMPS)/2019-01-21.tar.bz2 "update/*/json/*"
	$(ECHO) tar -C unpack.$@/bfile --wildcards --strip-components=3 -xjf $(DUMPS)/2019-01-21.tar.bz2 "update/*/bfile/*"
	cd unpack.$@/bfile | ls -1 B* | cut -b 2-11 | xargs -l -i{} mv B{} b{}
	find   unpack.$@/ajson -type f | xargs -l -i{} cp -upv {} ajson/
	find   unpack.$@/bfile -type f | xargs -l -i{} cp -upv {} bfile/
#----------------
unpack_gfis: \
	2019-01-17 \
	2019-01-22 \
	2019-01-23 \
	2019-01-24.07 \
	2019-01-24.21 \
	2019-01-25
2019-01-17:
	make unpack_bulk2 DATE=$@
2019-01-22:
	make unpack_bulk1 DATE=$@
2019-01-23:
	make unpack_bulk1 DATE=$@
2019-01-24.07:
	make unpack_bulk1 DATE=$@
2019-01-24.21:
	make unpack_bulk1 DATE=$@
2019-01-25:
	make unpack_bulk2 DATE=$@
unpack_bulks:
	make unpack_bulk2 DATE=2019-01-27
	make unpack_bulk2 DATE=2019-01-28
	make unpack_bulk2 DATE=2019-01-28.17
#----
unpack_bulk1:
	$(ECHO) rm -rf unpack.$(DATE)
	mkdir  unpack.$(DATE)
	mkdir  unpack.$(DATE)/ajson
	mkdir  unpack.$(DATE)/bfile
	$(ECHO) tar -C unpack.$(DATE)/ajson --wildcards --strip-components=2 -xjf $(DUMPS)/bulk.$(DATE).tar.bz2 "temp/json/*"
	$(ECHO) tar -C unpack.$(DATE)/bfile --wildcards --strip-components=2 -xjf $(DUMPS)/bulk.$(DATE).tar.bz2 "temp/bfile/*"
	find   unpack.$(DATE)/ajson -type f | xargs -l -i{} cp -upv {} ajson/
	find   unpack.$(DATE)/bfile -type f | xargs -l -i{} cp -upv {} bfile/
unpack_bulk2:
	$(ECHO) rm -rf unpack.$(DATE)
	$(ECHO) tar    -xjf $(DUMPS)/bulk.$(DATE).tar.bz2
	$(ECHO) mv     bulk.$(DATE) unpack.$(DATE)
	find   unpack.$(DATE)/ajson -type f | xargs -l -i{} cp -upv {} ajson/
	find   unpack.$(DATE)/bfile -type f | xargs -l -i{} cp -upv {} bfile/
#--------------
unpack_list:
	find . -type d -iname "unpack.*" | xargs -l -i{} make unpack_list1 DIR={}	
unpack_list1:
	find $(DIR)/ajson -type f -ls | head -n 4
	find $(DIR)/ajson -type f -ls | tail -n 4
	find $(DIR)/bfile -type f -ls | head -n 4
	find $(DIR)/bfile -type f -ls | tail -n 4
#======================
fetch_list:
	cut -b1-7 fetch_list.man \
	| grep -E "^A" | sort > $@.tmp
	uniq $@.tmp           >  $@.txt
	wc -l $@.*
#--------------------------------
ajson_extract: asinfo asname asdata
asdata: # parameter: DIR
	perl extract_info.pl -asr $(DIR)/ajson > $@.txt
	wc -l $@.txt
asdata_check:
	grep -vE "^#" $(DATABASE)/stripped | sed -e "s/ \,/\t/" -e "s/,$$//"  \
	> x.tmp
	sort x.tmp asdata.txt | uniq -c | grep -vE "^  *2 " \
	| grep -E "," \
	| cut -b 9- \
	> $@.txt
	wc -l $@.txt
#----
asname: # parameter: DIR
	perl extract_info.pl -anr $(DIR)/ajson > $@.txt
	wc -l $@.txt
asname_check:
	grep -vE "^#" $(DATABASE)/names | sed -e "s/ /	/" \
	> x.tmp
	perl uncode.pl asname.txt > y.tmp
	sort x.tmp y.tmp | uniq -c | grep -vE "^  *2 " \
	| grep -v "allocated for " \
	| grep -E "[a-zB-Z]" \
	| cut -b 9- \
	> $@.txt
	wc -l $@.txt
#----
asinfo: # parameter: DIR
	make asinfo_extract
asinfo_extract:
	perl extract_info.pl -jr $(DIR)/ajson | grep -v "notexist" > asinfo.txt
	# cp asinfo.txt asinfo.`date +%Y-%m-%d.%H_%M`.txt
	wc -l asinfo.txt
asinfo_load:
	perl extract_info.pl -jc | tee asinfo.create.sql
	$(DBAT) -f asinfo.create.sql
	cut -b1-256 asinfo.txt \
	| $(DBAT) -m csv -s "\t" -r asinfo
	$(DBAT) -4 asinfo
	$(DBAT) -n asinfo
asinfo_update:
	wc -l       $(INFO)
	make delseq $(INFO)   TAB=asinfo 
	$(DBAT) -m csv -s "\t" -r asinfo < $(INFO)
	$(DBAT) -4                asinfo
	$(DBAT) -n                asinfo
#--------------
bfile_extract: bfdata bfinfo 
bfdata: # parameter: DIR
	perl extract_info.pl -btr $(DIR)/bfile > $@.txt
	wc -l $@.txt
bfdata_check:
	grep -vE "^#" $(DATABASE)/stripped | sed -e "s/ \,/\t/" -e "s/,$$//"  \
	> x.tmp
	sort x.tmp bfdata.txt | uniq -c | grep -vE "^ +2 +" \
	| grep -E "," \
	| cut -b 9- \
	| perl comp_terms.pl \
	> $@.txt
	wc -l $@.txt
#------
bfinfo: # parameter: DIR
	make bfinfo_extract
bfinfo_extract:
	perl extract_info.pl -br $(DIR)/bfile > bfinfo.txt
	cp bfinfo.txt bfinfo.`date +%Y-%m-%d.%H_%M`.txt
	wc -l bfinfo.txt
bfinfo_load:
	perl extract_info.pl -bc | tee bfinfo.create.sql
	$(DBAT) -f bfinfo.create.sql
	cut -b1-128 bfinfo.txt \
	| $(DBAT) -m csv -s "\t" -r bfinfo
	$(DBAT) -4 bfinfo
	$(DBAT) -n bfinfo
bfinfo_update:
	wc -l       $(INFO)
	make delseq $(INFO)   TAB=bfinfo 
	$(DBAT) -m csv -s "\t" -r bfinfo < $(INFO)
	$(DBAT) -4                bfinfo
	$(DBAT) -n                bfinfo
#--------------------------------
bulk: # parameter: $(LIST)
	make   bulk_all DIR=bulk.`date +%Y-%m-%d.%H` LIST=fetch_list.txt
bulk_all:
	mkdir  $(DIR)
	wc -l  $(LIST)
	cp     $(LIST)        $(DIR)
	cp     fetch_list.man $(DIR)
	mkdir          $(DIR)/ajson
	mkdir          $(DIR)/bfile
	make   bulk_type TYPE=ajson
	make   bulk_type TYPE=bfile
	make   bulk_tar 
	make   bulk_extract 
#--
bulk_type:
	# mkdir  $(DIR)/$(TYPE)
	perl   aseq_wget.pl -t $(TYPE) -n 8 -o $(DIR)/$(TYPE) $(LIST) > wget.$(TYPE).tmp
	cat    wget.$(TYPE).tmp | xargs -l -i{} make bulk_$(TYPE)1 PARM={}
bulk_ajson1:
	wget   -O $@.tmp      "$(PARM)" 
	perl   split_json.pl -bf -d $(D) -o $(DIR) $@.tmp
	sleep  $(SLEEP)
bulk_bfile1:
	wget   $(PARM)
	sleep  $(SLEEP)
#--
bulk_tar:
	ls -lR $(DIR) | wc -l
	tar    -cjf $(DIR).tar.bz2 $(DIR)
#-------------------
bulk_extract: # parameter BULK, only for the bulk
	make asinfo_extract DIR=$(BULK)
	make bfinfo_extract DIR=$(BULK)
bulk_update:
	make asinfo_update INFO=asinfo.txt
	make bfinfo_update INFO=bfinfo.txt
#---------------------------
WWW_TEO=../bfcheck/www_teo
bfdel:
	cat \
	$(WWW_TEO)/gf1.txt \
	$(WWW_TEO)/gf2.txt \
	$(WWW_TEO)/gf5.txt \
	$(WWW_TEO)/gf9.txt \
	> $@.tmp
	make seq INFO=$@.tmp
bfdel_check: bfdel
	make bfdela_check bfdelb_check
bfdela_check:
	$(DBAT) -x "SELECT s.aseqno, substr(a.access, 1, 16), a.keyword \
		FROM  seq s, asinfo a \
		WHERE s.aseqno   =  a.aseqno \
	 	  AND a.keyword NOT LIKE '%synth%' \
		ORDER BY 1" \
	> $@.txt
	wc -l $@.txt
bfdelb_check:
	$(DBAT) -x "SELECT s.aseqno, substr(b.access, 1, 16), b.message \
		FROM  seq s, bfinfo b \
		WHERE s.aseqno   =  b.aseqno \
	 	  AND b.message NOT LIKE '%synth%' \
		ORDER BY 1" \
	> $@.txt
	wc -l $@.txt
#-------------------
NLIST=../bfcheck/neil_lists
bfdir: bfdir1 bfdir2
bfdir1:
	perl bfdir.pl -r \
	$(NLIST)/bfilelist0.txt \
	$(NLIST)/bfilelist1.txt \
	$(NLIST)/bfilelist2.txt \
	$(NLIST)/bfilelist3.txt \
	> $@.tmp
	perl NLIST.pl -c > bfdir.create.sql
bfdir2:
	$(DBAT) -f         bfdir.create.sql
	$(DBAT) -m csv -s "\t" -r bfdir < bfdir1.tmp
	$(DBAT) -4 bfdir
	$(DBAT) -n bfdir
bfdir_check:
	$(DBAT) -x "SELECT d.aseqno \
		, substr(d.created, 1, 16), substr(b.access, 1, 16) \
		, d.filesize - b.filesize \
		, d.filesize,  b.filesize \
		FROM  bfdir d, bfinfo b \
		WHERE d.aseqno   = b.aseqno \
	 	  AND d.created  > b.access \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#---------------------------
synth_check: syntha_check synthb_check
syntha_check:
	$(DBAT) -x "SELECT a.aseqno \
		, substr(a.access, 1, 16), substr(b.access, 1, 16) \
		, 'a:' || a.keyword, 'b:' || b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.keyword     LIKE '%synth%' \
	      AND b.message NOT LIKE '%synth%' \
	      AND a.access > b.access \
	      AND a.aseqno NOT in (SELECT aseqno FROM draft) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
synthb_check:
	$(DBAT) -x "SELECT a.aseqno \
		, substr(a.access, 1, 16), substr(b.access, 1, 16) \
		, 'a:' || a.keyword, 'b:' || b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.keyword NOT LIKE '%synth%' \
	      AND b.message     LIKE '%synth%' \
	      AND a.access > b.access \
	      AND a.aseqno NOT in (SELECT aseqno FROM draft) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#-----------------------------
terms_check:
	$(DBAT) -x "SELECT a.aseqno, a.terms, b.terms \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno AND a.terms <> b.terms \
	      AND b.message NOT LIKE '%synth%' \
	      AND a.aseqno NOT in (SELECT aseqno FROM draft) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------------------------------
offset_check:
	$(DBAT) -x "SELECT a.aseqno, a.offset1, b.bfimin \
		, substr(a.access, 1, 16), substr(b.access, 1, 16) \
		, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno AND a.offset1 <> b.bfimin \
	      AND a.keyword NOT LIKE '%allocated%'  \
	      AND a.keyword NOT LIKE '%recycled%'  \
	      AND a.aseqno NOT in (SELECT aseqno FROM draft) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#----
check_update:
	make asinfo_load
	make bfinfo_load
checks:          \
	asdata_check \
	asname_check \
	bfdata_check \
	bfdel_check  \
	bfdir_check  \
	offset_check \
	synth_check \
	terms_check  \
	eval_checks
eval_checks:
	cat *check.txt | cut -b1-7 | sort | uniq -c > $@.tmp
	gawk -e '{ print $$2 }' $@.tmp              > $@.txt
	wc -l *check*.txt \
	>   $@.`date +%Y-%m-%d.%H_%M`.log
	diff -wy --width=64 \
		$@.`date +%Y-%m-%d.%H_%M`.log $@.log || :
	cp  $@.`date +%Y-%m-%d.%H_%M`.log $@.log
	head -n 32768 *check.txt > $@.lst
prep_fetch:
	head -n 999999 *_check.txt > $@.tmp
	cut -b1-7 $@.tmp | grep -E "^A" | sort | uniq \
	>     $@.txt
	wc -l $@.txt
#----------------
seq: # parameter: $(INFO)
	$(DBAT) -f seq.create.sql
	cut -b1-7 $(INFO) | grep -E "^A" | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
delseq: seq # parameters: $(TAB) $(INFO)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#--------
draft: 
	make draft1 N=000
	make draft1 N=100
	make draft1 N=200
	make draft1 N=300
	make draft1 N=400
draft1:
	wget -O draft.$(N).html https://oeis.org/draft?start=$(N)
	sleep 16 
draft_load:
	grep -E "/draft/" draft.*.html \
	| sed -e "s/[^A0-9]/ /g" -e "s/  */ /g" \
	| cut -d" " -f3 | grep -E "^A" | sort \
	>     $@.tmp 
	wc -l $@.tmp
	perl draft.pl -c > draft.create.sql
	$(DBAT)       -f   draft.create.sql
	$(DBAT) -m csv -s "\t" -r draft < $@.tmp
	$(DBAT) -4 draft
	$(DBAT) -n draft
#--------
history: # parameter: DATE
	make hist_kw DATE=`date +%Y-%m-%d` KEYWORD=new     MAX=240
	make hist_kw DATE=`date +%Y-%m-%d` KEYWORD=changed MAX=1100
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
	| xargs -l -i{} perl split_json.pl -bf   -o temp {}
resplit:
	# rm -rf temp
	# mkdir temp
	# mkdir temp/ajson
	# mkdir temp/bfile
	find  hist.2019-02-01 -type f -iname "*.json" \
	| xargs -l -i{} perl split_json.pl -o temp {}

