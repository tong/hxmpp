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

/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
class VCard {
	
	public dynamic function onLoad( jid : String, data : xmpp.VCard ) : Void;
	public dynamic function onUpdate() : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Requests to load the vcard from the given entity or from its own if no argument given.
	*/
	public function load( ?jid : String  ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.x = xmpp.VCard.empty();
		stream.sendIQ( iq, handleLoad );
	}
	
	/**
		Update own vcard.
	*/
	public function update( vc : xmpp.VCard ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, stream.jid.domain );
		iq.x = vc;
		stream.sendIQ( iq, handleUpdate );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( iq.from, ( iq.x != null ) ? xmpp.VCard.parse( iq.x.toXml() ) : null );
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //
		}
	}
	
	function handleUpdate( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onUpdate();
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //
		}
	}
	
}
	 