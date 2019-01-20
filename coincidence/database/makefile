#!make

# Examine stripped.gz
# @(#) $Id$
# 2018-10-17: P=3
# 2018-10-09: gen_all, my_mails
# 2018-09-30, Georg Fischer 
#---------------------------------
H=4
MIN=0
MAX=10000
MINLEN=8
S=8
P=3
N=1
D=0

all: 
	# targets: new = prepare newseq archlist regen (in that order)
new: prepare newseq archlist regen
#----
# get base data files 'names' and 'stripped' and 
# preprocess/sort the latter
prepare: prep1 prep2 prep3 prep4
prep1:
	wget https://oeis.org/stripped.gz
	rm -f stripped
	gzip -d stripped.gz
prep2:
	wget https://oeis.org/names.gz
	rm -f names
	gzip -d names.gz
prep3:
	perl simseq.pl -a prep -h $(H) -l $(MINLEN) < stripped | sort > stripsort.tmp
prep4:
	perl simseq.pl -a name         < names           > namurl.tmp
#----
# regenerate lists for all sequences
regen: regen1 index deploy
regen1:
	make regen4 2>&1 | tee regen.`date +%Y-%m-%d`.log
regen4:	A00 A05 A10 A15	A20 A25	A30 A35
A00:
	perl simseq.pl -p $(P) -h $(H) -l $(MINLEN) -min 000000 -max 049999 -n $(N) -d $(D)  < stripsort.tmp 
A05:
	perl simseq.pl -p $(P) -h $(H) -l $(MINLEN) -min 050000 -max 099999 -n $(N) -d $(D)  < stripsort.tmp 
A10:
	perl simseq.pl -p $(P) -h $(H) -l $(MINLEN) -min 100000 -max 149999 -n $(N) -d $(D)  < stripsort.tmp 
A15:
	perl simseq.pl -p $(P) -h $(H) -l $(MINLEN) -min 150000 -max 199999 -n $(N) -d $(D)  < stripsort.tmp 
A20:
	perl simseq.pl -p $(P) -h $(H) -l $(MINLEN) -min 200000 -max 249999 -n $(N) -d $(D)  < stripsort.tmp 
A25:
	perl simseq.pl -p $(P) -h $(H) -l $(MINLEN) -min 250000 -max 299999 -n $(N) -d $(D)  < stripsort.tmp 
A30:
	perl simseq.pl -p $(P) -h $(H) -l $(MINLEN) -min 300000 -max 349999 -n $(N) -d $(D)  < stripsort.tmp 
A35:
	perl simseq.pl -p $(P) -h $(H) -l $(MINLEN) -min 350000 -max 399999 -n $(N) -d $(D)  < stripsort.tmp 
#------------
index:
	grep warnings                         regen.`date +%Y-%m-%d`.log
	perl simseq.pl -a index < regen.`date +%Y-%m-%d`.log > index.html
#------------
deploy: 
	scp *.html gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/coincidence/database
deplin:
	scp index.html gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/coincidence/database
#------------
# delete sequences modified by me
# (1) place new reply emails "Re  changes to A067482 - ..." into ../temp
# (2) make my_mails
newseq: news1 news2
news1:
	ls -1 ../temp/*.eml | cut -d" " -f 5 | sort | uniq | tee newseq.`date +%Y-%m-%d`.lst
	wc -l newseq*.lst
news2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	mv ../temp/*.eml ../archive || :
#----
allseq: archlist alls1 alls2
archlist:
	ls -1 ../archive/*.eml | cut -d" " -f 5 | sort | uniq > archlist.tmp
	wc -l archlist.tmp
	sed -e "s/A/b/" archlist.tmp > brchlist.tmp
	wc -l brchlist.tmp
alls1:
	cat archlist.tmp | xargs -l -i{} rm -vf ../store/{}.text
alls2:
	cat brchlist.tmp | xargs -l -i{} rm -vf ../bfiles/{}.txt
#------------
# fetch sequences for neil_lists/bextra.txt
bextra:
	grep ">" ../../bfcheck/neil_lists/bextra.txt | cut -b 3- \
	> $@,tmp
	wc -l $@.tmp
	perl simseq.pl -a wget < $@.tmp
bextra_h:
	cat bextra.tmp | xargs -l -i{} grep -iHE "^%H " ../store/{}.text
bextra_k:
	cat bextra.tmp | xargs -l -i{} grep -iHE "^%K " ../store/{}.text
#----
# fetch b-files for neil_lists/bextra.txt
bextrb:
	grep ">" ../../bfcheck/neil_lists/bextra.txt | cut -b 3- \
	| sed -e "s/A/b/" > $@.tmp
	wc -l $@.tmp
	perl simseq.pl -a wget < $@.tmp
#------------
# old targets
TEST=282876
test:
	perl simseq.pl -p $(P) -h $(H) -l $(MINLEN) -min $(TEST) -max $(TEST) -n 0 -d 1 < stripsort.tmp 
#------------
