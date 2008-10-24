
SYSTEM = Linux
NDLL = ../ndll/$(SYSTEM)/hxmpp_debug.ndll

OBJECTS =
OBJECTS += hxmpp_debug.o

CFLAGS = -g -Wall
CFLAGS += -I/usr/lib/neko/include

all linux: hxmpp_debug

hxmpp_debug: $(OBJECTS)
	$(CC) $(CFLAGS) -shared $(OBJECTS) -o ../ndll/$(SYSTEM)/hxmpp_debug.ndll 

clean:
	rm -f *.o

