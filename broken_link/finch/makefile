#!make

# for OEIS wiki concordance of Steven R. Finch's book "Mathematical Constants"
# @(#) $Id$
# 2019-04-19, Georg Fischer
#----------------
GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
#----

all: extract seq3 alist plist
#----
extract:
	# -e "s/\’/\'/g"
	perl finch_parse.pl Finch_Mathematical_Constants.xmls.html \
	| sed -e "s/´o/\&oacute\;/g" -e "s/´a/\&aacute\;/g" -e "s/¨o/\&\#337\;/g" \
	      -e "s/ϕ/\&phi;/g" -e "s/π/\&pi;/g" -e "s/\’/\&apos;/g" \
	>        $@.txt
	head -n4 $@.txt
	wc   -l  $@.txt
#----
seq3: # parameter: $(LIST)
	$(DBAT) -f seq3.create.sql
	cat extract.txt | grep -E "^A" | sort | uniq \
	| $(DBAT) -m csv -r seq3
	$(DBAT) -4 seq3
	$(DBAT) -n seq3
alist:
	$(DBAT) "SELECT ' ' || aseqno, pageno, section \
			FROM seq3 ORDER BY 1,2" \
	| sed -e "s/^/ /" > $@.txt
plist:
	$(DBAT) "SELECT ' ' || pageno, aseqno, section \
			FROM seq3 ORDER BY 1,2" \
	| sed -e "s/^/ /" > $@.txt
#----
dummy:
	head -n4 $@.txt
	wc -l    $@.txt
#----
