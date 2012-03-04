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
	<a href="http://xmpp.org/extensions/xep-0012.html">XEP-0012: Last Activity</a>
*/
class LastActivity {
	
	public dynamic function onLoad( entity : String, secs : Int ) {}
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Requests the given entity for their last activity.<br/>
		Given a bare jid will be handled by the server on roster subscription basis.<br/>
		Otherwise the request will be fowarded to the resource of the client entity.<br/>
	*/
	public function request( jid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.x = new xmpp.LastActivity();
		stream.sendIQ( iq, handleLoad );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			onLoad( iq.from, xmpp.LastActivity.parseSeconds( iq.x.toXml() ) );
		case error :
			onError( new XMPPError( iq ) );
		default : ///
		}
	}
	
}
