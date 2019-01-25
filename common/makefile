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
#--------
update_history: new changed
new:
	perl history.pl -g $@ -w $(SLEEP)
	ls -al `date +%Y-%m-%d`
changed:
	perl history.pl -g $@ -w $(SLEEP)
	ls -al `date +%Y-%m-%d`
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
unpack_dumps: unjs1 unjs2 unbf1 unbf2 unbf3
	du -m
	find   unjs -type f | wc -l
	find   unbf -type f | wc -l
unjs1:
	mkdir  unjs || :
	tar -C unjs --strip-components=2 -xjf $(DUMPS)/oeis-json.tar.bz2
unjs2:
	tar -C unjs --wildcards --strip-components=3 -xjf $(DUMPS)/2019-01-21.tar.xz "update/*/json/*"
unbf1:
	mkdir  unbf || :
	tar -C unbf --strip-components=0 -xzf $(DUMPS)/b000001-b321800.tar.gz
unbf2:
	tar -C unbf --strip-components=2 -xjf $(DUMPS)/bfiles-cleaned.tar.bz2
unbf3:
	tar -C unbf --wildcards --strip-components=3 -xjf $(DUMPS)/2019-01-21.tar.xz "update/*/bfile/*"
#--------------------------------
bfinfo: bfinfo_extract
bfinfo_extract:
	perl extract_info.pl -br unbf > bfinfo.txt
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
#--------------------------------
asinfo: asinfo_extract
asinfo_extract:
	perl extract_info.pl -jr unjs > asinfo.txt
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
bulk:
	rm -rf temp
	mkdir  temp
	make   bulk_type TYPE=json  
	make   bulk_type TYPE=bfile 
	make   bulk_tar
#--
bulk_type:
	mkdir  temp/$(TYPE)
	wc -l  $(LIST)
	perl   aseq_wget.pl -t $(TYPE) -n 8 $(LIST) > wget.$(TYPE).tmp
	cat    wget.$(TYPE).tmp | xargs -l -i{} make bulk_$(TYPE)1 PARM={}
bulk_json1:
	echo   wget -O $@.tmp "$(PARM)" 
	wget   -O $@.tmp "$(PARM)" 
	perl   split_json.pl -d $(D) -o temp/json $@.tmp
	sleep  $(SLEEP)
bulk_bfile1:
	echo   wget "$(PARM)"
	wget   $(PARM)
	sleep  10
#--
bulk_tar:
	ls -lR temp | wc -l
	wc -l $(LIST)
	cp -v $(LIST) temp
	tar -cjf  bulk.tar.bz2 temp
	cp -v	  bulk.tar.bz2 bulk.`date +%Y-%m-%d.%H-%M`.tar.bz2
#--
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
