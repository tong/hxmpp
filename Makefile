
##
## HXMPP - XMPP/Jabber library
##

HXCPP_FLAGS =
ARCH = $(shell sh -c 'uname -m 2>/dev/null || echo not')
ifeq (${ARCH},x86_64)
	HXCPP_FLAGS += -D HXCPP_M64
endif

SRC := $(wildcard src/*.hx) $(wildcard src/*/*.hx)
SRC_TESTS := $(wildcard test/unit/*.hx)
SRC_EXAMPLES := $(wildcard examples/*.hx) $(wildcard examples/*/*.hx)

EXAMPLE_BUILDFILES := $(wildcard examples/*/build.hxml)

all: build

build: tests examples documentation

tests: $(SRC) $(SRC_TESTS)
	@cd test/unit && haxe build.hxml $(HXCPP_FLAGS)

$(EXAMPLE_BUILDFILES): $(SRC) $(SRC_EXAMPLES)
	cd $(shell dirname $@) && haxe build.hxml $(HXCPP_FLAGS)

examples: $(EXAMPLE_BUILDFILES)

haxedoc.xml: $(SRC)
	cd documentation && haxe haxedoc.hxml

documentation: $(SRC) haxedoc.xml
	cd documentation \
		haxe api.hxml && haxelib run dox -i . -o api

hxmpp.zip: clean $(SRC) $(SRC_EXAMPLES) $(SRC_TESTS)
	zip -r $@ documentation/index.html documentation/api.hxml --exclude=*_*
	zip -r $@ examples --exclude=*_*
	cp -r src/jabber/ src/xmpp/ ./ && zip -r $@ jabber/ xmpp/ --exclude=*_* && rm -r jabber xmpp
	zip -r $@ haxelib.json README.md

haxelib: hxmpp.zip

install: hxmpp.zip
	haxelib local hxmpp.zip

uninstall:
	haxelib remove hxmpp

clean:
	rm -rf documentation/api
	rm -f documentation/hxmpp_*.xml
	rm -rf $(wildcard examples/*/cpp)
	rm -rf $(wildcard examples/*/java)
	rm -rf $(wildcard examples/*/cs)
	rm -rf $(wildcard examples/*/lib)
	rm -rf $(wildcard examples/*/app*)
	rm -rf test/unit/build
	rm -f hxmpp.zip
	
.PHONY: all build documentation examples tests haxelib install uninstall clean
