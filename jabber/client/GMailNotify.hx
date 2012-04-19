/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber.client;

import jabber.stream.PacketCollector;

/**
	A custom google extension to XMPP to enable users to query their Gmail account for emails,
	and receive notifications when a new message arrives.
	
	<a href="http://code.google.com/apis/talk/jep_extensions/gmail.html">http://code.google.com/apis/talk/jep_extensions/gmail.html</a>
*/
class GMailNotify {
	
	public static var XMLNS = "google:mail:notify";
	
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
