
SYSTEM = Linux

PROJECT:=hxmpp
VERSION:=0.4
#DATE:=$(shell date +"%Y-%m-%d")

#JSCOMPRESSOR = closure

include hxmpp.source
include hxmpp.stable

LIB_JS = lib/hxmpp.js
LIB_SWC = lib/hxmpp.swc
FLAGS = -cp lib -exclude hxmpp.exclude

all : libs


$(LIB_JS) : $(HXMPP_SRC)  hxmpp.stable
	haxe -js $@ $(FLAGS) $(STABLE_CLIENT_JS) --no-traces
	haxe -js lib/hxmpp-debug.js $(FLAGS) $(STABLE_CLIENT_JS) \
		-D JABBER_DEBUG -D XMPP_DEBUG -D JABBER_CONSOLE \
		-debug

$(LIB_SWC) : $(HXMPP_SRC)  hxmpp.stable
	haxe -swf9 $@ $(FLAGS) $(STABLE_CLIENT) --no-traces
	haxe -swf9 lib/hxmpp-debug.swc $(FLAGS) $(STABLE_CLIENT) \
		-D JABBER_DEBUG -D JABBER_CONSOLE -D XMPP_DEBUG \
		-debug --flash-strict

libs : $(LIB_JS) $(LIB_SWC)

utilities :
	haxe utilities.hxml
	
doc :
	haxe doc.hxml
	-haxeumlgen -c -b "#ffffff" -f "#000000" -o doc/uml doc/api.xml

samples : *
	(cd samples/client; haxe build.hxml)
	(cd samples/component; haxe build.hxml)

clean :
	-rm doc/api.xml
	(cd util; make clean)
	#TODO
	#rm util/*.o

.PHONY: all doc clean libs
