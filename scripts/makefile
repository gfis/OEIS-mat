#!make

# OEIS-mat/scripts - shell scripts and Windows commands
# @(#) $Id$
# 2024-06-28, Georg Fischer; HFE<=>ST
#---------------------------------
GITS=../..
COMMON=$(GITS)/OEIS-mat/common
DATA=$(GITS)/OEIS-mat/data
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
D=0
#-------------
all: # all possible targets:
	grep -P "^\w[^\:]*\:" makefile | sort
#========
gitadd: makecmd # all all relevant source files, and makecmd
	find . | cut -b3-  | grep -vP "\." | xargs -l git add -v
	git add -v *.pl
#----
test: # PL= test a Perl script
	grep -P "^A\d{6}" $(PL).pl | perl $(PL).pl -d $(D) 2> $(PL).err | tee $(PL).tst
	head -n256 $(PL).err || :

histoeis: 
	cp -v "C:/Users/drgeo/AppData/Local/Google/Chrome/User Data/Default/History" .
	sqlite3.exe --readonly "History" ".mode tabs" \
	"select url, id \
	  from urls \
	  where url like 'https://oeis.org/A______' \
	  order by id desc limit 8;" \
	| tee -a $@.txt
	

