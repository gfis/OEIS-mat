#!make

# OEIS-mat/eta: eta, theta, psi & al. Ramanujan functions
# @(#) $Id$
# 2020-10-31, Georg Fischer: copied from ../weidis
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMJAR=$(GITS)/ramath/dist/ramath.jar 
RAMATH=java -cp  $(RAMJAR) org.teherba.ramath
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
NT=32
COMMON=../common
D=0 # debug mode
HERE=../../OEIS-mat/eta

all:
	echo select specific target 
#===============================================
somos_download:
	rm rama37.gp*
	wget http://grail.eecs.csuohio.edu/~somos/rama37.gp
	rm monster3.gp*
	wget http://grail.eecs.csuohio.edu/~somos/monster3.gp
rama37: rama37a rama37b
rama37a:
	perl -ne 'if (m{\\\\ *(A\d+)}) { print "$$1\n" }; ' rama37.gp \
	| sort | uniq -c \
	| tee    $@.tmp
	wc       $@.tmp
rama37b:
	cut -b9-15 rama37a.tmp > $@.tmp
	cd $(COMMON) ; make seq LIST=$(HERE)/$@.tmp
	$(DBAT) -x "SELECT s.aseqno, j.superclass FROM seq s LEFT JOIN joeis j ON s.aseqno = j.aseqno ORDER BY 1" \
	>        $@.tmp
	grep -E null $@.tmp
#----
monster3: monster3a monster3b
monster3a:
	perl -ne 'if (m{\A(\S+)\s*\\\\ *(A\d+)}) { print join("\t", $$2, $$1) . "\n" }; ' monster3.gp \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
monster3b:
	cd $(COMMON) ; make seq2 LIST=$(HERE)/monster3a.tmp
	$(DBAT) -x "SELECT s.aseqno, j.superclass, '', s.info FROM seq2 s LEFT JOIN joeis j ON s.aseqno = j.aseqno ORDER BY 1" \
	| sed -e "s/\r//" \
	>        $@.tmp
	grep -E null $@.tmp
#----
allmonst:
	grep -E "\\\\" monster3.gp
#----
ecalc: ein1sk # with spread
	perl ecalc.pl -d $(D) -s monster3.gp \
	| sort \
	>        $@.tmp 
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
# chk("T1a==in1([1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],2)");
ein1sk:
	cat monster3.gp \
	| perl -ne 'if (m{chk\(\"(\w+)\=\=in1\(\[[^\]]+\]\,(\d+)}) { print join("\t", $$1, $$2) . "\n"; }' \
	| grep -vE "_" \
	| sort | uniq -w5 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------------------------------
mckaylc:
	grep -E "McKay" $(COMMON)/asname.txt \
	| perl -ne 'if (m{(\d+[a-z])}) { print join("\t", substr($$_, 0, 7), "mckaylc", 0, $$1, substr($$_, 8)); }' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
etagf:
	grep "in powers of [a-z] where" $(COMMON)/jcat25.txt | grep -E "^\%" \
	| tee    $@.tmp
	wc -l    $@.tmp
	grep "Ramanujan" $@.tmp | wc -l
etasum:
	grep "Expansion of " $(COMMON)/jcat25.txt | grep -E "^\%" \
	| grep -P "\b(eta|theta_?3|theta_?4|psi|phi|chi|f)\b" \
	| grep -Pi "Ramanujan|Somos|Eisenstein" \
	| tee    $@.tmp
	wc -l    $@.tmp
	grep "Ramanujan" $@.tmp | wc -l
etaq:
	grep "Expansion of " $(COMMON)/jcat25.txt | grep -E "^\%[NFC]" \
	| grep -P "\(q(\^\-?\d+(\/\d+)?)?\)" \
	| cut -b4- \
	| tee    $@.tmp
	wc -l    $@.tmp
etaqpm:
	grep "Expansion of " $(COMMON)/jcat25.txt | grep -E "^\%[NFC]" \
	| grep -P "\(q(\^\-?\d+(\/\d+)?)?\)" \
	| grep -vE " \+ | \- " \
	| tee    $@.tmp
	wc -l    $@.tmp
#----
etaperiod:
	grep "Euler transform of " $(COMMON)/jcat25.txt | grep period | grep -E "^\%" \
	| tee    $@.tmp
	wc -l    $@.tmp
#----
etaprep: etaq
	cat etaq.tmp \
	| perl etaprep.pl \
	| tee    $@.tmp
	wc -l    $@.tmp
etaprod:
	cat etaprep.tmp \
	| perl $(COMMON)/callmap22.pl -t 4 -n 64 -p etaprod.mpat \
	>        $@.tmp
	grep -E "^A[0-9]*" $@.tmp \
	| perl norm_epsig.pl - \
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
#----
williams2:
	perl $@.pl | tee $@.tmp
#----
