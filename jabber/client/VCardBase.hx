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
	Abstract base for vcard classes (jabber.client.VCard and jabber.client.VCardTemp)
*/
class VCardBase<T> {
	
	/** VCard loaded callback*/
	public dynamic function onLoad( jid : String, data : xmpp.VCardTemp ) {}
	/** Own vcard updated callback */
	public dynamic function onUpdate() {}
	/** */
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Requests to load the vcard from the given entity or own no jid is given.
	*/
	public function load( ?jid : String  ) {
		#if JABBER_DEBUG
		throw "abstract method";
		#end
	}
	
	/**
		Update own vcard.
	*/
	public function update( vc : T ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, stream.jid.domain );
		iq.x = cast vc;
		stream.sendIQ( iq, handleUpdate );
	}
	
	function _load( x : Xml, jid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.properties.push( x );
		stream.sendIQ( iq, handleLoad );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			_handleLoad( iq );
			//onLoad( iq.from, ( iq.x != null ) ? xmpp.VCardTemp.parse( iq.x.toXml() ) : null );
		case error :
			onError( new jabber.XMPPError( iq ) );
		default : //
		}
	}
	
	function _handleLoad( iq : xmpp.IQ ) {
		#if JABBER_DEBUG
		throw "abstract method";
		#end
	}
	
	function handleUpdate( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onUpdate();
		case error : onError( new jabber.XMPPError( iq ) );
		default : //
		}
	}
	
}
