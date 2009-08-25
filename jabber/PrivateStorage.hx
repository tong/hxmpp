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
	Extension to store any arbitrary XML on the server side.
	<a href="http://xmpp.org/extensions/xep-0049.html">XEP-0049: Private XML Storage</a><br/>
*/
class PrivateStorage {
	
	public dynamic function onStored( s : xmpp.PrivateStorage ) : Void;
	public dynamic function onLoad( s : xmpp.PrivateStorage ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;

	public function new( stream : jabber.client.Stream ) {
		this.stream = stream;
	}
	
	/**
		Store private data.
	*/
	public function store( name : String, namespace : String, data : Xml ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var xt = new xmpp.PrivateStorage( name, namespace, data );
		iq.x = xt;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result : me.onStored( xt );
			case error : me.onError( new jabber.XMPPError( me, iq ) );
			default://#
			}
		} );
	}
	
	/**
		Load private data.
	*/
	public function load( name : String, namespace : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get );
		iq.x = new xmpp.PrivateStorage( name, namespace );
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result : me.onLoad( xmpp.PrivateStorage.parse( r.x.toXml() ) );
			case error : me.onError( new jabber.XMPPError( me, iq ) );
			default://#
			}
		} );
	}
	
}
