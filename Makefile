
##
## HXMPP - Haxe XMPP library
##

HXCPP_FLAGS=
OS=$(shell sh -c 'uname -s 2>/dev/null || echo not')
ARCH=$(shell sh -c 'uname -m 2>/dev/null || echo not')

ifeq (${ARCH},x86_64)
HXCPP_FLAGS+=-D HXCPP_M64
endif

all: documentation examples tests

documentation:
	@(cd doc;haxe build.hxml;haxelib run dox -i ./ -o api;)

examples:
	@(cd examples;haxe buildall.hxml $(HXCPP_FLAGS);)

tests:
	@(cd test/unit;haxe build.hxml $(HXCPP_FLAGS);)
		
hxmpp.zip: clean
	zip -r $@ $(shell git ls-files)

install: hxmpp.zip
	haxelib local hxmpp.zip

uninstall:
	haxelib remove hxmpp

clean:
	rm -f doc/*.xml
	rm -rf doc/api
	rm -f hxmpp.zip
	cd examples && haxe buildall.hxml clean
	rm -rf test/unit/build
	
.PHONY: all documentation examples tests install uninstall clean
