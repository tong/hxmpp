
SYSTEM = Linux

include hxmpp.source
include hxmpp.stable

NDLL = ndll/$(SYSTEM)/hxmpp.ndll
NDLL_OBJECTS = util/sha1.o #util/base64.o
LIB_JS = out/hxmpp.js
LIB_SWC = out/hxmpp.swc
FLAGS = -cp lib/ -exclude hxmpp.exclude

all : $(NDLL) \
	  $(LIB_JS) \
	  $(LIB_SWC)

$(NDLL) : $(NDLL_OBJECTS)
	$(CC) -shared -O3 -I/usr/lib/neko/include $(NDLL_OBJECTS) -o $@

$(LIB_JS) : $(HXMPP_SRC)
	haxe -js out/hxmpp.js $(FLAGS) $(STABLE_CLIENT_JS) --no-traces
	haxe -js out/hxmpp-debug.js $(FLAGS) $(STABLE_CLIENT_JS) \
		-D JABBER_DEBUG -D XMPP_DEBUG -D JABBER_CONSOLE \
		-debug

$(LIB_SWC) : $(HXMPP_SRC)
	haxe -swf9 out/hxmpp.swc $(FLAGS) $(STABLE_CLIENT) --no-traces
	haxe -swf9 out/hxmpp-debug.swc $(FLAGS) $(STABLE_CLIENT) \
		-D JABBER_DEBUG -D JABBER_CONSOLE -D XMPP_DEBUG \
		-debug

utilities :
	haxe utilities.hxml

doc :
	#haxe doc.hxml

clean :
	rm util/*.o

.PHONY: all doc clean lib
