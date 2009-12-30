
SYSTEM = Linux

include hxmpp.stable

STABLE_BASE = jabber.ServiceDiscovery
STABEL_CLIENT_BASE = jabber.client.Stream jabber.client.Roster jabber.client.NonSASLAuthentication jabber.client.SASLAuthentication jabber.client.VCard net.sasl.PlainMechanism
STABEL_CLIENT_JS = $(STABEL_BASE) $(STABEL_CLIENT_BASE) jabber.BOSHConnection


NDLL = ndll/$(SYSTEM)/hxmpp.ndll
NDLL_OBJECTS = util/sha1.o #util/base64.o

all : $(NDLL) lib

$(NDLL) : $(NDLL_OBJECTS) 
	$(CC) -shared -O3 -I/usr/lib/neko/include $(NDLL_OBJECTS) -o $@

libjs :
	haxe -js out/hxmpp.js -cp lib/ --no-traces -exclude hxmpp.exclude $(STABEL_CLIENT_JS)
	#haxe -js tmp -cp lib/ --no-traces -exclude hxmpp.exclude $(STABEL_CLIENT_JS)
	#-java -jar ~/bin/closure.jar -js=tmp --js_output_file=out/hxmpp.js
	#rm tmp
	haxe -js out/hxmpp-debug.js -cp lib/ -exclude hxmpp.exclude \
		-D JABBER_DEBUG \
		-D XMPP_DEBUG \
		-D JABBER_CONSOLE \
		-debug \
		$(STABEL_CLIENT_JS)

libswc :
	haxe -swf9 out/hxmpp.swc -cp lib/ --no-traces -exclude hxmpp.exclude $(STABLE_CLIENT)
	haxe -swf9 out/hxmpp-debug.swc -cp lib/ -D JABBER_DEBUG -D JABBER_CONSOLE -D XMPP_DEBUG jabber.client.Stream

#libas3 :
	#haxe -as3 out/as3

lib : libjs libswc
	
tools :
	haxe utilities.hxml

doc :
	haxe doc.hxml

clean :
	rm util/*.o

.PHONY: all doc clean lib

##find jabber/ xmpp/ -name "*.hx" | sed -e 's/\//./g' -e 's/\.hx//' > temp;
##paste -s -d' ' temp > Makefile.inc
##sed -i  '1i CLASSES=' Makefile.inc
	