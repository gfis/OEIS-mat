#!make

# OEIS-mat/common - scripts and data common to all OEIS-mat subprojects
# @(#) $Id$
# 2021-02-04: REMOTE
# 2019-06-24: joeis_ofter
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
NMAX=90
CMAX=180
REMOTE=atair
# set_env_var_REMOTE
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
seq3: # parameter: $(LIST)
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
	rm -vf fetch_list.man
	touch  fetch_list.man
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
	wc -l bulk?.txt
	#### now copy bulk?.txt to the Linux machine
#---------
history: # Fetch new or recently changed JSONs
	make    history1
	make    history2  DIR=bulk KEYWORD=new       MAX=$(NMAX) 
	make    history2  DIR=bulk KEYWORD=changed   MAX=$(CMAX) 
	make    history2  DIR=bulk KEYWORD=recycled  MAX=$(NMAX) 
	make    history2  DIR=bulk KEYWORD=allocated MAX=$(CMAX) 
	make    history3  DIR=bulk
	make    bulk_type DIR=bulk TYPE=bfile LIST=bulkb.txt
	make    history4  DIR=bulk
	make    history5  DIR=bulk
#--
hinlin0: # estimate NMAX; CMAX
	ping -c2 $(REMOTE) 
	wget -q -O - "https://oeis.org/search?q=keyword:new&sort=created&fmt=json&start=$(NMAX)"      \
	| grep -E "\"time\"" | sort 
	wget -q -O - "https://oeis.org/search?q=keyword:changed&sort=modified&fmt=json&start=$(CMAX)" \
	| grep -E "\"time\"" | sort 
	ls -la ??????.txt
history0: # get new and changed JSONs, expand blocks, and get b-files
	wget -q -O - "https://oeis.org/search?q=keyword:new&sort=created&fmt=json&start=$(NMAX)"      \
	| grep -E "\"time\"" | sort 
	wget -q -O - "https://oeis.org/search?q=keyword:changed&sort=modified&fmt=json&start=$(CMAX)" \
	| grep -E "\"time\"" | sort 
history1: # prepare directories
	rm -rf  bulk
	mkdir   bulk
	mkdir   bulk/bfile
	mkdir   bulk/ajson
	cp -pv  bulka.txt bulk/ajson
	cp -pv  bulkb.txt bulk/bfile
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
	scp     bfsynth.zip names stripped gfis@$(REMOTE):~/work/gits/OEIS-mat/common
	#### make unpack_bfsynth on the Linux machine
hinlin3:
	ssh gfis@$(REMOTE) 'cd ~/work/gits/OEIS-mat/common ; time make daily NMAX=$(NMAX) CMAX=$(CMAX)'
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
	scp gfis@$(REMOTE):/home/gfis/work/gits/OEIS-mat/common/??????.txt .
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
	| grep -E "^A" \
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
	| grep -E "^A" \
	| $(DBAT) -m csv -s "\t" -r asinfo
	$(DBAT) -4                  asinfo
	$(DBAT) -n                  asinfo
asinfo_update:
	wc -l       $(LIST)
	make delseq $(LIST)     TAB=asinfo 
	$(DBAT) -m csv -s "\t" -r   asinfo < $(LIST)
	$(DBAT) -4                  asinfo
	$(DBAT) -n                  asinfo
asinhp: # special extract: aseqno, offset1, keyword(cons|table)  for H.P.
	cut -f1,2,7,8 asinfo.txt \
	| perl -ne 's{\s+\Z}{}; my ($$as, $$of, $$kw) = split(/\t/); '\
	' print join("\t", $$as, $$of, join(",", grep { ! m{synth|changed|allocated|new} } split(/\,/, $$kw))) . "\n"; '\
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
	# set REMOTE= !
	scp      $@.txt gfis@$(REMOTE):/var/www/html/teherba.org/OEIS-mat/common/asinhp.txt
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
	# cp bfinfo.txt bfinfo.`date +%Y-%m-%d.%H_%M`.txt
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
#--------
joeis_list: joeis_local joeis_pull joeis_reload
joeis_local:
	cd $(JOEIS) ; git pull ; ant jar
joeis_pull:
	ssh gfis@$(REMOTE) 'cd ~/work/gits/joeis ; git pull ; make joeis_list ; ant jar'
	scp gfis@$(REMOTE):work/gits/joeis/joeis_list.txt .
#--
joeis_reload: joeis_load joeis_ofter joeis_stamp joeis_ccan joeis_update joeis_eval joeis_count joeis_names jcat25 joeis_analog joeis_progress 
joeis_load: # populate a table with A-numbers and superclass names of implemented sequences
	$(DBAT) -f joeis.create.sql
	grep -E "^A" joeis_list.txt | sort \
	| $(DBAT) -m csv -r joeis
	$(DBAT) -4 joeis
	$(DBAT) -n joeis
joeis_dead:
	sed -e "s/$$/\tdead\t/" $(JOEIS)/src/irvine/oeis/dead.lst \
	>        $@.tmp
	wc -l    $@.tmp
	make seq3 LIST=$@.tmp
	$(DBAT) -n joeis
	$(DBAT) "INSERT INTO joeis (aseqno, superclass, status) SELECT aseqno, pattern, info FROM SEQ3"
	$(DBAT) -n joeis
joeis_names: # all A-numbers with their jOEIS superclass or null
	$(DBAT) -x "SELECT n.aseqno, j.superclass, n.name, a.keyword, b.bfimin || '..' || b.bfimax, COALESCE(j.callcode, 'nyi') \
	FROM  asinfo a, asname n, bfinfo b LEFT JOIN joeis j ON b.aseqno = j.aseqno \
	WHERE a.aseqno = n.aseqno \
	  and a.aseqno = b.aseqno \
	ORDER BY 1" \
	| perl -pe "s{\'\'}{\'}g" > $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
joeis_ofter: # A-numbers in jOEIS with offset and first ~7 reliable terms
	$(DBAT) -x "SELECT i.aseqno, i.offset1, i.terms \
	FROM  asinfo i INNER JOIN joeis j ON i.aseqno = j.aseqno \
	ORDER BY 1" \
	| perl -pe "s{\,\-?\d+\r?\Z}{};" \
	| sed -e "s/\r//" \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
joeis_stamp:
	$(DBAT) "DELETE FROM joeis WHERE aseqno = 'A000000';"
	$(DBAT) "INSERT INTO joeis VALUES ('A000000', '`date +%Y-%m-%d.%H`','created','cc','Georg');"
	$(DBAT) -4 joeis
joeis_count: # percentage of sequences implemented in jOEIS
	make -s joeis_stat
joeis_analog:
	cd $(FISCHER); make analog
ALAST=A050000
joeis_progress:
	$(DBAT) -x "SELECT current_date, current_time, a, ' Java classes = ', SUBSTR(CAST(a/b * 100 AS CHAR),1,9) \
	    , '% out of ', b, ' OEIS sequences are implemented by jOEIS' FROM \
	    ( (SELECT COUNT(j.aseqno) as a FROM joeis  j) j1 \
	    , (SELECT COUNT(i.aseqno) as b FROM asinfo i) j2 \
	    );" \
	>>        $@.txt
	tail -n16 $@.txt 
joeis_stat: # percentage of sequences implemented in jOEIS
	echo '************************************************************************'
	$(DBAT) -x "SELECT CAST(a AS CHAR) || ' Java classes = '   || SUBSTR(CAST(a/b * 100 AS CHAR),1,7) \
	    || '% out of ' || CAST(b AS CHAR) || ' OEIS sequences are implemented by jOEIS' FROM \
	    ( (SELECT COUNT(j.aseqno) as a FROM joeis  j) j1 \
	    , (SELECT COUNT(i.aseqno) as b FROM asinfo i) j2 \
	    );"
	$(DBAT) -x "SELECT CAST(a AS CHAR) || ' sequences in the range A000001-$(ALAST) = ' || SUBSTR(CAST(a/b * 100 AS CHAR),1,5) \
	    || '%' FROM \
	    ( (SELECT COUNT(j.aseqno) as a FROM joeis  j, asinfo i WHERE j.aseqno = i.aseqno AND i.aseqno <= '$(ALAST)') j1 \
	    , (SELECT COUNT(i.aseqno) as b FROM asinfo i           WHERE                         i.aseqno <= '$(ALAST)') j2 \
	    );"
	$(DBAT) -x "SELECT CAST(a AS CHAR) || ' nice sequences = ' || SUBSTR(CAST(a/b * 100 AS CHAR),1,5) \
	    || '% out of ' || CAST(b AS CHAR) FROM \
	    ( (SELECT COUNT(j.aseqno) as a FROM joeis  j, asinfo i WHERE j.aseqno = i.aseqno AND i.keyword LIKE '%nice%') j1 \
	    , (SELECT COUNT(i.aseqno) as b FROM asinfo i           WHERE                         i.keyword LIKE '%nice%') j2 \
	    );"
	$(DBAT) -x "SELECT CAST(a AS CHAR) || ' core sequences = ' || SUBSTR(CAST(a/b * 100 AS CHAR),1,5) \
	    || '% out of ' || CAST(b AS CHAR) || ', remaining are:' FROM \
	    ( (SELECT COUNT(j.aseqno) as a FROM joeis  j, asinfo i WHERE j.aseqno = i.aseqno AND i.keyword LIKE '%core%') j1 \
	    , (SELECT COUNT(i.aseqno) as b FROM asinfo i           WHERE                         i.keyword LIKE '%core%') j2 \
	    );"
	$(DBAT) -x "SELECT i.aseqno, n.name \
	    FROM asinfo i, asname n \
	    WHERE i.aseqno = n.aseqno \
	      AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	      AND (i.keyword LIKE '%core%') \
	      ORDER BY 1" \
	| cut -b1-80
#----
joeis_ccan:
	scp gfis@$(REMOTE):work/gits/joeis/joeis_list1.all.tmp .
	# cp -v ../../joeis/joeis_list1.all.tmp .
	perl joeis_list.pl             joeis_list1.all.tmp \
	>        $@.cc.tmp \
	2>       $@.an.tmp
	head -n4 $@.*.tmp
	wc -l    $@.*.tmp
joeis_update:
	make seq2 LIST=joeis_ccan.cc.tmp
	$(DBAT) "UPDATE joeis j SET j.callcode = COALESCE((SELECT SUBSTR(s.info,1,16) FROm seq2 s WHERE j.aseqno = s.aseqno), 'unkn');"
	uniq -w7  joeis_ccan.an.tmp > joeis_ccan.a1.tmp
	make seq2 LIST=joeis_ccan.a1.tmp
	$(DBAT) "UPDATE joeis j SET j.author   = COALESCE((SELECT s.info FROm seq2 s WHERE j.aseqno = s.aseqno), 'unkn');"
joeis_eval:
	cut -f2 joeis_ccan.an.tmp | sort | uniq -c | tee    $@.tmp
	cut -f2 joeis_ccan.cc.tmp | sort | uniq -c | tee -a $@.tmp
#----
jcat25:
	perl jcat25.pl cat25.txt > $@.txt
	wc -l cat25.txt $@.txt
	cut -b1 $@.txt | sort | uniq -c 
#----------------
corenice: core nice
core:
	make core1 KEYW=core
nice:
	make core1 KEYW=nice
core1:
	$(DBAT) -x "SELECT i.aseqno, i.keyword, n.name \
	    FROM asinfo i, asname n \
	    WHERE i.aseqno = n.aseqno \
	      AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	      AND (i.keyword LIKE '%$(KEYW)%') \
	      ORDER BY 1" \
	>        $(KEYW).tmp
	wc -l    $(KEYW).tmp
#----
joeis_block: joeis_block1 joeis_block2 joeis_block3
joeis_block1:
	cat asname.txt | perl -ne 'use strict; s/\s+\Z//; my ($$aseqno, $$name) = split(/\t/); '\
	'  $$name =~ m{(\w\w+|\w\W[\(\,\+\)\w]+ *\=* *)}; my $$word = $$1; $$word =~ s{ }{}g; '\
	'  print join("\t", $$aseqno, $$word) . "\n"; '\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	make seq2 LIST=$@.tmp
joeis_block2:
	$(DBAT) -x -s "#" "SELECT n.aseqno, s.info, i.author, substr(j.superclass, 1, 7), n.name, i.keyword, b.bfimin || '..' || b.bfimax \
	FROM  asinfo i, asname n, seq2 s, bfinfo b LEFT JOIN joeis j ON b.aseqno = j.aseqno \
	WHERE i.aseqno = n.aseqno \
	  and i.aseqno = b.aseqno \
	  and i.aseqno = s.aseqno \
	ORDER BY 1" \
	| perl -pe "s{\'\'}{\'}g; s{\_}{}g; s{\, (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d\d \d\d\d\d}{}; " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
joeis_block3: 
	sed -e "s/\t/\#/g" joeis_block2.tmp \
	| sort -t"#" -k3 -k2 -k5 -k4r -k1 \
	| sed -e "s/\#/\t/g" \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
#--------
cojec:
	grep -Ei "Conjecture|Empirical"  cat25.txt | grep -E "Colin Barker" \
	| cut -b4-10 | uniq \
	>        $@.tmp
	$(DBAT) -f cojec.create.sql
	cat      $@.tmp  \
	| $(DBAT) -m csv -r cojec
	$(DBAT) -4 cojec
	$(DBAT) -n cojec
	$(DBAT) "SELECT count(*) FROM cojec \
	    WHERE aseqno IN (SELECT aseqno FROM joeis) \
	      AND aseqno > 'A030000'"
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
#----
bfresh: # CC=
	cut -b1-7 $(FISCHER)/$(CC).gen \
	| grep -vE "^#" | sort | uniq \
	| sed -e "s/A/b/" -e "s/$$/.txt/" \
	>        $@.tmp
	scp      $@.tmp makefile gfis@$(REMOTE):~/work/gits/OEIS-mat/common
	ssh gfis@$(REMOTE) 'cd ~/work/gits/OEIS-mat/common ; make $@.remote'
	scp      gfis@$(REMOTE):~/work/gits/OEIS-mat/common/$@.tgz .
	cd bfile ; tar -xzvf ../$@.tgz
	rm -f $@.tgz
bfresh.remote:
	rm -rf temp bfresh.tgz
	mkdir temp
	cat bfresh.tmp | xargs -l -i{} cp bfile/{} temp/{}
	cd temp ; tar -czvf ../bfresh.tgz *.txt
#----
partial: ajpartial bfpartial
ajpartial:
	find ajson -type f -iname "A*.js*" -ctime -180 | sort > $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
	tar -czvf ajson.`date +%Y-%m-%d.%H`.tgz --files-from=$@.tmp
bfpartial:
	find bfile -type f -iname "b*.txt" -ctime -180 | sort > $@.tmp
	tar -czvf bfile.`date +%Y-%m-%d.%H`.tgz --files-from=$@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
#----------------------------
uncat_diff:
	perl -w uncat25.pl -m comp -o ./ajson cat25.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
uncat_prep:
	grep -E "^A" uncat_diff.tmp | cut -f1 | sort \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp	
uncat_down:
	make bulk_type DIR=bulk TYPE=ajson LIST=uncat_prep.tmp
	make history5
#----
uncat_date: uncat_date1 uncat_date2 uncat_date3
uncat_date1:
	perl -w uncat25.pl -m date            cat25.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
uncat_date2:
	make seq2 LIST=uncat_date1.tmp
uncat_date3:
#----

#------------
weidis:
	perl uncat25.pl -m text cat25.txt
	mkdir -f ../weidis/atext
	cut -b 1-7 ../weidis/gather1.tmp | xargs -l -innn cp -v atext/nnn.txt ../weidis/atext
#################################
old_targets:
magma:
	grep -iE "\(MAGMA\)" cat25.txt \
	| perl -ne 'if (m{(\_[^\_]+\_)}) { print "$$1\n"; }' \
	| sort | uniq -c | tee $@.tmp
