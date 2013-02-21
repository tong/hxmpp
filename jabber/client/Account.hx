/*
 * Copyright (c) 2012, disktree.net
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
		Request required registration fields from server
	*/
	public function requestRegistrationFields( jid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.x = new xmpp.Register();
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ ) {
			switch( r.type ) {
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
						me.onFields( fields );
						return;
					}
				}
			case error :
				me.onError( new jabber.XMPPError( r ) );
			default : //#
			}
		} );
	}
	
	/**
		Register new account.
	*/
	//public function register( username : String, password : String, email : String, name : String ) : Bool {
	public function register( reg : xmpp.Register ) : Bool {
		var self = this;
		var iq = new xmpp.IQ();
		iq.x = new xmpp.Register();
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result :
				//TODO check required register fields
				//var p = xmpp.Register.parse( iq.x.toXml() );
				//var required = new Array<String>();
				var resp = new xmpp.IQ( xmpp.IQType.set );
				resp.x = reg;
				self.stream.sendIQ( resp, function(r:xmpp.IQ) {
					switch( r.type ) {
					case result :
						//var l = xmpp.Register.parse( iq.x.toXml() );
						//if( !l.registered ) {
						//}
						self.onRegister( reg.username );
					case error:
						self.onError( new jabber.XMPPError( r ) );
					default : //#
					}
				} );
			case error :
				self.onError( new jabber.XMPPError( r ) );
			default : //#
			}
		} );
		return true;
	}
	
	/**
		Delete account from server.
	*/	
	public function remove() {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var ext = new xmpp.Register();
		ext.remove = true;
		iq.x = ext;
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				//var l = xmpp.Register.parse( iq.x.toXml() );
				//if( !l.remove ) {
				//}
				me.onRemove();
			case error :
				me.onError( new jabber.XMPPError( r ) );
			default : //#
			}
		} );
	}
	
	/**
		Change account password.
	*/
	public function changePassword( node : String, pass : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var e = new xmpp.Register();
		e.username = node;
		e.password = pass;
		iq.x = e;
		var self = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				//var l = xmpp.Register.parse( iq.x.toXml() );
				self.onPasswordChange( pass );
			case error :
				self.onError( new jabber.XMPPError( r ) );
			default : //#
			}
		} );
	}
	
}
