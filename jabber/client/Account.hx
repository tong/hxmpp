package jabber.client;


/**
	//TODO required fields handling, x:data form handling

	<a href="http://www.xmpp.org/extensions/xep-0077.html">XEP-0077: In-Band Registration</a>
*/
class Account {
	
	public dynamic function onRegistered( node : String ) : Void;
	public dynamic function onRemoved() : Void;
	public dynamic function onPasswordChange( pass : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
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
	public function register( username : String, password : String, email : String, name : String ) : Bool {
						  	
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
								//TODO
								//var l = xmpp.Register.parse( iq.ext.toXml() );
								self.onRegistered( username );
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
		iq.ext = ext;
		var self = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
				case result :
				//TODO
					//var l = xmpp.Register.parse( iq.ext.toXml() );
					self.onRemoved();
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
		iq.ext = e;
		var self = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
				case result :
					var l = xmpp.Register.parse( iq.ext.toXml() );
					self.onPasswordChange( pass );
				case error :
					self.onError( new jabber.XMPPError( self, r ) );
				default : //#
			}
		} );
	}
	
}
