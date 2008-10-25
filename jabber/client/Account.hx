package jabber.client;


private enum AccountEventType {
	//formRequest( r : xmpp.Register );
	registered( error : xmpp.Error );
	removed( error : xmpp.Error );
	passwordChanged( error : xmpp.Error );
}

typedef AccountEvent = {
	var stream : Stream;
	var type : AccountEventType;
}


/**
	//TOD required fields handling, x:data form handling

	<a href="http://www.xmpp.org/extensions/xep-0077.html">XEP-0077: In-Band Registration</a>
*/
class Account {
	
	public dynamic function onChange( e : AccountEvent ) {}
	//public dynamic function formRequestHandler( r : xmpp.Register ) : xmpp.Register {}
	
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
					
					//var p = xmpp.Register.parse( iq.ext.toXml() );
					//TODO check required register fields
					//var required = new Array<String>();
					//onChange( new AccountEvent( self.stream ) );
					
					var iq = new xmpp.IQ( xmpp.IQType.set );
					var submit = new xmpp.Register( username, password, email, name  );
					iq.ext = submit;
					self.stream.sendIQ( iq, function(r:xmpp.IQ) {
						switch( r.type ) {
							case result : 
								self.onChange( { stream : self.stream, type : registered( null ) } );
							case error:
								self.onChange( { stream : self.stream, type : registered( xmpp.Error.parse( r.errors[0] ) ) } );
							default : //#
						}
					} );
					
				case error :
					self.onChange( { stream : self.stream, type : registered( xmpp.Error.parse( r.errors[0] ) ) } );
				
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
					self.onChange( { stream : self.stream, type : removed( null ) } );
				case error : 
					self.onChange( { stream : self.stream, type : registered( xmpp.Error.parse( r.errors[0] ) ) } );
				default :
			}
		} );
	}
	
	/**
		TODO check since openfire seems to be buggy (?)
		
		Requests to change the account password.
	*/
	public function changePassword( node : String, pass : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var ext = new xmpp.Register();
		ext.username = node;
		ext.password = pass;
		iq.ext = ext;
		var self = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
				case result :
					self.onChange( { stream : self.stream, type : passwordChanged( null ) } );
				case error : 
					self.onChange( { stream : self.stream, type : passwordChanged( xmpp.Error.parse( r.errors[0] ) ) } );
				default :
			}
		} );
	}
	
}
