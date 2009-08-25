
##########################
### HXMPP nekoVM utilities
##########################

SYSTEM = Linux
NDLL_PATH = ../ndll/$(SYSTEM)

OBJECTS =
OBJECTS += sha1.o
#OBJECTS += hxmpp_debug.o

CFLAGS =
NEKO_FLAGS = -fPIC -shared -L/usr/lib/neko -lneko -lz -ldl
LOCAL_FLAGS = -DLINUX -DXP_UNIX=1 -D_DEBUG

all linux: sha1

sha1: $(OBJECTS)
	$(CC) $(CFLAGS) $(NEKO_FLAGS) $(LOCAL_FLAGS) $(OBJECTS) -o $(NDLL_PATH)/$@.ndll
	
#hxmpp_debug: $(OBJECTS)
#	$(CC) $(CFLAGS) -shared $(OBJECTS) -o $(NDLL_PATH)/hxmpp_debug.ndll 

install:
	cp $(NDLL_PATH)/sha1.ndll $(NEKO_INSTALL)
	
clean:
	rm -f *.o
