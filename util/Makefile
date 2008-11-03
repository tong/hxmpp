
SYSTEM = Linux

NEKO_INSTALL = /usr/lib/neko

OBJECTS =
OBJECTS += hxmpp_debug.o
OBJECTS += sha1.o

CFLAGS = -g -Wall
CFLAGS += -I/usr/lib/neko

all linux: hxmpp_debug sha1

	
hxmpp_debug: $(OBJECTS)
	$(CC) $(CFLAGS) -shared $(OBJECTS) -o ../ndll/$(SYSTEM)/hxmpp_debug.ndll 

sha1: $(OBJECTS)
	$(CC) $(CFLAGS) -shared $(OBJECTS) -o ../ndll/$(SYSTEM)/sha1.ndll 

install:
	cp ../ndll/$(SYSTEM)/hxmpp_debug.ndll $(NEKO_INSTALL)
	cp ../ndll/$(SYSTEM)/sha1.ndll $(NEKO_INSTALL)
	
clean:
	rm -f *.o
