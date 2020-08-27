#!make

# OEIS-mat/wikipedia - get the external page links ans scan them for OEIS 
# @(#) $Id$
# 2020-08-05, Georg Fischer: copied from ../weidis
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
D=0 # debug mode

all:
	echo select specific target 
#===============================================
get: get1 get2 wpoeis
get1: # get the external page links dump
	wget "https://ftp.acc.umu.se/mirror/wikimedia.org/dumps/enwiki/20200801/enwiki-20200801-externallinks.sql.gz" \
	  -O en_ext.gz
	gzip -d en_ext
get2: # extract the OEIS A-numbers
	perl -ne 'map { print "$$_\n"; } m{(https://oeis.org/A\d+)}ig;' \
	  en_ext > $@.tmp
wpoeis: # uniq, sorted external links (1105 entries)
	sort get2.tmp | uniq -c \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
wikify:
	perl wikify.pl wpoeis.txt > $@.txt
#----
templ: # templatelinks: Oeis 56, OEIS 698, OEIS2C 232, OEIS el 140, OEIS Link 113, Cite OEIS 290
	wget "https://ftp.acc.umu.se/mirror/wikimedia.org/dumps/enwiki/20200801/enwiki-20200801-templatelinks.sql.gz" \
	  -O $@.gz
	gzip -d $@.gz
	perl -ne 'map { print "$$_\n"; } m{(https://oeis.org/A\d+)}ig;' $@ \
	>        $@.oeis.tmp
	head -n4 $@.oeis.tmp
	wc -l    $@.oeis.tmp

#================

