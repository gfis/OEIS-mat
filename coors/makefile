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
WEIDIS= weidis

all: gather tile
#	echo select specific target 
#===============================================
gather: break extract extract_load count
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
	sed -e "s/\t/\tcoors\t0\t/" extract.tmp \
	| $(DBAT) -m csv -r coors
	$(DBAT) -4 coors
	$(DBAT) -n coors
count:
	perl tilings.pl extract.tmp \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
	cut -f 2 $@.tmp | sort -n | uniq -c \
	\
	| tee count_cut.tmp
#========
DIST=4
D=2
GAL=Gal.2.9
ID=1
GALID=$(GAL).$(ID)
NMAX=29061947
#--
tile: compile run
select:
	grep -E "$(GAL)\." extract.tmp | tee tiler.tst
compile:
	javac Tiler.java 
run: select
	java -cp . Tiler -id $(GALID) -dist $(DIST) -n $(NMAX) -d $(D) -svg test.svg -f tiler.tst  > test.tmp 
	grep -i assertion test.tmp || :
	grep -i distance  test.tmp || :
	wc -l test.svg    test.tmp 
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
