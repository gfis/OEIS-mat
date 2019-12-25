#!make

# OEIS-mat/common - scripts and data common to all subprojects
# @(#) $Id$
# 2019-07-16: joeis parallel to joeis-lite
# 2019-04-11: checks exported to ./checks.make
# 2019-02-19: HTMLIZE
# 2019-01-22: old_unpacking from ../dumps
# 2019-01-17: Georg Fischer
# [^\w\s\.\,\;\:\(\)\[\]\{\}\<\>\!\"\$\%\&\/\+\^\-\*\=\'\#\\\?\|\~\`öńáőωŁéü°øå≀è\@…\´ä\’∈î]
#---------------------------------
GITS=../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
SLEEP=16
DUMPS=../dumps
HEAD=8
PULL=../pull
COMMON=$(GITS)/OEIS-mat/common
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
D=0
G=n
NMAX=200
CMAX=500
#-------------
all:
	# targets: new = prepare newseq archlist regen (in that order)
help:
	grep -E "^[a-z]" makefile
#======================
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/$@.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
seq2: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/$@.create.sql
	cut -b1-  $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#==============================
bulk_lists:
	cat allocb_check.txt \
		asdata_check.txt \
		asdir_check.txt  \
		asname_check.txt \
		bad_check.txt    \
		bfdata_check.txt \
		bfdir_check.txt  \
		bfsize_check.txt \
		offset_check.txt \
		syntha_check.txt \
		synthb_check.txt \
		synthc_check.txt \
		synthd_check.txt \
		synthe_check.txt \
		terms_check.txt  \
		fetch_list.man   \
	| grep -Ev "^#" | cut -b1-7 | sort | uniq \
	>     bulka.txt
	wc -l bulka.txt
	cat allocb_check.txt \
		asdata_check.txt \
		asname_check.txt \
		bad_check.txt    \
		bfdata_check.txt \
		bfdir_check.txt  \
		bfsize_check.txt \
		offset_check.txt \
		syntha_check.txt \
		synthb_check.txt \
		synthc_check.txt \
		synthd_check.txt \
		terms_check.txt  \
	| grep -Ev "^#" | cut -b1-7 | sort | uniq \
	>     bulkb.txt
	wc -l bulkb.txt
	echo '#### with fetch_list: ???'
	cat fetch_list.man
	wc -l bulk?.txt
	#### now copy bulk?.txt to the Linux machine
#---------
history: # Fetch new or recently changed JSONs
	rm -rf  bulk
	mkdir   bulk
	mkdir   bulk/bfile
	mkdir   bulk/ajson
	cp -pv  bulka.txt bulk/ajson
	cp -pv  bulkb.txt bulk/bfile
	make    history2  DIR=bulk KEYWORD=new       MAX=$(NMAX) 
	make    history2  DIR=bulk KEYWORD=changed   MAX=$(CMAX) 
	make    history2  DIR=bulk KEYWORD=recycled  MAX=$(NMAX) 
	make    history2  DIR=bulk KEYWORD=allocated MAX=$(CMAX) 
	make    history3  DIR=bulk
	make    bulk_type DIR=bulk TYPE=bfile LIST=bulkb.txt
	make    history4  DIR=bulk
	make    history5  DIR=bulk
#--
history0: # get new and changed JSONs, expand blocks, and get b-files
	wget -q -O - "https://oeis.org/search?q=keyword:new&sort=created&fmt=json&start=$(NMAX)"      \
	| grep -E "\"time\"" | sort 
	wget -q -O - "https://oeis.org/search?q=keyword:changed&sort=modified&fmt=json&start=$(CMAX)" \
	| grep -E "\"time\"" | sort 
history2: # parameter KEYWORD, DIR, MAX: write blocks of new or changed JSONs into $(DIR)
	perl history.pl -k $(KEYWORD) -w $(SLEEP) -n $(MAX) $(DIR)
	ls -al $(DIR) | head -n 8
	ls -1  $(DIR) | wc -l
history3: # parameter DIR: unpack all blocks into $(DIR)/ajson
	find  $(DIR) -type f -iname "block*.json" \
	| xargs -l -i{} perl split_json.pl  -o $(DIR) {}
	find $(DIR)/ajson -iname "A*.json" -printf "%f\n" \
	| sed -e "s/.json//" | sort \
	>        $(DIR)/alist.tmp
	head -n4 $(DIR)/alist.tmp
	wc -l    $(DIR)/alist.tmp
history4:
	grep -v  bulk/alist.tmp bulka.txt | grep -E "^A[0-9]" | sort | uniq \
	>        bulka2.txt
	wc -l    bulka2.txt
	cp -pv   bulka.txt bulk/ajson
	make bulk_type DIR=bulk TYPE=ajson LIST=bulka2.txt
history5:
	cp -pv   $(DIR)/ajson/A*.json ./ajson
	cp -pv   $(DIR)/bfile/b*.txt  ./bfile
	make     bulk_tar  DIR=bulk
#------------------------
bulk_tar:
	ls -lR  $(DIR) | wc -l
	tar    -cjf $(DIR).`date +%Y-%m-%d.%H`.tar.bz2 $(DIR)
#--
bulk_type:
	perl   aseq_wget.pl -t $(TYPE) -n 8 -o $(DIR)/$(TYPE) $(LIST) > wget.$(TYPE).tmp
	cat    wget.$(TYPE).tmp | xargs -l -i{} make bulk_$(TYPE)1 PARM={}
bulk_ajson1:
	wget   -O $@.tmp      "$(PARM)" 
	perl   split_json.pl -d $(D) -o $(DIR) $@.tmp
	sleep  $(SLEEP)
bulk_bfile1:
	wget   $(PARM)
	sleep  $(SLEEP)
#==============================
# copy to Linux
hinlin: hinlin1 hinlin2 hinlin3
hinlin1:
	cd ../pull ; make
hinlin2: 
	make bulk_lists # prepare synthesized b-files and fetch lists for the Linux machine
	rm -rf  bfsynth
	cat     synthg_check.txt >> synthe_check.txt
	make    bfsynth LIST=synthe_check.txt
	rm -f   bfsynth.zip
	zip -rq bfsynth.zip bfsynth bulk?.txt
	scp     bfsynth.zip gfis@atair:~/work/gits/OEIS-mat/common
	#### make unpack_bfsynth on the Linux machine
hinlin3:
	ssh gfis@atair 'cd ~/work/gits/OEIS-mat/common ; time make daily NMAX=$(NMAX) CMAX=$(CMAX)'
	make herlin
daily:
	time make unpack_bfsynth history infos
#--
infos:  
	make ainfos DIR=.
	make binfos DIR=.
#----
ainfos: asdata asinfo asname asxref
binfos: bfdata bfinfo 
#----
# process after data extraction on Linux
herlin: herscp aloads bloads checks
herscp: 
	scp gfis@atair:/home/gfis/work/gits/OEIS-mat/common/??????.txt .
aloads: asdata_load asinfo_load asname_load asxref_load 
bloads: bfdata_load bfinfo_load bfdir_load 
#--------
asdata: # parameter: DIR
	perl extract_info.pl -asr $(DIR)/ajson > $@.txt
	wc -l $@.txt
asdata_load: # Load table <em>asdata</em>
	$(DBAT) -f                  asdata.create.sql
	cat asdata.txt \
	| $(DBAT) -m csv -s "\t" -r asdata
	$(DBAT) -4                  asdata
	$(DBAT) -n                  asdata
#--------
aslast:
	perl extract_last.pl -text cat25.txt | sort > calast.txt
	perl extract_last.pl -json ajson     | sort > aslast.txt
	diff -y --suppress-common-lines --width=48    calast.txt aslast.txt \
	| tee dilast.txt
aslast2:
	grep -v '2019-06' dilast.txt \
	| grep -E "^A" > $@.tmp
#--------
asname: # parameter: DIR
	perl extract_info.pl -anr $(DIR)/ajson > $@.txt
	wc -l $@.txt
asname_load: # Load table <em>asname</em>
	$(DBAT) -f                  asname.create.sql
	perl uncode.pl asname.txt \
	| $(DBAT) -m csv -s "\t" -r asname
	$(DBAT) -4                  asname
	$(DBAT) -n                  asname
#--------
asinfo: # parameter DIR: table for basic sequence data from JSONs
	make asinfo_extract DIR=.
asinfo_extract:
	perl extract_info.pl -jr $(DIR)/ajson | grep -v "notexist" > asinfo.txt
	# cp asinfo.txt asinfo.`date +%Y-%m-%d.%H_%M`.txt
	wc -l asinfo.txt
asinfo_load:
	perl extract_info.pl -jc | tee asinfo.create.sql
	$(DBAT) -f asinfo.create.sql
	cut -b1-256 asinfo.txt \
	| $(DBAT) -m csv -s "\t" -r asinfo
	$(DBAT) -4                  asinfo
	$(DBAT) -n                  asinfo
asinfo_update:
	wc -l       $(LIST)
	make delseq $(LIST)     TAB=asinfo 
	$(DBAT) -m csv -s "\t" -r   asinfo < $(LIST)
	$(DBAT) -4                  asinfo
	$(DBAT) -n                  asinfo
#--------
asxref: # parameter DIR: table for crossreferences
	make asxref_extract DIR=.
asxref_extract:
	perl extract_info.pl -jxr $(DIR)/ajson > asxref.txt
	wc -l asxref.txt
asxref_load:
	perl extract_info.pl -jxc -t asxref | tee asxref.create.sql
	$(DBAT) -f asxref.create.sql
	$(DBAT) -m csv -s "\t" -r   asxref  < asxref.txt
	$(DBAT) -4                  asxref
	$(DBAT) -n                  asxref
#--------------------------------
bfdata: # parameter: DIR
	perl extract_info.pl -btr $(DIR)/bfile > $@.txt
	wc -l $@.txt
bfdata_load: # Load table <em>bfdata</em>
	sed -e "s/asdata/bfdata/g"  asdata.create.sql > bfdata.create.sql
	$(DBAT) -f                  bfdata.create.sql
	cat bfdata.txt \
	| $(DBAT) -m csv -s "\t" -r bfdata
	$(DBAT) -4                  bfdata
	$(DBAT) -n                  bfdata
#----
bfinfo: # parameter: DIR
	make bfinfo_extract DIR=.
bfinfo_extract:
	perl extract_info.pl -br $(DIR)/bfile > bfinfo.txt
	cp bfinfo.txt bfinfo.`date +%Y-%m-%d.%H_%M`.txt
	wc -l bfinfo.txt
bfinfo_load:
	perl extract_info.pl -bc | tee bfinfo.create.sql
	$(DBAT) -f bfinfo.create.sql
	cat bfinfo.txt \
	| $(DBAT) -m csv -s "\t" -r bfinfo
	$(DBAT) "DELETE FROM bfinfo WHERE LENGTH(aseqno) = 1"
	$(DBAT) -4 bfinfo
	$(DBAT) -n bfinfo
bfinfo_update:
	wc -l       $(LIST)
	make delseq $(LIST)   TAB=bfinfo 
	$(DBAT) -m csv -s "\t" -r bfinfo < $(LIST)
	$(DBAT) -4                bfinfo
	$(DBAT) -n                bfinfo
#----
bfdir_load: # Load <em>bfilelist</em> into table <em>bfdir</em>
	perl bfdir.pl -c > bfdir.create.sql
	$(DBAT) -f         bfdir.create.sql
	perl bfdir.pl -r $(COMMON)/bfilelist \
	| $(DBAT) -m csv -s "\t" -r bfdir
	$(DBAT) -4 bfdir
	$(DBAT) -n bfdir
	$(DBAT) "SELECT 'bfdir: ', MAX(created) FROM bfdir"
#----
joeis_list: joeis_pull joeis_load joeis_names joeis_count joeis_stamp
joeis_pull:
	ssh gfis@atair 'cd ~/work/gits/joeis ; git pull ; make joeis_list'
	scp gfis@atair:work/gits/joeis/joeis_list.txt .
joeis_load: # populate a table with A-numbers and superclass names of implemented sequences
	$(DBAT) -f joeis.create.sql
	cat joeis_list.txt \
	| $(DBAT) -m csv -r joeis
	$(DBAT) -4 joeis
	$(DBAT) -n joeis
joeis_names:
	$(DBAT) "SELECT n.aseqno, substr(j.superclass, 1, 8), n.name, a.keyword, b.bfimin || '..' || b.bfimax \
	FROM  asinfo a, asname n , bfinfo b LEFT JOIN joeis j ON b.aseqno = j.aseqno \
	WHERE a.aseqno = n.aseqno \
	  and a.aseqno = b.aseqno \
	ORDER BY 1" \
	| perl -pe "s{\'\'}{\'}g" > $@.txt
joeis_count:
	$(DBAT) -x "SELECT a/b FROM ( \
	(SELECT COUNT(j.aseqno) as a FROM joeis  j) j1 , \
	(SELECT COUNT(i.aseqno) as b FROM asinfo i) j2 )" 
	$(DBAT) -n joeis
joeis_stamp:
	$(DBAT) "DELETE FROM joeis WHERE aseqno = 'A000000';"
	$(DBAT) "INSERT INTO joeis VALUES ('A000000', '`date +%Y-%m-%d.%H`','created');"
	$(DBAT) -4 joeis
#--------------------------------
checks:
	make -f checks.make $@
html_checks:
	make -f checks.make $@
#================================
bfsubset: # parameter LIST: creates a subset of bfiles in ./bfsub
	make bfsubset1 LIST=err.tmp
bfsubset1:
	rm -rf bfsub
	mkdir  bfsub
	cat $(LIST) | grep -E "^A" \
	| grep FA \
	| cut -b 2-7 \
	| xargs -l -i{} cp -v ./bfile/b{}.txt ./bfsub/
	ls -1 bfsub | wc -l
#-------
bfsynth: # Synthesize temp2/bfiles.txt for all in $(LIST)
	cut -b1-7 $(LIST) | sort | uniq > $@.1.tmp
	grep -f $@.1.tmp $(COMMON)/stripped > $@.2.tmp || :
	wc -l   $@.2.tmp
	make seq LIST=$@.1.tmp
	$(DBAT) -x "SELECT aseqno, offset1 FROM asinfo \
	WHERE aseqno IN (SELECT aseqno FROM seq) \
	  AND keyword LIKE '%synth%' \
	ORDER BY 1" \
	> $@.3.tmp
	wc -l $@.3.tmp
	rm -rf  bfsynth/
	mkdir   bfsynth || :
	perl    bfsynth.pl -s $@.2.tmp -o bfsynth $@.3.tmp
	find    bfsynth -iname "*.txt" | wc -l
unpack_bfsynth: # Unpack synthesized b-files and fetch lists on the Linux machine
	rm -rf  bfsynth/
	unzip  -o bfsynth.zip
	cp -pv  bfsynth/b*.txt  bfile/ || :
	cp -pv  bfsynth/A*.json ajson/ || :
	wc -l   bulk?.txt
#----
mvsynth:
	echo "mkdir -f bsynth" > $@.tmp
	$(DBAT) -x "SELECT 'mv bfile/b' || SUBSTR(i.aseqno, 2, 6) || '.txt bsynth/' \
		FROM bfinfo i WHERE i.aseqno NOT IN (SELECT d.aseqno FROM bfdir d)" \
	>> $@.tmp
	sed -e "s/\r//" $@.tmp > $@.sh
	wc -l $@.sh
#----------------------------
uncat_diff:
	perl -w uncat25.pl -m comp -o ./ajson cat25.txt \
	> $@.tmp
	wc -l $@.tmp
#################################
old_targets:

list_dumps:
	tar -tzvf $(DUMPS)/b000001-b321800.tar.gz  | head -$(HEAD)  # 2019-01-05
	# tar -tjvf $(DUMPS)/bfiles-cleaned.tar.bz2  | head -$(HEAD) # 2019-01-06
	tar -tjvf $(DUMPS)/oeis-json.tar.bz2       | head -$(HEAD)  # 2019-01-20
	tar -tjvf $(DUMPS)/2019-01-21.tar.xz       | head -$(HEAD)  # 2019-01-21
#================================
old_unpack: 
	make -i old_unpack0 ECHO= 2>&1 > old_unpack.log
old_unpack0: 
	make old_unpack_start 
	make old_unpack_tusk
	make old_unpack_gfis
	make old_unpack_bulks
	make old_unpack_extract
old_unpack_start:
	$(ECHO) rm -rf ajson
	$(ECHO) rm -rf bfile
	mkdir ajson
	mkdir bfile
extract:
	make ajson_extract DIR=.
	make bfile_extract DIR=.
#--------------
old_unpack_tusk: \
	2019-01-05 \
	2019-01-06 \
	2019-01-20 \
	2019-01-21
2019-01-05:
	$(ECHO) rm -rf old_unpack.$@
	mkdir  old_unpack.$@
	mkdir  old_unpack.$@/bfile
	$(ECHO) tar -C old_unpack.$@/bfile --strip-components=0 -xzf $(DUMPS)/b000001-b321800.tar.gz
	find   old_unpack.$@/bfile -type f | xargs -l -i{} cp -p   {} bfile/
2019-01-06: 
	echo these are cleaned - do not use them
	# $(ECHO) rm -rf old_unpack.$@
	# mkdir  old_unpack.$@
	# mkdir  old_unpack.$@/bfile
	# $(ECHO) tar -C old_unpack.$@/bfile --strip-components=2 -xjf $(DUMPS)/bfiles-cleaned.tar.bz2
	# find   old_unpack.$@/bfile -type f | xargs -l -i{} cp -up  {} bfile/
2019-01-20:
	$(ECHO) rm -rf old_unpack.$@
	mkdir  old_unpack.$@
	mkdir  old_unpack.$@/ajson
	$(ECHO) tar -C old_unpack.$@/ajson --strip-components=2 -xjf $(DUMPS)/oeis-json.tar.bz2
	find   old_unpack.$@/ajson -type f | xargs -l -i{} cp -p   {} ajson/
2019-01-21:
	$(ECHO) rm -rf old_unpack.$@
	mkdir  old_unpack.$@
	mkdir  old_unpack.$@/ajson
	mkdir  old_unpack.$@/bfile
	$(ECHO) tar -C old_unpack.$@/ajson --wildcards --strip-components=3 -xjf $(DUMPS)/2019-01-21.tar.bz2 "update/*/json/*"
	$(ECHO) tar -C old_unpack.$@/bfile --wildcards --strip-components=3 -xjf $(DUMPS)/2019-01-21.tar.bz2 "update/*/bfile/*"
	cd old_unpack.$@/bfile | ls -1 B* | cut -b 2-11 | xargs -l -i{} mv B{} b{}
	find   old_unpack.$@/ajson -type f | xargs -l -i{} cp -upv {} ajson/
	find   old_unpack.$@/bfile -type f | xargs -l -i{} cp -upv {} bfile/
#----------------
old_unpack_gfis: \
	2019-01-17 \
	2019-01-22 \
	2019-01-23 \
	2019-01-24.07 \
	2019-01-24.21 \
	2019-01-25
2019-01-17:
	make old_unpack_bulk2 DATE=$@
2019-01-22:
	make old_unpack_bulk1 DATE=$@
2019-01-23:
	make old_unpack_bulk1 DATE=$@
2019-01-24.07:
	make old_unpack_bulk1 DATE=$@
2019-01-24.21:
	make old_unpack_bulk1 DATE=$@
2019-01-25:
	make old_unpack_bulk2 DATE=$@
old_unpack_bulks:
	make old_unpack_bulk2 DATE=2019-01-27
	make old_unpack_bulk2 DATE=2019-01-28
	make old_unpack_bulk2 DATE=2019-01-28.17
#----
old_unpack_bulk1:
	$(ECHO) rm -rf old_unpack.$(DATE)
	mkdir  old_unpack.$(DATE)
	mkdir  old_unpack.$(DATE)/ajson
	mkdir  old_unpack.$(DATE)/bfile
	$(ECHO) tar -C old_unpack.$(DATE)/ajson --wildcards --strip-components=2 -xjf $(DUMPS)/bulk.$(DATE).tar.bz2 "temp/json/*"
	$(ECHO) tar -C old_unpack.$(DATE)/bfile --wildcards --strip-components=2 -xjf $(DUMPS)/bulk.$(DATE).tar.bz2 "temp/bfile/*"
	find   old_unpack.$(DATE)/ajson -type f | xargs -l -i{} cp -pv {} ajson/
	find   old_unpack.$(DATE)/bfile -type f | xargs -l -i{} cp -pv {} bfile/
old_unpack_bulk2:
	$(ECHO) rm -rf old_unpack.$(DATE)
	$(ECHO) tar    -xjf $(DUMPS)/bulk.$(DATE).tar.bz2
	$(ECHO) mv     bulk.$(DATE) old_unpack.$(DATE)
	find   old_unpack.$(DATE)/ajson -type f | xargs -l -i{} cp -pv {} ajson/
	find   old_unpack.$(DATE)/bfile -type f | xargs -l -i{} cp -pv {} bfile/
#--------------
old_unpack_list:
	find . -type d -iname "old_unpack.*" | xargs -l -i{} make old_unpack_list1 DIR={}	
old_unpack_list1:
	find $(DIR)/ajson -type f -ls | head -n 4
	find $(DIR)/ajson -type f -ls | tail -n 4
	find $(DIR)/bfile -type f -ls | head -n 4
	find $(DIR)/bfile -type f -ls | tail -n 4
#-------------
unbulk:
	# make unbulk1 DATE=2019-02-02.16
	# make unbulk1 DATE=2019-02-08.06
	make unbulk1 DATE=2019-02-15.10
	make unbulk1 DATE=2019-02-15.20
unbulk1:
	rm -rf bulk.$(DATE)
	tar    -xjf $(DUMPS)/bulk.$(DATE).tar.bz2
	find   bulk.$(DATE)/ajson -type f | xargs -l -i{} cp -pv {} ajson/
	find   bulk.$(DATE)/bfile -type f | xargs -l -i{} cp -pv {} bfile/
#-------------------
bulk_extract: # parameter BULK, only for the bulk
	make asinfo_extract DIR=$(BULK)
	make bfinfo_extract DIR=$(BULK)
bulk_update:
	make asinfo_update LIST=asinfo.txt
	make bfinfo_update LIST=bfinfo.txt
#---------------------------
#----
bulkb: # parameter: $(LIST)
	make   bulkb1 DIR=bulk.`date +%Y-%m-%d.%H` 
bulkb1:
	mkdir  $(DIR)               || :
	wc -l  $(LIST)
	cp     $(LIST)        $(DIR)
	mkdir          $(DIR)/ajson || :
	mkdir          $(DIR)/bfile || :
	make   bulk_tar 
#----
bulka: # parameter: $(LIST)
	make   bulka1 DIR=bulk.`date +%Y-%m-%d.%H` 
bulka1:
	mkdir  $(DIR)               || :
	wc -l  $(LIST)
	cp     $(LIST)        $(DIR)
	cp     fetch_list.man $(DIR)
	mkdir          $(DIR)/ajson || :
	mkdir          $(DIR)/bfile || :
	make   bulk_type TYPE=ajson
	make   bulk_tar 
#--------------------------------
bulk_old: 
	make   bulk_all DIR=bulk.`date +%Y-%m-%d.%H` 
bulk_all:
	mkdir  $(DIR)               || :
	wc -l  bulk?.txt
	cp     bulk?.txt      $(DIR)
	cp     fetch_list.man $(DIR)
	mkdir          $(DIR)/ajson || :
	mkdir          $(DIR)/bfile || :
	make   bulk_type TYPE=ajson LIST=bulka.txt
	make   bulk_type TYPE=bfile LIST=bulkb.txt
	make   bulk_tar 
	make   bulk_extract 
