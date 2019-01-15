#!/usr/bin/make

# Dbat specifications for OEIS-mat/bfcheck
# @(#) $Id
# 2019-01-15, Georg Fischer

TOMC=c:/var/lib/tomcat/webapps/dbat
PROJECT=bfcheck
DBAD=../../../../gits/dbat
DBAW=java -jar $(DBAD)/dist/dbat.jar -c worddb.properties  -e UTF-8
SRC=src/main/java/org/teherba/dbat
METHOD=get
TAB=bflink

all: deploy
	# targets: gen deploy
	# grep -E "^[a-z]" makefile
#-------------------------------------
dirs:
	ls -al                      $(TOMC)/spec/$(PROJECT)
	ls -al                      $(DBAD)/web/spec/$(PROJECT)
gen:
	cmd /C "dbat.cmd -f maxllen.xml" | grep -vE "java \-jar .." > ../maxllen.html
deploy:
	mkdir -p                    $(TOMC)/spec/$(PROJECT)
	mkdir -p                    $(DBAD)/web/spec/$(PROJECT)
	cp -v *.xml *.xinc *.css    $(TOMC)/spec/$(PROJECT)
	cp -v *.xml *.xinc *.css    $(DBAD)/web/spec/$(PROJECT)
