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

	//TODO required fields handling, x:data form handling
/**
	<a href="http://www.xmpp.org/extensions/xep-0077.html">XEP-0077: In-Band Registration</a><br/>
*/
class Account {
	
	public dynamic function onFields( fields : Array<String> ) : Void;
	public dynamic function onRegister( node : String ) : Void;
	public dynamic function onRemove() : Void;
	public dynamic function onPasswordChange( pass : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
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
				me.onError( new jabber.XMPPError( me, r ) );
			default : //#
			}
		} );
	}
	
	/**
		Requests to register a new account.
	*/
	//public function register( username : String, password : String, email : String, name : String ) : Bool {
	public function register( reg : xmpp.Register ) : Bool {				  	
		if( stream.status != jabber.StreamStatus.open )
			return false;
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
						self.onError( new jabber.XMPPError( self, r ) );
					default : //#
					}
				} );
			case error :
				self.onError( new jabber.XMPPError( self, r ) );
			default : //#
			}
		} );
		return true;
	}
	
	/**
		Requests to delete account from server.
	*/	
	public function remove() {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var ext = new xmpp.Register();
		ext.remove = true;
		iq.x = ext;
		var self = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				//var l = xmpp.Register.parse( iq.x.toXml() );
				//if( !l.remove ) {
				//}
				self.onRemove();
			case error :
				self.onError( new jabber.XMPPError( self, r ) );
			default : //#
			}
		} );
	}
	
	/**
		Requests to change accounts password.
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
				self.onError( new jabber.XMPPError( self, r ) );
			default : //#
			}
		} );
	}
	
	//function getRequiredFields()
	
}
