
import haxe.macro.Compiler;
import haxe.macro.Context;

/**
	HXMPP - Jabber/XMPP library
*/
@noDoc
class HXMPP {

	static function importAll() {
		import_jabber();
		import_xmpp();
	}

	static function import_jabber() {
		var blacklist = [
			'jabber.component',
			'jabber.crypto',
			'jabber.io',
			'jabber.jingle',
			'jabber.jingle2',
			'jabber.util.FlashPolicy',
			'jabber.data',
			'jabber.net',
			'jabber.SecureSocketConnection',
			'jabber.StreamCompression'
		];
		if( !Context.defined( 'flash' ) && !Context.defined( 'js' ) ) {
			blacklist.push('jabber.BOSHConnection');
		}
		if( Context.defined( 'js' ) || Context.defined( 'flash' ) ) {
			blacklist.push('jabber.sasl.ExternalMD5Mechanism' );
		}
		Compiler.include( 'jabber', true, blacklist );
	}

	static function import_xmpp() {
		var blacklist_xmpp = [];
		Compiler.include( 'xmpp', true, blacklist_xmpp );
	}

}
