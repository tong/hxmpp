
## HXMPP - Haxe Jabber/XMPP library

SRC := $(shell find src/ -type f -name '*.hx')
SRC_TESTS := $(wildcard test/unit/*.hx)
SRC_EXAMPLES := $(wildcard examples/*.hx) $(wildcard examples/*/*.hx)

EXAMPLES_BUILDFILES := $(wildcard examples/*/build.hxml)

all: documentation tests

tests: $(SRC) $(SRC_TESTS)
	@cd test/unit && haxe build.hxml

$(EXAMPLES_BUILDFILES): $(SRC) $(SRC_EXAMPLES)
	@echo $(OK_COLOR)$(shell dirname $@)$(NO_COLOR)
	@cd $(shell dirname $@) && haxe build.hxml 
examples: $(EXAMPLES_BUILDFILES)

haxedoc.xml: $(SRC)
	haxe haxedoc.hxml

documentation: $(SRC)
	@mkdir -p doc
	haxe apidoc.hxml
	haxelib run dox -o doc/api -i doc/ --title "Hxmpp" \
		-ex haxe -ex cpp -ex cs -ex flash -ex java -ex js -ex microsoft -ex neko -ex php -ex python -ex sys

hxmpp.zip: clean haxedoc.xml $(SRC)
	zip -r $@ src/ utils/flash-socketbridge/ haxedoc.xml haxelib.json README.md

haxelib: hxmpp.zip

install: hxmpp.zip
	haxelib local hxmpp.zip

uninstall:
	haxelib remove hxmpp

clean:
	@rm -rf doc/api
	@rm -f doc/*.xml
	@rm -rf $(wildcard examples/*/cpp) $(wildcard examples/*/cs) $(wildcard examples/*/java) $(wildcard examples/*/cs) $(wildcard examples/*/php) $(wildcard examples/*/lib)
	@rm -rf $(wildcard examples/*/app*)
	@rm -rf test/unit/build
	@rm -f haxedoc.xml hxmpp.zip
	
.PHONY: all documentation examples tests haxelib install uninstall clean
