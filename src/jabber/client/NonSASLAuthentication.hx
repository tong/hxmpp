/*
 * Copyright (c), disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.client;

import xmpp.IQ;
import jabber.util.SHA1;

/**
	Obsolete, superseded in favor of SASL authentication (jabber.client.Authentication)
	
	XEP-0078: Non-SASL Authentication
	http://xmpp.org/extensions/xep-0078.html
*/
class NonSASLAuthentication extends AuthenticationBase {
	
	public var usePlainText(default,null) : Bool;
	public var username(default,null) : String;
	public var password(default,null) : String;

	public function new( stream : Stream, ?usePlainText : Bool = false ) {
		#if jabber_debug
		if( stream.cnx.http )
			throw "non SASL authentication not supported on http connections";
		#end
		super( stream );
		this.usePlainText = usePlainText;
		username = stream.jid.node;
	}

	public override function start( password : String, ?resource : String ) {
		this.password = password;
		if( resource != null ) {
			this.resource = resource;
			stream.jid.resource = resource; // update stream jid resource
		}
		var iq = new IQ();
		iq.x = new xmpp.Auth( username );
		stream.sendIQ( iq, handleResponse );
		return true;
	}
	
	function handleResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			var r = new IQ( xmpp.IQType.set );
			r.x = ( !usePlainText && iq.x.toXml().elementsNamed( "digest" ).next() != null ) ?
					new xmpp.Auth( username, null, SHA1.encode( stream.id+password ), resource ) :
					new xmpp.Auth( username, password, null, resource );
			stream.sendIQ( r, handleResult );
		case error :
			onFail( iq.errors[0].condition );
		default : //#
		}
	}
	
	function handleResult( iq : IQ ) {
		switch( iq.type ) {
		case result : onSuccess();
		case error :
			onFail( iq.errors[0].condition );
		default : //#
		}
	}
	
}
