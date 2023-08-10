#!make

# OEIS-mat/contrib/hp - Hugo Pfoertner
# @(#) $Id$
# 2023-08-09: Georg Fischer; *VF=42
#---------------------------------
GITS=../../..
COMMON=../../common
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
#-------------
all: nodead gcdall
help:
	grep -E "^[a-z]" makefile
#==============================
nodead: # get asdata without dead sequences
	$(DBAT) -x "SELECT d.aseqno, 'orig', i.offset1, '1', d.data FROM asdata d, asinfo i WHERE i.aseqno = d.aseqno AND i.keyword NOT LIKE '%dead%';" \
	>        $@.txt
	head -n2 $@.txt
	wc -l    $@.txt
gcdall: gcd0 gcdminus1 gcdplus1
gcd0 gcdminus1 gcdplus1:
	perl gcd_reform.pl -c $@ $@.txt > $@.tmp
	wc -l   $@.tmp
	sort -k5,5 -k2,2  $@.tmp nodead.txt > $@.srt
	perl match_data.pl $@.srt > $@.mat
	wc -l    $@.mat
#----
