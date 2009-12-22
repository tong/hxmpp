
SYSTEM = Linux
HOME = /home/tong/projetcs/hxmpp

DEBUG=true

HX_JABBER_SRC = jabber/*.hx jabber/client/*.hx jabber/component/*.hx jabber/file/*.hx jabber/jingle/*.hx jabber/stream/*.hx jabber/tool/*.hx jabber/file/*.hx jabber/file/io/*.hx jabber/remoting/*.hx 
HX_XMPP_SRC = xmpp/*.hx
HX_SRC = $(HX_JABBER_SRC) $(HX_XMPP_SRC) 
HX_CP = -cp ../core/

TESTS_SRC = test/*.hx
TESTS_CP = -cp test/
TEST_PATH = bin/tests
TEST_XMPP_FLAGS = -main TestXMPP -debug $(HX_CP) $(TESTS_CP)
TEST_JABBER_FLAGS = -main TestJabber -debug  $(HX_CP) $(TESTS_CP)
PATH_XMPP = $(TEST_PATH)/test_xmpp
TEST_XMPP_JS = $(PATH_XMPP).js
TEST_XMPP_SWF = $(PATH_XMPP).swf
TEST_XMPP_NEKO = $(PATH_XMPP).n
TEST_XMPP_PHP = $(PATH_XMPP).php
PATH_JABBER = $(TEST_PATH)/test_jabber
TEST_JABBER_JS = $(PATH_JABBER).js
TEST_JABBER_SWF = $(PATH_JABBER).swf
TEST_JABBER_NEKO = $(PATH_JABBER).n
TEST_JABBER_PHP = $(TEST_PATH)/test_jabber.php

NDLL = ndll/$(SYSTEM)/sha1.ndll
NDLL_OBJECTS = util/sha1.o
NDLL_NEKO_FLAGS = -fPIC -shared -L/usr/lib/neko -lneko -lz -ldl
NDLL_LOCAL_FLAGS = -DLINUX -DXP_UNIX=1
NDLL_FLAGS = $(NDLL_NEKO_FLAGS) $(NDLL_LOCAL_FLAGS) $(NDLL_OBJECTS)

SWF_SOCKETBRIDGE = bin/f9_socketbridge.swf
SWF_SOCKETBRIDGE_SRC = jabber/tool/SocketBridge.hx

DOC_SRC = $(HX_JABBER_SRC ) $(HX_XMPP_SRC) doc/api/template.xml

TEMP_NAME = test
TEMP_MAIN = TestBOSH
TEMP_SRC = $(HX_SRC) test/jabber/*.hx
TEMP_FLAGS = $(HX_CP) -cp test/jabber -D XMPP_DEBUG -D JABBER_DEBUG
TEMP_NEKO = bin/$(TEMP_NAME).n
TEMP_SWF = bin/$(TEMP_NAME).swf
TEMP_JS = bin/$(TEMP_NAME).js
TEMP_PHP = bin/test.php

all : $(TEMP_NEKO) $(TEMP_SWF) $(TEMP_JS) \
	  $(SWF_SOCKETBRIDGE) $(NDLL) \
	  #$(SWC) \

$(TEMP_NEKO) : $(TEMP_SRC)
	haxe -neko $(TEMP_NEKO) -main $(TEMP_MAIN) $(TEMP_FLAGS)
$(TEMP_SWF) : $(TEMP_SRC)
	haxe -swf9 $(TEMP_SWF) -main $(TEMP_MAIN) $(TEMP_FLAGS)
$(TEMP_JS) : $(TEMP_SRC)
	haxe -js $(TEMP_JS) -main $(TEMP_MAIN) $(TEMP_FLAGS) -D JABBER_SOCKETBRIDGE
$(TEMP_PHP) : $(TEMP_SRC)
	haxe -php bin  --php-front test.php -main $(TEMP_MAIN) $(TEMP_FLAGS)

tests : $(HX_SRC) $(TESTS_SRC)
	haxe $(TEST_XMPP_FLAGS) -js $(TEST_XMPP_JS)
	haxe $(TEST_XMPP_FLAGS) -swf9 $(TEST_XMPP_SWF)
	haxe $(TEST_XMPP_FLAGS) -neko $(TEST_XMPP_NEKO)
	haxe $(TEST_XMPP_FLAGS) -php $(TEST_PATH) --php-front test_xmpp.php
	haxe $(TEST_JABBER_FLAGS) -js $(TEST_JABBER_JS)
	haxe $(TEST_JABBER_FLAGS) -swf9 $(TEST_JABBER_SWF)
	haxe $(TEST_JABBER_FLAGS) -neko $(TEST_JABBER_NEKO)
	haxe $(TEST_JABBER_FLAGS) -php $(TEST_PATH) --php-front test_jabber.php

$(NDLL) : $(NDLL_OBJECTS)
	$(CC) $(NDLL_FLAGS) -o $@

$(SWF_SOCKETBRIDGE) : $(SWF_SOCKETBRIDGE_SRC)
	haxe -swf-header 0:0:60:000000 -swf9 $@ -main FlashSocketBridge -cp util/ --no-traces --flash-strict

#$(SWC) :
#	haxe -swf9 bin/hxmpp.swc -cp lib/ -D JABBER_DEBUG --no-traces \
#		jabber.client.Stream

doc : $(DOC_SRC) Makefile
	haxe -js temp.js -xml doc/api/api.xml -cp lib/  \
		jabber.BlockList jabber.BOB jabber.BOBListener jabber.BOSHConnection jabber.Chat jabber.ChatStateNotification jabber.EntityCapabilities jabber.JID jabber.JIDUtil jabber.LastActivity jabber.LastActivityListener jabber.MessageListener jabber.Ping jabber.Pong jabber.PrivacyLists jabber.PubSub jabber.PersonalEvent jabber.PersonalEventListener jabber.ServiceDiscovery jabber.ServiceDiscoveryListener jabber.SocketConnection jabber.SoftwareVersion jabber.XMPPDebug jabber.XMPPError jabber.client.Account jabber.client.MUChat jabber.client.NonSASLAuthentication jabber.client.Roster jabber.client.SASLAuthentication jabber.client.Stream jabber.client.VCard jabber.component.Stream xmpp.Bind xmpp.ChatState xmpp.ChatStateExtension xmpp.Compression xmpp.DataForm xmpp.DateTime xmpp.Delayed xmpp.Error xmpp.ErrorCondition xmpp.IQ xmpp.MUC xmpp.PlainPacket xmpp.Presence xmpp.PrivacyLists xmpp.SASL xmpp.XHTML net.sasl.AnonymousMechanism net.sasl.PlainMechanism net.sasl.MD5Mechanism \
		-D JABBER_SOCKETBRIDGE \
		-D XMPP_DEBUG \
		-D JABBER_DEBUG;\
	cd doc/api; \
	haxedoc api.xml -f jabber -f jabber.tool -f xmpp -f net -f crypt -f util -f error; \
	cd -; rm temp.js; echo  OK

clean :
	rm util/*.o

.PHONY: all tests doc clean

##find jabber/ xmpp/ -name "*.hx" | sed -e 's/\//./g' -e 's/\.hx//' > temp;
##paste -s -d' ' temp > Makefile.inc
##sed -i  '1i CLASSES=' Makefile.inc
	