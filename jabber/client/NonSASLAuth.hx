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

import jabber.util.SHA1;

/**
	<a href="http://xmpp.org/extensions/xep-0078.html">XEP-0078: Multi-User Chat</a><br>
*/
class NonSASLAuth extends Authentication {
	
	public var active(default,null) : Bool;
	public var usePlainText(default,null) : Bool;
	public var username(default,null) : String;
	public var password(default,null) : String;

	public function new( stream : Stream,
						 /*?onSuccess : Void->Void, ?onFail : jabber.XMPPError->Void,*/
					 	 ?usePlainText : Bool = false ) {
		#if JABBER_DEBUG
		if( stream.http )
			throw "NonSASL authentication is not supported on HTTP/BOSH connections";
		#end
		super( stream );
		this.usePlainText = usePlainText;
		username = stream.jid.node;
		active = false;
	}

	public override function authenticate( password : String, ?resource : String ) {
		if( active )
			throw "Authentication in progress";
		this.password = password;
		if( resource != null ) {
			this.resource = resource;
			stream.jid.resource = resource; // update stream jid resource
		}
		active = true;
		var iq = new xmpp.IQ();
		iq.x = new xmpp.Auth( username );
		stream.sendIQ( iq, handleResponse );
		return true;
	}
	
	
	function handleResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			var hasDigest = ( !usePlainText && iq.x.toXml().elementsNamed( "digest" ).next() != null );
			var r = new xmpp.IQ( xmpp.IQType.set );
			r.x = if( hasDigest ) new xmpp.Auth( username, null, SHA1.encode( stream.id+password ), resource );
			else new xmpp.Auth( username, password, null, resource );
			stream.sendIQ( r, handleResult );
		case error : onFail( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
	function handleResult( iq : xmpp.IQ ) {
		active = false;
		switch( iq.type ) {
		case result : onSuccess();
		case error : onFail( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
}
