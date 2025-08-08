#!make

# OEIS-mat/data - extraction from repositories
# @(#) $Id$
# 2025-03-26: git reset --hard HEAD
# 2023-06-17: compile-internal
# 2023-05-02: Georg Fischer
#
# from https://github.com/oeis/oeisdata        - sequence in internal format and b-files
#  and https://github.com/archmageirvine/joeis - Java programs
#---------------------------------
GITS=../..
COMMON=../common
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
HERE=../OEIS-mat/data
JOEIS=$(GITS)/joeis
FISCHER=$(GITS)/joeis-lite/internal/fischer
OEISDATA=$(GITS)/oeisdata
REM=set_environment_variable_REMOTE_to_g@a
REMDIR=$(REM):~/work/gits/OEIS-mat/data
SLEEP=8
D=0
#-------------
all: remote
help:
	grep -E "^[a-z]" makefile
#==============================
# the following are to be used on the remote server
#----
# Download stripped.gz, names.gz, bfilelist.gz
oprep_down: oprep1 oprep2 oprep3 oprep_pack
oprep1:
	rm -f stripped*
	wget https://oeis.org/stripped.gz
	gzip -df  stripped.gz
	cp -pv    stripped  $(COMMON)
	sleep $(SLEEP)
oprep2:
	rm -f names*
	wget https://oeis.org/names.gz
	gzip -df  names.gz
	cp -pv    names     $(COMMON)
	sleep $(SLEEP)
oprep3:
	rm -f bfilelist*
	wget https://oeis.org/bfilelist.gz
	gzip -df  bfilelist.gz
	cp -pv    bfilelist $(COMMON)
oprep_pack:
	tar -czvf $@.tgz stripped names bfilelist
	ls -al
#----
catex_down: oeisdata_pull cat28 tinfo catex_pack
tinfo_down:                     tinfo catex_pack
#--
oeisdata_pull: # update the OEIS git repository
	cd $(OEISDATA) ; git reset --hard HEAD ; git pull 
oeisdata_fillxxx: # SUB= replace b-file pointers by their content
	find ../../oeisdata/files/$(RANGE) -maxdepth 1 -type d | xargs -innn make -s oeisdata_fill1 SUB=nnn
oeisdata_fill: # SUB=
	cd $(OEISDATA) ; pwd                           ; \
	echo "git lfs fetch -X= -I=files/$(SUB)/b??????.txt" ; \
	      git lfs fetch -X= -I=files/$(SUB)/b??????.txt  ; \
	echo "git lfs checkout     files/$(SUB)/b??????.txt" ; \
	      git lfs checkout     files/$(SUB)/b??????.txt  ;  
odnnn5:
	make oeisdata_fill SUB=A359
	make oeisdata_fill SUB=A358
	make oeisdata_fill SUB=A357
	make oeisdata_fill SUB=A356
	make oeisdata_fill SUB=A355
	make oeisdata_fill SUB=A354
	make oeisdata_fill SUB=A353
	make oeisdata_fill SUB=A352
	make oeisdata_fill SUB=A351
	make oeisdata_fill SUB=A350
	#
	make oeisdata_fill SUB=A349
	make oeisdata_fill SUB=A348
	make oeisdata_fill SUB=A347
	make oeisdata_fill SUB=A346
	make oeisdata_fill SUB=A345
	make oeisdata_fill SUB=A344
	make oeisdata_fill SUB=A343
	make oeisdata_fill SUB=A342
	make oeisdata_fill SUB=A341
	make oeisdata_fill SUB=A340
od3:
	make oeisdata_fill SUB=A339
	make oeisdata_fill SUB=A338
	make oeisdata_fill SUB=A337
	make oeisdata_fill SUB=A336
	make oeisdata_fill SUB=A335
	make oeisdata_fill SUB=A334
	make oeisdata_fill SUB=A333
	make oeisdata_fill SUB=A332
	make oeisdata_fill SUB=A331
	make oeisdata_fill SUB=A330
	make oeisdata_fill SUB=A329
	make oeisdata_fill SUB=A328
	make oeisdata_fill SUB=A327
	make oeisdata_fill SUB=A326
	make oeisdata_fill SUB=A325
	make oeisdata_fill SUB=A324
	make oeisdata_fill SUB=A323
	make oeisdata_fill SUB=A322
	make oeisdata_fill SUB=A321
	make oeisdata_fill SUB=A320
od1:
	make oeisdata_fill SUB=A319
	make oeisdata_fill SUB=A318
	make oeisdata_fill SUB=A317
	make oeisdata_fill SUB=A316
	make oeisdata_fill SUB=A315
	make oeisdata_fill SUB=A314
	make oeisdata_fill SUB=A313
	make oeisdata_fill SUB=A312
	make oeisdata_fill SUB=A311
	make oeisdata_fill SUB=A310
	make oeisdata_fill SUB=A309
	make oeisdata_fill SUB=A308
	make oeisdata_fill SUB=A307
	make oeisdata_fill SUB=A306
	make oeisdata_fill SUB=A305
	make oeisdata_fill SUB=A304
	make oeisdata_fill SUB=A303
	make oeisdata_fill SUB=A302
	make oeisdata_fill SUB=A301
	make oeisdata_fill SUB=A300
od29:
	make oeisdata_fill SUB=A299
	make oeisdata_fill SUB=A298
	make oeisdata_fill SUB=A297
	make oeisdata_fill SUB=A296
	make oeisdata_fill SUB=A295
	make oeisdata_fill SUB=A294
	make oeisdata_fill SUB=A293
	make oeisdata_fill SUB=A292
	make oeisdata_fill SUB=A291
	make oeisdata_fill SUB=A290
	make oeisdata_fill SUB=A289
	make oeisdata_fill SUB=A288
	make oeisdata_fill SUB=A287
	make oeisdata_fill SUB=A286
	make oeisdata_fill SUB=A285
	make oeisdata_fill SUB=A284
	make oeisdata_fill SUB=A283
	make oeisdata_fill SUB=A282
	make oeisdata_fill SUB=A281
	make oeisdata_fill SUB=A280
	make oeisdata_fill SUB=A279
	make oeisdata_fill SUB=A278
	make oeisdata_fill SUB=A277
	make oeisdata_fill SUB=A276
	make oeisdata_fill SUB=A275
	make oeisdata_fill SUB=A274
	make oeisdata_fill SUB=A273
	make oeisdata_fill SUB=A272
	make oeisdata_fill SUB=A271
	make oeisdata_fill SUB=A270
	make oeisdata_fill SUB=A269
	make oeisdata_fill SUB=A268
	make oeisdata_fill SUB=A267
	make oeisdata_fill SUB=A266
	make oeisdata_fill SUB=A265
	make oeisdata_fill SUB=A264
	make oeisdata_fill SUB=A263
	make oeisdata_fill SUB=A262
	make oeisdata_fill SUB=A261
	make oeisdata_fill SUB=A260
od25:
	make oeisdata_fill SUB=A259
	make oeisdata_fill SUB=A258
	make oeisdata_fill SUB=A257
	make oeisdata_fill SUB=A256
	make oeisdata_fill SUB=A255
	make oeisdata_fill SUB=A254
	make oeisdata_fill SUB=A253
	make oeisdata_fill SUB=A252
	make oeisdata_fill SUB=A251
	make oeisdata_fill SUB=A250
	make oeisdata_fill SUB=A249
	make oeisdata_fill SUB=A248
	make oeisdata_fill SUB=A247
	make oeisdata_fill SUB=A246
	make oeisdata_fill SUB=A245
	make oeisdata_fill SUB=A244
	make oeisdata_fill SUB=A243
	make oeisdata_fill SUB=A242
	make oeisdata_fill SUB=A241
	make oeisdata_fill SUB=A240
od23:
	make oeisdata_fill SUB=A239
	make oeisdata_fill SUB=A238
	make oeisdata_fill SUB=A237
	make oeisdata_fill SUB=A236
	make oeisdata_fill SUB=A235
	make oeisdata_fill SUB=A234
	make oeisdata_fill SUB=A233
	make oeisdata_fill SUB=A232
	make oeisdata_fill SUB=A231
	make oeisdata_fill SUB=A230
	make oeisdata_fill SUB=A229
	make oeisdata_fill SUB=A228
	make oeisdata_fill SUB=A227
	make oeisdata_fill SUB=A226
	make oeisdata_fill SUB=A225
	make oeisdata_fill SUB=A224
	make oeisdata_fill SUB=A223
	make oeisdata_fill SUB=A222
	make oeisdata_fill SUB=A221
	make oeisdata_fill SUB=A220
	make oeisdata_fill SUB=A219
	make oeisdata_fill SUB=A218
	make oeisdata_fill SUB=A217
	make oeisdata_fill SUB=A216
	make oeisdata_fill SUB=A215
	make oeisdata_fill SUB=A214
	make oeisdata_fill SUB=A213
	make oeisdata_fill SUB=A212
	make oeisdata_fill SUB=A211
	make oeisdata_fill SUB=A210
	make oeisdata_fill SUB=A209
	make oeisdata_fill SUB=A208
	make oeisdata_fill SUB=A207
	make oeisdata_fill SUB=A206
	make oeisdata_fill SUB=A205
	make oeisdata_fill SUB=A204
	make oeisdata_fill SUB=A203
	make oeisdata_fill SUB=A202
	make oeisdata_fill SUB=A201
	make oeisdata_fill SUB=A200

od19:
	make oeisdata_fill SUB=A199
	make oeisdata_fill SUB=A198
	make oeisdata_fill SUB=A197
	make oeisdata_fill SUB=A196
	make oeisdata_fill SUB=A195
	make oeisdata_fill SUB=A194
	make oeisdata_fill SUB=A193
	make oeisdata_fill SUB=A192
	make oeisdata_fill SUB=A191
	make oeisdata_fill SUB=A190
	make oeisdata_fill SUB=A189
	make oeisdata_fill SUB=A188
	make oeisdata_fill SUB=A187
	make oeisdata_fill SUB=A186
	make oeisdata_fill SUB=A185
	make oeisdata_fill SUB=A184
	make oeisdata_fill SUB=A183
	make oeisdata_fill SUB=A182
	make oeisdata_fill SUB=A181
	make oeisdata_fill SUB=A180
	make oeisdata_fill SUB=A179
	make oeisdata_fill SUB=A178
	make oeisdata_fill SUB=A177
	make oeisdata_fill SUB=A176
	make oeisdata_fill SUB=A175
	make oeisdata_fill SUB=A174
	make oeisdata_fill SUB=A173
	make oeisdata_fill SUB=A172
	make oeisdata_fill SUB=A171
	make oeisdata_fill SUB=A170
	make oeisdata_fill SUB=A169
	make oeisdata_fill SUB=A168
	make oeisdata_fill SUB=A167
	make oeisdata_fill SUB=A166
	make oeisdata_fill SUB=A165
	make oeisdata_fill SUB=A164
	make oeisdata_fill SUB=A163
	make oeisdata_fill SUB=A162
	make oeisdata_fill SUB=A161
	make oeisdata_fill SUB=A160
	make oeisdata_fill SUB=A159
	make oeisdata_fill SUB=A158
	make oeisdata_fill SUB=A157
	make oeisdata_fill SUB=A156
	make oeisdata_fill SUB=A155
	make oeisdata_fill SUB=A154
	make oeisdata_fill SUB=A153
	make oeisdata_fill SUB=A152
	make oeisdata_fill SUB=A151
	make oeisdata_fill SUB=A150
	make oeisdata_fill SUB=A149
	make oeisdata_fill SUB=A148
	make oeisdata_fill SUB=A147
	make oeisdata_fill SUB=A146
	make oeisdata_fill SUB=A145
	make oeisdata_fill SUB=A144
	make oeisdata_fill SUB=A143
	make oeisdata_fill SUB=A142
	make oeisdata_fill SUB=A141
	make oeisdata_fill SUB=A140
	make oeisdata_fill SUB=A139
	make oeisdata_fill SUB=A138
	make oeisdata_fill SUB=A137
	make oeisdata_fill SUB=A136
	make oeisdata_fill SUB=A135
	make oeisdata_fill SUB=A134
	make oeisdata_fill SUB=A133
	make oeisdata_fill SUB=A132
	make oeisdata_fill SUB=A131
	make oeisdata_fill SUB=A130
	make oeisdata_fill SUB=A129
	make oeisdata_fill SUB=A128
	make oeisdata_fill SUB=A127
	make oeisdata_fill SUB=A126
	make oeisdata_fill SUB=A125
	make oeisdata_fill SUB=A124
	make oeisdata_fill SUB=A123
	make oeisdata_fill SUB=A122
	make oeisdata_fill SUB=A121
	make oeisdata_fill SUB=A120
	make oeisdata_fill SUB=A119
	make oeisdata_fill SUB=A118
	make oeisdata_fill SUB=A117
	make oeisdata_fill SUB=A116
	make oeisdata_fill SUB=A115
	make oeisdata_fill SUB=A114
	make oeisdata_fill SUB=A113
	make oeisdata_fill SUB=A112
	make oeisdata_fill SUB=A111
	make oeisdata_fill SUB=A110
	make oeisdata_fill SUB=A109
	make oeisdata_fill SUB=A108
	make oeisdata_fill SUB=A107
	make oeisdata_fill SUB=A106
	make oeisdata_fill SUB=A105
	make oeisdata_fill SUB=A104
	make oeisdata_fill SUB=A103
	make oeisdata_fill SUB=A102
	make oeisdata_fill SUB=A101
	make oeisdata_fill SUB=A100
#--------
od09:
	make oeisdata_fill SUB=A099
	make oeisdata_fill SUB=A098
	make oeisdata_fill SUB=A097
	make oeisdata_fill SUB=A096
	make oeisdata_fill SUB=A095
	make oeisdata_fill SUB=A094
	make oeisdata_fill SUB=A093
	make oeisdata_fill SUB=A092
	make oeisdata_fill SUB=A091
	make oeisdata_fill SUB=A090
	make oeisdata_fill SUB=A089
	make oeisdata_fill SUB=A088
	make oeisdata_fill SUB=A087
	make oeisdata_fill SUB=A086
	make oeisdata_fill SUB=A085
	make oeisdata_fill SUB=A084
	make oeisdata_fill SUB=A083
	make oeisdata_fill SUB=A082
	make oeisdata_fill SUB=A081
	make oeisdata_fill SUB=A080
	make oeisdata_fill SUB=A079
	make oeisdata_fill SUB=A078
	make oeisdata_fill SUB=A077
	make oeisdata_fill SUB=A076
	make oeisdata_fill SUB=A075
	make oeisdata_fill SUB=A074
	make oeisdata_fill SUB=A073
	make oeisdata_fill SUB=A072
	make oeisdata_fill SUB=A071
	make oeisdata_fill SUB=A070
	make oeisdata_fill SUB=A069
	make oeisdata_fill SUB=A068
	make oeisdata_fill SUB=A067
	make oeisdata_fill SUB=A066
	make oeisdata_fill SUB=A065
	make oeisdata_fill SUB=A064
	make oeisdata_fill SUB=A063
	make oeisdata_fill SUB=A062
	make oeisdata_fill SUB=A061
	make oeisdata_fill SUB=A060
	make oeisdata_fill SUB=A059
	make oeisdata_fill SUB=A058
	make oeisdata_fill SUB=A057
	make oeisdata_fill SUB=A056
	make oeisdata_fill SUB=A055
	make oeisdata_fill SUB=A054
	make oeisdata_fill SUB=A053
	make oeisdata_fill SUB=A052
	make oeisdata_fill SUB=A051
	make oeisdata_fill SUB=A050
	make oeisdata_fill SUB=A049
	make oeisdata_fill SUB=A048
	make oeisdata_fill SUB=A047
	make oeisdata_fill SUB=A046
	make oeisdata_fill SUB=A045
	make oeisdata_fill SUB=A044
	make oeisdata_fill SUB=A043
	make oeisdata_fill SUB=A042
	make oeisdata_fill SUB=A041
	make oeisdata_fill SUB=A040
	make oeisdata_fill SUB=A039
	make oeisdata_fill SUB=A038
	make oeisdata_fill SUB=A037
	make oeisdata_fill SUB=A036
	make oeisdata_fill SUB=A035
	make oeisdata_fill SUB=A034
	make oeisdata_fill SUB=A033
	make oeisdata_fill SUB=A032
	make oeisdata_fill SUB=A031
	make oeisdata_fill SUB=A030
	make oeisdata_fill SUB=A029
	make oeisdata_fill SUB=A028
	make oeisdata_fill SUB=A027
	make oeisdata_fill SUB=A026
	make oeisdata_fill SUB=A025
	make oeisdata_fill SUB=A024
	make oeisdata_fill SUB=A023
	make oeisdata_fill SUB=A022
	make oeisdata_fill SUB=A021
	make oeisdata_fill SUB=A020
	make oeisdata_fill SUB=A019
	make oeisdata_fill SUB=A018
	make oeisdata_fill SUB=A017
	make oeisdata_fill SUB=A016
	make oeisdata_fill SUB=A015
	make oeisdata_fill SUB=A014
	make oeisdata_fill SUB=A013
	make oeisdata_fill SUB=A012
	make oeisdata_fill SUB=A011
	make oeisdata_fill SUB=A010
	make oeisdata_fill SUB=A009
	make oeisdata_fill SUB=A008
	make oeisdata_fill SUB=A007
	make oeisdata_fill SUB=A006
	make oeisdata_fill SUB=A005
	make oeisdata_fill SUB=A004
	make oeisdata_fill SUB=A003
	make oeisdata_fill SUB=A002
	make oeisdata_fill SUB=A001
	make oeisdata_fill SUB=A000
#--------
cat28: # reassemble the cat25.txt file
	cd $(OEISDATA) ; find seq -type f | sort > $(HERE)/$@.list.tmp
	rm -f    $@.txt
	cd $(OEISDATA) ; cat $(HERE)/$@.list.tmp | xargs -innn cat nnn >> $(HERE)/$@.txt
	head -n2 $@.txt
	wc -l    $@.txt
	ls -al   *$@.*
tinfo: # extract ASINFO, ASNAME, BFINFO database tables
	perl -w catex_info.pl -d $(D) cat28.txt
	ls -al   ??????.txt
	wc -l    ??????.txt
	tail -n2 ??????.txt
catex_pack:
	tar -czvf $@.tgz asdata.txt asinfo.txt asname.txt bfinfo.txt
	ls -al *.tgz
#====
joeis_down: joeis_pull joeis_list joeis_ofpre joeis_coral joeis_ofter jcat28 joeis_pack
	# joeis_list1 joeis_list2 
	
#--
joeis_pull:	# update Sean's jOEIS repository
	cd $(JOEIS) ; git pull | tee joeis_pull.`date +%Y-%m-%d.%H.%M`.txt
#--
joeis_list_untested: # version with SuperclassReflector
	scp $(FISCHER)/reflect/makefile $(REM):~/work/gits/joeis-lite/internal/fischer/reflect/
	cd $(FISCHER)/reflect ; make joeis_list
# get the A-numbers and used superclasses of all implemented sequences
joeis_list: joeis_list1 joeis_list2
joeis_list1:
	find $(JOEIS)/src/irvine/oeis -iname "A??????.java" \
	| xargs -l grep -HP "( extends | implements |\@author|^\/\/ Generated by )" \
	>        $@.all.tmp || :
	head -n2 $@.all.tmp 
	wc -l    $@.all.tmp 
joeis_list2:
	grep -E  "public class *A" joeis_list1.all.tmp \
	| sed -e "s/[a-zA0-9\.\/]*://" \
	| sed -e "s/public class *A/A/" \
	      -e "s/ extends / /" \
	      -e "s/ implements / /" \
	      -e "s/ *[^A-Za-z0-9 ].*//" \
	      -e "s/ /\t/" \
	| sort \
	| grep -E "^A" \
	>        joeis_list.txt
	head -n2 joeis_list.txt
	wc -l    joeis_list.txt
#--
joeis_ofpre: # build a preliminary ofter file (with offset = terms = 0) for jcat25.pl
	grep -E "^A" joeis_list.txt | cut -b1-7 | sed -e "s/$$/\t0\t0,0,0,0,0,0,0,0$$/" \
	>        $@.txt
	head -n2 $@.txt
	wc -l    $@.txt
#--
joeis_coral: # get the A-numbers with "... implements Conjectural"
	grep -iE "Conjectural" joeis_list.txt \
	| cut -b1-7 \
	| sort > $@.txt
	head -n2 $@.txt
	wc -l    $@.txt
#--
joeis_ofter: # A-numbers implemented in jOEIS, offsets and a few terms, reduced by the A-numbers in joeis_coral
	perl delete_coral.pl -f joeis_coral.txt joeis_ofpre.txt \
	>        $@.txt
	head -n2 $@.txt
	wc -l    joeis*.txt
	cp -pv   $@.txt ../common
#--
jcat28: # qualify the cat28 lines with "#" = implemented in jOEIS, "%" = nyi, "?" = conjectured
	perl jcat28.pl -f joeis_ofpre.txt -n € cat28.txt > $@.txt
	cut -b1 $@.txt | sort | uniq -c
	cp -pv    $@.txt ../common/jcat25.txt
#--
joeis_pack:
	tar -czvf $@.tgz jcat28.txt joeis_list1.all.tmp joeis_list.txt joeis_ofter.txt joeis_coral.txt
	ls -al   *.tgz
#========
# to be used locally:
#
remote: joeis_pull jar_remote catex_remote oprep_remote joeis_remote load4 reflect arti
load4:
	cd ../common ; make asdata_load asinfo_load asname_load bfinfo_load joeis_reload
reflect:
	cd $(FISCHER)/reflect ; make -i ; make vector
arti:
	cd ../arti ; make sortprep evalsame
robots:
	cd $(FISCHER) ; make robots
#====
oprep_remote: # download stripped, names, bfilelist
	ssh $(REM)           "cd ~/work/gits/OEIS-mat/data ; make oprep_down"
	scp               $(REM):~/work/gits/OEIS-mat/data/oprep_pack.tgz .
	tar -xzvf                                             oprep_pack.tgz
	ls -al
	tail -n2 stripped names bfilelist
	mv -v    stripped names bfilelist ../common/
#====
catex_remote: # refresh oeisdata, generate cat28 and db table content and download
	ssh $(REM)           "cd ~/work/gits/OEIS-mat/data ; git stash ; git pull"
	scp makefile *.pl $(REM):~/work/gits/OEIS-mat/data/
	ssh $(REM)           "cd ~/work/gits/OEIS-mat/data ; make catex_down"
	scp               $(REM):~/work/gits/OEIS-mat/data/catex_pack.tgz .
	tar -xzvf                                          catex_pack.tgz
	ls -al
	tail -n2 asdata.txt asinfo.txt asname.txt bfinfo.txt
	mv -v    asdata.txt asinfo.txt asname.txt bfinfo.txt ../common/
tinfo_remote: # refresh generate db table content and download
	ssh $(REM)           "cd ~/work/gits/OEIS-mat/data ; git stash ; git pull"
	scp makefile *.pl $(REM):~/work/gits/OEIS-mat/data/
	ssh $(REM)           "cd ~/work/gits/OEIS-mat/data ; make tinfo_down"
	scp               $(REM):~/work/gits/OEIS-mat/data/catex_pack.tgz .
	tar -xzvf                                             catex_pack.tgz
	ls -al
	tail -n2 asdata.txt asinfo.txt asname.txt bfinfo.txt
	mv -v    asdata.txt asinfo.txt asname.txt bfinfo.txt ../common/
#====
joeis_remote: # update jOEIS repository, produce lists and jcat28, pack them and download
	ssh $(REM)           "cd ~/work/gits/OEIS-mat/data ; git stash ; git pull"
	scp makefile *.pl $(REM):~/work/gits/OEIS-mat/data/
	ssh $(REM)           "cd ~/work/gits/OEIS-mat/data ; make joeis_down"
	scp               $(REM):~/work/gits/OEIS-mat/data/joeis_pack.tgz .
	tar -xzvf                                             joeis_pack.tgz
	ls -al
	tail -n2 jcat28.txt joeis_list1.all.tmp joeis_list.txt joeis_ofter.txt joeis_coral.txt
	cp -pv   jcat28.txt ../common/jcat25.txt
	cp -pv   joeis_list1.all.tmp joeis_list.txt joeis_ofter.txt joeis_coral.txt ../common/
#====
jar_remote: # refresh jOEIS and rebuild the joeis.jar; needs > 8 GB RAM
	ssh $(REM) "cd ~/work/gits/joeis ; git pull ; ant clean all-jar"
	scp $(REM):~/work/gits/joeis/build.tmp/joeis.jar $(JOEIS)/build.tmp/joeis.jar 
#========
jar_push: # REM= ; distribute the local joeis.jar to some remote server
	scp $(JOEIS)/build.tmp/joeis.jar $(REM):work/gits/joeis/build.tmp/joeis.jar
#====
joeis-prep: # REM= ; make a fresh copy of joeis on the remote server
	ssh $(REM) "cd  ~/work/gits/joeis-prep ; rm -rf * ; cp -pr ../joeis/* . ; rm -f joeis_pull* *.log ; ant clean ; ls -al ; ant test"
jprep:
	cd ../../joeis-prep ; rm -f joeis_pull* *.log ; ant clean all-jar
#====
bfsynth: bfsynth1 bfsynth2 bfsynth3 # generate all "synthesized" b-files from asdata
bfsynth1:
	$(DBAT) -x "SELECT d.aseqno, ',' || d.data || ',' FROM asdata d, bfinfo b WHERE d.aseqno = b.aseqno AND b.message LIKE '%synth%' \
	  ORDER BY 1" \
	>        $@.tmp
	tail -n2 $@.tmp
bfsynth2:
	$(DBAT) -x "SELECT i.aseqno, i.offset1            FROM asinfo i, bfinfo b WHERE i.aseqno = b.aseqno AND b.message LIKE '%synth%' \
	  ORDER BY 1" \
	>        $@.tmp
	tail -n2 $@.tmp
	wc -l    bfsynth*.tmp
bfsynth3:
	perl $(COMMON)/bfsynth.pl -s bfsynth1.tmp -p 3 -o $(COMMON)/bfile bfsynth2.tmp   
#================
# update of the algol system (Windows); requires X: -> remote ; check with dir x:\users\user\work
RGITS=x:/users/user/work/gits
algol: \
	algol_joeis   \
	algol_jar     \
	algol_common  \
	algol_reflect \
	algol_load    \
	#
algol_joeis: # update joeis repository (A*.java)
	cd $(GITS)/joeis ; git pull
#
algol_jar: # get the freshly compiled joeis.jar
	cd $(GITS)/joeis/build.tmp ; cp -vp $(RGITS)/joeis/build.tmp/joeis.jar .
#
algol_common: # copy recent database content
	cd $(GITS)/OEIS-mat/common ; perl ue_script.pl -close ; \
	rm -vf joeis_names.txt ; \
	find $(RGITS)/OEIS-mat/common                     -maxdepth 1 -type f -ctime -4 | xargs -innn cp -vp nnn .
	cd $(GITS)/OEIS-mat/common ; perl ue_script.pl -open
#
algol_reflect: # copy recent from internal/fischer/reflect 
	cd $(GITS)/joeis-lite/internal/fischer/reflect; \
	find $(RGITS)/joeis-lite/internal/fischer/reflect -maxdepth 1 -type f -ctime -4 | xargs -innn cp -vp nnn .
#
algol_load: # recreate database tables
	cd $(GITS)/OEIS-mat/common; make aloads bloads
#
