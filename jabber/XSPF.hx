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

import jabber.Stream;

/**
 * Request entities for their XSPF playlist.
 */
class XSPF {
	
	public dynamic function onLoad( jid : String, playlist : xspf.Playlist ) {}
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	public function request( jid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.properties.push( xmpp.XSPF.emptyXml() );
		stream.sendIQ( iq, handleResult );
	}
	
	function handleResult( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			if( iq.x == null ) {
				onLoad( iq.from, null );
			} else {
				var x = iq.x.toXml().firstElement();
				var pl : xspf.Playlist = null;
				try {
					pl = xspf.Playlist.parse( x );
				} catch( e : Dynamic ) {
					trace(e); //TODO
					return;
				}
				onLoad( iq.from, pl );
			}
		case error :
			onError( new jabber.XMPPError( iq ) );
		default:
		}
	}
	
}
