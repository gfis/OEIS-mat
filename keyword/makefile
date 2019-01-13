#!make

# OEIS-mat: keyword-related queries
# @(#) $Id$
# 2019-01-13: Georg Fischer, copied from ../bfcheck
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
BASE=../bfcheck/keywordlist.txt

all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#----
list:
	less $(BASE)
keyw_split:
	perl keyword.pl -a split $(BASE) > $@.1.tmp
	cut -d" " -f 2 $@.1.tmp | sort | uniq -c | tee $@.2.tmp
keyword_stats:
	perl keyword.pl -a html  keyw_split.2.tmp > $@.html
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
strip_len:
	perl linelen.pl ../coincidence/database/stripped | sort -rn | uniq -c \
	| tee $@.tmp
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
