#!/bin/make

# makefile for OEIS URL checking
# 2018-12-11: use bigout1 with 389420 %H lines and A-numbers
# 2018-10-16: revived
# 2009-01-07, Georg Fischer, punctum(at)punctum.com
# The database files were formerly named like
#	http://www.research.att.com/~njas/sequences/eisBTfry00000.txt
#----------------------------------------
LIM=99999
DBAT=java -jar ../../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
BASE=bigout1
#-------------------------
all: clean nonlocal nocommon tilde
	# do not call make without a target
#-----------
clean:
	rm -f *.tmp
nonlocal:
	wc -l $(BASE)
	grep -vE "href=\"/"     $(BASE)  > x.tmp
	grep -vE "\/oeis.org\/" x.tmp    > $@.tmp
	grep  -E "\/oeis.org\/" x.tmp    > $@.local-http.tmp
	wc -l $@.*tmp
nocommon:
	grep -vEi "(doi.org|en.wikipedia.org|mathworld.wolfram.com|arXiv.org|web.archive.org|lacim.uqam.ca|emis.de)"  nonlocal.tmp > $@.tmp
	wc -l $@.tmp
tilde: tilde_full tilde_root
tilde_full:
	grep -E "(~|\%E7)" nocommon.tmp  > $@.tmp
	perl grepurl.pl $@.tmp           > $@.url.tmp
	cut -d "	" -f 2 $@.url.tmp | sort | uniq -c > $@.uniq.tmp
	wc -l $@.*tmp 
tilde_root:
	grep -E "(~|\%E7)" nocommon.tmp  > $@.tmp
	perl grepurl.pl -t $@.tmp        > $@.url.tmp
	cut -d "	" -f 2 $@.url.tmp | sort | uniq -c > $@.uniq.tmp
	wc -l $@.*tmp 
test_urls: test1 test2
test1:
	cat tilde_root.uniq.tmp \
	| sort -rn \
	| cut -b 9- | head -$(LIM)  > url.tmp.lst
	wget --spider --tries=1 --timeout=2 -i url.tmp.lst -o wget.log || :
test2:
	perl eval_log.pl wget.log \
	| sort \
	| tee url_result.log
test3:
	cut -d "	" -f 1 url_result.log \
	| sort | uniq -c | tee tilde_return_codes.tmp
hosts: hosts1 hosts2 hosts4
hosts1:
	perl grepurl.pl -h 1 nocommon.tmp > $@.name.tmp
	cut -d "	" -f 2 $@.name.tmp | sort | uniq -c > $@.uniq.tmp
	wc -l $@.*tmp 
hosts2: 
	make hosts3 2>&1 | tee $@.log
hosts3:
	cat hosts1.uniq.tmp \
	| sort -rn \
	| cut -b 9- | head -$(LIM)  > $@.tmp
	cat $@.tmp | xargs -l nslookup 2>&1 > $@.log
	# cat $@.tmp | xargs -l ping -w 2 -c 1 > $@.log
hosts4:
	grep -E "\*\*\* " hosts2.log \
	| cut -b 5- \
	| sed -e "s/ wurde von Speedport.ip nicht gefunden: /	/" | tee $@.1.log || :
	grep -B1 -E "62.138.23[89].45" hosts3.log | grep "Name:" \
	| cut -b 10- | sed -e "s/$$/	Unknown domain/" | tee $@.2.log
	wc $@.*.log
#-------------------------
# database
brol: brol_prep brol_create brol_load
brol_prep: brol_tsv brol_thin
brol_tsv:
	perl brol_prepare.pl -i $(BASE) > $@.tmp
	wc -l $@.tmp
brol_thin:
	grep -viE "	(oeis://|dx.doi.org|doi.org|oeis.org|en.wikipedia.org|mathworld.wolfram.com|arXiv.org|web.archive.org|lacim.uqam.ca|emis.de)	" \
		brol_tsv.tmp  > $@.tmp
	wc -l $@.tmp
brol_create:
	perl brol_prepare.pl -c > brol.create.sql
	$(DBAT) -f                brol.create.sql
brol_load:
	$(DBAT) -m csv -s "\t" -r brol < brol_thin.tmp
	$(DBAT) -n brol
brol_stat:
	$(DBAT) "select distinct protocol from brol"
help:
	$(DBAT) -h
#-------------------------
# old targets
check: down geturls spider eval

geturls:
	rm -f url*.tmp
	find ../store -name "*.text" | xargs -l -ißß perl grepurl.pl ßß > url1.tmp
	sort -k2 url1.tmp | tee url2.tmp
	wc -l url*.tmp
testdown:
	wget -r -l1 -nd --no-parent -A.jpg http://localhost/html/hroschmann.de/
	ls -al *.jpg
	rm -f *.jpg
prep:
	perl prep_files.pl > filenames.tmp
down:
	wget -i filenames.tmp
#	wget -r -l1 --no-parent --ignore-length --accept=.txt http://www.research.att.com/~njas/sequences/
testspider:
	wget --spider --tries=1 --timeout=2 --force-html --follow-ftp --base=http://localhost/html/punctum.com/ -i /var/www/html/punctum.com/index.html 2>&1 | tee spider.log
spider:
#	cut -f 2 url2.txt | sort | uniq > url3.txt
	wget --spider --tries=1 --timeout=2 -i url.tmp.lst --base=http://www.research.att.com/~njas/sequences/ 2>&1 | tee spider.mats.log
eval:
	perl eval_log.pl spider*.log | sort | tee access.eval
count:
	wc access.eval
	cut -f 1 access.eval | sort | uniq -c | tee access.uniq.txt
dirs:
	mkdir url
	mkdir done
	mkdir open
split:
	perl split_url.pl url.split.txt 
gather:
	rm -f url.tmp.lst
	find url -name "*.lst" | sort | xargs -l cat >> url.tmp.lst
