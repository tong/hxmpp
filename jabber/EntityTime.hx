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

/**
	<a href="http://www.xmpp.org/extensions/xep-0202.html">XEP 202 - EntityTime</a><br/>
	Extension for comunicating the local time of an entity.
*/
class EntityTime {
	
	public dynamic function onLoad( jid : String, t : xmpp.EntityTime ) {}
	public dynamic function onError( err : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Request the local time of another jabber entity.
	*/
	public function load( jid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.x = new xmpp.EntityTime();
		stream.sendIQ( iq, handleLoad );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( iq.from, xmpp.EntityTime.parse( iq.x.toXml() ) );
		case error : onError( new XMPPError( this, iq ) );
		default : //#
		}
	}
	
}
