#!make

# OEIS-mat/common - scripts and data common to all subprojects
# @(#) $Id$
# 2019-02-19: HTMLIZE
# 2019-01-22: unpacking from ../dumps
# 2019-01-17: Georg Fischer
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb
SLEEP=16
DUMPS=../dumps
HEAD=8
PULL=../pull
COMMON=../common
D=0
G=n
SORTALLN=sort       -k1$(G)  -k2$(G)  -k3$(G)  -k4$(G)  -k5$(G)  -k6$(G)  -k7$(G)  -k8$(G)  -k9$(G) \
	      -k10$(G) -k11$(G) -k12$(G) -k13$(G) -k14$(G) -k15$(G) -k16$(G) -k17$(G) -k18$(G) -k19$(G) \
	      -k20$(G) -k21$(G) -k22$(G) -k23$(G) -k24$(G) -k25$(G) -k26$(G) -k27$(G) -k28$(G) -k29$(G) \
	      -k30$(G) -k31$(G) -k32$(G) -k33$(G) -k34$(G) -k35$(G) -k36$(G) -k37$(G) -k38$(G) -k39$(G) \
	      -k40$(G) -k41$(G) -k42$(G) -k43$(G) -k44$(G) -k45$(G) -k46$(G) -k47$(G) -k48$(G) -k49$(G) \
	      -k30$(G) -k31$(G) -k32$(G) -k33$(G) -k34$(G) -k35$(G) -k36$(G) -k37$(G) -k38$(G) -k39$(G) \
	      -k40$(G) -k41$(G) -k42$(G) -k43$(G) -k44$(G) -k45$(G) -k46$(G) -k47$(G) -k48$(G) -k49$(G) \
	      -k50$(G) -k51$(G) -k52$(G) -k53$(G) -k54$(G) -k55$(G) -k56$(G) -k57$(G) -k58$(G) -k59$(G) \
	      -k60$(G) -k61$(G) -k62$(G) -k63$(G) -k64$(G) -k65$(G) -k66$(G) -k67$(G) -k68$(G) -k69$(G) 
all:
	# targets: new = prepare newseq archlist regen (in that order)
help:
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
extract:
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
	find   unpack.$(DATE)/ajson -type f | xargs -l -i{} cp -pv {} ajson/
	find   unpack.$(DATE)/bfile -type f | xargs -l -i{} cp -pv {} bfile/
unpack_bulk2:
	$(ECHO) rm -rf unpack.$(DATE)
	$(ECHO) tar    -xjf $(DUMPS)/bulk.$(DATE).tar.bz2
	$(ECHO) mv     bulk.$(DATE) unpack.$(DATE)
	find   unpack.$(DATE)/ajson -type f | xargs -l -i{} cp -pv {} ajson/
	find   unpack.$(DATE)/bfile -type f | xargs -l -i{} cp -pv {} bfile/
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
	| grep -E "^A" | sort | uniq > $@.txt
	wc -l $@.*
#--------------------------------
ajson_extract: asinfo asname asdata
asdata: # parameter: DIR
	perl extract_info.pl -asr $(DIR)/ajson > $@.txt
	wc -l $@.txt
#----
asname: # parameter: DIR
	perl extract_info.pl -anr $(DIR)/ajson > $@.txt
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
#--
bfdata_check: # Compare <code>stripped</code> file with terms extracted from local b-files
	grep -vE "^#" $(COMMON)/stripped | sed -e "s/ \,/\t/" -e "s/,$$//"  \
	> x.tmp
	echo -e "A-Number\tTerms" > $@.txt
	sort x.tmp bfdata.txt | uniq -c | grep -vE "^ +2 +" \
	| grep -E "," \
	| cut -b 9- \
	| perl comp_terms.pl \
	| grep -vf $(COMMON)/draft_load.tmp \
	>> $@.txt
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
	cat bfinfo.txt \
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
bulk_lists:
	cat asname_check.txt asdata_check.txt bfdata_check.txt offset_check.txt terms_check.txt \
	| grep -Ev "^#" | cut -b1-7 | sort | uniq \
	>     bulka.txt
	wc -l bulka.txt
	cat bfdir_check.txt \
	| grep -Ev "^#" | cut -b1-7 | sort | uniq \
	>     bulkb.txt
	wc -l bulkb.txt
	# copy them to the Unix machine
bulk: 
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
#--
bulk_tar:
	ls -lR $(DIR) | wc -l
	tar    -cjf $(DIR).tar.bz2 $(DIR)
#----
bulkb: # parameter: $(LIST)
	make   bulkb1 DIR=bulk.`date +%Y-%m-%d.%H` 
bulkb1:
	mkdir  $(DIR)               || :
	wc -l  $(LIST)
	cp     $(LIST)        $(DIR)
	mkdir          $(DIR)/ajson || :
	mkdir          $(DIR)/bfile || :
	make   bulk_type TYPE=bfile
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
	$(DBAT) "SELECT s.aseqno, substr(a.access, 1, 16), a.keyword \
		FROM  seq s, asinfo a \
		WHERE s.aseqno   =  a.aseqno \
	 	  AND a.keyword NOT LIKE '%synth%' \
		ORDER BY 1" \
	> $@.txt
	wc -l $@.txt
bfdelb_check:
	$(DBAT) "SELECT s.aseqno, substr(b.access, 1, 16), b.message \
		FROM  seq s, bfinfo b \
		WHERE s.aseqno   =  b.aseqno \
	 	  AND b.message NOT LIKE '%synth%' \
		ORDER BY 1" \
	> $@.txt
	wc -l $@.txt
#-------------------
bfmess_stat:
	$(DBAT) -x "select message from bfinfo" \
	| sed -e "s/[0-9]//g" > $@.1.tmp 
	grep "neof" $@.1.tmp | wc -l
	sort $@.1.tmp | uniq -c > $@.txt
#-------------------
bfdir_load: # Load <code>bfilelist</code> into table <code>bfdir</code>
	perl bfdir.pl -c > bfdir.create.sql
	$(DBAT) -f         bfdir.create.sql
	perl bfdir.pl -r $(COMMON)/bfilelist \
	| $(DBAT) -m csv -s "\t" -r bfdir
	$(DBAT) -4 bfdir
	$(DBAT) -n bfdir
#--
asdata_check: # Show sequence terms and entry in <code>stripped</code> file
	grep -vE "^#" $(COMMON)/stripped | sed -e "s/ \,/\t/" -e "s/,$$//"  \
	> x.tmp
	echo -e "A-Number\tName" > $@.txt
	sort x.tmp asdata.txt | uniq -c | grep -vE "^  *2 " \
	| grep -E "," \
	| cut -b 9- \
	| grep -vf $(PULL)/draft_load.tmp \
	>> $@.txt
	wc -l $@.txt
asname_check: # Show sequence name and entry in <code>names</code> file
	grep -vE "^#" $(COMMON)/names | sed -e "s/ /	/" \
	> x.tmp
	perl uncode.pl asname.txt > y.tmp
	echo -e "A-Number\tName" > $@.txt
	sort x.tmp y.tmp | uniq -c | grep -vE "^  *2 " \
	| grep -v "allocated for " \
	| grep -E "[a-zB-Z]" \
	| cut -b 9- \
	| grep -vf $(PULL)/draft_load.tmp \
	>> $@.txt
	wc -l $@.txt
bfdir_check: # Compare <code>bfilelist</code> with local b-file sizes (maybe for draft)
	$(DBAT) "SELECT d.aseqno \
		, substr(d.created, 1, 16) AS oeis_time, substr(b.access, 1, 16) as local_time \
		, d.filesize AS oeis_size,  b.filesize AS local_size, b.message \
		FROM  bfdir d LEFT JOIN bfinfo b ON d.aseqno = b.aseqno  \
		WHERE d.filesize <> COALESCE(b.filesize, 1) \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#   	        OR substr(d.created, 1, 10)  <> substr(b.access, 1, 10)s \
#		, d.filesize - b.filesize \
#	      AND d.aseqno NOT IN (SELECT aseqno FROM draft  ) 
#---------------------------
bfsynth: # synthesize temp2/bfiles.txt for all in fetch_list.txt
	cut -b1-7 fetch_list.txt > $@.1.tmp
	grep -f $@.1.tmp $(COMMON)/stripped > $@.2.tmp
	wc -l $@.2.tmp
	make seq INFO=$@.1.tmp
	$(DBAT) -x "SELECT aseqno, offset1 FROM asinfo \
	WHERE aseqno IN (SELECT aseqno FROM seq) \
	  AND keyword LIKE '%synth%' \
	ORDER BY 1" \
	> $@.3.tmp
	wc -l $@.3.tmp
	rm -rf temp2
	mkdir  temp2
	perl bfsynth.pl -s $@.2.tmp -o temp2 $@.3.tmp
	find   temp2 -iname "*.txt" | wc -l
#-------
mvsynth:
	echo "mkdir -f bsynth" > $@.tmp
	$(DBAT) -x "SELECT 'mv bfile/b' || SUBSTR(i.aseqno, 2, 6) || '.txt bsynth/' \
		FROM bfinfo i WHERE i.aseqno NOT IN (SELECT d.aseqno FROM bfdir d)" \
	>> $@.tmp
	sed -e "s/\r//" $@.tmp > $@.sh
	wc -l $@.sh
#---------------------------
synth_check: syntha_check synthb_check synthc_check synthd_check synthe_check
#--
syntha_check: # Sequence (no draft) does not link to a b-file, but there is one in <code>bfilelist</code>
	$(DBAT) "SELECT a.aseqno \
		, a.keyword \
		, substr(a.access , 1, 16) AS oeis_time \
		, substr(d.created, 1, 16) AS bfdir_time \
		, d.filesize \
	    FROM asinfo a, bfdir d \
	    WHERE a.aseqno = d.aseqno \
	      AND a.keyword      LIKE '%synth%' \
	      AND a.aseqno NOT IN (SELECT aseqno FROM draft  ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
synthb_check: # Sequence links to a b-file which is not in <code>bfilelist</code>
	$(DBAT) "SELECT a.aseqno \
		, substr(a.access, 1, 16) AS access \
		, a.keyword \
	    FROM asinfo a \
	    WHERE a.keyword  NOT LIKE '%synth%' \
	      AND a.aseqno   NOT IN (SELECT aseqno FROM bfdir b) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
synthc_check: # Local b-file is not <code>synth</code>, but it is not in <code>bfilelist</code>
# our file is not synth and it is not in bfdir
	$(DBAT) "SELECT b.aseqno \
		, substr(b.access, 1, 16) AS access \
		, b.filesize \
		, b.message \
	    FROM bfinfo b \
	    WHERE b.message  NOT LIKE '%synth%' \
	      AND b.aseqno   NOT IN (SELECT d.aseqno FROM bfdir d) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
synthd_check: # Local b-file is <code>synth</code>, but it is in <code>bfilelist</code>
	$(DBAT) "SELECT d.aseqno \
		, substr(d.created, 1, 16) AS oeis_time, substr(b.access, 1, 16) AS local_time\
		, d.filesize, b.filesize \
		, b.message \
	    FROM bfdir d, bfinfo b \
	    WHERE d.aseqno   = b.aseqno \
	      AND b.message      LIKE '%synth%' \
	      AND d.aseqno NOT IN (SELECT aseqno FROM draft  ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
synthe_check: # Sequence without local synthesized b-file and no entry in <code>bfilelist</code>
	$(DBAT) "SELECT a.aseqno, a.offset1 \
		, substr(a.access, 1, 16) AS astime \
		, a.keyword \
	    FROM asinfo a \
	    WHERE a.keyword LIKE '%synth%' \
	      AND a.aseqno   NOT IN (SELECT d.aseqno FROM bfdir  d) \
	      AND a.aseqno   NOT IN (SELECT b.aseqno FROM bfinfo b) \
	      AND a.aseqno NOT IN (SELECT aseqno FROM draft  ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
synthf: synthf1 synthf2
synthf1:
	$(DBAT) -x "SELECT 'bfile/b' || SUBSTR(aseqno, 2, 6) || '.txt' \
	    FROM bfdir \
	    ORDER BY 1" \
	| sed -e "s/\r//" > $@.txt
	head -n 4 $@.txt
	wc -l $@.txt
synthf2:
	rm -f $@.tmp
	cat synthf1.txt | xargs -l head -n 1 >> $@.tmp || :
#
synthf_check: # b-files with fake comment "synthesized from ..."
	grep -i synthesi synthf2.tmp | cut -b 3- | sed -e "s/ /\t/" > $@.tmp
	wc -l $@.tmp
	make seq INFO=$@.tmp
	$(DBAT) "SELECT aseqno FROM seq \
		WHERE aseqno IN (SELECT aseqno FROM BFDIR) \
		ORDER BY 1 " \
	| sed -e "s/\r//" > $@.txt
	head -n 4 $@.txt
	wc -l $@.txt
#-----------------------------
terms_check: # The first few terms differ from the b-file, and that is not synthesized and no draft
	$(DBAT) "SELECT a.aseqno, a.terms AS asterms, b.terms AS bfterms\
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.terms <> b.terms \
	      AND b.message NOT LIKE '%synth%' \
	      AND a.aseqno  NOT in (SELECT aseqno FROM draft) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------------------------------
keyword_check: # Forbidden combinations of keywords
	$(DBAT) "SELECT aseqno, keyword \
	    FROM asinfo a \
	    WHERE (keyword     LIKE '%tabl%' AND keyword     LIKE '%tabf%') \
	      OR  (keyword     LIKE '%nice%' AND keyword     LIKE '%less%') \
	      OR  (keyword     LIKE '%easy%' AND keyword     LIKE '%hard%') \
	      OR  (keyword     LIKE '%nonn%' AND keyword     LIKE '%sign%') \
	      OR  (keyword     LIKE '%full%' AND keyword     LIKE '%more%') \
	      OR  (keyword     LIKE '%cons%' AND keyword     LIKE '%sign%') \
	      OR  (keyword     LIKE '%full%' AND keyword NOT LIKE '%fini%') \
	      OR  (keyword NOT LIKE '%nonn%' AND keyword NOT LIKE '%sign%'  \
	       			AND keyword NOT LIKE 'allocat%' \
	       			AND keyword NOT LIKE 'dead%' \
	       			AND keyword NOT LIKE 'recycled%' \
	          ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------------------------------
offset_check: # Sequence offset differs from first index in b-file
	$(DBAT) "SELECT a.aseqno, a.offset1, b.bfimin \
		, substr(a.access, 1, 16) AS astime, substr(b.access, 1, 16) as bftime \
		, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.offset1 <> b.bfimin \
	      AND a.keyword NOT LIKE '%allocated%'  \
	      AND a.keyword NOT LIKE '%recycled%'  \
	      AND a.aseqno NOT in (SELECT aseqno FROM draft) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------------------------------
denom_check: # Name of the sequence contains "Denominator", keyword <code>sign</code>, and <code>nonn</code> terms
	$(DBAT) -f seq2.create.sql
	grep -i "denominator" asname.txt > $@.tmp
	$(DBAT) -m csv -s "\t" -r seq2 < $@.tmp
	$(DBAT) "SELECT a.aseqno, s.info AS name, a.revision AS rev, substr(a.access, 1, 10) AS changed, a.keyword, a.author \
		FROM seq2 s, asinfo a  \
		LEFT JOIN bfinfo b ON b.aseqno = a.aseqno \
		WHERE a.aseqno = s.aseqno \
		  AND a.keyword LIKE '%sign%' \
		  AND COALESCE(b.message, 'dummy') NOT LIKE '%sign%' \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------------------------------
neof_check: # b-files with no LF behind the last term
	$(DBAT) "SELECT 'b' || substr(aseqno, 2, 6) || '.txt' FROM bfinfo WHERE message LIKE '%neof%' ORDER BY 1" \
	| sed -e "s/\r//" \
	> $@.1.tmp
	wc -l $@.1.tmp
noef2:
	grep -E "neof48|neof49|neof50|neof51|neof52|neof53|neof54|neof55|neof56|neof57" \
	rm -f $@.2.tmp
	cat  $@.1.tmp | xargs -l -i{} tail -vc32 bfile/{}.txt >> $@.2.tmp
	wc -l $@.*
#--------------------------------
sign_check: signa_check signb_check
signa_check: # Sequence has keyword <code>sign</code> and no negative terms in b-file
	$(DBAT)  "SELECT a.aseqno, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND b.bfimin >= 0 \
	      AND  a.keyword NOT LIKE '%dead%' \
	      AND (a.keyword     LIKE '%sign%' AND b.message NOT LIKE '%sign%' \
	      ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
signb_check: # Sequence has no keyword <code>sign</code> and b-file has negative terms
	$(DBAT)  "SELECT a.aseqno, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND b.bfimin >= 0 \
	      AND  a.keyword NOT LIKE '%dead%' \
	      AND (a.keyword NOT LIKE '%sign%' AND b.message     LIKE '%sign%' \
	      ) \
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
	bfdir_check  \
	offset_check \
	sign_check   \
	synth_check  \
	terms_check  \
	eval_checks  \
	html_checks
	# bfdel_check  
eval_checks:
	cat *check.txt \
	| grep -E "^A[0-9]" \
	| cut -b1-7 | sort | uniq -c > $@.tmp
	gawk -e '{ print $$2 }'        $@.tmp  > fetch_list.txt
	wc -l fetch_list.txt
	wc -l *check*.txt \
	>   $@.`date +%Y-%m-%d.%H_%M`.log
	diff -wy --width=64 \
		$@.`date +%Y-%m-%d.%H_%M`.log $@.log || :
	cp  $@.`date +%Y-%m-%d.%H_%M`.log $@.log
	head -n 999999 *_check.txt > $@.lst
html_checks:
	perl ../bfcheck/tsv_html.pl -m init eval_checks.lst >  check_index.html
	ls -1 *_check.txt | sed -e "s/.txt//" \
	| xargs -l -i{} make -s html_check1 FILE={}
	perl ../bfcheck/tsv_html.pl -m term eval_checks.lst >> check_index.html
html_check1:
	perl ../bfcheck/tsv_html.pl -m var $(FILE).txt > $(FILE).html
deploy_checks:
	scp *check*.html gfis@teherba.org:/var/www/html/teherba.org/OEIS-mat/common/
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
draft: draft_get draft_load
draft_get:
	rm draft.*.html
	make draft1 N=000
	make draft1 N=100
	make draft1 N=200
	make draft1 N=300
	make draft1 N=400
draft1:
	wget -O draft.$(N).html https://oeis.org/draft?start=$(N)
	sleep 10 
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
history: # Fetch new or recently changed JSONs
	make -s history1 DIR=bulk.`date +%Y-%m-%d.%H`
	make -s history3 DIR=bulk.`date +%Y-%m-%d.%H`
history1:
    # https://oeis.org/search?q=keyword:new&sort=created&fmt=json&start=280
    # https://oeis.org/search?q=keyword:changed&sort=modified&fmt=json&start=600
	make history2 KEYWORD=new     MAX=50
	make history2 KEYWORD=changed MAX=150
	make hist_split
history2: # parameter KEYWORD, DIR, MAX
	perl history.pl -k $(KEYWORD) -w $(SLEEP) -n $(MAX) $(DIR)
	ls -al $(DIR) | head -n 8
	ls -1  $(DIR) | wc -l
history3:
	mkdir                     $(DIR)/ajson
	cp -pv temp/ajson/A*.json $(DIR)/ajson/
	cp -pv temp/ajson/A*.json                     ./ajson/
	make bulkb1      LIST=bfdir_check.txt
	cp -pv                    $(DIR)/bfile/b*.txt ./bfile  
hist_split: # parameter DIR
	rm -rf temp
	mkdir temp
	mkdir temp/ajson
	find  $(DIR) -type f -iname "A*.json" \
	| xargs -l -i{} perl split_json.pl  -o temp {}
resplit:
	# rm -rf temp
	# mkdir temp
	# mkdir temp/ajson
	# mkdir temp/bfile
	find  hist.2019-02-01 -type f -iname "*.json" \
	| xargs -l -i{} perl split_json.pl -o temp {}
#----------------------
flinrec:
	perl flinrec.pl $(COMMON)/stripped | tee $@.tmp
linhrec1:
	perl linhrec.pl $(COMMON)/stripped 
linhrec:
	cp -v ../../linhrec/dist/linhrec.jar .
	java -jar linhrec.jar -f $(COMMON)/stripped
#======================================================
linrec: lrlink lrindx lrload
# linrec_link linrec_mmacall linrec_wget linrec_index
#--
lrlink: lrlink2 lrlink3 lrlink_patch lrlord_patch lrlink_check
lrlink0:
	find ajson -iname "*.json" | sort | xargs -l grep -H \
	"Index entries for linear recurrence" > lrlink1.tmp || :
lrlink2:
	perl extract_linrec.pl -m link          lrlink1.tmp \
	| $(SORTALLN) \
	| uniq \
	| grep -vE "01174[05]" \
	> lrlink2.tmp
	wc -l lrlink*.tmp
lrlink3:
	perl extract_linrec.pl -m lrlink > lrlink.create.sql
	$(DBAT) -f                         lrlink.create.sql
	$(DBAT) -m csv -s "\t" -r lrlink < lrlink2.tmp
	$(DBAT) -n lrlink
	$(DBAT) -4 lrlink
#--
lrlink_patch:
	$(DBAT) -n lrlink
	$(DBAT) -v "DELETE FROM lrlink where lorder <> 88888888 AND lorder >= 2800;"
	$(DBAT) -v "UPDATE lrlink SET lorder = sigorder WHERE lorder = 88888888;"
	$(DBAT) -n lrlink
#----
lrlink_check: # Lin. rec. link, but no index entry
	$(DBAT) "SELECT 'A' || seqno, lorder, compsig, sigorder, signature, '#' \
	FROM lrlink \
	WHERE seqno NOT IN (SELECT seqno FROM lrindx) \
	  AND lorder < 2800 \
	ORDER by 1" \
	| sed -e "s/\r//" \
	>       $@.txt
	head -4 $@.txt	
	wc -l   $@.txt
#----
lrlord_check: # Compare orders in lin. rec. links
	# Link was to wrong order.
	$(DBAT) "SELECT 'A' || seqno AS aseqno, lorder, sigorder, signature \
	FROM lrlink \
	WHERE lorder    <> sigorder \
	  AND sigorder  <> 0 \
	  AND signature <> '88888888' \
	ORDER by 1" \
	| sed -e "s/\r//" \
	>       $@.txt
	head -4 $@.txt	
	wc -l   $@.txt
lrlord_patch:
	$(DBAT) -v "UPDATE lrlink SET sigorder = lorder WHERE seqno = '322829';"
	make seq INFO=lrlord_check.man
	$(DBAT) -v "UPDATE lrlink SET lorder = sigorder WHERE 'A' || seqno IN \
		(SELECT aseqno FROM seq);"
lriord_check: # Compare orders in lin. rec. index
	$(DBAT) "SELECT 'A' || seqno AS aseqno, lorder, sigorder, compsig, signature \
	FROM lrindx \
	WHERE lorder <> sigorder \
	ORDER by 1" \
	| sed -e "s/\r//" \
	>       $@.txt
	head -4 $@.txt	
	wc -l   $@.txt
#----
lrlink_insert: lrlink_insert1 lrlink_insert2
lrlink_insert1:
	$(DBAT) -x "SELECT lorder, compsig, seqno, sigorder, signature, '#<strong>' \
	FROM lrlink \
	WHERE seqno NOT IN (SELECT seqno FROM lrindx) \
	  AND lorder < 2800 \
	ORDER by 1" \
	| sed -e "s/\r//" \
	>       $@.txt
	head -4 $@.txt	
	wc -l   $@.txt
lrlink_insert2:
	$(DBAT) -n lrindx
	$(DBAT) -m csv -s "\t" -r lrindx < lrlink_insert1.txt
	$(DBAT) -n lrindx
#-------------
lrlink_mmacall:
	find ajson -iname "*.json" | xargs -l grep -iH \
	"LinearRecurrence" \
	> $@.1.tmp || :
	perl extract_linrec.pl -m mmacall $@.tmp > $@.1.tmp
#-----
lrperiod:
	find ajson -iname "*.json" | sort | xargs -l grep -H \
	"Index entries for periodic sequences with large period" \
	> $@.tmp
#----------------------
lrindx: lrindx1 lrindx2 lrindx3 lrindx4 lrindx5
lrindx0:
	wget "https://oeis.org/wiki/Index_to_OEIS:_Section_Rec?action=raw" -O lrindx.raw
lrindx1:
	# sed -e "s/:signature */:/" -e "s/=====/====/g" lrindx.raw \
	# | grep -vE "^ *$$" \
	cat lrindx.raw \
	> lrindx.wiki
	echo >> lrindx.wiki # append linefeed
	# diff -y --suppress-common-lines lrindx.raw lrindx.wiki || :
	perl extract_linrec.pl -d $(D) -m index -f lrindx.spec.tmp  lrindx.wiki \
			> lrindx.tmp
lrindx2:
	perl extract_linrec.pl -d $(D) -m lrindx \
			>  lrindx.create.sql
	$(DBAT) -f lrindx.create.sql
	$(DBAT) -m csv -s "\t" -r lrindx <  lrindx.tmp
	$(DBAT) -n                lrindx
	$(DBAT) -4 lrindx
lrindx3:
	$(DBAT) -x "SELECT lorder, compsig, seqno, sigorder, signature, comment \
		FROM lrindx " \
	| sed -e "s/\r//" \
	| $(SORTALLN) \
	| perl -ne "s/\'\'/\'/g; print;" \
	> lrindx.sort.tmp
	# diff -wy --suppress-common-lines lrindx.tmp lrindx.sort.tmp || :  
	# diff -C0 -w                      lrindx.tmp lrindx.sort.tmp || :
lrindx4:
	perl extract_linrec.pl -d $(D) -m wrindx -f lrindx.spec.tmp lrindx.sort.tmp \
	> lrindx.new.tmp
	# | grep -vE "^ *$$"
	tail -2 lrindx.new.tmp | hexdump -C
	wc -l lrindx.new.tmp 
lrindx5:
	wc -l      lrindx.wiki lrindx.new.tmp 
	diff -C0                          lrindx.wiki lrindx.new.tmp > lrindx.diffc.tmp || :
	diff -wy --suppress-common-lines  lrindx.wiki lrindx.new.tmp > lrindx.diffy.tmp || :
#-------------------------------------
lrtest: lrtest0 lrtest1 lrindx2 lrindx3 lrindx4 lrtest5
lrtest0:
lrtest1:
	perl extract_linrec.pl -d $(D) -m index  -f lrindx.spec.tmp  lrtest.man \
	          > lrindx.tmp
lrtest5:
	head -n 999         lrindx.new.tmp 
	diff -C2   lrtest.man lrindx.new.tmp > lrindx.diffc.tmp || :
	diff -wy   lrtest.man lrindx.new.tmp                    || :
#-------------------------------	
linrec_xtract:
	perl extract_linrec.pl -m xtract  linhrec12.txt > $@.txt
linrec_eval:
	cat linrec_*.txt \
	| gawk -e '{print $$1 "\t" $$2 "\t" $$3 "\t" $$4}' \
	| sort | uniq \
	| grep -v "113300	mmacall	3	1,1,1" \
	>     all_linrec.tmp
	wc -l all_linrec.tmp
#-------------
lr_checks: lrlink_check lrindex_check lriord_check lrlord_check
# lrsign_check 
#--	
#--	
lrindex_check: # Lin. rec. in index, but no link -&gt; delete index entry
	$(DBAT) "SELECT a.seqno, a.lorder, a.signature as Index_Signature \
	FROM lrindx a \
	WHERE a.seqno NOT IN (SELECT seqno FROM lrlink) \
	  AND (SELECT s.keyword FROM asinfo s WHERE s.aseqno = 'A' || a.seqno) NOT LIKE '%dead%' \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#--	
lrsign_check: # Differences in lin. rec. signatures
	$(DBAT) "SELECT 'A' || a.seqno, a.lorder \
	    , b.mode \
		, a.signature AS Index_Signature \
		, b.signature AS Link_Signature \
	FROM lrindx a, lrlink b \
	WHERE a.seqno     =  b.seqno \
	  AND a.compsig   <> b.compsig \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#---------------------
lrsigadd_check: # Additional signatures in links
	$(DBAT) "SELECT DISTINCT a.signature \
	FROM lrlink a LEFT JOIN lrindx b ON a.signature = b.signature
	WHERE a.signature NOT IN (SELECT DISTINCT b.signature FROM lrindx b) \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#---------------------
lrsigadd:
	$(DBAT) "SELECT DISTINCT a.lorder \
		, a.signature AS asig \
	FROM linrec a \
	WHERE a.mode      = 'link' \
	  AND a.signature NOT IN \
	    ( SELECT DISTINCT b.signature \
	      FROM linrec b \
	      WHERE b.mode      = 'index'\
	    ) \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#
lrordadd:
	$(DBAT) "SELECT DISTINCT a.lorder \
	FROM linrec a \
	WHERE a.mode      = 'link' \
	  AND a.lorder NOT IN \
	    ( SELECT DISTINCT b.lorder \
	      FROM linrec b \
	      WHERE b.mode      = 'index'\
	    ) \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#---------------------
uncat_diff:
	perl -w uncat25.pl -m comp -o ./ajson cat25.txt \
	> $@.tmp
	wc -l $@.tmp
