#!make

# OEIS-mat/contrib/hp - Hugo Pfoertner
# @(#) $Id$
# 2023-08-09: Georg Fischer; *VF=42
#---------------------------------
GITS=../../..
COMMON=../../common
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
FISCHER=$(GITS)/joeis-lite/internal/fischer
#-------------
all: part1 part2
part1: dead nodead gcd3 accum align grepcd 
part2: load_match match_select jcat25_extract failures gcd_annot gcd_check
help:
	grep -E "^[a-z]" makefile
#==============================
dead:
	grep -P "^.K" $(COMMON)/jcat25.txt | grep dead | cut -d" " -f2 \
	| sed -e "s/\r//" \
	>        $@.lst
	head -n2 $@.lst
	wc -l    $@.lst
nodead: # get asdata without dead sequences
	$(DBAT) -x "SELECT d.aseqno, 'orig', i.offset1, '1', d.data \
	  FROM asdata d, asinfo i \
	  WHERE i.aseqno = d.aseqno AND i.keyword NOT LIKE '%dead%';" \
	>        $@.txt
	head -n2 $@.txt
	wc -l    $@.txt
gcd3: gcd0 gcdminus1 gcdplus1 # prepare the 3 input files
gcd0 gcdminus1 gcdplus1: # prepare 1 input file
	perl gcd_reform.pl -c $@ $@.txt \
	| grep -vf dead.lst \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
accum: # create blocks of two lines with matching data
	sort -k5,5 -k2,2  nodead.txt gcd0.tmp gcdminus1.tmp gcdplus1.tmp > $@.srt
	perl match_data.pl $@.srt \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
align: # flatten the blocks with ny, yn and reverse the latter
	perl match_align.pl accum.tmp \
	| sort -k2,2 -k6,6 \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
grepcd: # grep only those involving a GCD
	grep cd  align.tmp \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
#----
load_match: # load the matched ones into seq4
	$(DBAT) -f $(FISCHER)/sql/seq4.create.sql
	$(DBAT) -r seq4 < grepcd.tmp
match_select: # select those with that are crossreferenced and have different GCDs
	$(DBAT) -x -f match.sql \
	| sed -e "s/\r//" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
#--
jcat25_list: # make a list of the relevant sequences
	cut -f1 match_select.tmp  > $@.1.tmp
	cut -f5 match_select.tmp  > $@.5.tmp
	sort $@.1.tmp $@.5.tmp | uniq | sed -e "s/\r//" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
jcat25_extract: jcat25_list # make a jcat25 extract with the relevant sequences
	grep -f jcat25_list.tmp $(COMMON)/jcat25.txt > $@.tmp
	wc -l    $@.tmp
#----
failures: fail1 fail2 # remove the known failing ones
fail1:
	cut -f1 simgcd.fail.man | grep -E "^A[0-9]" | sed -e "s/\r//" > $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
fail2:
	grep -vf fail1.tmp match_select.tmp \
	| sort > $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
#----
gcd_annot: # append crossreferencing jcat25 lines to the seq4 records
	perl gcd_annot.pl fail2.tmp > $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
gcd_check: # try to derive the formula, skip and prepend operations
	perl gcd_check.pl -d 1 gcd_annot.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp 
	head -n8 $@.tmp
	wc -l    $@*.tmp
	grep -E "^A" $@.tmp | wc -l
#----
