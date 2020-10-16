package xmpp.component;

import haxe.crypto.Sha1;

/*
@:enum abstract ConnectionMethod(String) to String {
	var accept = "accept";
	var connect = "connect";
}
*/

/**
	[XEP-0114: Jabber Component Protocol](https://xmpp.org/extensions/xep-0114.html)
*/
class Stream extends xmpp.Stream {

	/** */
	public static inline var PORT = 5275;

	/** XMPP server component namespace */
	public static inline var XMLNS = 'jabber:component:accept';

	/** Component name */
	public var name(default,null) : String;

	/** Component jid */
	public var jid(default,null) : String;

	public function new( name : String, domain : String,  ?lang : String ) {
		super( XMLNS, domain, lang );
		this.name = name;
		this.jid = '$name.$domain';
	}

	//public function start( secret : String, callback : xmpp.Stream.StreamError->Void ) {
	public function start( secret : String, callback : (?error:xmpp.Stanza.Error)->Void ) {

		reset();

		input = function(str) {

			var header = xmpp.Stream.readHeader( str );
			id = header.id;
			send( XML.create( 'handshake', Sha1.encode( id + secret ) ) );

			input = function(str) {
				var xml : XML = XML.parse( str );
				switch xml.name {
				case 'handshake':
					ready = true;
					input = handleString;
					callback( null );
				default:
					//TODO
					trace( xml );
					switch xml.name {
					case 'stream:error':
						//TODO
						trace(">>>>>>>>>>>");
						//var error = xmpp.Stream.Error.fromXML( xml );
						//trace(error.condition);
						//callback( error );
					}
				}
			}
		}

		output( xmpp.Stream.createHeader( XMLNS, jid, null, lang ) );
	}

	override function handleXML( xml : XML ) {

		var xmlns = xml.get( 'xmlns' );
		if( xmlns != null && xmlns != this.xmlns ) {
			trace("INVALID NAMESPACE");
			return;
		}

		switch xml.name {
		case 'message':
			onMessage( xml );
		case 'presence':
			onPresence( xml );
		case 'iq':
			//onIQ( xml );
			trace(">>>");
		}
	}

}
