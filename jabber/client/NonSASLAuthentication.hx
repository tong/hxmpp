package jabber.client;


/**
*/
class NonSASLAuthentication {
	
	public dynamic function onSuccess() {}
	public dynamic function onFailed( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : Stream;
	public var active(default,null) : Bool;
	public var usePlainText(default,null) : Bool;
	public var username(default,null) : String;
	public var password(default,null) : String;
	public var resource(default,null) : String;

	public function new( stream : Stream,
						 ?onSuccess : Void->Void, ?onFailed : jabber.XMPPError->Void,
					 	 ?usePlainText : Bool ) {
		this.stream = stream;
		this.onSuccess = onSuccess;
		this.onFailed = onFailed;
		this.usePlainText = ( usePlainText != null ) ? usePlainText : false;
		username = stream.jid.node;
		resource = stream.jid.resource;
		active = false;
	}

	public function authenticate( pw : String, ?resource : String ) {
		if( active ) throw new error.Exception( "Authentication already in progress" );
		this.password = pw;
		this.resource = resource;
		if( resource != null ) stream.jid.resource = resource; // ???
		active = true;
		var iq = new xmpp.IQ();
		iq.ext = new xmpp.Auth( username );
		stream.sendIQ( iq, handleResponse );
	}
	
	
	function handleResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				var hasDigest = ( !usePlainText && iq.ext.toXml().elementsNamed( "digest" ).next() != null );
				var r = new xmpp.IQ( xmpp.IQType.set );
				r.ext = if( hasDigest ) new xmpp.Auth( username, null, crypt.SHA1.encode( stream.id+password ), resource );
				else new xmpp.Auth( username, password, null, resource );
				stream.sendIQ( r, handleResult );
			case error : onFailed( new jabber.XMPPError( this, iq ) );
			default : //#
		}
	}
	
	function handleResult( iq : xmpp.IQ ) {
		active = false;
		switch( iq.type ) {
			case result : onSuccess();
			case error : onFailed( new jabber.XMPPError( this, iq ) );
			default : //#
		}
	}
	
}
