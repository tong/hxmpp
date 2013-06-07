
#
# hxmpp
#

all: doc test

doc:
	cd doc/api && haxe build.hxml && haxedoc cross.xml -f jabber -f xmpp

examples:
	cd examples && haxe build.hxml

haxelib: hxmpp.zip

hxmpp.zip:
	rm -rf temp
	mkdir -p temp
	cd temp && git clone git://github.com/tong/hxmpp.git && cd hxmpp && zip -r $@ examples/ jabber/ xmpp/ haxelib.json README.md #-x "*_*" "*2"
	mv temp/hxmpp/hxmpp.zip .
	rm -rf temp
	
test:
	cd test/unit && haxe build.hxml

clean-examples:
	cd examples && haxe build.hxml clean
	
clean: clean-examples
	rm -f doc/api/*.xml doc/api/index.html
	rm -rf doc/api/content
	rm -rf temp
	rm -rf test/unit/out
	rm -f hxmpp.zip
	
.PHONY: all doc examples haxelib test clean
