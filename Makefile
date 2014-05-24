
##
## HXMPP - Haxe Jabber/XMPP library
##

SRC := $(wildcard src/*.hx) $(wildcard src/*/*.hx)
SRC_TESTS := $(wildcard test/unit/*.hx)
SRC_EXAMPLES := $(wildcard examples/*.hx) $(wildcard examples/*/*.hx)

EXAMPLES_BUILDFILES := $(wildcard examples/*/build.hxml)
DOC_PATH = doc

all: tests examples documentation

tests: $(SRC) $(SRC_TESTS)
	@cd test/unit && haxe build.hxml

$(EXAMPLES_BUILDFILES): $(SRC) $(SRC_EXAMPLES)
	@echo $(OK_COLOR)$(shell dirname $@)$(NO_COLOR)
	@cd $(shell dirname $@) && haxe build.hxml 
examples: $(EXAMPLES_BUILDFILES)

haxedoc.xml: $(SRC)
	haxe haxedoc.hxml

documentation: haxedoc.xml
	haxelib run dox -o doc/api -i doc/xml -t doc/tpl --title "HXMPP - Haxe jabber/xmpp library" -ex haxe -ex cpp -ex cs -ex flash -ex java -ex js -ex microsoft -ex neko -ex php -ex python -ex sys

hxmpp.zip: clean haxedoc.xml documentation $(SRC)
	zip -r $@ examples/ src/ utils/flash-socketbridge/ haxedoc.xml haxelib.json README.md

haxelib: hxmpp.zip

install: hxmpp.zip
	haxelib local hxmpp.zip

uninstall:
	haxelib remove hxmpp

clean:
	@rm -rf doc/api
	@rm -rf doc/xml
	@rm -rf $(wildcard examples/*/cpp) $(wildcard examples/*/cs) $(wildcard examples/*/java) $(wildcard examples/*/cs) $(wildcard examples/*/php) $(wildcard examples/*/lib)
	@rm -rf $(wildcard examples/*/app*)
	@rm -rf test/unit/build
	@rm -f haxedoc.xml
	@rm -f hxmpp.zip
	
.PHONY: all documentation examples tests haxelib install uninstall clean
