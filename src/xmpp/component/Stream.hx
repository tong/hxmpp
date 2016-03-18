package xmpp.component;

import haxe.crypto.Sha1;

enum State {
    header;
	handshake;
    open;
}

/**
	XMPP server-component stream.

	XEP-0114: Jabber Component Protocol, http://www.xmpp.org/extensions/xep-0114.html
*/
class Stream extends xmpp.Stream {

	public static inline var XMLNS = 'jabber:component:accept';
    public static inline var PORT = 5275;

	public var name(default,null) : String;
	public var domain(default,null) : String;
	public var secret(default,null) : String;
	public var state(default,null) : State;

	public var jid(get,null) : String;
	inline function get_jid() return name+'.'+domain;

	//var disco : ServiceDicovery;

	public function new( name : String, domain : String, secret : String ) {
		super( XMLNS );
		this.name = name;
		this.domain = domain;
		this.secret = secret;
	}

	public override function open() {
		send( xmpp.Stream.createInitElement( xmlns, jid, false, lang ) );
		state = State.header;
	}

	override function _receive( str : String ) : Bool {
		switch state {
		case header:
			var header = xmpp.Stream.readHeader( str );
			id = header.id;
			send( XML.create( 'handshake', Sha1.encode( id + secret ) ) );
			state = handshake;
		case handshake:
			var xml = XML.parse( str );
			if( xml.name == 'handshake' ) {
				state = State.open;
				onReady();
			} else {
				//....
			}
		case open:
			trace(">>");
			//TODO

		}
		return true;
	}
}
