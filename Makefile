
##
## HXMPP - Haxe XMPP/Jabber library
##

SRC := $(wildcard src/*.hx) $(wildcard src/*/*.hx)
SRC_TESTS := $(wildcard test/unit/*.hx)
SRC_EXAMPLES := $(wildcard examples/*.hx) $(wildcard examples/*/*.hx)

EXAMPLE_BUILDFILES := $(wildcard examples/*/build.hxml)

all: build

build: tests examples documentation

tests: $(SRC) $(SRC_TESTS)
	@cd test/unit && haxe build.hxml

$(EXAMPLE_BUILDFILES): $(SRC) $(SRC_EXAMPLES)
	cd $(shell dirname $@) && haxe build.hxml

examples: $(EXAMPLE_BUILDFILES)

haxedoc.xml: $(SRC)
	cd documentation && haxe haxedoc.hxml

documentation: $(SRC) haxedoc.xml
	cd documentation \
		haxe api.hxml \
		haxelib run dox -i . -o api

hxmpp.zip: clean $(SRC) $(SRC_EXAMPLES) $(SRC_TESTS)
	zip -r $@ examples test utils src CHANGES haxelib.json README.md

haxelib: hxmpp.zip

install: hxmpp.zip
	haxelib local hxmpp.zip

uninstall:
	haxelib remove hxmpp

clean:
	@rm -rf documentation/api
	@rm -f documentation/hxmpp_*.xml
	@rm -rf $(wildcard examples/*/cpp)
	@rm -rf $(wildcard examples/*/java)
	@rm -rf $(wildcard examples/*/cs)
	@rm -rf $(wildcard examples/*/lib)
	@rm -rf $(wildcard examples/*/app*)
	@rm -rf test/unit/build
	@rm -f haxedoc.xml
	@rm -f hxmpp.zip
	
.PHONY: all build documentation examples tests haxelib install uninstall clean
