
##
## HXMPP - Haxe XMPP/Jabber library
##

SRC := $(wildcard src/*.hx) $(wildcard src/*/*.hx)
SRC_TESTS := $(wildcard test/unit/*.hx)
SRC_EXAMPLES := $(wildcard examples/*.hx) $(wildcard examples/*/*.hx)

EXAMPLES_BUILDFILES := $(wildcard examples/*/build.hxml)
EXAMPLE =

COLOR_OK = \x1b[32;01m
#STRING_OK = $(OK_COLOR)[OK]$(NO_COLOR)

all: build

build: tests examples documentation

tests: $(SRC) $(SRC_TESTS)
	@cd test/unit && haxe build.hxml

$(EXAMPLES_BUILDFILES): $(SRC) $(SRC_EXAMPLES)
	@echo $(OK_COLOR)$(shell dirname $@)$(NO_COLOR)
	@cd $(shell dirname $@) && haxe build.hxml 

examples: $(EXAMPLES_BUILDFILES)

haxedoc.xml: $(SRC)
	cd documentation && haxe haxedoc.hxml

documentation: $(SRC) haxedoc.xml
	cd documentation \
		haxe api.hxml \
		haxelib run dox -i . -o api

hxmpp.zip: clean $(SRC) $(SRC_EXAMPLES) $(SRC_TESTS)
	zip -r $@ examples/ utils/flash-socketbridge/ src/ haxelib.json README.md

haxelib: hxmpp.zip

install: hxmpp.zip
	haxelib local hxmpp.zip

uninstall:
	haxelib remove hxmpp

clean:
	@rm -rf documentation/api
	@rm -f documentation/hxmpp_*.xml
	@rm -rf $(wildcard examples/*/cpp) $(wildcard examples/*/cs) $(wildcard examples/*/java) $(wildcard examples/*/cs) -rf $(wildcard examples/*/php)
	@rm -rf $(wildcard examples/*/app*)
	@rm -rf test/unit/build
	@rm -f haxedoc.xml
	@rm -f hxmpp.zip
	
.PHONY: all build documentation examples tests haxelib install uninstall clean
