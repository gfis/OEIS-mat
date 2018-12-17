#!make

# makefile for OEIS URL checking
# @(#) $Id$
# 2018-12-17: brol_process -g = get status codes for URLs
# 2018-12-13: https://github.com/gfis/OEIS-mat/blob/master/broken_link/makefile
# 2018-12-11: use bigout1 with 389420 %H lines and A-numbers
# 2018-10-16: revived
# 2009-01-07, Georg Fischer
#----------------------------------------
LIM=16
MF=64
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
BASE=bigout1
#-------------------------
all: 
	# please make targets explicitely: table, brol, url1 ...
	grep -E "^[a-z]" makefile
table: brol url1
old: clean nonlocal nocommon tilde
	# do not call make without a target
#-------------------------
# database
brol: brol_prep brol_table
#---
brol_prep: raw_thin brol_tsv brol_thin
raw_thin:
	grep -v "#" exclude.1.lst | cut -f2 > x.tmp
	grep -vEf x.tmp $(BASE) > $@.tmp
	wc -l $@.tmp
brol_tsv:
	perl brol_process -r raw_thin.tmp > $@.tmp
	head -4 $@.tmp
	wc -l $@.tmp
brol_thin: 
	grep -v "#" exclude.2.lst | cut -f2 \
	| sed -e "s/^\(.*\)$$/	\1	/" | tee exclude.tmp
	# | paste -s --delimiters="|"  | tee exclude.tmp
	grep -iE "	(file://|oeis.org)	" brol_tsv.tmp | wc -l
	grep -ivE "	(file://|oeis.org)	" brol_tsv.tmp\
	| grep -vif exclude.tmp > $@.tmp
	wc -l $@.tmp
#---
brol_table: brol_create brol_load brol_statatistic
brol_create:
	perl brol_process -c brol | tee brol.create.sql
	$(DBAT) -f                         brol.create.sql
brol_load:
	$(DBAT) -m csv -s "\t" -r brol < brol_thin.tmp
	$(DBAT) -n brol
brol_statistic:
	$(DBAT) -n brol
	$(DBAT) "select protocol, count(protocol) from brol group by protocol"
	$(DBAT) "select protocol, port, count(*) from brol group by protocol, port"
	$(DBAT) "select count(distinct host) from brol"
	$(DBAT) "select count(distinct protocol, host, path, filename) from brol"
#---
url1: url1_create url1_load url1_stat
url1_create:
	perl brol_process -c url1 | tee url1.create.sql
	$(DBAT) -f                         url1.create.sql
url1_load:
	$(DBAT) -f url1.load.sql
	$(DBAT) -n url1
url1_stat:
	$(DBAT) -x -32 -m csv "SELECT noccur, protocol || host || port || path || filename \
	FROM url1 ORDER BY noccur DESC" | tee $@.tmp
#---
special:
	$(DBAT) -v -f $@.update.sql
#---
fetch: fetch1 fetch2 fetch3
fetch1:
	$(DBAT) -$(MF) -x "SELECT noccur, protocol, host, port, path, filename, status FROM url1 \
	WHERE status = 'unknown' \
	ORDER BY noccur DESC, filename" \
	> urls.tmp
fetch2:
	perl brol_process.pl -g urls.tmp 
fetch3:
	$(DBAT) -f update.tmp
fetch_stat:
	$(DBAT) "SELECT noccur, status, access, protocol || host || port || path || filename FROM url1 WHERE status <> 'unknown' ORDER BY noccur DESC;"
fetch_repair:
	$(DBAT) 
#---

trivial:
	$(DBAT) "select * from brol where host = 'http'"
ip-address:
	$(DBAT) -x "select count(host), host from brol where host < 'A' \
	and host not like '%c%' and host not like '%e%' and host not like '%h%' \
	group by host" | tee $@.1.tmp
	cut -f 2 $@.1.tmp > $@.2.tmp
	make ip-address.4 2>&1 | tee $@.3.tmp
ip-address.4:
	cat ip-address.2.tmp | xargs -l ping -c1 -w2 
wrong:
	$(DBAT) "select * from brol where host = '10.1007'"
help:
	$(DBAT) -h
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
