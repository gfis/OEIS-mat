#!make

# OEIS-mat/coors - coordination sequences
# @(#) $Id$
# 2020-05-09: new format of a250120.html
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
HERE=$(GITS)/OEIS-mat/coors
MAXT=32
COMMON=../common
D=0 # debug mode

all: gather update
#   echo select specific target 
#================
init:
	mkdir bfile
	mkdir svg
wget:
	rm -f a250120.html
	wget https://oeis.org/A250120/a250120.html
#----
gather: break extract extract_load 
#   update_noflip
break:
	perl -pe "s{\<br\>}{\<br \/\>\n}ig;" a250120.html > $@.tmp
	perl -pe \
	's{(\<\/?)(\w+)}{"$$1" . lc($$2)}eg; '\
	's{\A\<b\>(Gal\.\d+\.\d+\.\d+)\:\s+(\d)}{\<a name\=\"$$1\" \/\>\n\<b\>$$1\: $$2}i;' \
	$@.tmp > a250120.a.html
	tail -n16 a250120.a.html
#   's{(.)(A\d{6})(.)}{\1\<a href=\"https://oeis.org/\2\" target=\"_blank\"\>\2\<\/a\>\3}g; '
extract:
	perl extract_gal.pl break.tmp \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
	grep "Gal.3.44.3" $@.tmp
extract_load:
	$(DBAT) -f coors.create.sql
	sed -e "s/\t/\tcoors\t0\t/" extract.tmp \
	| $(DBAT) -m csv -r coors
	$(DBAT) -4 coors
	$(DBAT) -n coors
check:
	$(DBAT) -x "SELECT aseqno, rseqno, galid, tilingno \
	  FROM coors \
	  WHERE aseqno <> rseqno \
	  ORDER BY 1" \
	| tee    $@.tmp
	wc -l    $@.tmp
#--------------------------------
guess: guess1 guess2
guess1:
	$(DBAT) -x "SELECT aseqno, galid, sequence \
	  FROM coors \
	  ORDER BY tilingno, galid" \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
guess2:
	head -n16000 guess1.tmp \
	| perl tilemaple.pl \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
#--------
# A310296 null    Coordination sequence Gal.6.52.1 where G.u.t.v
update: updano1 updano2 updano3 update_same update_man check_unk
updano1:
	grep Galebach ../common/joeis_names.txt \
	| perl -ne 'if (s{\A(A\d+)\t\w+\tCoordination sequence (Gal[\.\d]+) where.*}{$$1\t$$2}) { print; };' \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
updano2: # takes 57 s
	cd $(COMMON) ; make seq2 LIST=$(HERE)/updano1.tmp
	$(DBAT) -v "UPDATE coors c SET c.aseqno = 'unknown'"
	$(DBAT) -v "UPDATE coors c SET c.aseqno = \
	  COALESCE((SELECT s.aseqno FROM seq2 s WHERE c.galid = s.info), 'unkoeis')"
LEN=128
updano3:
	$(DBAT) -v "UPDATE coors c SET c.aseqno = c.rseqno WHERE EXISTS \
	  ( SELECT d.aseqno \
		FROM   asdata d \
		WHERE d.aseqno = c.rseqno \
		  AND SUBSTR(c.sequence, 1, (CASE WHEN LENGTH(d.data) < LENGTH(c.sequence) THEN LENGTH(d.data) ELSE LENGTH(c.sequence) END)) \
		   =  SUBSTR(d.data    , 1, (CASE WHEN LENGTH(d.data) < LENGTH(c.sequence) THEN LENGTH(d.data) ELSE LENGTH(c.sequence) END)) \
	  ) "
update_same:
	$(DBAT) -x "SELECT c.aseqno, c.galid, c.sequence \
	  FROM coors c\
	  ORDER BY 3, 1" \
	>        $@.1.tmp
	perl update_same.pl $@.1.tmp \
	>        $@.2.tmp
	head -n4 $@.2.tmp
	wc -l    $@.2.tmp
	grep UPDATE $@.2.tmp \
	>        $@.3.tmp || :
	head -n4 $@.3.tmp
	wc -l    $@.3.tmp
	$(DBAT) -f $@.3.tmp
	$(DBAT) -x "SELECT * FROM coors WHERE aseqno LIKE 'unk%' ORDER BY 1" \
	| tee    $@.4.tmp
	wc -l    $@.4.tmp
update_man:
	$(DBAT) -v -f update_same.man
#--------
allbf:
	rm -f bfile/b*.txt $@.log
	$(DBAT) -x "SELECT aseqno, galid, stdnot, vtype, tarots, sequence \
		, 'allbf.3 GAL=' || SUBSTR(galid, 1, LENGTH(galid) - 2) || ' ID=' || SUBSTR(galid, LENGTH(galid), 1) \
		FROM coors ORDER BY 1" \
	>        $@.1.tmp
	tail -n4 $@.1.tmp
	wc -l    $@.1.tmp
	cut -f7  $@.1.tmp > $@.2.tmp
allbf2:
	cat allbf.2.tmp | xargs -l make -s
allbf.3:
	grep -E "$(GAL)\." allbf.1.tmp | tee tiler.tst
	java -cp . Tiler -id $(GAL).$(ID) $(BFILE) -dist -1 -n $(NMAX) -d $(D) -f tiler.tst | tee -a $@.log
#--------
bigbf: bigbf1 bigbf2 bigbf4
bigbf1:
	$(DBAT) -x "SELECT c.aseqno, b.bfimax, c.galid \
		, 'bigbf3 ASEQNO=' || c.aseqno || ' GAL=' || SUBSTR(c.galid, 1, LENGTH(c.galid)-2) \
		|| ' ID=' || SUBSTR(c.galid, LENGTH(c.galid), 1) || ' DIST=' || \
		CAST(CASE WHEN b.bfimax > 1000 THEN 1000 ELSE b.bfimax END AS CHAR) \
	  FROM coors c, bfinfo b \
	  WHERE c.aseqno = b.aseqno \
		AND b.bfimax > 49 \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cut -f4  $@.tmp | sed -e "s/\r//" > bigbf2.tmp
#--
bigbf2:
	rm -rvf bigbfile bigbf*.log
	mkdir  bigbfile
	cat bigbf2.tmp | xargs -l make 
bigbf3:
	grep -E "$(GAL)." extract.tmp > tiler.tst
	# echo ASEQNO=$(ASEQNO) GAL=$(GAL) ID=$(ID) DIST=$(DIST)
	java -cp . Tiler -a $(ASEQNO) -id $(GAL).$(ID) -bfile bigbfile/ -dist $(DIST) -n $(NMAX) -d 0 -f tiler.tst | tee -a $@.log
bigbf4:
	find bigbfile -iname "b*.txt" | xargs -l -i{} make -s bigbf5 BF={}
bigbf5: # BF=
	echo $(BF)
	diff -wy --width=32 --suppress-common-lines $(BF) ../common/bfile | head -n4
#----
galist:
	$(DBAT) -x "SELECT aseqno        FROM coors ORDER BY tilingno, galid" > galist.1.txt
	$(DBAT) -x "SELECT aseqno, galid FROM coors ORDER BY tilingno, galid" > galist.2.txt
	head -n4 galist*
	wc -l    galist*
#--------
checkbf: 
	make -s checkbf1
	make -s patchbf DIG=2
	make -s checkbf1
	make -s patchbf DIG=1
	make -s checkbf1
checkbf1:
	$(DBAT) -x "SELECT c.aseqno, c.galid, c.sequence \
		FROM  coors c, asdata d \
		WHERE c.aseqno = d.aseqno \
		  AND SUBSTR(c.sequence, 1, (CASE WHEN LENGTH(d.data) < LENGTH(c.sequence) THEN LENGTH(d.data) ELSE LENGTH(c.sequence) END)) \
		   <> SUBSTR(d.data    , 1, (CASE WHEN LENGTH(d.data) < LENGTH(c.sequence) THEN LENGTH(d.data) ELSE LENGTH(c.sequence) END)) \
		ORDER BY 1, 2" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
patchbf: # DIG=
	$(DBAT) "UPDATE coors SET sequence = '$(DIG)' || SUBSTR(sequence, 2, LENGTH(SEQUENCE) - 1) \
		WHERE galid = 'Gal.1.1.1'"
#--------
list:
	$(DBAT) "SELECT tilingno, galid, stdnot, vtype, tarots, aseqno, sequence \
		FROM coors ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
checkano:
	$(DBAT) -x "SELECT c.aseqno, c.galid, c.rseqno, c.tilingno \
	  , SUBSTR(c.sequence, 1, $(LEN)), SUBSTR(d.data, 1, $(LEN)) \
	  FROM  coors c, asdata d \
	  WHERE r.aseqno = d.aseqno \
		AND SUBSTR(c.sequence, 1, $(LEN)) <> SUBSTR(d.data, 1, $(LEN)) \
	  ORDER BY 2" \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
checkun:
	$(DBAT) -x "SELECT c.aseqno, c.galid, c.rseqno, c.tilingno, b.bfimax \
	  , c.sequence \
	  , '#' \
	  , SUBSTR(d.data    , 1, LENGTH(c.sequence)) \
	  , '#' \
	  , n.name \
	  , '#' \
	  FROM coors c, bfinfo b, asdata d, asname n \
	  WHERE c.aseqno LIKE 'unk%' \
		AND c.rseqno = b.aseqno \
		AND c.rseqno = d.aseqno \
		AND c.rseqno = n.aseqno \
	  ORDER BY 4, 2" \
	| sed -e "s/#/\nOEIS\t\t\t\t\t/g" \
	>        $@.tmp
	head -n4 $@.tmp
	grep unk $@.tmp \
	| wc -l 
check2:
	$(DBAT) -x "SELECT * FROM seq2 ORDER BY 2" \
	| perl check2.pl 2> check2.missing.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
check2un:
	cut -f1 check2.missing.tmp      | sort \
	>        $@.1.tmp
	grep unk checkun.tmp | cut -f2  | sort \
	>        $@.2.tmp
	diff -wy --width=32 $@.1.tmp $@.2.tmp \
	| tee    $@.3.tmp
	grep -vE "[\<\>]" $@.3.tmp \
	>        $@.4.tmp
	wc l     $@.*
check_unk:
	$(DBAT) "SELECT aseqno, galid, tilingno, rseqno, SUBSTR(sequence, 1, 64) FROM coors WHERE aseqno LIKE 'unk%'"
#----
lshow:
	$(DBAT) -x "SELECT galid, stdnot, vtype, tilingno \
	    FROM coors\
	    ORDER BY tilingno, galid" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
l2a:
	perl letter2angle.pl unmarked_codes-1.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	# | sort -k7 -k2 
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
DIST=8
D=0
GAL=2.9
ID=1
GALID=Gal.$(GAL).$(ID)
NMAX=29061947
SVG=-svg Test.svg
BFILE=-bfile bfile/
BFILP=-bfile bfilp/
SELECT=1
TILTES=java -cp . TilingTest
#----------------
select:
	grep -E "Gal\.$(GAL)\." extract.tmp > $@.tst
	# cp -v select.man $@.tst
test: test1 test2
test1: compile1 run1
test2: compile2 run2
compile: compile1 compile2
compile1:
	javac Tiler1.java 
compile2:
	javac TilingTest.java 
#----
run: run1 run2
run1: select
	java -cp . Tiler1     -id Gal.$(GAL).$(ID) -bfile $@/   -dist $(DIST) -n $(NMAX) -d $(D) -svg $@.svg -f select.tst > $@.tmp 
	grep -i assertion $@.tmp || :
EDGE=
POLY=
OPER=net
run2: 
	#---------------- 
	$(TILTES) -id Gal.$(GAL).$(ID) -$(OPER)     -dist $(DIST) $(EDGE) $(POLY) -d $(D) -svg $@.svg -f select.tst | tee $@.tmp 
	grep -i assertion $@.tmp || :
	ls -tc1r run2/* | tail -n1 | cut -b6- \
	| xargs -l -i{} diff -wy --suppress-common-lines run1/{} run2/{} || :
	# ls -tclr *.svg run2/*
rub2: select
	#---------------- 
	$(TILTES) -id Gal.$(GAL).$(ID) -bfile rub2/ -dist $(DIST) $(EDGE) $(POLY) -d $(D)             -f select.tst > $@.tmp 
	grep -i assertion $@.tmp || :
	ls -tc1r rub2/* | tail -n1 | cut -b6- \
	| xargs -l -i{} diff -wy --suppress-common-lines run1/{} rub2/{} || :
	ls -tclr rub2/*
#----
WID=80
notae: select
	$(TILTES) -notae -f select.tst | tee notae0.tmp | cut -b1-$(WID)
	# grep -E "^A[0-9][0-9]*	Gal" select.tst  | tee notae0.tmp | cut -b1-$(WID)
	perl notae.pl -e notae0.tmp              | tee nota.tmp   | cut -b1-$(WID)
	perl notae.pl -a notae0.tmp              | tee note.tmp   | cut -b1-$(WID)
	#........
	$(TILTES) -notae -f nota.tmp | tee notae1.tmp | cut -b1-$(WID)
	diff -wC0 notae0.tmp notae1.tmp || :
	#........                                   
	$(TILTES) -notae -f note.tmp | tee notae2.tmp | cut -b1-$(WID)
	diff -wC0 notae0.tmp notae2.tmp || :
#----
single:
	java -cp . TilingSequence -dist $(DIST) -id $(ID) $(EDGE) $(POLY) -d $(D) 2> x.tmp | tee $@.tmp
#----
speed: speed1 speed2
speed1: select
	java -cp . Tiler1     -id Gal.$(GAL).$(ID) -dist $(DIST) -n $(NMAX) -d 0 -f select.tst 
speed2: select
	$(TILTES) -id Gal.$(GAL).$(ID) -dist $(DIST)            -d 0 -f select.tst
#----
newn: 
	make newna | grep -E "tiler" | tee $@1.tmp
	make newne | grep -E "tiler" | tee $@2.tmp
	diff -wC0 $@1.tmp $@2.tmp || :
newna: 
	perl notation.pl    | tee $@.tmp
	java -cp . Tiler1 -dist $(DIST)  -f $@.tmp
newne: select
	perl notation.pl -e | tee $@.tmp
	java -cp . Tiler1 -dist $(DIST)  -f $@.tmp
#-----------------
pave: compave pavr
compave:
	javac Paver.java 
pavr: selecp
#--
tile: compile tilr
tilr: select 
	java -cp . Tiler -id Gal.$(GAL).$(ID) $(BFILE) -dist $(DIST) -n $(NMAX) -d $(D) $(SVG) -f tiler.tst > test.tmp 
	grep -i assertion test.tmp || :
	head -n4 test.tmp
	wc -l    test.tmp 
#----
#----
tils: select 
	java -cp . Tiler -id Gal.$(GAL).$(ID) -dist $(DIST) -n $(NMAX) -d $(D) -f tiler.tst
run3:
	rm 3.44.txt
	java -cp . Tiler -id Gal.3.44.1 $(BFILE) -dist -1 -n $(NMAX) -d $(D) $(SVG) -f tiler.tst | tee -a 3.44.txt
	java -cp . Tiler -id Gal.3.44.2 $(BFILE) -dist -1 -n $(NMAX) -d $(D) $(SVG) -f tiler.tst | tee -a 3.44.txt
	java -cp . Tiler -id Gal.3.44.3 $(BFILE) -dist -1 -n $(NMAX) -d $(D) $(SVG) -f tiler.tst | tee -a 3.44.txt
runold: select
	java -cp . Tiler -id $(GALID)   $(BFILE) -dist -1 -n $(NMAX) -d $(D) $(SVG) -f tiler.tst 
deploy:
	scp *est.svg tiling.css gfis@teherba.org:/var/www/html/teherba.org/OEIS-mat/coors
#================
test_mma:
	echo "Print[InputForm[Simplify[(x-1)^2*(x^6+x^5+x^4+x^3+x^2+x+1)^2]]];" > test.mma
	scp test.mma pi@piras:
	ssh pi@piras 'cat test.mma | wolfram -noinit > out.tmp'
	scp pi@piras:out.tmp .
	cat out.tmp
#================
cenall: # compute all central sequences
	$(TILTES) -central -e 0 -dist $(DIST) -d $(D) -f extract.tmp > $@.$(DIST).txt
	head -n4 $@.$(DIST).txt
	wc -l    $@.*.t*
cendiv:
	# remove aseqno, callcode, offset; keep galid, vertexid, edge=-1, substr(seq, 2)
	cut -f1- cenall.128.txt \
	>        $@.tmp
	make divall LIST=$@.tmp
	mv divall.tmp $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
#--
cens:
	sort -k2 -k1 central.tmp > central.sort
cenu:
	cut -f2 central.sort | uniq -c | sort -rn > $@.tmp
cenguess:
	perl callmaple.pl -p guessgf.mpat central.128.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
#================
netall: # compute all coordination sequences
	rm -f $@.$(DIST).txt
	head -n$(NMAX) extract.tmp > $@.in.tmp
	$(TILTES) -net -dist $(DIST) -d $(D) -f $@.in.tmp >> $@.$(DIST).txt
	head -n4 $@.$(DIST).txt
	wc -l    $@.$(DIST).txt
#----
netdiv:
	# remove aseqno, callcode, offset; keep galid, edge=-1, vertexid, substr(seq, 2)
	cut -f4- netall.128.txt \
	| perl -ne 'my @parts = split(/\t/); $$parts[2] = substr($$parts[2], 2); $$parts[0] .= "\t-1"; print join("\t", @parts);' \
	>        $@.tmp
	make divall LIST=$@.tmp
	mv divall.tmp $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
#----
divall:
	perl divall.pl -c 4 $(LIST)\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cut -f1  $@.tmp \
	| sort | uniq -c
#----
diveval: # input is gcd, galid, edge, vertexid, seq
	cat netdiv.tmp cendiv.tmp \
	| grep -vE "1=gcd" \
	| gawk '{ print $$2, $$3, $$4, $$1, $$5 }' | sort \
	| perl -ne 's{\A(Gal\.\d+\.\d+)\.}{$$1\t}; print; '\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cut -f1  $@.tmp | sort | uniq -c > $@.2.tmp
	head -n4 $@.2.tmp
	wc -l    $@.2.tmp
divmiss:
	cut -b9- diveval.2.tmp \
	| perl missing.pl \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#---#----
guessall:
	perl tilemaple.pl runall.tmp | tee $@.tmp
#================
map256:
	sed -e "s/\[/ogf\t0\t/" -e "s/\, *ogf\]//" -e "s/\r//" guessall.tmp > $@.1.tmp
	head -n4 $@.1.tmp
	perl runmaple.pl $@.1.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp 
diff256:
	rm -v $@.*tmp
	sed -e "s/\[/tiler\t0\t/" -e "s/\, */\,/g" -e "s/\]//" map256.tmp > $@.1.tmp
	head -n2 $@.1.tmp
	diff -wy --width=128 --suppress-common-lines runall.256.tmp $@.1.tmp \
	>        $@.tmp || : 
	head -n4 $@.tmp
	wc -l    $@.tmp 
denom:
	cat guessall.tmp \
	| perl -ne 'm{^(A\d+)\t\[(....)[^\/]+\/([^\,]+)}; print "$$1\t$$2\t$$3\n";' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp 
#================
# A008486   Gal.1.1.1   [-(x^2+x+1)/(-x^2+2*x-1), ogf]
# A024313   lingfo  0   (-3+2*x^7+3*x^5+x^4-4*x^3+2*x^2)/((x^2+x-1)*(x^4+x^2-1)^2)  ogf Gal.1.2.3
#   sed -e "s/\[/lingfo\t0\t/" -e "s/\, *ogf\]/\togf/" -e "s/\r//" guessall.128.txt 
#   | perl -ne 'if (length($$_) < 2048) { print; }' 
tilegf:
	perl -ne 's{\s+\Z}{}; my ($$aseqno, $$galid, $$fract) = split(/\t/); '\
	'$$fract =~ s{\[}{}; $$fract =~ s{\, *ogf\]}{}; '\
	'print join("\t", $$aseqno, "lingfo", 0, $$fract, "ogf", "oldfract", $$galid) . "\n"; ' guessall.tmp \
	>        $@.1.tmp
	head -n4 $@.1.tmp
	wc   -l  $@.1.tmp
	$(RAMATH).sequence.JoeisPreparer -f $@.1.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@*.tmp
#----
evalgf:
	perl evalgf.pl tilegf.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
	# cut -f2-4  $@.tmp \
	# | sort | uniq -c
evalgf2:
	cut -f2,6 evalgf.tmp \
	| sort | uniq -c | tee $@.tmp
	wc -l $@.tmp
evalgf_load:
	$(DBAT) -f coogf.create.sql
	cat evalgf.tmp \
	| $(DBAT) -m csv -r coogf
	$(DBAT) -4 coogf
	$(DBAT) -n coogf
denpoly:
	perl denpoly.pl evalgf.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
densimplify:
	perl callmaple.pl -p factor.mpat denpoly.tmp \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
densimma1:
	perl callmma.pl -p Simplify.tpat denpoly.tmp \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
densimma2:
	perl callmma.pl -p FactorList.tpat denpoly.tmp \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
# perl -ne "print if m{\t\(\-1 \+ x\^\d+\)\^2\n}" densimma.simplify.man
GCD=
denfactor:
	perl denfactor.pl $(GCD) densimplify.tmp \
	| sort | uniq -c | sort -rn > $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
demfactor:
	perl demfactor.pl densimma2.tmp \
	| sort | uniq -c | sort -rn > $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
decr_factor:
	perl callmaple.pl -p $@.mpat denpoly.tmp \
	| grep -E "^A[0-9]" \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
incr_factor:
	perl callmaple.pl -p $@.mpat denpoly.tmp \
	| grep -E "^A[0-9]" \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
decr_uniq:
	perl denfactor.pl $(GCD) decr_factor.tmp \
	| sort | uniq -c \
	| perl -pe 's{x\^(\d+)}{x\^ \1 };' \
	| sort -k3n -k4 \
	| perl -pe 's{x\^ (\d+) }{x\^\1};' \
	> $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
#================
bf: select
	rm -vf temp/b*.txt
	java -cp . Tiler -id Gal.$(GAL).$(ID) -bfile temp/ -dist -1 -n $(NMAX) -d $(D) -f tiler.tst 
	ls -tcr1 temp | tail -n1 \
	| xargs -l -i{} diff -wy --suppress-common-lines --width=40 "temp/{}" ../common/bfile > diff.log || :
	head -n4 diff.log
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
	java -cp . Tiler -id Gal.$(GAL).$(ID) -dist $(DIST) -n $(NMAX) -d $(D) -f tiler.tst > test.tmp
	grep -i assertion test.tmp || :
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
	zip coors.`date +%Y-%m-%d.%H`.zip *.java *.pl makefile Test.svg test.tmp *.css
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
