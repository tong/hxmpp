
SYS = Linux

CC = gcc
CFLAGS = -shared -O2 -Wall
NDLL = ../ndll/$(SYS)/hxmpp.ndll
INC = -I/usr/local/include -I/usr/lib/neko/include
OBJS = sha1.o #util.o

$(NDLL) : $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(INC) $(OBJS)

clean :
	rm $(OBJS) $(NDLL)
