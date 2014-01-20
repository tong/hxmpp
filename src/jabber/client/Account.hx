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
import xmpp.IQType;

//TODO required fields handling, x:data form handling
	
/**
	XEP-0077: In-Band Registration: http://www.xmpp.org/extensions/xep-0077.html
*/
class Account {
	
	/** Callback for recieved registration fields */
	public dynamic function onFields( fields : Array<String> ) {}
	
	/** Callback for account registering success */
	public dynamic function onRegister( node : String ) {}
	
	/** Callback for account remove success  */
	public dynamic function onRemove() {}
	
	/** Callback for password change success */
	public dynamic function onPasswordChange( pass : String ) {}
	
	/** */
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Request required registration fields
		@param server Server hostname
	*/
	public function requestRegistrationFields( server : String ) {
		var iq = new IQ( null, null, server );
		iq.x = new xmpp.Register();
		stream.sendIQ( iq, function(r:IQ) {
			switch r.type {
			case result :
				for( e in r.properties ) {
					if( e.nodeName == "query" && e.get("xmlns") == xmpp.Register.XMLNS ) {
						var fields = new Array<String>();
						for( c in e.elements() ) {
							if( c.nodeName == "x" ) {
								//TODO
							} else {
								fields.push( c.nodeName );
							}
						}
						onFields( fields );
						return;
					}
				}
			case error :
				onError( new jabber.XMPPError( r ) );
			default : //#
			}
		} );
	}
	
	/**
		Register client account.
	*/
	public function register( creds : xmpp.Register ) : Bool {
		var iq = new IQ();
		iq.x = new xmpp.Register();
		stream.sendIQ( iq, function(r:IQ) {
			switch r.type {
			case result:
				//TODO check required register fields
				//var p = xmpp.Register.parse( iq.x.toXml() );
				//var required = new Array<String>();
				var iq = new IQ( IQType.set );
				iq.x = creds;
				stream.sendIQ( iq, function(r:IQ) {
					switch r.type {
					case result :
						//var l = xmpp.Register.parse( r.x.toXml() );
						//if( !l.registered ) {
						onRegister( creds.username );
					case error:
						onError( new jabber.XMPPError( r ) );
					default:
					}
				} );
			case error:
				onError( new jabber.XMPPError( r ) );
			default:
			}
		} );
		return true;
	}
	
	/**
		Unregister client account.
	*/	
	public function remove() {
		var iq = new IQ( IQType.set );
		var x = new xmpp.Register();
		x.remove = true;
		iq.x = x;
		stream.sendIQ( iq, function(r:IQ) {
			switch r.type {
			case result :
				//var l = xmpp.Register.parse( iq.x.toXml() );
				//if( !l.remove ) {
				onRemove();
			case error :
				onError( new jabber.XMPPError( r ) );
			default : //#
			}
		} );
	}
	
	/**
		Change account password.
	*/
	public function changePassword( node : String, pass : String ) {
		var iq = new IQ( IQType.set );
		var x = new xmpp.Register();
		x.username = node;
		x.password = pass;
		iq.x = x;
		stream.sendIQ( iq, function(r:IQ) {
			switch r.type {
			case result: onPasswordChange( pass );
			case error: onError( new jabber.XMPPError( r ) );
			default:
			}
		} );
	}
	
}
