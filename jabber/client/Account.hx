package jabber.client;

import jabber.event.IQResult;
import jabber.event.XMPPErrorEvent;


/**
	//TOD required fields handling, x:data form handling

	<a href="http://www.xmpp.org/extensions/xep-0077.html">XEP-0077: In-Band Registration</a>
*/
class Account {
	
	public dynamic function onRegistered( e : IQResult<xmpp.Register> ) {}
	public dynamic function onRemoved( e : IQResult<xmpp.Register> ) {}
	public dynamic function onPasswordChange( e : IQResult<xmpp.Register> ) {}
	public dynamic function onError( e : XMPPErrorEvent ) {}
	
	public var stream(default,null) : Stream;
	
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	
	/**
		TODO
	public function requestRegistrationForm() {
		var self = this;
		var iq = new xmpp.IQ();
		iq.ext = new xmpp.Register();
		stream.sendIQ( iq );
	}
	*/
	
	/**
		Requests to register a new account.
	*/
	public function register( username : String, password : String,
							  email : String, name : String ) : Bool {
						  	
		if( stream.status != jabber.StreamStatus.open ) return false;

		var self = this;
		var iq = new xmpp.IQ();
		iq.ext = new xmpp.Register();
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
				case result :
					
					//TODO check required register fields
					//var p = xmpp.Register.parse( iq.ext.toXml() );
					//var required = new Array<String>();
					//onChange( new AccountEvent( self.stream ) );
					
					var iq = new xmpp.IQ( xmpp.IQType.set );
					var submit = new xmpp.Register( username, password, email, name  );
					iq.ext = submit;
					self.stream.sendIQ( iq, function(r:xmpp.IQ) {
						switch( r.type ) {
							case result :
								var l = xmpp.Register.parse( iq.ext.toXml() );
								self.onRegistered( new IQResult( self.stream, r, l ) );
							case error:
								self.onError( new jabber.event.XMPPErrorEvent( self.stream, r ) );
							default : //#
						}
					} );
					
				case error : self.onError( new jabber.event.XMPPErrorEvent( self.stream, r ) );
				default : //#
			}
		} );
		return true;
	}
	
	/**
		Requests to delete account from server.
	*/	
	public function delete() {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var ext = new xmpp.Register();
		ext.remove = true;
		iq.ext = ext;
		var self = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
				case result :
					var l = xmpp.Register.parse( iq.ext.toXml() );
					self.onRemoved( new IQResult( self.stream, r, l ) );
				case error : self.onError( new jabber.event.XMPPErrorEvent( self.stream, r ) );
				default : //#
			}
		} );
	}
	
	/**
		TODO check since openfire seems to be buggy (?)
		
		Requests to change the account password.
	*/
	public function changePassword( node : String, pass : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var e = new xmpp.Register();
		e.username = node;
		e.password = pass;
		iq.ext = e;
		var self = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
				case result :
					var l = xmpp.Register.parse( iq.ext.toXml() );
					self.onPasswordChange( new IQResult( self.stream, r, l ) );
				case error : self.onError( new jabber.event.XMPPErrorEvent( self.stream, r ) );
				default : //#
			}
		} );
	}
	
}
