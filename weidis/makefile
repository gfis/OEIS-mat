#!make

# OEIS-mat/weidis - weight distributions
# @(#) $Id$
# 2020-04-14, Georg Fischer: copied from ../holrec
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
#--------
test1:
	# wget -N "https://oeis.org/b151939.txt"
	head -n1600 b151939.txt \
	| perl weight_dist.pl -s A151939 \
	| tee    $@.tmp
	grep -vE " 17" test1.tmp
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
