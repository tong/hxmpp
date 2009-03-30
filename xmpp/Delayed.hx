package xmpp;


typedef PacketDelay = {
	
	/**
		The Jabber ID of the entity that originally sent the XML stanza
		or that delayed the delivery of the stanza (e.g., the address of a multi-user chat room).
	*/
	var from : String;
	
	/**
		The time when the XML stanza was originally sent.
	*/
	var stamp : String;
	
	/**
		Description of the reason for the delay.
	*/
	var description : String;
}


/**
	<a href="http://xmpp.org/extensions/xep-0203.html">XEP-0203: Delayed Delivery</a><br/>
*/
class Delayed {
	
	public static var XMLNS = "urn:xmpp:delay";
	
	/*
	public var from : String;
	public var stamp : String;
	public var description : String;
	
	public function new() {}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "delay" );
		x.set( "xmlns", XMLNS );
		x.set( "from", from );
		x.set( "stamp", stamp );
		if( description != null ) x.set( "description", description );
		return x;
	}
	*/
	
	/**
		Parses/Returns the packet delay from the properties of the given XMPP packet.
	*/
	public static function get( p : xmpp.Packet ) : xmpp.PacketDelay {
		for( e in p.properties ) {
			var nodeName = e.nodeName;
			var xmlns = e.get( "xmlns" );
			if( nodeName == "delay" ) {
				var desc : String = null;
				try { desc = e.firstChild().nodeValue; } catch( e : Dynamic ) {}
				return { from : e.get( "from" ), stamp : e.get( "stamp" ), description : desc };
			} else {
				if( nodeName == "x" && xmlns == "jabber:x:delay" ) {
					var desc : String = null;
					try { desc = e.firstChild().nodeValue; } catch( e : Dynamic ) {}
					return { from : e.get( "from" ), stamp : e.get( "stamp" ), description : desc };
				}
				continue;
			}
		}
		return null;
	}
	
}
