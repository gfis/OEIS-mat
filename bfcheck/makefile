#!/bin/make

# OEIS-mat: b-file check
# @(#) $Id$
# 2019-01-18: analyze, refresh
# 2019-01-07: split tgz
# 2019-01-05: Georg Fischer, copied from ../coincidence/database
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
BASE=b000001-b321800.tar
BASEZ=$(BASE).gz
SLEEP=16

all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#--------
bfall: u0 u1 u2 u3 
# parameter is $(TARGET)
u0:
	make $(TARGET) D1=0 D2=0
	make $(TARGET) D1=0 D2=5
u1:
	make $(TARGET) D1=1 D2=0
	make $(TARGET) D1=1 D2=5
u2:
	make $(TARGET) D1=2 D2=0
	make $(TARGET) D1=2 D2=5
u3:
	make $(TARGET) D1=3 D2=0
	make $(TARGET) D1=3 D2=5
#----
split: unpack pack count
unpack:
	make bfall TARGET=unpack1
unpack1:
	mkdir       b$(D1)$(D2)
	grep -vE  "^b$(D1)\[$(D2)" exclude_all.pat > exclude.tmp
	tar -C      b$(D1)$(D2) --exclude-from=exclude.tmp -xzf $(BASEZ)
#----
untgz:
	make bfall  TARGET=untgz1
untgz1:
	tar -xzf    b$(D1)$(D2).tgz
#----
pack:
	make bfall  TARGET=pack1
pack1:
	tar -czf    b$(D1)$(D2).tgz b$(D1)$(D2)
#--------
count:
	make bfall  TARGET=count1
count1:
	ls -1       b$(D1)$(D2) | wc -l
#--------
count_all:
	find b00 b05 b10 b15 b20 b25 b30 b35 -type f | wc
count_synth:
	rm -f $@.log
	make bfall  TARGET=count_synth1
	cat $@.log
count_synth1:
	head -qn 1 b$(D1)$(D2)/* | grep "(b-file synthesized from sequence entry)" \
		| wc -l | tee $@.tmp
	sed -e "s/^/b$(D1)$(D2)\t/" $@.tmp >> count_synth.log
#--------
list_synth:
	rm -f $@.lst
	make bfall  TARGET=list_synth1
	wc -l $@.lst
list_synth1:
	head -qn 1 b$(D1)$(D2)/* | grep -H "(b-file synthesized from sequence entry)" \
		| cut -d" " -f 3 >> list_synth.lst
#----
pretend_synth:
	cut -b2-7 list_synth.lst > $@.1.tmp
	cut -b2-7 bflink.txt     > $@.2.tmp
	sort $@.1.tmp $@.2.tmp | uniq -c | grep "   2" \
	| cut -b 9- | sed -e "s/^/A/" -e "s/$$/\tpretends \"b-file synthesized from sequence entry\"/" \
	| perl tsv_html.pl | tee $@.html
#----
clean:
	rm -f clean.log
	make u0 u1 u2 u3 TARGET=clean1
	cat clean.log
clean1:
	perl rm_synthesized.pl b$(D1)$(D2) 2>> clean.log
#------------------
refresh: refresh_get
refresh_get:
	rm -rf temp 
	mkdir  temp
	cp     refresh.man temp/refresh.`date +%Y-%m-%dT%H_%M`.lst
	mkdir  temp/bfile
	mkdir  temp/json
	cut -b2-7 refresh.man \
	| xargs -l -i{} make --silent refresh_bf SEQNO={}
	cut -b2-7 refresh.man \
	| xargs -l -i{} make --silent refresh_as SEQNO={}
	tar -cjvf refresh.tar.bz2 temp
	cp -v     refresh.tar.bz2 refresh.`date +%Y-%m-%d`.tar.bz2 
	find  temp/bfile | wc -l
	find  temp/json  | wc -l
refresh_bf:
	sleep $(SLEEP)
	wget -O temp/bfile/$(SEQNO).txt "https://oeis.org/A$(SEQNO)/b$(SEQNO).txt"
refresh_as:
	sleep $(SLEEP)
	wget -O temp/json/$(SEQNO).json "https://oeis.org/search?q=id:A$(SEQNO)&fmt=json"
#-------
refresh_unpack:
	rm -rf temp 
	tar -xjvf refresh.tar.bz2
	echo "cp -v temp/bfile/* unbf"  
	echo "cp -v temp/json/*  unjs"  
#------------------
get_delseq: get_delseq1 get_delseq2
get_delseq1:
	wget https://oeis.org/wiki/Deleted_sequences      -O delseq.2018.tmp
	sleep $(SLEEP)
	wget https://oeis.org/wiki/Deleted_sequences/2017 -O delseq.2017.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2016 -O delseq.2016.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2015 -O delseq.2015.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2014 -O delseq.2014.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2013 -O delseq.2013.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2012 -O delseq.2012.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2011 -O delseq.2011.tmp
	sleep $(SLEEP)                                                  
	wget https://oeis.org/wiki/Deleted_sequences/2010 -O delseq.2010.tmp
	sleep $(SLEEP)
get_delseq2:
	rm -f delseq.tsv.txt
	find . -iname "delseq.*.tmp" | sort -r | xargs -l perl bfdelseq.pl >> delseq.tsv.txt
	wc -l delseq.tsv.txt
very_diff: 
	sed -e "s/^b/A/" -e "s/.txt//" Pedersen.very-different.234.txt > $@.tmp 
	grep -f $@.tmp delseq.tsv.txt | sort > delseq.$@.txt
	perl tsv_html.pl delseq.$@.txt > delseq.$@.html
#-----------------
deploy:
	# scp delseq.tsv.txt delseq.very_diff.txt delseq.very_diff.html index.html \
	#	gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/bfcheck/
	scp maxllen.html \
		gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/bfcheck/
#=================
# database table creation
bextra: 
	grep ">" ./neil_lists/bextra.txt | cut -b 3- \
	> $@.tmp
	head -4 $@.tmp
	wc   -l $@.tmp
	perl bfdata.pl -c $@ > $@.create.sql
	$(DBAT) -f $@.create.sql
	$(DBAT) -m csv -s " " -r $@ < $@.tmp
	$(DBAT) -n $@
bextrb: 
	grep ">" ./neil_lists/bextra.txt | cut -b 3- \
	| sed -e "s/A/b/" -e "s/$$/.txt/" > $@.tmp
	head -4 $@.tmp
	wc   -l $@.tmp
bextra_h: bextra_h1 bextra_h2
bextra_h1:
	cat bextra.tmp | xargs -l -i{} grep -iHE "^%H " ../coincidence/store/{}.text \
	> $@.tmp || :
bextra_h2:
	grep -f bextrb.tmp bextra_h1.tmp \
	| cut -d":" -f 2- > $@.tmp || :
	head -4 $@.tmp
	wc   -l $@.tmp
bextra_k:
	cat bextra.tmp | xargs -l -i{} grep -E "^%K " ../coincidence/store/{}.text \
	> $@.tmp
	head -4 $@.tmp
	wc   -l $@.tmp
bextra_e:
	cat bextra.tmp \
	| sed -e "s/^/%E /" -e "s/$$/ ========================/" \
	> $@.tmp
	head -4 $@.tmp
	wc   -l $@.tmp
#----
#A316712	(W. Lang) duplicate of A276383 - N. J. A. Sloane 19:23, 4 January 2019 (EST)
#A322998	(Felix Fröhlich) withdrawn - Felix Fröhlich (talk) 14:01, 2 January 2019 (EST)
delseq_table: delseq bextra_delseq bextra_not_delseq
delseq:
	sed -e "s/\"/\'\'/g" ./delseq.tsv.txt | cut -b 1-128 > $@.tmp
	wc   -l $@.tmp
	perl bfdata.pl -c $@ > $@.create.sql
	$(DBAT) -f $@.create.sql
	$(DBAT) -m csv -s "\t" -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
bextra_delseq:
	$(DBAT) -x -m csv -s " " "SELECT '%d',  d.aseqno, 'in wiki del.seq.: ', d.comment FROM delseq d, bextra e \
		WHERE d.aseqno = e.aseqno \
		ORDER BY 1" > $@.tmp
	head -4 $@.tmp
	wc   -l $@.tmp
bextra_not_delseq:
	$(DBAT) -x -m csv -s " " "SELECT '%d', e.aseqno, 'not in wiki del.seq.'  FROM bextra e \
		WHERE e.aseqno NOT IN (SELECT d.aseqno FROM delseq d) \
		ORDER BY 1" > $@.tmp
	head -4 $@.tmp
	wc   -l $@.tmp
#----
#../coincidence/bfiles/b004693.txt:# A004693 (b-file synthesized from sequence entry)
#         1         2         3
#123456789012345678901234567890
bextra_synth:
	cat bextrb.tmp | xargs -l -i{} grep -iHE "synthesized" ../coincidence/bfiles/{} \
	| cut -b24- \
	| sed -e "s/^/%y A/" -e "s/.txt:/ /" > $@.tmp
	head -4 $@.tmp
	wc   -l $@.tmp
bextra_stripped:
	grep -f bextra.tmp ../coincidence/database/stripped \
	| sed -e "s/^/%a /" > $@.tmp
	head -4 $@.tmp
	wc   -l $@.tmp
bextra_head:
	cat bextrb.tmp | xargs -l -i{} perl bfhead.pl ../coincidence/bfiles/{} \
	> $@.tmp
	head -4 $@.tmp
	wc   -l $@.tmp
bextra_combine:
	cat \
	bextra_head.tmp \
	bextra_stripped.tmp \
	bextra_delseq.tmp \
	bextra_not_delseq.tmp \
	bextra_e.tmp \
	bextra_h2.tmp \
	bextra_k.tmp \
	bextra_synth.tmp \
	| sort --field-sep=" " --key=2.1,2.7 --key=1.2,1.2 > $@.txt
	head -32 $@.txt
bextra_list:
	head -2 \
	bextra_head.tmp \
	bextra_stripped.tmp \
	bextra_delseq.tmp \
	bextra_not_delseq.tmp \
	bextra_e.tmp \
	bextra_h2.tmp \
	bextra_k.tmp \
	bextra_synth.tmp \
	#
#---------------------------
# Neil's email 2018-01-12
bextra_dead2:
	grep dead bextra_combine.txt | cut -d" " -f 2 | tee $@.txt
bextra_split: gf0 gf1 gf2 gf3 gf4 gf5 gf6 gf7 gf8
	grep -e "^gf[0-9]" makefile | tee $@.txt
	wc -l gf*.txt
gf0: # ok, corrected
	grep -E "^%0" bextra_combine.txt | cut -d" " -f 2 > $@.txt
gf1: # to be DELETEd since "dead"
	grep -E "^%1" bextra_combine.txt | cut -d" " -f 2 > $@.txt
gf2: # to be DELETEd since severe differences and mentioned
	grep -E "^%2" bextra_combine.txt | cut -d" " -f 2 > $@.txt
gf3: # b-file is longer, %H link to it is missing
	grep -E "^%3" bextra_combine.txt | cut -d" " -f 2 > $@.txt
gf4: # like gf3, but offset differs 
	grep -E "^%4" bextra_combine.txt | cut -d" " -f 2 > $@.txt
gf5: # to be DELETEd since terms are the same
	grep -E "^%5" bextra_combine.txt | cut -d" " -f 2 > $@.txt
gf6: # strange cases, some similiarities
	grep -E "^%6" bextra_combine.txt | cut -d" " -f 2 > $@.txt
gf7: # severe differences, but not mentioned 
	grep -E "^%7" bextra_combine.txt | cut -d" " -f 2 > $@.txt
gf8: # no terms, b-file only; new allocated
	grep -E "^%8" bextra_combine.txt | cut -d" " -f 2 > $@.txt
bextra_codes:
	cut -b 1-2 bextra_combine.txt | sort | uniq -c | tee $@.txt
#-----------------
bflink: bflink_prep bflink_load \
	maxllen_update \
	fsizes_update  \
	#
bflink_prep: 
	perl bflink.pl -x ../broken_link/bigout1 > bflink.txt 2> bflink_strange.txt
	cat bflink_strange.txt
	wc -l bflink*.txt
bflink_load:
	perl bflink.pl -c >       bflink.create.sql
	$(DBAT) -f                bflink.create.sql
	$(DBAT) -m csv -s "\t" -r bflink < bflink.txt
	$(DBAT) -4                bflink
	$(DBAT) -n                bflink
#-----------------------------------
# maximum line length
# wc -L with uppercase "ell" yields maximum of lengths of lines
maxllen_new: maxllen_all maxllen_update
maxllen:
	make bfall TARGET=maxllen1
maxllen1:
	wc -L b$(D1)$(D2)/* | sort -nr \
	| grep -v "total" \
	> maxllen.b$(D1)$(D2).tmp
	head -8 maxllen.b$(D1)$(D2).tmp
#      9867 total
#      9867 b00/b048707.txt
#      9863 b00/b000133.txt
# 123456789012345           
maxllen_all: 
	sed -e "s/ b[0-9][0-9]\// /" maxllen.*.tmp \
	| grep -v "total" \
	| sort -rn \
	> $@.tmp
maxllen_h:
	sed -e "s/^ *//" maxllen_all.tmp | cut -d" " -f2 \
	| sed -e "s/b/A/" -e "s/.txt//" > $@.1.tmp
	grep -f $@.1.tmp bflink.txt      | tee $@.2.tmp
maxllen_update:
	gawk -e '{print "A" substr($$2,2,6) " " $$1}'  maxllen_all.tmp  > $@.1.tmp
	perl bfdata.pl -c temp > temp.create.sql
	$(DBAT) -f temp.create.sql
	$(DBAT) -m csv -s " " -r temp < $@.1.tmp
	$(DBAT) -4 temp
	$(DBAT) -n temp
	$(DBAT) -v "UPDATE bflink b SET b.maxllen = \
	    COALESCE((SELECT t.temp FROM temp t WHERE b.aseqno = t.aseqno), -1)"
#-------------------------------
# %K A000001 nonn,core,nice,hard
# %K A000002 nonn,core,easy,nice
# 12345
keywords:
	cat ./neil_lists/keywordlist.txt | cut -b 4- \
	| sed -e "s/ /\t/" -e "s/\,/ /g" > $@.tmp
	perl bfdata.pl -c $@ > $@.create.sql
	$(DBAT) -f $@.create.sql
	$(DBAT) -m csv -s "\t" -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
bextra_dead:
	$(DBAT) -m csv -s " " "SELECT '%k', k.aseqno, k.words FROM keywords k, bextra e \
		WHERE k.aseqno = e.aseqno \
		  AND k.words LIKE '%dead%' \
		ORDER BY 1" | tee $@.tmp
#----
# %O A000001 0,5
# %O A000002 1,2
# 12345
offset: 
	cat ./neil_lists/offsetlist.txt \
	| sed -re "s/(A[0-9]+) (\-?[0-9]+)$$/\1 \2\,1/" \
	| cut -b 4- \
	| sed -e "s/\,/ /" > $@.tmp
	# sed fixes the missing second part problem
	wc -l $@.tmp
	perl bfdata.pl -c $@ > $@.create.sql
	$(DBAT) -f $@.create.sql
	$(DBAT) -m csv -s " " -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
no_offset_2:
	grep -v "," neil_lists/offsetlist.txt \
	| sort > $@.txt
	# sed fixes the missing second part problem
	wc -l $@.txt
#----------------------
analyze:
	make --silent bfall TARGET=analyze1
	cat analyze.b*.tmp > $@.txt
	head -4 $@.txt
	wc   -l $@.txt
	make --silent analyze2
analyze1:
	rm -f analyze.b$(D1)$(D2).tmp
	find b$(D1)$(D2) -type f | sort | xargs -l -i{} \
	perl bfanalyze.pl {} >> analyze.b$(D1)$(D2).tmp
analyze2:
	grep " n" analyze.txt | grep -v "sign" | cut -b1-64 \
	| tee $@.`date +%Y-%m-%dT%H_%M`.txt
	wc -l $@.*.txt
#----
first:
	perl bfstrip.pl analyze.txt | tee $@.tmp
first_diff:
	cut -b1-7 first.tmp                          | sort > $@.1.tmp
	cut -b18-24 neil_lists/missing-few-terms.txt | sort > $@.2.tmp
	diff -wy --width=24 $@.1.tmp $@.2.tmp | tee $@.3.txt
firch:
	cut -b1-7 refresh.man  > $@.1.tmp
	cut -b1-7 first_diff.3.txt | grep -E "[0-9]" | sort > $@.2.tmp
	grep -vf $@.1.tmp $@.2.tmp | tee $@.3.tmp
first_terms:
	perl tsv_html.pl -m strip first.tmp > $@.html
first_terms3:
	perl tsv_html.pl -m strip www_teo/grep3.tmp > $@.html
deploy_first:
	scp first_terms.html gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/bfcheck
buthors:
	sed -e "s/^A\([0-9]*\)\.*/b\1.txt/" first.tmp | cut -b1-11 > $@.b.tmp
	grep -f $@.b.tmp ../broken_link/bigout1 | tee $@.2.tmp
first_down:
	rm -rf temp
	mkdir temp
	perl aseq_wget.pl -t text -n 8 first.tmp > wget.tmp
	wget -w $(SLEEP) -i wget.tmp -O - >> temp/down.tmp 
first_int:
	grep -E "^%(A|H|O|K)" down.tmp | grep -vE "https?\:" \
	| grep -vEi "Index|transform" | sort -k1.4,1.11 | tee $@.txt
f1_corr:
	grep -E "corrected" first_int.txt | cut -b4-10 | tee $@.1.tmp
	grep -f $@.1.tmp first.tmp | tee $@.2.tmp
#-------------------
check_gf9:
	rm -f $@.ls.txt
	sed -e "s/^A/b/" -e "s/$$/.txt/" gf9.txt | tee check_gf9.tmp
	make  bfall TARGET=check1_gf9
check1_gf9:
	find b$(D1)$(D2) -type f -ls | grep -f check_gf9.tmp | tee >> check_gf9.ls.txt
#----
# total 1215010                                            
# -rw-r--r--+ 1 User Kein    46244 Feb 22  2018 b300000.txt
# -rw-r--r--+ 1 User Kein      581 Feb 25  2018 b300003.txt
# 1           2 3    4       5     6   7   8    9 
fsizes: fsizes.1 fsizes_update
fsizes.1: 
	ls -l b??/ | grep -vE "^total " \
	| gawk  -e '{print "A" substr($$9,2,6) " " $$5}' \
	| grep -vE "^A *$$" > $@.tmp
	head    -4 $@.tmp
	wc      -l $@.tmp
fsizes_update:
	$(DBAT) -f temp.create.sql
	$(DBAT) -m csv -s " " -r temp < fsizes.1.tmp
	$(DBAT) -4 temp
	$(DBAT) -n temp
	$(DBAT) -v "UPDATE bflink b SET b.fsize = \
	    COALESCE((SELECT t.temp FROM temp t WHERE b.aseqno = t.aseqno), -1)"
#=================
# old targets
news2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	cat archlist.tmp | xargs -l -i{} rm -vf ../store/{}.text
#------------
