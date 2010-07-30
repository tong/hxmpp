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
	Request entity for 'Bits Of Binary'.<br/>
	<a href="http://xmpp.org/extensions/xep-0231.html">XEP-0231: Bits Of Binary.</a><br/>
*/
class BOB {
	
	public dynamic function onLoad( from : String, bob : xmpp.BOB ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Load BOB from entity.
	*/
	public function load( from : String, cid : String ) {
		var iq = new xmpp.IQ( null, null, from );
		iq.x = new xmpp.BOB( cid );
		stream.sendIQ( iq, handleResponse );
	}
	
	function handleResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( iq.from, xmpp.BOB.parse( iq.x.toXml() ));
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
}
