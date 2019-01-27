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
#--------
seq: # parameter: $(LIST)
	$(DBAT) -f seq.create.sql
	cut -b1-7 $(LIST) | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#--------------------------------
update_list:
	tar -czvf update_list.`date +%Y-%m-%d`.tgz `date +%Y-%m-%d`/*.t*
#================================
list_dumps:
	tar -tjvf $(DUMPS)/oeis-json.tar.bz2       | head -$(HEAD)
	tar -tjvf $(DUMPS)/2019-01-21.tar.xz       | head -$(HEAD)
	tar -tzvf $(DUMPS)/b000001-b321800.tar.gz  | head -$(HEAD)
	tar -tjvf $(DUMPS)/bfiles-cleaned.tar.bz2  | head -$(HEAD)
#----
#================================
unpack: 
	make -i unpack0 ECHO= 2>&1 > unpack.log
unpack0: unpack_start \
	unpack_tusk \
	unpack_gfis \
	unpack_end
unpack_start:
	$(ECHO) rm -rf ajson
	$(ECHO) rm -rf bfile
	mkdir ajson
	mkdir bfile
unpack_end:
	make   asextract
	make   bfextract
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
	$(ECHO) rm -rf unpack.$@
	mkdir  unpack.$@
	mkdir  unpack.$@/bfile
	$(ECHO) tar -C unpack.$@/bfile --strip-components=2 -xjf $(DUMPS)/bfiles-cleaned.tar.bz2
	find   unpack.$@/bfile -type f | xargs -l -i{} cp -up  {} bfile/
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
	cd bfile | ls -1 B* | cut -b 2-11 | xargs -l -i{} mv B{} b{}
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
	$(ECHO) rm -rf unpack.$@
	mkdir  unpack.$@
	mkdir  unpack.$@/ajson
	mkdir  unpack.$@/bfile
	$(ECHO) tar -C unpack.$@/ajson --wildcards --strip-components=2 -xjf $(DUMPS)/bulk.hist.2019-01-17.tar.bz2 "temp/json/*"
	$(ECHO) tar -C unpack.$@/bfile --wildcards --strip-components=2 -xjf $(DUMPS)/bulk.hist.2019-01-17.tar.bz2 "temp/bfile/*"
	find   unpack.$@/ajson -type f | xargs -l -i{} cp -upv {} ajson/
	find   unpack.$@/bfile -type f | xargs -l -i{} cp -upv {} bfile/
2019-01-25:
	$(ECHO) rm -rf unpack.$@
	mkdir  unpack.$@
	mkdir  unpack.$@/ajson
	$(ECHO) tar -C unpack.$@/ajson --wildcards --strip-components=2 -xjf $(DUMPS)/bulk.hist.2019-01-25.tar.bz2 "temp/json/*"
	find   unpack.$@/ajson -type f | xargs -l -i{} cp -upv {} ajson/
2019-01-22:
	make unpack_bulk1 DATE=$@
2019-01-23:
	make unpack_bulk1 DATE=$@
2019-01-24.07:
	make unpack_bulk1 DATE=$@
2019-01-24.21:
	make unpack_bulk1 DATE=$@
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
#--------------
unpack_list:
	find . -type d -iname "unpack.*" | xargs -l -i{} make unpack_list1 DIR={}	
unpack_list1:
	find $(DIR)/ajson -type f -ls | head -n 4
	find $(DIR)/ajson -type f -ls | tail -n 4
	find $(DIR)/bfile -type f -ls | head -n 4
	find $(DIR)/bfile -type f -ls | tail -n 4
#------------------------------------------
old.jan25:
	rm -rf temp
	mkdir temp
	mkdir temp/json
	mkdir temp/bfile
	find  hist.2019-01-25 -type f -iname "*.json" | xargs -l -i{} \
	perl split_json.pl -o temp/json {}
	tar -cjvf bulk.hist.2019-01-25 temp
stop:
	cp -u temp/bfile/* unbf
	cp -u temp/json/*  unjs
#--------------------------------
bsextract: bsinfo
bfinfo: 
	make bfinfo_extract DIR=bfile
bfinfo_extract:
	perl extract_info.pl -br $(DIR) > bfinfo.txt
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
	perl extract_info.pl -br temp/bfile > $@.txt
	wc -l $@.txt
	make delseq TAB=bfinfo LIST=$@.txt
	cat $@.txt | $(DBAT) -m csv -s "\t" -r bfinfo
	$(DBAT) -4 bfinfo
	$(DBAT) -n bfinfo
#---------
to_be_fetched:
	A084706/b084706.txt
	A096089/b096089.txt
	A299791/b299791.txt
#--------------------------------
asextract: asinfo asname asdata
asinfo: 
	make asinfo_extract DIR=ajson
asinfo_extract:
	perl extract_info.pl -jr $(DIR) | grep -v "notexist" > asinfo.txt
	cp asinfo.txt asinfo.`date +%Y-%m-%d.%H_%M`.txt
	wc -l asinfo.txt
asinfo_load:
	perl extract_info.pl -jc | tee asinfo.create.sql
	$(DBAT) -f asinfo.create.sql
	cut -b1-256 asinfo.txt \
	| $(DBAT) -m csv -s "\t" -r asinfo
	$(DBAT) -4 asinfo
	$(DBAT) -n asinfo
asinfo_update:
	perl extract_info.pl -jr temp/json > $@.txt
	wc -l $@.txt
	make delseq TAB=asinfo LIST=$@.txt
	cat $@.txt | $(DBAT) -m csv -s "\t" -r asinfo
	$(DBAT) -4 asinfo
	$(DBAT) -n asinfo
#--------------
asdata:
	perl extract_info.pl -asr ajson > $@.txt
asdata_check:
	grep -vE "^#" $(DATABASE)/stripped | sed -e "s/ \,/\t/" -e "s/,$$//"  \
	> x.tmp
	sort x.tmp asdata.txt | uniq -c | grep -vE "^ +2 +" \
	| grep -E "," \
	| cut -b 9- > $@.txt
	wc -l $@.txt
#-------
asname:
	perl extract_info.pl -nr unjs > $@.txt
asname_check:
	grep -vE "^#" $(DATABASE)/names | sed -e "s/ /	/" \
	> x.tmp
	perl uncode.pl asname.txt > y.tmp
	sort x.tmp y.tmp | uniq -c | grep -vE "^ +2 +" \
	| grep -v "allocated for " \
	| grep -E "[a-zB-Z]" \
	> $@.txt
	wc -l $@.txt
#--------
history: hist_recycled \
         hist_new \
         hist_changed
hist_changed:
	make hist_kw DATE=`date +%Y-%m-%d` KEYWORD=changed    
hist_new:                              
	make hist_kw DATE=`date +%Y-%m-%d` KEYWORD=new        
hist_recycled:                         
	make hist_kw DATE=`date +%Y-%m-%d` KEYWORD=recycled   
hist_kw:
	perl history.pl -k $(KEYWORD) -w $(SLEEP) hist.$(DATE)
	ls -al hist.$(DATE) | head -n 8
	ls -1  hist.$(DATE) | wc -l
hist_split:
	rm -rf temp
	mkdir temp
	mkdir temp/json
	mkdir temp/bfile
	find  hist.`date +%Y-%m-%d` -type f -iname "*.json" | xargs -l -i{} \
	perl split_json.pl -o temp/json {}
	# make asinfo_extract DIR=temp/json
old_hist:
	find 2019-01-17 -iname "*.t*" | xargs -l grep -h "%I" \
	| cut -b4-10         | sort > $@.1.tmp
	cut -b1-7 asinfo.txt | sort > $@.2.tmp
	grep -vf $@.2.tmp $@.1.tmp | sort > $@.txt
	wc -l $@.*
old_hist_diff:
	diff --width=24 -wy old_hist.1.tmp old_hist.2.tmp | less
#------------------
refresh: refresh_get
refresh_get:
	rm -rf temp
	mkdir  temp
	cp     refresh.man temp/refresh.`date +%Y-%m-%dT%H_%M`.lst
	mkdir  temp/bfile
	mkdir  temp/json
refresh_bf:
	cut -b2-7 refresh.man \
	| xargs -l -i{} make --silent refresh_bf1 SEQNO={}
refresh_as:
	cut -b2-7 refresh.man \
	| xargs -l -i{} make --silent refresh_as1 SEQNO={}
	tar -cjvf refresh.tar.bz2 temp
	cp -v     refresh.tar.bz2 refresh.`date +%Y-%m-%d`.tar.bz2
	find  temp/bfile | wc -l
	find  temp/json  | wc -l
refresh_bf1:
	sleep $(SLEEP)
	wget -O temp/bfile/$(SEQNO).txt "https://oeis.org/A$(SEQNO)/b$(SEQNO).txt"
refresh_as1:
	sleep $(SLEEP)
	wget -O temp/json/$(SEQNO).json "https://oeis.org/search?q=id:A$(SEQNO)&fmt=json"
#-------
refresh_unpack:
	rm -rf temp
	tar -xjvf refresh.tar.bz2
	echo "cp -v temp/bfile/* unbf"
	echo "cp -v temp/json/*  unjs"
#--------------------------------
check_terms:
	$(DBAT) -x "SELECT a.aseqno, a.terms, b.terms \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno AND a.terms <> b.terms \
	      AND b.message NOT LIKE '%synth%' \
	    ORDER BY 1" | tee $@.tmp
	wc -l $@.tmp
#--------------------------------
check_offset:
	$(DBAT) -m html "SELECT a.aseqno, a.offset1, b.bfimin, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno AND a.offset1 <> b.bfimin \
	    ORDER BY 1" | tee $@.html
#	      AND b.message NOT like '%synth%' \
#	wc -l $@.html
comp1:
	cut -b1-7 check_offset.tmp >  x.tmp
	cut -b1-7 check_terms.tmp  >> x.tmp
	sort x.tmp | uniq -c | grep -v " 1 "
#--------------------------------
bulk: # parameter: $(LIST)
	make   bulk_all DIR=bulk.`date +%Y-%m-%d`

	mkdir  bulk.`date +%Y-%m-%d`
	make   bulk_type  TYPE=ajson
	make   bulk_type DIR=bulk.`date +%Y-%m-%d` TYPE=bfile
	make   bulk_tar  DIR=bulk.`date +%Y-%m-%d`
#--
bulk_type:
	mkdir  $(DIR)/$(TYPE)
	wc -l  $(LIST)
	perl   aseq_wget.pl -t $(TYPE) -n 8 $(LIST) > wget.$(TYPE).tmp
	cat    wget.$(TYPE).tmp | xargs -l -i{} make bulk_$(TYPE)1 PARM={}
bulk_json1:
	wget   -O $@.tmp      "$(PARM)" 
	perl   split_json.pl -d $(D) -o $(DIR)/$(TYPE) $@.tmp
	sleep  $(SLEEP)
bulk_bfile1:
	wget   $(PARM)
	sleep  $(SLEEP)
#--
bulk_tar:
	ls -lR $(DIR) | wc -l
	wc -l  $(LIST)
	cp -v  $(LIST) $(DIR)
	tar    -cjf $(DIR).tar.bz2 $(DIR)
#-------------------
bulk_split:
	perl split_json.pl -d $(D) bulk_json.tmp
	ls -al temp
bulk_update:
	tar -xjvf bulk.tar.bz2 # to temp
	make asinfo_update
	make bfinfo_update
#--------------------------------
fsizes_update:
	$(DBAT) -f temp.create.sql
	$(DBAT) -m csv -s " " -r temp < fsizes.1.tmp
	$(DBAT) -4 temp
	$(DBAT) -n temp
	$(DBAT) -v "UPDATE bflink b SET b.fsize = \
	    COALESCE((SELECT t.temp FROM temp t WHERE b.aseqno = t.aseqno), -1)"
#--------------------------------
#=================
# old targets
news2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	cat archlist.tmp | xargs -l -i{} rm -vf ../store/{}.text
#------------
