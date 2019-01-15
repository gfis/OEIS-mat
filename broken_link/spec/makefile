#!/usr/bin/make

# Dbat specifications for OEIS-mat/broken_link
# @(#) $Id
# 2019-01-02: OEIS-mat. removed from $(PROJECT)
# 2018-12-29, Georg Fischer

TOMC=c:/var/lib/tomcat/webapps/dbat
PROJECT=broken_link
DBAD=../../../../gits/dbat
DBAW=java -jar $(DBAD)/dist/dbat.jar -c worddb.properties  -e UTF-8
SRC=src/main/java/org/teherba/dbat
METHOD=get
TAB=brol

all: 
	# targets: deploy
	grep -E "^[a-z]" makefile
#-------------------------------------
dirs:
	ls -al                      $(TOMC)/spec/$(PROJECT)
	ls -al                      $(DBAD)/web/spec/$(PROJECT)
deploy:
	mkdir -p                    $(TOMC)/spec/$(PROJECT)
	mkdir -p                    $(DBAD)/web/spec/$(PROJECT)
	cp -v *.xml *.xinc *.css    $(TOMC)/spec/$(PROJECT)
	cp -v *.xml *.xinc *.css    $(DBAD)/web/spec/$(PROJECT)
#-------------------------------------
