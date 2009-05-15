
##########################
### HXMPP nekoVM utilities
##########################

SYSTEM = Linux
NDLL_PATH = ../ndll/$(SYSTEM)
NEKO_INSTALL = /usr/lib/neko

OBJECTS =
#OBJECTS += hxmpp_debug.o
OBJECTS += sha1.o

CFLAGS = -g -Wall -O3
CFLAGS += -I/usr/lib/neko

all linux: sha1

sha1: $(OBJECTS)
	$(CC) $(CFLAGS) -shared $(OBJECTS) -o $(NDLL_PATH)/$@.ndll
	
#hxmpp_debug: $(OBJECTS)
#	$(CC) $(CFLAGS) -shared $(OBJECTS) -o $(NDLL_PATH)/hxmpp_debug.ndll 

install:
	cp $(NDLL_PATH)/sha1.ndll $(NEKO_INSTALL)
	
clean:
	rm -f *.o
