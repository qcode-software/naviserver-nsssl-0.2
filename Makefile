ifndef NAVISERVER
    NAVISERVER  = /usr/local/ns
endif

#
# Filename of loadable binary of the module
#
MOD      =  nsssl.so

#
# Objects to build.
#
MODOBJS     = nsssl.o

#MODLIBS = -L/usr/local/ssl/lib -Wl,-rpath,/usr/local/ssl/lib
MODLIBS  += -lssl -lcrypto

CLEAN	 += clean-cert

include  $(NAVISERVER)/include/Makefile.module

dhparams.h:
	openssl dhparam -C -2 -noout 512 >> dhparams.h
	openssl dhparam -C -2 -noout 1024 >> dhparams.h

nsssl.o: dhparams.h

LD_LIBRARY_PATH = LD_LIBRARY_PATH="./:$$LD_LIBRARY_PATH"
NSD             = $(NAVISERVER)/bin/nsd
NS_TEST_CFG     = -c -d -t tests/config.tcl -u nsadmin
NS_TEST_ALL     = all.tcl $(TCLTESTARGS)
PEM_FILE	= tests/etc/server.pem

certificate: $(PEM_FILE)

$(PEM_FILE):
	openssl genrsa 1024 > host.key
	openssl req -new -config tests/etc/openssl.cnf -x509 -nodes -sha1 -days 365 -key host.key > host.cert
	cat host.cert host.key > server.pem
	rm -rf host.cert host.key
	openssl dhparam 1024 >> server.pem
	mv server.pem $(PEM_FILE)

clean-cert:
	rm -f $(PEM_FILE)

test: certificate all 
	export $(LD_LIBRARY_PATH); $(NSD) $(NS_TEST_CFG) $(NS_TEST_ALL)
