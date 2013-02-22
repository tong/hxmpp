/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.client;

/**
	A custom google extension to XMPP to enable users to query their Gmail account for emails,
	and receive notifications when a new message arrives.

	https://developers.google.com/talk/jep_extensions/gmail
*/
class GMailNotify {
	
	public static var XMLNS(default,null) : String = "google:mail:notify";
	
	public dynamic function onMail( m : Xml ) {}
	
	public var stream(default,null) : Stream;
	
	var c : PacketCollector;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		@param newerThanTime The time of the oldest unread email to retrieve, in milliseconds
		
		@param newerThanTid The highest thread number of messages to return, where higher numbers are more recent email threads.
		The server will return only threads newer than that specified by this attribute.
		If using this attribute, you should also use newer-than-time for best results.
		When querying for the first time, you should omit this value.
		
		@param q Specifies an optional search query string.
		This string uses the same syntax as the search box in Gmail, including supported operators.
		
		The server will also subscribe the client to receive notifications when new mail is received.
	*/
	public function request( ?newerThanTime : Int, ?newerThanTid : Int, ?q : String  ) {
		if( c == null )
			c = stream.collect( [new xmpp.filter.IQFilter(XMLNS,xmpp.IQType.set,"mailbox")], handleNotification, true );
		var iq = new xmpp.IQ();
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( newerThanTime != null ) x.set( "newer-than-time", Std.string( newerThanTime ) );
		if( newerThanTid != null ) x.set( "newer-than-tid", Std.string( newerThanTid ) );
		iq.properties.push( x );
		stream.sendIQ( iq, handleNotification );
	}
	
	/**
		Stops collecting/reporting mail notifications.
		This does NOT unsubscribe from getting mail notifications (currently not provided by the service).
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
