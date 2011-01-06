package jabber.client;

import jabber.stream.PacketCollector;

/**
	A custom google extension to XMPP to enable users to query their Gmail account for emails,
	and receive notifications when a new message arrives.
	
	http://code.google.com/apis/talk/jep_extensions/gmail.html
*/
class GMailNotify {
	
	static var XMLNS = "google:mail:notify";
	
	public dynamic function onMail( m : Xml ) : Void;
	
	public var stream(default,null) : Stream;
	
	var c : PacketCollector;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		newerThanTime: The time of the oldest unread email to retrieve, in milliseconds
		
		newerThanTid: The highest thread number of messages to return, where higher numbers are more recent email threads.
		The server will return only threads newer than that specified by this attribute.
		If using this attribute, you should also use newer-than-time for best results.
		When querying for the first time, you should omit this value.
		
		q: Specifies an optional search query string.
		This string uses the same syntax as the search box in Gmail, including supported operators.
		
		The server will also subscribe the client to receive notifications when new mail is received.
	*/
	public function request( ?newerThanTime : Int, ?newerThanTid : Int, ?q : String  ) {
		if( c == null )
			c = stream.collect( [cast new xmpp.filter.IQFilter(XMLNS,"mailbox",xmpp.IQType.set)], handleNotification, true );
		var iq = new xmpp.IQ();
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( newerThanTime != null ) x.set( "newer-than-time", Std.string( newerThanTime ) );
		if( newerThanTid != null ) x.set( "newer-than-tid", Std.string( newerThanTid ) );
		iq.properties.push( x );
		stream.sendIQ( iq, handleNotification );
	}
	
	/**
		Stops collecting/reporting mail notifications.
		This does NOT unsubscribe from getting mail notifications (currently not provided by the service)
	*/
	public function dispose() {
		stream.removeCollector( c );
		c = null;
	}
	
	function handleNotification( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			onMail( iq.x.toXml() );
		case set :
			onMail( iq.x.toXml() );
			stream.sendPacket( xmpp.IQ.createResult( iq ) );
		default :
		}
	}
	
}
