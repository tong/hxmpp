package jabber.client;

import xmpp.IQ;


typedef EntityTimeData = {
	
	var from : String;
	
	/**
		The entity's numeric time zone offset from UTC.
		The format conforms to the Time Zone Definition (TZD) specified in XEP-0082 (http://www.xmpp.org/extensions/xep-0082.html).
	*/
	var tzo : String;
	
	/**
		 The UTC time according to the responding entity.
		 The format conforms to the dateTime profile specified in XEP-0082 (http://www.xmpp.org/extensions/xep-0082.html)
		 and MUST be expressed in UTC.
	*/
	var utc : String;	
}


/**
	<a href="http://www.xmpp.org/extensions/xep-0202.html">XEP 202 - EntityTime</a>
	
	Extension for communicating the local time of an entity.<br>
*/
class EntityTime {
	
	public static inline var XMLNS = "urn:xmpp:time";
	
	public dynamic function onResult( t : EntityTimeData ) {}
	//public var onError : String->Void;
	
	public var stream(default,null) : Stream;
	var iq : IQ;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		//stream.features.push( XMLNS );
		
		iq = new IQ( IQType.get );
		var child = Xml.createElement( "time" );
		child.set( "xmlns", XMLNS );
		iq.ext = new xmpp.PlainPacket( child );
	}
	
	
	/**
	*/
	public function request( jid : String ) {
		iq.to = jid;
		stream.sendIQ( iq, handleIQ );
	}
	
	
	/// Processes response.
	function handleIQ( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var child = iq.ext.toXml();
				if( child.nodeName == "time" && child.get( "xmlns" ) == XMLNS ) {
					var tzo, utc : String;
					//TODO haxe.xml.Fast
					for( c in child.elements() ) {
						var v = c.firstChild().nodeValue;
						if( c.nodeName == "tzo" ) tzo = v;
						if( c.nodeName == "utc" ) utc = v;
					}
					//onData( { from : iq.from, tzo : tzo, utc : utc } );
				}
			case get :
			case set :
			case error :
				trace("ENTITYTIME ERROR");
		}
	}
}
