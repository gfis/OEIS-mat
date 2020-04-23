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

all:
	echo select specific target 
#===============================================
gather: gather1 gather2
gather1:
	grep -iE "weight distribution" $(COMMON)/joeis_names.txt \
	| tee    $@.tmp
	wc -l    $@.tmp
	grep -v "full" $@.tmp | wc -l
	cd $(COMMON) ; make seq LIST=../$(WEIDIS)/$@.tmp
gather2:
	$(DBAT) -x "SELECT SUBSTR(s.aseqno, 2, 6) FROM seq s ORDER BY 1" \
	| sed -e "s/\r//" \
	| xargs -l -inn perl weight_dist.pl -s Ann -o Ann.wd.tmp $(COMMON)/bfile/bnn.txt 
#----
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
#--------
test488:
	perl co488.pl -n $(MAXT) -d 0 \
	| tee    $@.tmp
#--------
LEVEL=2
GAL=2.9
NMAX=29061947
tile: compile run
compile:
	javac       Tiler.java 
run:
	java  -cp . Tiler -d 2 -m $(LEVEL) -n $(NMAX) -svg $(GAL).svg -f tiler.$(GAL).tst 2> $(GAL).svg\
	| tee $(GAL).tmp
	perl svgen.pl -n $(NMAX) -w 4 $(GAL).tmp | tee $(GAL).b.svg
circle:
	java  -cp . Tiler -d 2 -m $(LEVEL) -svg $@.svg -circle 2> $@.svg
#	| tee $@.tmp
#	perl svgen.pl -w 2 $@.tmp | tee $@.svg
#================
# old targets
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
