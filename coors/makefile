#!make

# OEIS-mat/coors - coordination sequences
# @(#) $Id$
# 2020-04-17, Georg Fischer: copied from ../weidis
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMJAR=$(GITS)/ramath/dist/ramath.jar 
RAMATH=java -cp  $(RAMJAR) org.teherba.ramath
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
MAXT=32
COMMON=../common
D=0 # debug mode

all: init gather tile
#	echo select specific target 
#================
init:
	mkdir bfile
	mkdir svg
	wget https://oeis.org/A250120/a250120.html
#----
gather: break extract extract_load count update_noflip
break:
	perl -pe "s{\<br\>}{\<br \/\>\n}g;" a250120.html > $@.tmp
	perl -pe \
	's{(.)(A\d{6})(.)}{\1\<a href=\"https://oeis.org/\2\" target=\"_blank\"\>\2\<\/a\>\3}g; '\
	's{\A\<b\>(Gal\.\d+\.\d+\.\d+)\:\s+(\d)}{\<a name\=\"$$1\" \/\>\n\<b\>$$1\: $$2};' \
	    $@.tmp > a250120.a.html
	tail -n16 a250120.a.html
extract: break
	perl extract_gal.pl break.tmp \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
extract_load:
	$(DBAT) -f coors.create.sql
	sed -e "s/\t/\tcoors\t0\t/" -e "s/Gal\.//" -e "s/\./,/" -e "s/\./\t/" -e "s/,/\./" extract.tmp \
	| $(DBAT) -m csv -r coors
	$(DBAT) -4 coors
	$(DBAT) -n coors
count:
	perl tilings.pl extract.tmp \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
	cut -f 2 $@.tmp | sort -n | uniq -c \
	| tee count_cut.tmp
update_noflip:
	grep -vE "[a-z]" count.tmp \
	>        noflip.tmp
	tail -n8 noflip.tmp
	wc -l    noflip.tmp
	$(DBAT) -f $(COMMON)/seq.create.sql
	cut -f1  noflip.tmp \
	| $(DBAT) -m csv -r seq
	$(DBAT) -v "UPDATE coors SET noflip='noflip' WHERE tileid IN (SELECT aseqno FROM seq);"
	$(DBAT) -16 coors
	$(DBAT) "SELECT COUNT(DISTINCT tileid) FROM coors WHERE noflip = 'noflip';"
#================
program:
	$(DBAT) -x "SELECT DISTINCT i.aseqno, c.tileid || '.' || c.galv, b.bfimin, b.bfimax, i.program \
	    , COALESCE(c.noflip, '-'), COALESCE(j.superclass, 'jnyi') \
	    FROM asinfo i, bfinfo b, coors c \
	    LEFT JOIN joeis j ON c.aseqno = j.aseqno \
	    WHERE i.aseqno = b.aseqno \
	      AND b.aseqno = c.aseqno \
	      AND ( b.bfimax > 50 OR LENGTH(i.program) > 0 \
	            OR i.aseqno IN (SELECT aseqno FROM cojec) \
	          ) \
	    ORDER BY 1" \
	>        $@.tmp
	head -n100 $@.tmp
	wc -l    $@.tmp
#================
DIST=4
D=0
GAL=2.9
ID=1
GALID=Gal.$(GAL).$(ID)
NMAX=29061947
SVG=-svg test.svg
BFILE=-bfile bfile/
SELECT=1
#----------------
select:
	grep -E "Gal\.$(GAL)\." extract.tmp | tee tiler.tst
#--
pave: compave pavr
compave:
	javac Paver.java 
pavr: select
	java -cp . Paver -id $(GALID) $(BFILE) -dist $(DIST) -n $(NMAX) -d $(D) $(SVG) -f tiler.tst > test.tmp 
	grep -i assertion test.tmp || :
	grep -i distance  test.tmp || :
	wc -l test.svg    test.tmp 
#--
tile: compile tilr
compile:
	javac Tiler.java 
tilr: select 
	java -cp . Tiler -id Gal.$(GAL).$(ID) $(BFILE) -dist $(DIST) -n $(NMAX) -d $(D) $(SVG) -f tiler.tst > test.tmp 
	grep -i assertion test.tmp || :
	grep -i distance  test.tmp || :
	wc -l test.svg    test.tmp 
run3:
	rm 3.44.txt
	java -cp . Tiler -id Gal.3.44.1 $(BFILE) -dist -1 -n $(NMAX) -d $(D) $(SVG) -f tiler.tst | tee -a 3.44.txt
	java -cp . Tiler -id Gal.3.44.2 $(BFILE) -dist -1 -n $(NMAX) -d $(D) $(SVG) -f tiler.tst | tee -a 3.44.txt
	java -cp . Tiler -id Gal.3.44.3 $(BFILE) -dist -1 -n $(NMAX) -d $(D) $(SVG) -f tiler.tst | tee -a 3.44.txt
#================
bf: select
	rm -vf temp/b*.txt
	java -cp . Tiler -id Gal.$(GAL).$(ID) -bfile temp/ -dist $(DIST) -n $(NMAX) -d $(D) -f tiler.tst 
	ls -tcr1 temp | tail -n1 \
	| xargs -l -i{} diff -wy --suppress-common-lines --width=40 "temp/{}" ../common/bfile > diff.log || :
	head -n16 diff.log
#================
verall:
	make verify SELECT=1
	make verify SELECT=2
	make verify SELECT=3
	make verify SELECT=4
	make verify SELECT=5
	make verify SELECT=6
verify:
	echo "all:" > $@.tmp
	grep -E "Gal\.$(SELECT)\." extract.tmp | cut -f 2 \
	| perl -ne 'm{\AGal\.(\d+\.\d+)\.(\d+)}; my ($$gal, $$id) = ($$1, $$2); print "\tmake verify1 GAL=$$gal ID=$$id\n"' \
	>>         $@.tmp
	tail -n4   $@.tmp
	wc -l      $@.tmp
	make -s -f $@.tmp | tee verify.$(SELECT).log
verify1: 
	grep -E "Gal\.$(GAL)\." extract.tmp > tiler.tst
	java -cp . Tiler -id Gal.$(GAL).$(ID) $(BFILE) -dist -1 -n $(NMAX) -d $(D) $(SVG) -f tiler.tst 
#================
bcheck:
	rm -f bcheck.log
	find bfile -iname "*.txt" | xargs -l -i{} make -s bcheck1 BF={}
bcheck1:
	head -n5 ../common/$(BF) | grep -vE "^ *\#" > x.tmp
	echo $(BF) >> bcheck.log
	diff -wy --suppress-common-lines --width=32 x.tmp $(BF) | head -n4 >> bcheck.log || :
#================
zip:
	zip coors.`date +%Y-%m-%d.%H`.zip *.java *.pl makefile test.svg test.tmp *.css
#================
# old targets
circle:
	java  -cp . Tiler -d 2 -m $(LEVEL) -svg $@.svg -circle 
#--------
test488:
	perl co488.pl -n $(MAXT) -d 0 \
	| tee    $@.tmp
recur3:
	$(DBAT) -x "SELECT s.aseqno, 'recur', i.offset1, s.info, d.data, d.termno, s.number \
		FROM seq3 s, asdata d, asinfo i \
		WHERE s.aseqno = d.aseqno \
		  AND s.aseqno = i.aseqno \
		  AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
		ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
