#!make

# OEIS-mat/robot - automatic preparation of parameters for the generation of Java programs for jOEIS
# @(#) $Id$
# 2023-05-01, Georg Fischer: start with ogf
#---------------------------------
GITS=../..
COMMON=$(GITS)/OEIS-mat/common
DATA=$(GITS)/OEIS-mat/data
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
RAMATH=java -cp  $(GITS)/ramath/dist/ramath.jar org.teherba.ramath
JCAT28=$(DATA)/jcat28.txt
JPREP=$(RAMATH).sequence.JoeisPreparer
PFRACT=java -cp  $(RAMATH).symbolic.PolyFraction
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
OEISDATA=$(GITS)/oeisdata
HERE=$(GITS)/OEIS-mat/robot
REMOTE=atair
NYI=perl $(COMMON)/nyi.pl -q
# set_env_var_REMOTE
#-------------
all: help
help:
	grep -E "^[a-z]" makefile
#========
#----
# simple formula a(n) = Aqseqno(n...) op Arseqno(n...)
anopan: anopan0 anopan1
	grep -P "\tanopan\t" anopan1.tmp \
	| grep -vE "A068310|A121835|A123538|A130911|A137851|A178467|A185246|A262348|A274996|A277078" \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
anopan0:
	grep -Pi "\= *A\d+\([^\)]+\) *([\+\-\*\/\^]|and|or|xor|xand|mod) *A\d+\([^\)]+\)" $(JCAT28) \
	| grep -E "^%[NF]" | cut -b 4- | sort | uniq -w7 | sed -e "s/ /\t/" \
	>        $@.tmp
	wc -l    $@.tmp
	make seq2 LIST=$@.tmp
	$(DBAT) -x "SELECT s.aseqno, 'anopan', i.offset1, REGEXP_SUBSTR(d.data, '[\-0-9]+(\,[\-0-9]+){8}'), s.info \
	  FROM seq2 s, asinfo i, asdata d \
	  WHERE s.aseqno = i.aseqno \
	    AND i.aseqno = d.aseqno \
	    ORDER BY 1" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
anopan1:
	perl $(COMMON)/anopan.pl anopan0.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	wc -l    $@.tmp $@.rest.tmp
	cut -f2  $@.tmp | sort | uniq -c
#----
binomx:
	grep -E "^%" $(JCAT28) | grep -P "[Bb]inomial transform of [^A]*A" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{transform of [^A]*(A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, binomx, 0, "$$rn", ",0", (($$line =~ m{Inverse binomial}i) ? ", true" : ", false"), $$line); } else { print "# $$line"; }}'\
	| tee    $@.gen
	wc -l    $@.gen
#----
charfun:
	grep -E "^%" $(JCAT28) | grep -P "Characteristic function of A" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{of (A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, charfun, 0, "$$rn", "", "", "", "", "", "") . "\n"; } else { print "# $$line"; }}'\
	| tee    $@.gen
	wc -l    $@.gen
#--------
convol: # convolution, convolved with or inverse
	grep -iP "convol" $(JCAT28) | grep -P "^\%[NFCY]" | grep -viP "Dirichlet|Exponential" | $(NYI) convprod \
	| perl convol.pl \
	2>       $@.rest.tmp \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.*
#----
diffseq:
	grep -E "^%" $(JCAT28) | grep -P "(First |Second |Third |)[Dd]ifferences of [^A]* A\d{6}" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{of [^A]*(A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, diffseq, 0, $$rn, $$line); } else { print "# $$line"; }}'\
	| grep -vE "Annnnnn" \
	| tee    $@.gen
	wc -l    $@.gen
#--------
dirichcon: # Dirichlet convolution or inverse
	grep -P "Dirichlet convolution of " $(JCAT28) | grep -P "^\%[NF]" | $(NYI) dirichcon \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/);'\
	' $$name =~ s{(A\d+)(\(n\))? with itself}{$$1 with $$1};'\
	' if ($$name =~ m{(A\d+)[^A]+(A\d+)}) { my ($$rn1, $$rn2) = ($$1, $$2);'\
	' print join("\t", $$aseqno, "dirichcon2", $$offset, "new $$rn1()", 1, "new $$rn2()", 1, $$name); }'\
	>        $@.gen
	grep -P "Dirichlet inverse of " $(JCAT28) | grep -P "^\%[NF]" | $(NYI) dirichinv \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/); '\
	' if ($$name =~ m{(A\d+)}) { my $$rn1 = $$1;'\
	' print join("\t", $$aseqno, $$callcode, $$offset, "new $$rn1()", 1, $$name); }'\
	>>       $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#--------
m1pow: # a(n) = (-1)^Annnnnn  or (-1)^n * Annnnnn
	grep -P "\A\%[NF] A\d+ a\(n\) *\= *\(\-\w+\)\^A\d+\(n\)"             $(JCAT28) | $(NYI) m1pow \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/);'\
	' if ($$name =~ m{(A\d+)}) { my $$rn = $$1;'\
	' print join("\t", $$aseqno, $$callcode, $$offset, $$rn, $$name); }'\
	>        $@.gen
	grep -P "\A\%[NF] A\d+ a\(n\) *\= *\(\-1\)\^n *\* *A\d+\(n\)[ \.\,]" $(JCAT28) | $(NYI) m1mul \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/); '\
	' if ($$name =~ m{(A\d+)}) { my $$rn = $$1;'\
	' print join("\t", $$aseqno, $$callcode, $$offset, $$rn, $$name); }'\
	>>       $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#--------
# Robot#1: Ordinary (rational) generating functions
ogf: ogf1 ogf2 
ogf1: # extract
	grep -E "%[SOFN]" $(JCAT28) \
	| perl catex_gf.pl -d 0 \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
ogf2: # use JPREP to generate (num, den) tuples for rational o.g.f.s 
	$(JPREP) -f ogf1.tmp \
	>        $@.tmp
	grep -E "fract1" $@.tmp | sed -e "s/fract1/lingf/" \
	| perl -ne 'my @f = split(/\t/); print if length($$f[4]) < 2048;' \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
	mv -v    $@.gen ogf.gen
	cp -v    ogf.gen ogf.`date +%Y-%m-%d`.gen
fract21:
	grep -E  "fract21" ogf2.tmp \
	| sed -e "s/fract21/trigf/" \
	>        $@.gen
	tail -n2 $@.gen
	wc -l    $@.gen
fract22:
	grep -E  "fract22" ogf2.tmp \
	| sed -e "s/fract22/trigf/" \
	>        $@.gen
	tail -n2 $@.gen
	wc -l    $@.gen
#----
parity:
	grep -iP "Parity of A\d+" $(JCAT28) | grep -P "^\%[NFCY]" | $(NYI) parity \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/); '\
	' if ($$name =~ m{(A\d+)}) { my $$rn1 = $$1;'\
	' print join("\t", $$aseqno, $$callcode, $$offset, "$$rn1", 1, $$name); }'\
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#--------
#----
partprod:
	grep -E "^%" $(JCAT28) | grep -P "Partial products of A" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{of (A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, partprod, 0, "", "", "new $$rn()", $$line); } else { print "# $$line"; }}'\
	| tee    $@.gen
	wc -l    $@.gen
#----
partsum:
	grep -E "^%" $(JCAT28) | grep -P "Partial sums of A" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{of (A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, partsum, 0, $$rn, "", "", $$line); } else { print "# $$line"; }}'\
	| tee    $@.gen
	wc -l    $@.gen
#----
reconcat: # extract recurrent concatenations from asdata
	$(DBAT) -x "SELECT d.aseqno, d.termno, d.data, SUBSTR(n.name, 1, 96) FROM asdata d, asname n WHERE d.aseqno = n.aseqno \
	  AND d.aseqno NOT IN (SELECT aseqno FROM joeis) \
	  AND UPPER(n.name) LIKE '%CONCATENAT%';"\
	| perl reconcat.pl \
	| tee    $@.tmp
	wc -l    $@.tmp
#----
rowsums:
	grep -E "^%" $(JCAT28) | grep -P "Row sums of [^A]* A\d{6}" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{of [^A]*(A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, rowsums, 0, $$rn, $$line); } else { print "# $$line"; }}'\
	| grep -vE "A253722|A325546" \
	| tee    $@.gen
	wc -l    $@.gen
#----
seqsum:
	# Sum of sequences with optional factors
	grep   -E "^%[NFC]" $(JCAT28) \
	| grep -P "^%[NFC] A\d+ (a\(\w\) *\=) *[\+\-]? *\(?\d+(\/\d+)?\)? *(\* *)?A\d+" \
	| perl seqsum.pl > $@.tmp 2> $@.rest.tmp
	wc -l $@*.tmp
	cat $@.tmp \
	| $(NYI) seqsum \
	| grep -vE "A133571|A134233|A134349" \
	| sort | uniq -w7 \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#----
triprod: 
	# Triangles that are products of 2 other triangles
	grep -E "^%[NF]" $(JCAT28) |  grep -P "A\d{6}(\^\(\-1\))? *\* *A\d{6}" | $(NYI) triprod \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/);'\
	' $$name =~ s{A000012(\^\(\-1\)| *\(signed)}{A097807}g;'\
	' $$name =~ s{A007318(\^\(\-1\)| *\(signed)}{A130595}g;'\
	' if ($$name =~ m{(A\d+)[^A]+(A\d+)}) { my ($$rn1, $$rn2) = ($$1, $$2);'\
	' print join("\t", $$aseqno, "triprod", $$offset, $$rn1, $$rn2, $$name); }'\
	| tee    $@.gen
	wc -l    $@.gen
	# tripro3: # Triangles that are products of 3 other triangles
	grep -E "^%[NF]" $(JCAT28) |  grep -P "A\d{6}(\^\(\-1\)| *\(signed\))? *\* A\d{6}(\^\(\-1\))? *\* *A\d{6}" | $(NYI) tripro3 \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/);'\
	' $$name =~ s{A000012(\^\(\-1\)| *\(signed)}{A097807}g;'\
	' $$name =~ s{A007318(\^\(\-1\)| *\(signed)}{A130595}g;'\
	' if ($$name =~ m{(A\d+)[^A]+(A\d+)[^A]+(A\d+)}) { my ($$rn1, $$rn2, $$rn3) = ($$1, $$2, $$3);'\
	' print join("\t", $$aseqno, "tripro3", $$offset, $$rn1, $$rn2, $$rn3, $$name); }'\
	| tee -a $@.gen
	wc -l    $@.gen
trisum: 
	# Triangles that are sums of other triangles
	grep -E "^%[NF]" $(JCAT28) | grep -P "(\d+ *\* *)?(I|A\d{6}) *[-\+] *(\d+ *\* *)?(I|A\d{6})" | $(NYI) trisum \
	| perl trisum.pl \
	| grep -vE "A133571|A134233|A134349" \
	| tee    $@.gen
	wc -l    $@.gen
#----
