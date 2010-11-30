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
	<a href="http://xmpp.org/extensions/xep-0055.html">XEP-0055: Search</a><br/>
*/
class UserSearch {
	
	public dynamic function onFields( jid : String, l : xmpp.UserSearch ) : Void;
	public dynamic function onResult( jid : String, l : xmpp.UserSearch ) : Void;
	public dynamic function onError( e : XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	public function requestFields( jid : String ) {
		var iq = new xmpp.IQ();
		iq.to = jid;
		iq.x = new xmpp.UserSearch();
		sendIQ( iq, onFields );
	}
	
	public function search( jid : String, item : xmpp.UserSearchItem ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		iq.to = jid;
		var u = new xmpp.UserSearch();
		for( f in Reflect.fields( item ) )
			Reflect.setField( u, f, Reflect.field( item, f ) );
		iq.x = u;
		sendIQ( iq, onResult );
	}
	
	function sendIQ( iq : xmpp.IQ, h : String->xmpp.UserSearch->Void ) {
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ){
			switch( r.type ) {
			case result : h( r.from, xmpp.UserSearch.parse( r.x.toXml() ) );
			case error : me.onError( new XMPPError( me, r ) );
			default :
			}
		} );
	}

}
