#!make

# OEIS-mat: b-file check
# @(#) $Id$
# 2019-01-07: split tgz
# 2019-01-05: Georg Fischer, copied from ../coincidence/database
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
BASE=b000001-b321800.tar
BASEZ=$(BASE).gz
SLEEP=8

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
	# tar -C    b$(D1)$(D2) --exclude-from=exclude.tmp -xf $(BASE)
#----
untgz:
	make bfall TARGET=untgz1
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
#-----------------
bfli: bflink bflink_load
bflink: 
	perl bflink.pl -x ../broken_link/bigout1 > bflink.txt 2> bflink_strange.txt
	cat bflink_strange.txt
	wc -l bflink*.txt
bflink_load:
	perl bflink.pl -c >       bflink.create.sql
	$(DBAT) -f                bflink.create.sql
	$(DBAT) -m csv -s "\t" -r bflink < bflink.txt
	$(DBAT) -n                bflink
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
	scp delseq.tsv.txt delseq.very_diff.txt delseq.very_diff.html index.html \
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
#-----------------------------------
# line lengths
linelen:
	make bfall TARGET=linelen1
linelen1:
	wc -L b$(D1)$(D2)/* | sort -nr > linelen.b$(D1)$(D2).tmp
	head -8 linelen.b$(D1)$(D2).tmp
strip_len:
	perl linelen.pl ../coincidence/database/stripped | sort -rn | uniq -c \
	| tee $@.tmp
linelen_sum:
	sed -e "s/ b[0-9][0-9]\// /" linelen.*.tmp | grep -v total | sort -rn | head -60 > $@.tmp
linelen_h:
	sed -e "s/^ *//" linelen_sum.tmp | cut -d" " -f2 \
	| sed -e "s/b/A/" -e "s/.txt//" > $@.1.tmp
	grep -f $@.1.tmp bflink.txt      | tee $@.2.tmp
#-------------------------------
#%K A000001 nonn,core,nice,hard
#%K A000002 nonn,core,easy,nice
#12345
keywords: 
	cat ./neil_lists/keywordlist.txt | cut -b 4- > $@.tmp
	wc  -l $@.tmp
	perl bfdata.pl -c $@ > $@.create.sql
	$(DBAT) -f $@.create.sql
	$(DBAT) -m csv -s " " -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
bextra_dead:
	$(DBAT) -m csv -s " " "SELECT '%k', k.aseqno, k.words FROM keywords k, bextra e \
		WHERE k.aseqno = e.aseqno \
		  AND k.words LIKE '%dead%' \
		ORDER BY 1" | tee $@.tmp
#----
#%O A000001 0,5
#%O A000002 1,2
#12345
offset: 
	cat ./neil_lists/offsetlist.txt | cut -b 4- \
	| sed -e "s/\,/ /" > $@.tmp
	wc -l $@.tmp
	perl bfdata.pl -c $@ > $@.create.sql
	$(DBAT) -f $@.create.sql
	$(DBAT) -m csv -s " " -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
#=================
# old targets
news2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	cat archlist.tmp | xargs -l -i{} rm -vf ../store/{}.text
#------------
