
SYS = Linux

CC = gcc
CFLAGS = -shared -O2 -Wall
NDLL = ../ndll/$(SYS)/hxmpp.ndll
INC = -I/usr/local/include -I/usr/lib/neko/include
SRCS = sha1.c
OBJS = $(SRCS:.c=.o)

$(NDLL) : $(SRCS) $(OBJS) Makefile
	$(CC) $(CFLAGS) -o $@ $(INC) $(OBJS)

clean :
	rm $(OBJS) $(NDLL)
