#!make

# Cache links to Yahoo groups
# @(#) $Id$
# 2019-11-12, Georg Fischer
#----------------
GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
D=0
N=22771
#----

all: extract wget
#----
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
	
