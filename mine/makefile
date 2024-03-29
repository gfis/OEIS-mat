#!make

# OEIS-mat/mine - Search for hidden connections between OEIS sequences
# @(#) $Id$
# 2019-03-20: Georg Fischer, copied from ./common
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMATH=java -cp ../../ramath/dist/ramath.jar org.teherba.ramath
SLEEP=16
DUMPS=../dumps
HEAD=8
PULL=../pull
COMMON=../common
D=0
RMIN=128
TOMC=c:/var/lib/tomcat/webapps/dbat
PROJECT=mine
DBAD=../../dbat
DBAW=java -jar $(DBAD)/dist/dbat.jar -c worddb  -e UTF-8
SRC=src/main/java/org/teherba/dbat
METHOD=get
TAB=milong
FISCHER=../../joies-lite/internal/fischer


all: bflong
	# targets: 
	grep -E "^[a-z]" makefile
#======================
bflong: bflong_sort bflong_thin 
bfmine:	mine_bflong mine_uniq
bflong0:
	$(DBAT) "SELECT aseqno FROM bfinfo WHERE maxlen >= $(RMIN) ORDER BY 1" \
	>     bflong_select.tmp
	wc -l bflong_select.tmp
bflong1:
	wc -l  $@.tmp
	ls -al $@.tmp
	time perl extract_bflong.pl -r $(RMIN) -f bflong_select.tmp $(COMMON)/bfile \
	>         bflong.txt
	wc -l     bflong.txt
	ls -al    bflong*
	head -n4  bflong.txt
bflong_sort:
	time sort bflong.txt \
	| uniq >  $@.tmp
	wc -l  $@.tmp
	ls -al $@.tmp
bflong_thin:
	cat  bflong_sort.tmp \
	| grep -v "0000000000000000000000000000000000000000000000000000000000000000" \
	| grep -v "1111111111111111111111111111111111111111111111111111111111111111" \
	| grep -v "2222222222222222222222222222222222222222222222222222222222222222" \
	| grep -v "3333333333333333333333333333333333333333333333333333333333333333" \
	| grep -v "4444444444444444444444444444444444444444444444444444444444444444" \
	| grep -v "5555555555555555555555555555555555555555555555555555555555555555" \
	| grep -v "6666666666666666666666666666666666666666666666666666666666666666" \
	| grep -v "7777777777777777777777777777777777777777777777777777777777777777" \
	| grep -v "8888888888888888888888888888888888888888888888888888888888888888" \
	| grep -v "9999999999999999999999999999999999999999999999999999999999999999" \
	>      $@.1.tmp            
	# grep -vE "A000079" $@.1.tmp > $@.tmp
	mv -v $@.1.tmp  $@.tm
	# powers of 2
	wc -l  $@.*tmp
	ls -al $@.*tmp
#---------------
# for Hugo Pfoertner 2020-09-23
# Determine a common factor beginning at the end of the term list. 
comfact: comfact1 comfact2 comfact3 comfact4
comfact1:
	$(RAMATH).sequence.CommonFactor -f $(COMMON)/stripped \
	>        $@.strip.txt
	head -n4 $@.strip.txt
	wc -l    $@.strip.txt
comfact2:
	cut -b1-7 comfact1.strip.txt     > $@.list.tmp
	$(RAMATH).sequence.CommonFactor -f $@.list.tmp -b $(COMMON)/bfile \
	| tee    $@.bf.txt
	head -n4 $@.bf.txt
	wc -l    $@.bf.txt
comfact3:
	$(DBAT) -f $(COMMON)/seq3.create.sql # aseqno, pattern, info
	cut -f1-3 comfact2.bf.txt \
	| $(DBAT) -r seq3 
	$(DBAT) -4 seq3
	$(DBAT) -n seq3
comfact4:
	$(DBAT) -f comfact.xml > comfact.html
comfact5:
	$(DBAT) "SELECT s.aseqno, s.pattern, s.info FROM seq3 s WHERE s.aseqno NOT IN (SELECT aseqno FROM joeis) ORDER BY 1" \
	| tee    $@.txt
	wc -l    $@.txt
comfact_deploy:
	scp comfact.html stylesheet.css javascript.js comfact2.bf.txt gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat
ASEQNO=A072143
comfact_test:
	$(RAMATH).sequence.CommonFactor -d 1 -a $(ASEQNO) -b $(COMMON)/bfile
comfact_t2b:
	$(RAMATH).sequence.CommonFactor -d $(D) -f x4x.tmp -b $(COMMON)/bfile
comfact_t2:
	$(RAMATH).sequence.CommonFactor -d $(D) -f x4x.tmp 
#---------------
known10:
	$(DBAT) -x -f miknown.xml -p minocc=914 -m tsv \
	| grep -E "^A[0-9]" \
	| tee $@.txt
	wc -l $@.txt
mine_bflong:
	perl mine_bflong.pl -k known10.txt bflong_thin.tmp \
	>      $@.tmp
	wc -l  $@.tmp
	ls -al $@.tmp
	sort   $@.tmp > $@.txt
mine_uniq:
	uniq -c mine_bflong.txt \
	| sort -k1rn -k2 > $@.tmp
	wc -l  $@.tmp
mine_sign:
	head -n 5000 mine_uniq.tmp \
	| perl bfdiff.pl -f - > $@.tmp
#--------------
milong: milong_load milong_html
milong_load:
	perl bfdiff.pl -c | tee milong.create.sql
	$(DBAT) -f              milong.create.sql
	grep -nE "^"  mine_sign.tmp \
	| sed -e "s/:/ /" -e "s/  */\t/g" \
	> $@.tmp
	$(DBAT) -s "\t" -m csv -r milong < $@.tmp
	$(DBAT) -x "DELETE FROM milong WHERE nsame < 256"
	$(DBAT) -4 milong
	$(DBAT) -n milong
milong_html:
	$(DBAT) -f milong.xml \
	> milong.html
miknown_html:
	$(DBAT) -f miknown.xml \
	> miknown.html
#--------------
deploy:
	mkdir -p                    $(TOMC)/spec/$(PROJECT)
	mkdir -p                    $(DBAD)/web/spec/$(PROJECT)
	cp -v *.xml *.xinc *.css    $(TOMC)/spec/$(PROJECT)
	cp -v *.xml *.xinc *.css    $(DBAD)/web/spec/$(PROJECT)
	scp milong.html stylesheet.css gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat
