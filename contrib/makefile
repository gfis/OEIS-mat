#!make

# makefile for Gfis's OEIS contributions
# @(#) $Id$
# 2020-06-23: check, distrib
# 2019-10-27, Georg Fischer

GITS=../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
BFILE=$(COMMON)/bfile
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
SHIFT=+1
WIDTH=64
SLEEP=8
HEAD=16
OFFSET=0
#----------------
all:
	grep -E "^[a-z]" makefile
	# parameter S=seqno SLEEP=$(SLEEP) SHIFT=$(SHIFT) WIDTH=$(WIDTH)
#================
refresh:
	grep -E "^A[0-9]" refresh.list.man | cut -b2-7 \
	| xargs -l -innn make refresh1 S=nnn
refresh1: # S=012345, read into ./oeis.org/ and copy to ../common/bfile
	make SLEEP=2 wgeto
	make SLEEP=1 distrio
#--
wgeto: # S=012345, read into ./oeis.org/
	#--------------------------------
	wget -r "https://oeis.org/b$(S).txt" # do not include /A012345 
	ls -al   oeis.org/b$(S).txt
	wc -l    oeis.org/b$(S).txt
	head -n4 oeis.org/b$(S).txt
	sleep $(SLEEP)
shiftm: # shift -1
	make shifto SHIFT=-1
shiftp: # shift +1
	make shifto SHIFT=+1
shifto: # shift, from ./oeis.org/ to here
	perl ../bfcheck/bfclean.pl $(SHIFT) -f oeis.org/b$(S).txt b$(S).txt
	uedit64 b$(S).txt
#----
mma: # $(S), $(OFFSET); from program from clipboard, writes b-file into current directory
	powershell Get-Clipboard \
	| perl -ne 's{\s+\Z}{}; print "Print[$$_]\n"; ' \
	| tee mma.1.tmp
	perl -e 'print "A$(S)\t\t\n";' | tee mma.2.tmp
	perl $(COMMON)/callmma.pl -b -o $(OFFSET) -p mma.1.tmp mma.2.tmp | tee b$(S).txt
#	| perl -ne 's{\s+\Z}{}; print "(* <<SpecialFunctions` *)\n\n"; print "Print[$$_]\n"; ' \
#
#----
regen: # parameter S=012345
	echo "all: # for b$(S).txt" > $@.make.tmp
	$(DBAT) -x "SELECT '', 'cd $(FISCHER) ; make seqtest ASEQNO=A$(S)' \
	    || ' OFFSET=' || (SELECT bfimin              FROM bfinfo WHERE aseqno = 'A$(S)') \
	    || ' MAXT='   || (SELECT bfimax - bfimin + 1 FROM bfinfo WHERE aseqno = 'A$(S)') ;" \
	>>       $@.make.tmp
	cat      $@.make.tmp
	make -f  $@.make.tmp | grep -viE "^(cd|java|make)" > $@.bj.tmp
	head -n8 $@.bj.tmp
	wc -l    $@.bj.tmp
	$(DBAT) -x "SELECT '# A$(S) ' || name FROM asname WHERE aseqno = 'A$(S)';" \
	| sed -e "s/\'\'/\'/g" \
	>                     $@.bf.tmp
	cat      $@.bj.tmp >> $@.bf.tmp
	echo               >> $@.bf.tmp
	echo               >> $@.bf.tmp
	sed -e "s/\r//"       $@.bf.tmp > b$(S).txt
	tail -n4 b$(S).txt
	wc -l    b$(S).txt
regen2:
	make -f  regen.make.tmp | grep -viE "^(cd|java|make)" > b$(S).txt
#----
diffo: # S=012345, compare ./oeis.org/ with here
	diff -w -y --suppress-common-lines --width=$(WIDTH) oeis.org/b$(S).txt b$(S).txt | head -n$(HEAD)
check: diffo # S=012345
	grep -vE "^\#" oeis.org/b$(S).txt | sed -e "s/^[ \t]*[0-9][0-9]*[ \t]*//" > $@.old.tmp
	grep -vE "^\#"          b$(S).txt | sed -e "s/^[ \t]*[0-9][0-9]*[ \t]*//" > $@.new.tmp
	diff -w -y --suppress-common-lines --width=$(WIDTH) $@.old.tmp $@.new.tmp | head -n$(HEAD)
#----
distrib: # S=012345, copy from here to common/bfile
	cp -v          b$(S).txt                              $(COMMON)/bfile/
	scp            b$(S).txt gfis@atair:~/work/gits/OEIS-mat/common/bfile/
distrio: # S=012345, copy from ./oeis.org/ to common/bfile
	cp -v oeis.org/b$(S).txt                              $(COMMON)/bfile/
	scp   oeis.org/b$(S).txt gfis@atair:~/work/gits/OEIS-mat/common/bfile/
#----
getatair:
	grep -E "^A[0-9]" $(LIST) \
	| cut -b2-7 \
	| head -n22222 \
	| xargs -l -innn make getatair1 S=nnn
getatair1:
	scp gfis@atair:~/work/gits/OEIS-mat/common/bfile/b$(S).txt $(COMMON)/bfile/b$(S).txt
#-----------------
jallrest:
	cut -b2-7 $(FISCHER)/jallrest1.gen \
	| head -n22222 \
	| xargs -l -i{} make wgeto diffo distrio S={}
jall1:
	ls -1 oeis.org | perl -ne 'm{(\d+)}; print "$$1\n";' \
	| head -n22222 \
	| xargs -l -i{} make distrio S={}
#================
MAILBOX="C:/Users/User/AppData/Roaming/Thunderbird/Profiles/4yg92219.default/Mail/Local Folders/Hobby.sbd/seqfan.sbd/changes"
change:
	grep -E "published your |^From -" $(MAILBOX) \
	| perl -ne 'if (m{published}) { m{(A\d{6})}; print "$$1\n"; }' \
	| tee $@.tmp
#----------------
# ajson/A252769.json:				"Colin Barker, \u003ca href=\"/A252769/b252769.txt\"\u003eTable of n, a(n) for n = 1..557\u003c/a\u003e",
# ajson/A274975.json:				"Colin Barker, \u003ca href=\"/A274975/b274975.txt\"\u003eTable of n, a(n) for n = 0..1000\u003c/a\u003e",
colinb:
	perl -ne 'm{\/(A\d+)}; print "$$1\n";' colin-b-files.txt \
	>        $@.tmp
	make -f $(COMMON)/makefile seq LIST=$@.tmp
colinb_check:
	$(DBAT) "SELECT s.aseqno, b.bfimax, b.message \
	FROM  seq s, bfinfo b \
	WHERE s.aseqno = b.aseqno \
	 AND b.maxlen = 18 \
	ORDER BY 1;"  \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
#	 AND CAST(b.bfimax AS CHAR) NOT LIKE '%00' \
#----------------------------
b287182:
	echo "A287182	1" \
	| perl $(COMMON)/callmma.pl -b -o 1 -p A287182.tpat \
	>        $@.txt
	head -n8 $@.txt
	wc -l    $@.txt
#----------------------------
b288479:
	echo "A288479	1" \
	| perl $(COMMON)/callmma.pl -b -o 1 -p A288479.tpat \
	>        $@.txt
	head -n8 $@.txt
	wc -l    $@.txt
	# 
	diff --suppress-common-lines -wy $@.txt ../common/bfile/$@.txt | less
	# --suppress-common-lines
	# diff --suppress-common-lines -wy $@.txt $@.15.man | less
#----------------------------
b285658:
	echo "A285658	1" \
	| perl $(COMMON)/callmma.pl -b -o 1 -p A285658.tpat \
	>        $@.txt
	head -n8 $@.txt
	wc -l    $@.txt
	# 
	diff --suppress-common-lines -wy $@.txt ../common/bfile/$@.txt | less
	# --suppress-common-lines
	# diff --suppress-common-lines -wy $@.txt $@.15.man | less
#----------------------------
N=284792
N=284933
b1:
	echo "A$(N)	1" \
	| perl $(COMMON)/callmma.pl -b -o 1 -p A$(N).tpat \
	>        b$(N).txt
	head -n8 b$(N).txt
	wc -l    b$(N).txt
	# 
	diff --suppress-common-lines -wy b$(N).txt ../common/bfile/b$(N).txt | less
	# --suppress-common-lines
	# diff --suppress-common-lines -wy $@.txt $@.10.man | less
b2:
	head -n10017 b$(N).10.man > x.tmp
	cp x.tmp b$(N).txt
b3:
	diff --suppress-common-lines -wy b$(N).txt ../common/bfile/b$(N).txt | less
b4:
	cp -v b$(N).txt ../common/bfile/b$(N).txt
#----------------
tc4:
	echo "# A308681 International telephone country prefix codes in use as of June 2019, in lexicographic order." > $@.tmp
	echo "# Table of n, a(n) for n = 1..248" >> $@.tmp
	echo "# Georg Fischer, 16 Jun 2019, from https://en.wikipedia.org/wiki/List_of_country_calling_codes" >> $@.tmp
	sort -n telephone_codes.txt >> $@.tmp
	head -8 $@.tmp
#----------------
gettc:
	wget "https://en.wikipedia.org/wiki/List_of_country_calling_codes" -O b308681.raw
#----------------
karn:
	perl karn_reformat.pl a180g.mma > b180g.mma
	perl karn_reformat.pl a180h.mma > b180h.mma
	diff -wC0 b180h.mma b180g.mma

