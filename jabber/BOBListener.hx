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
package jabber;

import jabber.util.Base64;

/**
	<a href="http://xmpp.org/extensions/xep-0231.html">XEP-0231: Bits of Binary</a><br/>
	Listens for 'Bits Of Binary' requests.
*/
class BOBListener {
	
	/**
		Callback handler for BOB requests.<br/>
		JID->CID .. return BOB
	*/
	public var onRequest : String->String->xmpp.BOB;
	
	public var stream(default,null) : jabber.Stream;

	public function new( stream : jabber.Stream, onRequest : String->String->xmpp.BOB ) {
		this.stream = stream;
		this.onRequest = onRequest;
		var f_iq : xmpp.PacketFilter = new xmpp.filter.IQFilter( xmpp.BOB.XMLNS, "data", xmpp.IQType.get );
		stream.addCollector( new jabber.stream.PacketCollector( [f_iq], handleRequest, true ) );
	}

	function handleRequest( iq : xmpp.IQ ) {
		var _bob = xmpp.BOB.parse( iq.x.toXml() );
		var _cid = xmpp.BOB.getCIDParts( _bob.cid );
		var bob : xmpp.BOB = onRequest( iq.from, _cid[1] );
		if( bob == null ) {
			//trace("NO BOB FOUND");
			//TODO check XEP for updates
			//.??
		} else {
			var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
			// encode here?
			bob.data =  new haxe.BaseCode( haxe.io.Bytes.ofString( Base64.CHARS ) ).encodeString( bob.data );
			r.x = bob;
			stream.sendPacket( r );
		}
	}
	
}
