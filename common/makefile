#!make

# OEIS-mat/common - scripts and data common to all OEIS-mat subprojects
# @(#) $Id$
# [^\w\s\.\,\;\:\(\)\[\]\{\}\<\>\!\"\$\%\&\/\+\^\-\*\=\'\#\\\?\|\~\`öńáőωŁéü°øå≀è\@…\´ä\’∈î]
# 2022-07-05: asinfo_{loda|pari}
# 2022-06-21: old poeis -> noeis, new poeis for OEIS-prog
# 2022-06-16: asprog
# 2022-03-01: bfimer
# 2021-11-05: extract Maple lines
# 2021-02-04: REMOTE
# 2019-06-24: joeis_ofter
# 2019-07-16: joeis parallel to joeis-lite
# 2019-04-11: checks exported to ./checks.make
# 2019-02-19: HTMLIZE
# 2019-01-22: old_unpacking from ../dumps
# 2019-01-17: Georg Fischer
# C:\Program Files\Java\jdk1.8.0_172\bin
#---------------------------------
GITS=../..
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
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
CC=man
DATA=$(GITS)/OEIS-MAT/data
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
	cat asdata_check.txt \
		asdir_check.txt  \
		asname_check.txt \
		terms_check.txt  \
		fetch_list.man   \
	| grep -Ev "^#" | cut -b1-7 | sort | uniq \
	>     bulka.txt
	wc -l bulka.txt
	rm -vf fetch_list.man
	touch  fetch_list.man
	cat bfdata_check.txt \
		bfdir_check.txt  \
		bfsize_check.txt \
	| grep -Ev "^#" | cut -b1-7 | sort | uniq \
	>     bulkb.txt
	wc -l bulk?.txt
	uedit64 bulkb.txt
	# cmd /c pause
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
ainfos: asdata asinfo asname asprog asxref
binfos: bfdata bfinfo
#----
# process after data extraction on Linux
herlin: herscp aloads bloads checks
herscp:
	scp gfis@$(REMOTE):/home/gfis/work/gits/OEIS-mat/common/??????.txt .
aloads: asdata_load asinfo_load asname_load asxref_load \
	# asprog_load asinfo_loda asinfo_pari
bloads: bfdata_load bfinfo_load bfdir_load
#--------
asdata: # parameter: DIR
	perl extract_info.pl -asr $(DIR)/ajson > $@.txt
	wc -l $@.txt
asdata_load: # Load table <em>asdata</em>
	$(DBAT) -f                  asdata.create.sql
	cat                         asdata.txt \
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
	perl uncode.pl              asname.txt \
	| grep -E "^A" \
	| $(DBAT) -m csv -s "\t" -r asname
	$(DBAT) -4                  asname
	$(DBAT) -n                  asname
#--------
asprog_old: # parameter: DIR
	perl extract_info.pl -apr $(DIR)/ajson > $@.txt
	wc -l $@.txt
asprog: # parameter: DIR
	perl extract_asprog.pl -n jcat25.txt \
	>        $@.txt
	tail -n2 $@.txt
	wc -l    $@.txt
asprog_load: # Load table <em>asprog</em>
	# perl extract_asprog.pl -c > asprog.create.sql
	$(DBAT) -f                  asprog.create.sql
	grep -E "^A"                asprog.txt \
	| perl asprog_clean.pl \
	| perl uncode.pl \
	| $(DBAT) -m csv -s "\t" -r asprog
	$(DBAT) -4                  asprog
	$(DBAT) -n                  asprog
asprog_potential: # how many could still be realized by foreign producers
	$(DBAT) "\
	(SELECT lang,    COUNT(lang) FROM asprog \
	  WHERE lang   NOT IN ('maple','mma','magma') \
	    AND aseqno NOT IN (SELECT aseqno FROM joeis) \
	    AND aseqno NOT IN (SELECT aseqno FROM poeis) \
	   GROUP BY lang \
	) UNION  (SELECT 'total', COUNT(*) FROM asprog \
	  WHERE lang   NOT IN ('maple','mma','magma') \
	    AND aseqno NOT IN (SELECT aseqno FROM joeis) \
	    AND aseqno NOT IN (SELECT aseqno FROM poeis) \
	);"
#--------
asinfo: # parameter DIR: table for basic sequence data from JSONs
	make asinfo_extract DIR=.
asinfo_extract:
	perl extract_info.pl -jr $(DIR)/ajson | grep -v "notexist" > asinfo.txt
	# cp asinfo.txt asinfo.`date +%Y-%m-%d.%H_%M`.txt
	wc -l asinfo.txt
asinfo_load: # Load table <em>asinfo</em>
	perl extract_info.pl -jc | tee asinfo.create.sql
	$(DBAT)                  -f asinfo.create.sql
	cut -b1-256                 asinfo.txt \
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
#----
asinfo_loda:
	$(DBAT) "UPDATE asinfo i SET program = program || 'L' \
	  WHERE i.aseqno IN (SELECT aseqno FROM loda) \
	    AND i.program NOT LIKE '%L%';"
asinfo_pari:
	$(DBAT) "UPDATE asinfo i SET program = program || 'G' \
	  WHERE i.aseqno IN (SELECT aseqno FROM poeis WHERE lang = 'pari') \
	    AND i.program NOT LIKE '%G%';"
#--------
asxref: # table for crossreferences
	perl extract_xref.pl jcat25.txt > asxref.txt
	head -n4 asxref.txt
	wc -l    asxref.txt
asxref_load: # Load table <em>asxref</em>
	perl extract_xref.pl -c | tee asxref.create.sql
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
bfmiss: # get missing b-files (which contain "version" from git-lfs)
	grep -P "^A\d+\s0" bfdata.txt | cut -f1 \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
	cp -v    $@.tmp ../contrib/refresh.list.man
	ro 
bfsave: # pack all b-files in 40 archives
	tar -czf bf00.tgz bfile/b00????.txt
	tar -czf bf01.tgz bfile/b01????.txt
	tar -czf bf02.tgz bfile/b02????.txt
	tar -czf bf03.tgz bfile/b03????.txt
	tar -czf bf04.tgz bfile/b04????.txt
	tar -czf bf05.tgz bfile/b05????.txt
	tar -czf bf06.tgz bfile/b06????.txt
	tar -czf bf07.tgz bfile/b07????.txt
	tar -czf bf08.tgz bfile/b08????.txt
	tar -czf bf09.tgz bfile/b09????.txt
	#
	tar -czf bf10.tgz bfile/b10????.txt
	tar -czf bf11.tgz bfile/b11????.txt
	tar -czf bf12.tgz bfile/b12????.txt
	tar -czf bf13.tgz bfile/b13????.txt
	tar -czf bf14.tgz bfile/b14????.txt
	tar -czf bf15.tgz bfile/b15????.txt
	tar -czf bf16.tgz bfile/b16????.txt
	tar -czf bf17.tgz bfile/b17????.txt
	tar -czf bf18.tgz bfile/b18????.txt
	tar -czf bf19.tgz bfile/b19????.txt
	#
	tar -czf bf20.tgz bfile/b20????.txt
	tar -czf bf21.tgz bfile/b21????.txt
	tar -czf bf22.tgz bfile/b22????.txt
	tar -czf bf23.tgz bfile/b23????.txt
	tar -czf bf24.tgz bfile/b24????.txt
	tar -czf bf25.tgz bfile/b25????.txt
	tar -czf bf26.tgz bfile/b26????.txt
	tar -czf bf27.tgz bfile/b27????.txt
	tar -czf bf28.tgz bfile/b28????.txt
	tar -czf bf29.tgz bfile/b29????.txt
	#
	tar -czf bf30.tgz bfile/b30????.txt
	tar -czf bf31.tgz bfile/b31????.txt
	tar -czf bf32.tgz bfile/b32????.txt
	tar -czf bf33.tgz bfile/b33????.txt
	tar -czf bf34.tgz bfile/b34????.txt
	tar -czf bf35.tgz bfile/b35????.txt
	tar -czf bf36.tgz bfile/b36????.txt
	tar -czf bf37.tgz bfile/b37????.txt
	tar -czf bf38.tgz bfile/b38????.txt
	tar -czf bf39.tgz bfile/b39????.txt
#----
bfimer: # merge extract only
	perl extract_info.pl -br bulk/bfile > $@.txt
	cp $@.txt $@.`date +%Y-%m-%d.%H_%M`.txt
	wc -l $@.txt
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
bfimer_load:
	cut -b1-7 bfimer.txt > $@.tmp
	make seq LIST=$@.tmp
	$(DBAT) "DELETE FROM bfinfo WHERE aseqno IN (SELECT aseqno FROM seq)"
	$(DBAT) -m csv -s "\t" -r bfinfo < bfimer.txt
	$(DBAT) -n bfinfo
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
bflink: # extract the linked b-files from %H records in a CAT25 file
	grep -P "^.H" jcat25.txt | grep ".txt" \
	| perl extract_bflink.pl -d $(D) \
	2>         $@.rest.tmp \
	>          $@.txt
	tail -n2   $@.txt
	wc -l      $@*
bflink_load: # load the linked b-file parameters into table bflink
	perl extract_bflink.pl -c > bflink.create.sql
	$(DBAT) -f bflink.create.sql
	$(DBAT) -m csv -s "\t" -r bflink < bflink.txt
	$(DBAT) -n bflink
bfoeis: bfoeis1 bfoeis2 # extract sizes and sha256sums of b-files from gits/oeisdata
bfoeis1:
	rm -f      $@.tmp
	find ../../oeisdata/files -iname "b??????.txt" \
	| xargs -l head -v \
	>>         $@.tmp
	head -n8   $@.tmp
	wc -l      $@.tmp
bfoeis2:
	perl extract_bfoeis.pl bfoeis1.tmp \
	| sort   > bfoeis.txt
	cut -f4    bfoeis.txt | sort | uniq -c
	tail -n2   bfoeis.txt
	wc -l      bfoeis.txt 
bfoeis_load:
	perl extract_bfoeis.pl -c > bfoeis.create.sql
	$(DBAT) -f bfoeis.create.sql
	$(DBAT) -m csv -s "\t" -r bfoeis < bfoeis.txt
	$(DBAT) -n bfoeis
#--------
bfdata_uniq_old:
	sort -k3,3 bfdata.txt \
	| perl -ne 'use strict; my ($$aseqno, @fields) = split(/\t/); print join("\t", $$aseqno, "cc", @fields); ' \
	| perl $@.pl -m 16 \
	2> $@.rest.tmp \
	>  $@.tmp
	head -n4 $@*.tmp
	wc -l    $@*.tmp
bfdata_uniq:
	$(DBAT) -x "SELECT aseqno, 'cc', termno, data \
	  FROM  bfdata d \
	  WHERE termno >= 16 \
	    AND aseqno NOT IN (SELECT aseqno FROM joeis) \
	    ORDER BY 4" \
	| perl $@.pl -m 16 \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n4 $@*.tmp
	wc -l    $@*.tmp
bfwidth:
	find bfile -iname "b*.txt" | xargs -l wc -L > $@.txt
	cut -f1 $@.txt | sort -nr | head -n2000     > $@.sortr.tmp
#--------
list: joeis_list
joeis_list: joeis_local joeis_pull joeis_jar joeis_reload
joeis_local:
	cd $(JOEIS) ; git pull | tee joeis_pull.`date +%Y-%m-%d.%H`.txt
joeis_pull:   # refresh remote and local
	ssh gfis@$(REMOTE) 'cd ~/work/gits/joeis ; git pull ; ant compile-internal jar'
joeis_jar: joeis_jar1 joeis_jar2
joeis_jar1:
	scp gfis@$(REMOTE):work/gits/joeis/build.tmp/joeis.jar $(JOEIS)/build.tmp/
joeis_jar2:
	ssh gfis@$(REMOTE) 'cd ~/work/gits/joeis ; make joeis_list'
	scp gfis@$(REMOTE):work/gits/joeis/joeis_list.txt .
#--
joeis_pullloc: # refresh local only
	cd    $(JOEIS) ; git pull ; make joeis_list
	cp -v $(JOEIS)/joeis_list.txt .
	make joeis_reload
#--
tinfo_reload: asinfo_load asname_load bfinfo_load
joeis_reload: joeis_load joeis_ofter joeis_ofdec joeis_stamp joeis_ccan joeis_update joeis_eval joeis_count joeis_rest
# joeis_rest: joeis_names jcat25 joeis_analog joeis_progress joeis_50pc
joeis_rest: joeis_names joeis_progress
joeis_load: # populate a table with A-numbers and superclass names of implemented sequences
	$(DBAT) -f joeis.create.sql
	grep -E "^A" ../data/joeis_list.txt | sort | uniq -w7 \
	| $(DBAT) -m csv -r joeis
	$(DBAT) -4 joeis
	$(DBAT) -n joeis
joeis_dead: # not used
	sed -e "s/$$/\tdead\t/" $(JOEIS)/src/irvine/oeis/dead.lst \
	>        $@.tmp
	wc -l    $@.tmp
	make seq3 LIST=$@.tmp
	$(DBAT) -n joeis
	$(DBAT) "INSERT INTO joeis (aseqno, superclass, status) SELECT aseqno, pattern, info FROM SEQ3"
	$(DBAT) -n joeis
joeis_names: # all A-numbers with their jOEIS superclass or null
	perl ue_script.pl -close
	cmd /c attrib -R $@.txt
	$(DBAT) -x "SELECT n.aseqno, COALESCE(j.superclass, 'nyi ' || a.program), n.name, a.keyword, b.bfimin || '..' || b.bfimax, COALESCE(j.callcode, 'nyi'), a.author \
	FROM  asinfo a, asname n, bfinfo b LEFT JOIN joeis j ON b.aseqno = j.aseqno \
	WHERE a.aseqno = n.aseqno \
	  and a.aseqno = b.aseqno \
	ORDER BY 1" \
	| endirect \
	| perl -pe "s{\'\'}{\'}g" > $@.1.txt
	cp -v $@.1.txt $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
	perl ue_script.pl -open
joeis_tabl: # 'tabl' A-numbers with their jOEIS superclass or null,
	$(DBAT) -x "SELECT n.aseqno, COALESCE(j.superclass, 'nyi ' || a.program), n.name, a.keyword, b.bfimin || '..' || b.bfimax, COALESCE(j.callcode, 'nyi'), a.author \
	FROM  asinfo a, asname n, bfinfo b LEFT JOIN joeis j ON b.aseqno = j.aseqno \
	WHERE a.aseqno = n.aseqno \
	  and a.aseqno = b.aseqno \
	  and a.keyword LIKE '%tabl%' \
	ORDER BY 1" \
	| perl -pe "s{\'\'}{\'}g" > $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
jon_test:
	# perl -i.bak -e "s{^A}{B}" joeis_names.txt
	uedit64 /s="C:\\Users\\User\\work\\gits\\OEIS-mat\\common\\joeis_names_open.js"
	uedit64 /s="C:\\Users\\User\\work\\gits\\OEIS-mat\\common\\joeis_names_close.js"
joeis_ofter: # A-numbers in jOEIS with offset1 and first ~7 reliable terms
	$(DBAT) -x "SELECT i.aseqno, i.offset1, i.terms \
	FROM  asinfo i INNER JOIN joeis j ON i.aseqno = j.aseqno \
	ORDER BY 1" \
	| perl -pe "s{\,\-?\d+\r?\Z}{};" \
	| sed -e "s/\r//" \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
joeis_ofdec: # same, but for constants only
	$(DBAT) -x "SELECT i.aseqno, i.offset1, i.terms \
	FROM  asinfo i INNER JOIN joeis j ON i.aseqno = j.aseqno \
	WHERE i.keyword LIKE '%cons%' \
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
	# currently not; cd $(FISCHER); make analog
ALAST=A079000
joeis_progress:
	$(DBAT) -x "SELECT current_date, current_time, a, ' Java classes = ', SUBSTR(CAST(a/b * 100 AS CHAR),1,9) \
	    , '% out of ', b, ' OEIS sequences are implemented by jOEIS' FROM \
	    ( (SELECT COUNT(j.aseqno) as a FROM joeis  j) j1 \
	    , (SELECT COUNT(i.aseqno) as b FROM asinfo i) j2 \
	    );" \
	>>        $@.txt
	tail -n16 $@.txt
joeis_50pc: # how many remain until 50%
	$(DBAT) -x "SELECT SUBSTR(CAST((b/2 - a) AS CHAR),1,6) \
	    || ' jOEIS sequences remaining until 50%' FROM \
	    ( (SELECT COUNT(j.aseqno) as a FROM joeis  j) j1 \
	    , (SELECT COUNT(i.aseqno) as b FROM asinfo i) j2 \
	    );"
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
	$(DBAT) -x "SELECT CAST(a AS CHAR) || ' cons sequences = ' || SUBSTR(CAST(a/b * 100 AS CHAR),1,5) \
	    || '% out of ' || CAST(b AS CHAR) FROM \
	    ( (SELECT COUNT(j.aseqno) as a FROM joeis  j, asinfo i WHERE j.aseqno = i.aseqno AND i.keyword LIKE '%cons%') j1 \
	    , (SELECT COUNT(i.aseqno) as b FROM asinfo i           WHERE                         i.keyword LIKE '%cons%') j2 \
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
	# cp -v ../../joeis/joeis_list1.all.tmp .
	perl joeis_list.pl             joeis_list1.all.tmp \
	2>       $@.an.tmp \
	| sort | uniq -w7 \
	>        $@.cc.tmp
	head -n4 $@.*.tmp
	wc -l    $@.*.tmp
joeis_ccanloc:
	cp -v ../../joeis/joeis_list1.all.tmp .
	perl joeis_list.pl             joeis_list1.all.tmp \
	2>       $@.an.tmp \
	| sort | uniq -w7 \
	>        $@.cc.tmp
	head -n4 $@.*.tmp
	wc -l    $@.*.tmp
joeis_update:
	make seq2 LIST=joeis_ccan.cc.tmp
	$(DBAT) "UPDATE joeis j SET j.callcode = COALESCE((SELECT SUBSTR(s.info,1,16) FROm seq2 s WHERE j.aseqno = s.aseqno), 'unkn');"
	uniq -w7  joeis_ccan.an.tmp | grep -vE "A173930|A361897" > joeis_ccan.a1.tmp
	make seq2 LIST=joeis_ccan.a1.tmp
	$(DBAT) "UPDATE joeis j SET j.author   = COALESCE((SELECT s.info FROm seq2 s WHERE j.aseqno = s.aseqno), 'unkn');"
joeis_eval:
	cut -f2 joeis_ccan.an.tmp | sort | uniq -c | tee    $@.tmp
	cut -f2 joeis_ccan.cc.tmp | sort | uniq -c | tee -a $@.tmp
#----
jcat25:
	cp -v ../data/jcat28.txt jcat25.txt
jcat25_old:
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
	grep -Ei "Conjecture|Empirical|Apparently" jcat25.txt \
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
maple_lines:
combstruct:
	grep -E "^\%p" jcat25.txt | grep combstruct | cut -b4- \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----------------------------
uncat_diff: # extract the A-numbers of the JSONs that differ from cat25.txt
	perl -w uncat25.pl -m comp -o ./ajson cat25.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
uncat_check1: # extract only those with a diff value > 1
	perl -ne 'print if !m{\AA\d+\s+diff\s+1\Z};' \
	| tee    $@.tmp
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
#--------
nydone: # populate the table from joeis/notdone.dat
	$(DBAT) -f nydone.create.sql
	sed -e "s/ /\t/" $(JOEIS)/notdone.dat \
	| $(DBAT) -m csv -s "\t" -r nydone
	$(DBAT) -4   nydone
	$(DBAT) -n   nydone

#----
nydone_sdb: # determine which are in sequencedb and in nydone
	$(DBAT) "SELECT n.aseqno, s.si, s.mt, s.ix, n.info \
	  FROM nydone n, seqdb s \
	  WHERE n.aseqno = s.aseqno \
	  ORDER BY 1" \
	| tee $@.tmp
#--------
ageorg: # which were authored by Georg Fischer
	# %A A307048 _Georg Fischer_, Mar 21 2019
	#          1         2         3         4
	# 1234567890123456789012345678901234567890
	grep -E "^.A" jcat25.txt | grep "Georg Fischer" \
	| cut -b4-11,29-39 \
	| sed -e "s/ /\t/" \
	| tee $@.tmp
	$(DBAT) -f seq2.create.sql
	$(DBAT) -m csv -r seq2 < $@.tmp
	$(DBAT) "SELECT s.aseqno, s.info, j.superclass, n.name \
	  FROM seq2 s, asname n LEFT JOIN joeis j ON n.aseqno = j.aseqno \
	  WHERE s.aseqno = n.aseqno \
	  ORDER BY 1" \
	| tee $@.tmp
#----
datalen:
	$(DBAT) "SELECT datalen, COUNT(datalen) FROM asinfo GROUP BY datalen ORDER BY by 1 DESC"  | head -32
#----
noprog:
	$(DBAT) "SELECT i.aseqno, substr(n.name, 1,100), i.keyword \
	  FROM asinfo i, asname n \
	  WHERE i.aseqno = n.aseqno \
	    AND i.program = '' \
	    AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	  ORDER BY 1" \
	| tee $@.tmp
#--------
kill:
	cmd /c tasklist | grep make | cut -b28-34 | xargs -l -innn cmd /c taskkill /F /PID nnn
#--------
oeis_created:
	echo '# created' `date +%Y-%m-%dT%H:%M` > $@.txt
	cat $@.txt
	$(DBAT) -x "select aseqno, substr(created,1, 10) from asinfo" \
	>>       $@.txt
	head -n4 $@.txt
	tail -n4 $@.txt
	wc -l    $@.txt
	scp      $@.txt gfis@teherba.org:/var/www/html/teherba.org/OEIS-mat/$@.txt
#--------
progstat: progstat1 progstat2 progstat3
progstat1:
	$(DBAT) -x "SELECT program, COUNT(program) FROM asinfo GROUP BY program" \
	| tee    $@.tmp
progstat2:
	$(DBAT) -x "(SELECT 'Mathematica ', COUNT(program) FROM asinfo WHERE program LIKE '%t%') UNION \
	            (SELECT 'Maple       ', COUNT(program) FROM asinfo WHERE program LIKE '%p%') UNION \
	            (SELECT 'PARI + other', COUNT(program) FROM asinfo WHERE program LIKE '%o%') UNION \
	            (SELECT 'Formula     ', COUNT(program) FROM asinfo WHERE program LIKE '%F%')       \
	            ORDER BY 1" \
	| tee    $@.tmp
progstat3:
	grep -P          "\A.o +A\d+ +(\([^\)]+\))" jcat25.txt \
	| perl -ne 'if (m{\A.o +A\d+ +\(((tcl|bash|awk|gawk|bc|[A-Z][A-Za-z0-9\/\-]+)( [Vv\.0-9\/\-]+)?)}) { print "$$1\n"; }'\
	| grep -vP "^A\d\d\d+" \
	| sort | uniq -c \
	| tee    $@.tmp
	sort -rn  $@.tmp | grep -vP "^ *\d " > $@.sort.tmp
#---------
doubled: doubled1 doubled2 # with distinct pairs
doubled1:
	perl doubled_terms.pl stripped \
	| tee $@.tmp
	wc -l $@.tmp
doubled2:
	cat doubled1.tmp \
	| perl -ne 'print if m{nyi[^A]+A};' \
	| tee $@.tmp
	wc -l $@.tmp
#----
#---------
zero_spaced: zero_spaced1
zero_spaced1:
	perl zero_spaced.pl -v $(V) stripped \
	| tee $@.tmp
	wc -l $@.tmp
#----
fiboluca:
	grep -Pi "a\(n\) *\= *(Fibonacci|Lucas)" jcat25.txt | grep -E "^\%" \
	| cut -b 4- | sed -e "s/ /\tfiboluca\t0\t/" \
	| sort | uniq -w7 \
	| tee $@.tmp
	wc -l $@.tmp
#----
selfconv:
	grep -Pi "self[\- ]convol|convolved with" jcat25.txt | grep -P "^\%[NFC]" | cut -b4- \
	| grep -v "€" \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
convinv:
	grep -i "convolution inverse " jcat25.txt | grep -E "^\%[NFCY]" | grep -v Dirichlet \
	| perl nyi.pl -p | grep "{{" | cut -b4- \
	| perl -ne 'use strict; m{^(A\d+)[^\{]+\{\{(A\d+)}; my ($$aseqno, $$rseqno) = ($$1, $$2); '\
	' print join("\t", $$aseqno, "rootet", 0, $$rseqno, 0, -1, 1, 0) . "\n"; '\
	| grep -vE "A115784" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
convprod:
	grep -Pi "convolution of " jcat25.txt | grep -E "^\%[NFCY]" | grep -v Dirichlet \
	| perl nyi.pl -p | grep "{{" | cut -b4- \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
nest0:
	grep -P "^\%[NFC] A\d+ a\(n\) *\= *" jcat25.txt \
	| grep -P "\= *A\d+[\[\(]A\d+[\[\(]n([\+\-]\d)?[\)\]][\)\]]([\*\/]\w+)? *[\.\,\;\=]" \
	| cut -b4- \
	| sed -e "s/a(n) *= */\t/" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
nestuniq:
	cut -f2 nest0.tmp | cut -b1-7 | sort -r | uniq -c | sort -rn > $@.tmp
	head -n32 $@.tmp
knesto: # operator \d+ follows
	grep -E "^\%[NFC]" jcat25.txt | grep -Pi "\d\d a\(n\) *\= *A\d+\(n([\+\-]\d+)\)[\+\-\*\/\^\%](\d+) *[w\.\,\;]" \
	| perl nyi.pl -p | cut -b6- | grep -vP "\#\?" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
knestm:
	grep -E "^\%[NFC]" jcat25.txt | grep -Pi "\d\d a\(n\) *\= *A\d+\(n([\+\-]\d+)\)[\+\-\*\/\^\%](\d+) *[w\.\,\;]" \
	| perl nyi.pl -p | cut -b6- | grep -vP "\#\?" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
simjagfa:
	grep -E "^%[NF]" jcat25.txt \
	| cut -b4- \
	| grep -Pi "^A\d+ +a\(n\) *\=[ \d\+\-\*\/\^\(]*(Stirling\d?|tau|d|phi|gpf|gcd|lcm|lambda|core|pod|lpf|sopfr|omega|binomial|C|F(ibonacci)?|fib(onacci)?|[Ll]ucas|Bell|bell|sigma_?[\{\}n\d]+|log_2)\(" \
	| grep -vE "prime|composite|Sum|Product|Pell|Bernoulli|digit|reverse|Gamma" \
	| perl -ne 'my ($$aseqno, $$name) = split(/ /, $$_, 2); $$name =~ s{^ *a\(n\) *\= *}{}; '\
	' if ($$name !~ m{A\d{6}}) { print join("\t", $$aseqno, "simbinom", 0, $$name); }' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
simpow:
	grep -E "^%[NF]" jcat25.txt \
	| cut -b4- \
	| grep -Pi "^A\d+ +a\(n\) *\=[ \d\+\-\*\/\^\(]*" \
	| perl -ne 'my ($$aseqno, $$name) = split(/ /, $$_, 2); $$name =~ s{^ *a\(n\) *\= *}{}; '\
	' $$name =~ s{ *([\,\.\;\:]|where|if|for|with).*}{}; '\
	' if (0 || ($$name =~ m{\^(\d+|\([ n\d\+\-\*]+\))\Z})) { print join("\t", $$aseqno, "simpow", 0, $$name); }' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
seqpoly:
	grep -Pi "^%[NF] +A\d+ +a\(n\) *\=[An \d\+\-\*\/\^\(\)\^]+([\,\.\;\:]|where|if|for|with)" jcat25.txt \
	| perl nyi.pl -p | cut -b6- | grep -vP "\#\?|\.\.\." \
	| perl -ne 'my ($$aseqno, $$name) = split(/ /, $$_, 2); $$name =~ s{\s\Z}{}; my $$orig = $$name; '\
	' $$name =~ s{^ *a\(n\) *\= *}{}; $$name =~ s{ *([\,\.\;\:]|where|if|for|with).*}{}; $$name =~ s{ }{}g; '\
	' print join("\t", $$aseqno, $$name, $$orig) ."\n"; '\
	| sort -k2.1 -k1.1 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
dirichcon:
	grep -Pi "^%[NF]" jcat25.txt | grep -Pi "Dirichlet conv" \
	| perl nyi.pl -p | cut -b6- | grep -v "#" | grep -E "^A[0-9]" \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
multnyi:
	$(DBAT) "SELECT i.aseqno, i.offset1, n.name FROM asinfo i, asname n \
	WHERE i.aseqno = n.aseqno \
	  AND i.keyword LIKE '%mult%' \
	  AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	  ORDER BY 1;" \
	| perl nyi.pl -p \
	| tee    $@.tmp
	wc -l    $@.tmp
#----
conjectural: # get all classes that "implement Conjectural"
	find $(JOEIS)/src/irvine/oeis/ -iname "A??????.java" | xargs -l grep -H "irvine.oeis.Conjectural" | tee $@.tmp
conject: conjec1 conjec2 conjec3 conjec4 conjec5
conjec1: # obsolete
conjec2: # extract the A-numbers
	cat conjectural.tmp \
	| perl -ne 'm{\/(A\d{6})\.}; print "$$1\n";' \
	| sort \
	| tee    $@.tmp
	wc -l    $@.tmp
conjec3: # lines with conjectures and verifications
	cat      conjec2.tmp \
	| xargs -l -innn grep -iHE "empirical|apparent|conjectur|verif|is true" ajson/nnn.json \
	| tee    $@.tmp
conjec4: # those that have verification 1 line behind the conjecture
	grep -EB1 "verif|is true" conjec3.tmp \
	| tee    $@.tmp
	wc -l    $@.tmp
conjec5: # get all from remote
	scp gfis@atair:~/work/gits/OEIS-mat/common/conjec*.tmp .
conjec6: # extract manually verified ones
	grep -E "^ajson" conjec4.man | perl -ne 'm{\/(A\d{6})\.}; print "$$1\t" .substr($$_, 23);' \
	| sort \
	| tee    $@.tmp
conjec7: # load those implementing Conjectural and those with decriptions containing "conj..|verif..."
	make seq  LIST=conjec2.tmp
	cat conjec3.tmp | perl -ne 'm{\/(A\d{6})\.}; print "$$1\n";' | sort | uniq | tee $@.1.tmp
	make seq2 LIST=$@.1.tmp
conjec8: # compare the 2 from conjec7
	$(DBAT) -x "SELECT s.aseqno, j.superclass, n.name \
	  FROM  seq s, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE s.aseqno = n.aseqno \
	    AND s.aseqno NOT IN (SELECT s2.aseqno FROM seq2 s2) ORDER BY 1" \
	| tee    $@.tmp
	wc -l    $@.tmp
#----
parity:
	grep -Pi "Parity of A\d+" jcat25.txt | grep -E "%[NF]" | perl nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| tee    $@.tmp
	wc -l    $@.tmp
#--
selfcon:
	grep -E "^%" jcat25.txt | grep -Pi "(Self\-)?convolution" | perl nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| tee    $@.tmp
	wc -l    $@.tmp
diff1:
	grep -E "^%" jcat25.txt | grep -P "First differences of A" | perl nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| tee    $@.tmp
	wc -l    $@.tmp
signature:
	grep -E "^%H" $(DATA)/jcat28.txt | grep -P "signature *\(" | cut -b4- \
	| perl -ne 'if (m{order_(\d+)}) { my $$order = $$1 + 0; if (m{signature *\(([^\)]+)\)}) { my $$sig = $$1; $$sig =~ s{ }{}g;'\
	' if (length($$sig) < 256 && $$order >= 3 && $$order < 64 && ($$sig !~ m{(0\,){7}})) { print join("\t", substr($$_, 0, 7), "ixsig", 0, $$sig, $$order) . "\n"; }}}'\
	| tee    $@.gen
	wc -l    $@.gen
#----
mathconj: # nyi conjectures of RM
	grep -Pi "Conjectur|Empirical|Apparent|seem" jcat25.txt | grep -P "^.[NFC]" | grep -P "Mathar" \
	>        $@.0.tmp
	cut -b4-11 $@.0.tmp | uniq \
	>        $@.1.tmp
	wc -l    $@.1.tmp
	cut -b1-7 joeis_list.txt  > $@.2.tmp
	wc -l    $@.2.tmp
	grep -vf $@.2.tmp $@.1.tmp > $@.3.tmp
	wc -l    $@.3.tmp
	grep -f  $@.3.tmp jcat25.txt \
	| sed -e "s/^\%I/\n\%I/" \
	| endirect \
	>        $@.man
	uedit64  $@.man
mathconi: # implemented conjectures of RM
	grep -Pi "Conjectur|Empirical|Apparent|seem" jcat25.txt | grep -P "^.[NFC]" | grep -P "Mathar" \
	>        $@.0.tmp
	cut -b4-11 $@.0.tmp | uniq \
	>        $@.1.tmp
	wc -l    $@.1.tmp
	grep Holonomic joeis_list.txt | cut -b1-7 > $@.2.tmp
	wc -l    $@.2.tmp
	grep  -f $@.2.tmp $@.1.tmp > $@.3.tmp
	wc -l    $@.3.tmp
	grep -f  $@.3.tmp jcat25.txt \
	| sed -e "s/^\%I/\n\%I/" \
	>        $@.man
	uedit64  $@.man
pari_tnk:
	grep -P "^%o A\d+ +\(PARI\) +\w\(n\, *[i-n]\) \=" jcat25.txt | sed -e "s/ //g" | cut -b3- \
	| sed -e "s/(PARI)/\ttrilamb\t0\t/" -e "s/\=/ -> /" | sort -k4,4 -k6,6 \
	| tee $@.tmp
	wc -l $@.tmp
#----
tabfnyi: # nyi tabf
	grep -Pi "^%K.*\btabf\b" jcat25.txt  \
	>        $@.0.tmp
	cut -b4-11 $@.0.tmp | uniq \
	>        $@.1.tmp
	wc -l    $@.1.tmp
	grep -f  $@.1.tmp jcat25.txt \
	| sed -e "s/^\%I/\n\%I/" \
	>        $@.man
	uedit64  $@.man
#----
dyck: # nyi tabf
	grep -Pi "Dyck" joeis_names.txt  \
	| cut -b1-7 | uniq \
	>        $@.1.tmp
	wc -l    $@.1.tmp
	grep -f  $@.1.tmp jcat25.txt \
	| grep -P "^%[Np]" \
	| sed -e "s/^%N/\n%N/" -e "s/^\%p A[0-9]* //" \
	>        $@.man
	uedit64  $@.man
#----
lpf_gpf:
	grep -P "(largest|least|smallest|greatest) prime factor|\b(lpf|spf|gpf|A020639|A009190)\b" jcat25.txt \
	| grep -P "^%[NFC] A\d+ +a\(n\) *\=" | grep -v "€" \
#----
selecta: # LIST=; select formulas for a list of A-numbers
	grep -P "$(LIST)" jcat25.txt | grep -P "^%[NF]" \
	| perl -pe 's{€}{A}g' | endirect | cut -b 5- | grep -vP "A\d{6}" | perl -pe 's/^/A/; s/ /\t/;'\
	| sort -k2 \
	| perl poor.pl \
	| tee $@.tmp
	wc -l $@.tmp
#----
nest_count: # count the nested A-number calls
	grep -P "A\d{6}\([\+\-\*0-9n]*A\d{6}\(" jcat25.txt | grep -P "^." \
	| perl nest_count.pl \
	| endirect \
	| sort -k2,2 > $@.tmp
	head -n8 $@.tmp
	wc    -l $@.tmp
	cut -f2  $@.tmp | sort | uniq -c | sort -k2 \
	>        $@.sort.tmp
	head -n8 $@.sort.tmp
	wc    -l $@.sort.tmp
nest_names: # attach the names to J-numbers
	$(DBAT) -f seq2.create.sql
	grep J nest_count.sort.tmp \
	| sed -e "s/J/A/" \
	| gawk -e '{print $$2 "\t" $$1+1000 }' \
	| $(DBAT) -r seq2
	$(DBAT) -x "SELECT s.aseqno, 'names', s.info, n.name \
	  FROM seq2 s, asname n \
	  WHERE s.aseqno = n.aseqno \
	  ORDER BY 3 DESC" \
	| endirect | grep -P "^J" | grep -vP "100[123]" | sed -e "s/\t10*/\t/" \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
nest_form: # formulas with nested A-number callse
	grep -P "A\d{6}\([\+\-\*0-9n]*A\d{6}\(" jcat25.txt | grep -P "^%[NF]" \
	| perl -pe 's{€}{A}g' | endirect | cut -b 5- | grep -vP "A\d{6}" | perl -pe 's/^/A/; s/ /\t/;'\
	| sort -k2 \
	| perl poor.pl \
	| tee $@.tmp
	wc -l $@.tmp
nest_eval:
	grep -P "lambdan" nest_form.tmp \
	| grep -vP "J\d+\([A-Z]\d+" \
	| tee $@.tmp
#----
jnnn: # which sequences occur in formulas as Jxxxxxx(n)
	grep -P "^%[NFC] A\d{6} +a\(n\) * \=" jcat25.txt \
	| endirect \
	| perl -ne 'foreach my $$xno (m{([J]\d{6})\(n\)}g) { print "$$xno\n"; }'\
	| sort | uniq -c | sort -rn > $@.tmp
	head -n8 $@.tmp
	wc    -l $@.tmp
xxx:
	cut -f2  $@.tmp | sort | uniq -c | sort -k2 \
	>        $@.sort.tmp
	head -n8 $@.sort.tmp
	wc    -l $@.sort.tmp
#--
jnnn_names: # attach the names to J-numbers
	$(DBAT) -f seq2.create.sql
	grep J jnnn.tmp \
	| sed -e "s/J/A/" \
	| gawk -e '{print $$2 "\t" $$1+1000 }' \
	| $(DBAT) -r seq2
	$(DBAT) -x "SELECT s.aseqno, 'names', s.info, n.name \
	  FROM seq2 s, asname n \
	  WHERE s.aseqno = n.aseqno \
	  ORDER BY 3 DESC" \
	| endirect | grep -P "^J" | grep -vP "100[123]" | sed -e "s/\t10*/\t/" \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
#----
jnames: # nyi, and sorted by name
	# endirect joeis_names.txt | grep -P "^A" | cut -f1,3- | sort -k2,2 -t"	" -k1,1 > jnames.txt
	endirect joeis_names.txt  > jnames.txt

mma_series: # grep Series with Sqrt
	grep -iP "CoefficientList\[Series" jcat25.txt |grep -P "^%[t] A\d+ " | grep -viP "Sum|Product|Exp|log|cos|sin|tan|cot|arc|Continued|Lambert|Bessel|Fold|Elliptic|Jacobi|ator|Pochhammer" >> makefile

dgf: # Dirichlet g.f.s in jcat25 nyi
	grep -iP "Dirichlet g\.f\." jcat25.txt | grep -P "^%[NFC]" \
	| perl -pe "s/g\.f\. /g\.f\.\: /" \
	| sort -k3,3 -k4,4 -k5,5 -k6,6 | tee $@.tmp
#--------
hmize: # TARGET= htmlize the result of a grep
	wc -l        $(TARGET).tmp
	perl $(FISCHER)/htmlize.pl $(TARGET).tmp > $(TARGET).html
	chmod 755    $(TARGET).html
	cmd /c start $(TARGET).html
	e            $(TARGET).tmp
arydiv:
	grep -P "(ary |anti)divisor" jcat25.txt | grep -P "^%[NFCY]" | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
bern:
	grep -P "Bernoulli" jcat25.txt | grep -P "^%[NF]" | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
filprim:
	grep -P "Numbers [nk] such that \(\d+\^[^i]+is prime" joeis_names.txt | grep nyi | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
sumpari:
	grep -P "^%o A38\d+ \(PARI" jcat25.txt | grep sum | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
essent:
	grep -Pi "Essentially (the same as )?A\d+" jcat25.txt | grep -P "^%[NFCY]" | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
diffeq:
	grep -P "differential eq" jcat25.txt | grep -P "^%[NFC]" | endirect | grep -viP "€|Prod|sum|row|column" \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
egf:
	grep -P "([Ee]\.g\.f\.)" jcat25.txt | grep -P "^%[NF]" | endirect | grep -viP "€|Prod|sum|row|column" \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
lgf:
	grep -P "([Ll]\.g\.f\.)" jcat25.txt | grep -P "^%[NF]" | endirect | grep -viP "€|Prod|sum|row|column" \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
ogf:
	grep -P "([O]\.g\.|G\.)f\. " jcat25.txt | grep -P "^%[NF]" | endirect |grep -viP "€|Prod" | grep -P "[B-Z]\d{6}" \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
algdif:
	grep -P "\bA\(x\)" jcat25.txt | grep -P "^%[NF]" | endirect | grep -vPi "\bA\([^\)]{2}|sum|prod|[B-Z]\(|\.\.\.|\^\(n|\[x" \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
ratn:
	grep -P "\br\(n\) *\=" jcat25.txt | grep -P "^%[NF]" | endirect | grep -viP "€" \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
rators:
	grep -P "ators of " jcat25.txt | grep -P "^%[NF]" | endirect | grep -viP "€" \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
series:
	grep -P "^%t" jcat25.txt | grep -Pi "CoefficientList\[Series" \
	| cut -b 4- | sed -e "s/ /\t/"    >        $@.tmp
	make hmize TARGET=$@
middle:
	grep -P "A\d{6} ([^\-\+\*\/\=\<\>\|\.\& a-zA-Z0-9]+) A\d{6}" jcat25.txt | grep -P "^%[NFCY]"  | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
section:
	grep -Pi "section of \w\d{6}" jcat25.txt | grep -P "^%[NFCY]" | grep -v "€" | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
anexp:
	grep -iP "^%[NF] A\d+\s+([LED]\.)?g\.f\.\:? *A\(x\) *\= [^S]+Sum" jcat25.txt | grep -vP "\.\.\." | grep -P "^%[NF]" | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
expsum:
	grep -iP "Expansion of exp *\( *Sum" jcat25.txt | grep -vP "\.\.\." | grep -P "^%[NF]" | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
bn:
	grep -P "\b[bcr]\(n\) *\=" jcat25.txt | grep -P "\b[bcr]\(n *\- *1\)" | grep -P "^%[NF]" | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
convol:
	grep -Pi "convol" jcat25.txt | grep -Pi "convol" | grep -P "^%[NFCY]" | grep -v € | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
equals:
	grep "Equals " jcat25.txt | grep -P "^%[NFYC]" | grep -v € | grep -vPi "Sum|prod|column|integral|infinity|root of" | endirect | tee equals.tmp
	make hmize TARGET=$@
hologf1:
	cat ../holrec/hologf1.tmp | endirect \
	>        $@.tmp
	make hmize TARGET=$@
xpown:
	grep -iP "\[x\^n\]" jcat25.txt | grep -vP "\.\.\." | grep -P "^%[NF]" | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
xpow2n:
	grep -iP "\[x\^\(" jcat25.txt | grep -vP "\.\.\." | grep -P "^%[NF]" | endirect \
	| cut -b 4- | perl -pe 's/ /\t/;' | tee    $@.tmp
	make hmize TARGET=$@
cob:
	find ../../oeisdata/files/A386 -name "b3861[01]?.txt" | xargs -innn cp -v nnn bfile

dfinit:
	grep -P "^%[NF] A\d+ (D\-finite )?([Rr]ecurrence)? *\:? *[0-9an\+\-\*\(\)\^ \=]+(for n *\>\=? *\d+)?\." jcat25.txt \
	| grep -vP " \(\d+[\.\)]| a\([\da]" \
	| tee $@.tmp
	make hmize TARGET=$@
#----
lamprot:
	grep -P "^%[NF]" jcat25.txt \
	| grep -P "[Pp]rod(uct)?(_{| *\() *[i-n] *\>\=? *[0-2]" \
	| grep -viP "y[\*\^]|A\(x\)|Sum|Decimal|Equals|Continued|column|row|~" \
	| endirect | cut -b 4- | sed -e "s/ /\t/" \
	| tee $@.tmp
	make hmize TARGET=$@
eisenstein:
	grep -P "\WE\_\d+\W" jcat25.txt | grep -P "^%[NF]" \
	| endirect | cut -b 4- | sed -e "s/ /\t/" \
	| tee $@.tmp
	make hmize TARGET=$@
even_odd:
	grep -P "(even|odd) digits" jcat25.txt \
	| grep -P "^%[NF]" | endirect | cut -b 4- | sed -e "s/ /\t/" | tee $@.tmp
	make hmize TARGET=$@
parian:
	grep -P "^%o A\d+ +\(PARI\) +a\(n\) +\=" jcat25.txt \
	| endirect | cut -b 4- \
	| sed -e "s/  */\t/" -e "s/(PARI) *a(n) *= */a(n) = /" \
	| sort -k2 \
	> $@.tmp
	make hmize TARGET=$@
eta:
	grep -P "\Weta\(" jcat25.txt | grep -P "^%[NF]" \
	| endirect | cut -b 4- | sed -e "s/ /\t/" \
	| tee $@.tmp
	make hmize TARGET=$@
qpowers:
	grep -P "powers of q" jcat25.txt | grep -P "^%[NF]" \
	| endirect | cut -b 4- | sed -e "s/ /\t/" \
	| tee $@.tmp
	make hmize TARGET=$@
mult: # Multiplicative in jcat25 nyi
	grep -iP "multiplicative" jcat25.txt | grep -P "^%[NFC]" \
	| grep -vP "multiplicative (closure|digital|group|invers|order|persistence|root|subgroup|sum|Wiener|Zagreb)" \
	| sort -k3,3 -k4,4 -k5,5 -k6,6 \
	| endirect | cut -b 4- | sed -e "s/ /\t/" \
	| tee $@.tmp
	make hmize TARGET=$@
niven: #
	grep -iP "Niven|Harshad|[AJ]005349" jcat25.txt | grep -P "^%[NF]" \
	| endirect | cut -b 4- | sed -e "s/ /\t/" \
	| tee $@.tmp
	make hmize TARGET=$@
partn: #
	grep "Number of partitions of n into " jcat25.txt | grep -P "^%[NFCY]" \
	| endirect | cut -b 4- | sed -e "s/ /\t/" \
	| tee $@.tmp
	make hmize TARGET=$@
#--------