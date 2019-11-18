#!make

# Save Yahoo groups threads and enter links to the cached files
# @(#) $Id$
# 2019-11-12, Georg Fischer
#----------------
GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON= $(GITS)/OEIS-mat/common
D=0
N=22771
SLEEP=16
#----

all: extract wget
#----
seq3: # parameter: $(LIST)
	$(DBAT) -f $@.create.sql
	cut -b1-  $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
#---------------
extract:
	mkdir html  || :
	mkdir text  || :
	perl get_links.pl yahoo_links.txt \
	| sort | uniq -c \
	| tee       $@.1.tmp
	grep   -v "#" $@.1.tmp \
	| grep http \
	| grep -v messages \
	| grep -v Aurifeuille \
	| cut -b9- \
	>         $@.2.tmp
	wc -l     $@.2.tmp
	head -n40000  $@.2.tmp > wget.tmp
	cat wget.tmp
#----
wget:
	cd html ; wget --wait=4 --input-file=../wget.tmp
wget2:
	cd html ; wget --wait=4 --input-file=../wget2.tmp 
#----
clean:
	find html -type f -printf "%f\n" | xargs -l -i{} perl clean_yahoo.pl html/{} text/yg.{}.txt \
	| tee clean.log.txt
check:
	grep -EH -B1 "/yg." clean.log.txt | grep Message | tee text/check.txt
#----
clean1:
	perl clean_yahoo.pl -d $(D) html/$(N).html text/yg.$(N).txt
#----
entity:
	find text -iname "*.txt" | xargs -l -i{} grep -iH "&#" "{}"
zip:
	rm -f text/yahoo_groups.cached.zip
	zip   text/yahoo_groups.cached.zip text/*.txt wget.tmp wget2.tmp clean.log.txt
rename:
	find html -iname "*.html"  -printf "%f\n" | sed -e "s/.html//" \
	| xargs -l -i{}  mv -v html/{}.html html/{}
#==============================
# Work lists
yahoo_links: yal1 yal2 yal3
yal1:
	  sed -e "s/^done \%H */njas#/" yahoo_links.txt \
	| sed -e "s/^\%H */\?\#/" \
	| sed -e "s/^\%o */gfis\#/" \
	| sed -e "s/ /\t/" \
	| perl -pe 's{\A([^\#]+)\#(\w+)}{$$2\t$$1};' \
	>         $@.tmp
	wc -l     $@.tmp
	cut -b1-7 $@.tmp | sort | uniq -c | grep -v "  1 "
yal2:
	make seq3 LIST=yal1.tmp
	$(DBAT) -v "UPDATE seq3 s SET status = 'edits' WHERE \
		(SELECT SUBSTR(i.access, 1, 9) \
		  FROM ASINFO i \
		  WHERE i.aseqno = s.aseqno) \
		= '2019-11-1' \
		AND status = '?'" 
#----
yal3: yahoo_check link_checks
yahoo_check: # Work list for vanishing Yahoo group links
	$(DBAT) -16000 "SELECT s.aseqno AS 'A_number', s.status, substr(i.access, 1, 10) AS 'last_change'\
		, s.info AS 'yahoo_link' \
	FROM      seq3 s \
	LEFT JOIN asinfo i ON s.aseqno = i.aseqno \
	ORDER BY 1" \
	| perl $(COMMON)/uniq1.pl \
	> yahoo_check.txt
link_checks:
	perl link_checks.pl -init $(COMMON)/eval_checks.lst >  check_index.html
	ls -1 *_check.txt | sed -e "s/.txt//" \
	| xargs -l -i{} make -s link_check1 FILE={}
	perl link_checks.pl -term $(COMMON)/eval_checks.lst >> check_index.html	
	mv -v *.html text
link_check1:
	perl link_checks.pl -m makefile -var $(FILE).txt -s geth.txt  >  $(FILE).html
	# mod_links.pl no longer in use
#----
lists: list1 list2
list1:
list2:
#------------------------
# get current %H lines
#
geth: geth1 geth2 geth3
geth0: # create temp directories
	# mkdir temp
	# mkdir temp/text
geth1: # prepare the fetch commands for wget
	cut -b1-7 yal1.tmp | sort | uniq \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	perl $(COMMON)/aseq_wget.pl -t text $@.tmp > geth2.tmp
	head -n4 geth2.tmp
	wc -l    geth2.tmp
geth2: # fetch with wget
	rm -f    geth.txt
	touch    geth.txt
	head -n1024 $@.tmp \
	| xargs -l -i{} make geth_text1 PARM={}
geth_text1: # xargs subtarget
	wget  -O $@.tmp      "$(PARM)" 
	cat      $@.tmp >> geth.txt
	sleep  $(SLEEP)
get_rest: # manunal additionals
	perl $(COMMON)/aseq_wget.pl -t text rest.man > geth2.tmp
	cat geth2.tmp \
	| xargs -l -i{} make geth_text1 PARM={}
geth3: # compare whether we got all
	grep -iE "%N" geth.txt | cut -b4-11 | sort | uniq > $@.2.tmp
	sort geth1.tmp | uniq          > $@.1.tmp
	diff -wy --suppress-common-lines $@.1.tmp           $@.2.tmp
geth4: # get relevant links; parameter ASEQNO=
	grep -iE "%H $(ASEQNO)" geth.txt | cut -b12- | grep -iE "yahoo|\/a[0-9]+\.txt"
	
	