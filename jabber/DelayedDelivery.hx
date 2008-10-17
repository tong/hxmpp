package jabber;


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
	
	Use compiler flag 'XEP_0091' for backwards compatibility with <a href="http://xmpp.org/extensions/xep-0091.html">XEP-0091: Delayed Delivery</a>.
*/
class DelayedDelivery {
	
	public static var XMLNS = "urn:xmpp:delay"; // TODO move to xmpp.DelayedDelivery
	
	/**
		Parses/returns the packet delay of the given packet.
	*/
	public static function getDelay( m : xmpp.Message ) : jabber.PacketDelay {
		for( e in m.properties ) {
			if( e.nodeName != "delay" || e.get( "xmlns" ) != XMLNS ) return null;
			return { from : e.get( "from" ),
					 stamp : e.get( "stamp" ),
					 description : e.firstChild().nodeValue };
			
			#if XEP_0091
			var description : String = null;
			try { description = e.firstChild().nodeValue; } catch( e : Dynamic ) {}
			return { from : e.get( "from" ),
					 stamp : e.get( "stamp" ),
					 description : description };
			#end//XEP_0091
		}
		return null;	
	}
	
}
