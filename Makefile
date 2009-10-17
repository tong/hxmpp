
SYSTEM = Linux
HOME = /home/tong/projetcs/hxmpp

HX_JABBER_SRC = jabber/*.hx jabber/client/*.hx jabber/component/*.hx jabber/file/*.hx jabber/jingle/*.hx jabber/stream/*.hx jabber/tool/*.hx
HX_XMPP_SRC = xmpp/*.hx
HX_SRC = $(HX_JABBER_SRC) $(HX_XMPP_SRC) 
HX_CP = -cp ../core/

TESTS_SRC = test/*.hx
TESTS_CP = -cp test

TEST_PATH = bin/tests
TEST_XMPP_PATH = $(TEST_PATH)/test_xmpp
TEST_XMPP_JS = $(TEST_XMPP_PATH).js
TEST_XMPP_SWF = $(TEST_XMPP_PATH).swf
TEST_XMPP_NEKO = $(TEST_XMPP_PATH).n
TEST_XMPP_PHP = $(TEST_XMPP_PATH).php
TEST_JABBER_PATH = $(TEST_PATH)/test_jabber
TEST_JABBER_JS = $(TEST_JABBER_PATH).js
TEST_JABBER_SWF = $(TEST_JABBER_PATH).swf
TEST_JABBER_NEKO = $(TEST_JABBER_PATH).n
TEST_JABBER_PHP = $(TEST_JABBER_PATH).php

NDLL = ndll/$(SYSTEM)/sha1.ndll
NDLL_OBJECTS = util/sha1.o
NDLL_NEKO_FLAGS = -fPIC -shared -L/usr/lib/neko -lneko -lz -ldl
NDLL_LOCAL_FLAGS = -DLINUX -DXP_UNIX=1

SWF_SOCKETBRIDGE = bin/f9_socketbridge.swf
SWF_SOCKETBRIDGE_SRC = jabber/tool/SocketBridge.hx

DOC = doc/api/api.xml
DOC_SRC = $(HX_JABBER_SRC ) $(HX_XMPP_SRC)


all :  $(TEST_XMPP_JS) $(TEST_XMPP_SWF) $(TEST_XMPP_NEKO) $(TEST_XMPP_PHP) \
	   $(TEST_JABBER_JS) $(TEST_JABBER_SWF) $(TEST_JABBER_NEKO) $(TEST_JABBER_PHP) \
	   $(SWF_SOCKETBRIDGE) \
	   $(NDLL) \
	   $(DOC) \


$(TEST_XMPP_JS) : $(HX_SRC) $(TESTS_SRC)
	haxe -main TestXMPP $(HX_CP) $(TESTS_CP) -js $(TEST_XMPP_JS)
$(TEST_XMPP_SWF) : $(HX_SRC) $(TESTS_SRC)
	haxe -main TestXMPP $(HX_CP) $(TESTS_CP) -swf9 $(TEST_XMPP_SWF)
$(TEST_XMPP_NEKO) : $(HX_SRC) $(TESTS_SRC)
	haxe -main TestXMPP $(HX_CP) $(TESTS_CP) -neko $(TEST_XMPP_NEKO)
$(TEST_XMPP_PHP) : $(HX_SRC) $(TESTS_SRC)
	haxe -main TestXMPP $(HX_CP) $(TESTS_CP) -php $(TEST_PATH) --php-front test_xmpp.php

$(TEST_JABBER_JS) : $(HX_SRC) $(TESTS_SRC)
	haxe -main TestJabber $(HX_CP) $(TESTS_CP) -js $(TEST_JABBER_JS)
$(TEST_JABBER_SWF) : $(HX_SRC) $(TESTS_SRC)
	haxe -main TestJabber $(HX_CP) $(TESTS_CP) -swf9 $(TEST_JABBER_SWF)
$(TEST_JABBER_NEKO) : $(HX_SRC) $(TESTS_SRC)
	haxe -main TestJabber $(HX_CP) $(TESTS_CP) -neko $(TEST_JABBER_NEKO)
$(TEST_JABBER_PHP) : $(HX_SRC) $(TESTS_SRC)
	haxe -main TestJabber $(HX_CP) $(TESTS_CP) -php $(TEST_PATH) --php-front test_jabber.php


$(NDLL) : $(NDLL_OBJECTS)
	$(CC) $(NDLL_NEKO_FLAGS) $(NDLL_LOCAL_FLAGS) $(NDLL_OBJECTS) -o $(NDLL)


$(SWF_SOCKETBRIDGE) : $(SWF_SOCKETBRIDGE_SRC)
	haxe -swf-header 0:0:60:000000 -swf9 $@ -main FlashSocketBridge -cp util/ --no-traces --flash-strict


$(DOC) : $(DOC_SRC)
	haxe -xml $(DOC) -cp lib/ jabber.BlockList \
		-D XMPP_DEBUG \
		-D JABBER_DEBUG \
		-D JABBER_SOCKETBRIDGE; \
	cd doc/api && haxedoc api.xml -f jabber -f jabber.tool -f xmpp -f net -f crypt -f util -f error


clean :
	rm util/*.o

	
.PHONY: all clean
