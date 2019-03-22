#!make

# OEIS-mat/mine - Search for hidden connections between OEIS sequences
# @(#) $Id$
# 2019-03-20: Georg Fischer, copied from ./common
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb
SLEEP=16
DUMPS=../dumps
HEAD=8
PULL=../pull
COMMON=../common
D=0
G=n
RMIN=64
all:
	# targets: 
	grep -E "^[a-z]" makefile
#======================
bflong: bflong1 bflong2
bflong0:
	$(DBAT) "SELECT aseqno FROM bfinfo WHERE maxlen >= $(RMIN) ORDER BY 1" \
	> bflong_select.tmp
bflong1:
	wc -l  $@.tmp
	ls -al $@.tmp
	time perl extract_bflong.pl -r $(RMIN) -f bflong_select.tmp $(COMMON)/bfile \
	 >        bflong.txt
bflong2:
	head -n4  bflong.txt
bflong_sort:
	time sort bflong.txt \
	>      $@.tmp
	wc -l  $@.tmp
	ls -al $@.tmp
bflong_thin:
	cat  bflong_sort.tmp \
	| grep -v "000000000000000000000000000000000000000000000000" \
	| grep -v "111111111111111111111111111111111111111111111111" \
	| grep -v "222222222222222222222222222222222222222222222222" \
	| grep -v "333333333333333333333333333333333333333333333333" \
	| grep -v "444444444444444444444444444444444444444444444444" \
	| grep -v "555555555555555555555555555555555555555555555555" \
	| grep -v "666666666666666666666666666666666666666666666666" \
	| grep -v "777777777777777777777777777777777777777777777777" \
	| grep -v "888888888888888888888888888888888888888888888888" \
	| grep -v "999999999999999999999999999999999999999999999999" \
	>      $@.tmp            
	wc -l  $@.tmp
	ls -al $@.tmp
mine_bflong:
	perl mine_bflong.pl bflong_thin.tmp \
	>      $@.tmp
	wc -l  $@.tmp
	ls -al $@.tmp
	sort   -k1 -k2n -k3n $@.tmp > $@.txt
mine_uniq:
	cut -f1,3 mine_bflong.txt | sort | uniq -c \
	>      $@.tmp
	wc -l  $@.tmp
#--------------
fetch_list:
	cut -b1-7 fetch_list.man \
	| grep -E "^A" | sort | uniq > $@.txt
	wc -l $@.*
#--------------
bfile_extract: bfdata bfinfo 
bfdata: # parameter: DIR
	perl extract_info.pl -btr $(DIR)/bfile > $@.txt
	wc -l $@.txt
#--
bfdata_check: # Compare <code>stripped</code> file with terms extracted from local b-files
	grep -vE "^#" $(COMMON)/stripped | sed -e "s/ \,/\t/" -e "s/,$$//"  \
	> x.tmp
	echo -e "A-Number\tTerms" > $@.txt
	sort x.tmp bfdata.txt | uniq -c | grep -vE "^ +2 +" \
	| grep -E "," \
	| cut -b 9- \
	| perl comp_terms.pl \
	| grep -vf $(COMMON)/draft_load.tmp \
	>> $@.txt
	wc -l $@.txt
