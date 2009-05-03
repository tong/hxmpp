package jabber.client;

/**
	<a href="http://xmpp.org/extensions/xep-0078.html">XEP-0078: Multi-User Chat</a><br>
*/
class NonSASLAuthentication extends Authentication {
	
	public var active(default,null) : Bool; // TODO remove?
	public var usePlainText(default,null) : Bool;
	public var username(default,null) : String;
	public var password(default,null) : String;

	public function new( stream : Stream,
						 /*?onSuccess : Void->Void, ?onFail : jabber.XMPPError->Void,*/
					 	 ?usePlainText : Bool = false ) {
		super( stream );
		this.usePlainText = usePlainText;
		username = stream.jid.node;
		active = false;
	}

	public override function authenticate( password : String, ?resource : String ) {
		if( active )
			throw new error.Exception( "Authentication already in progress" );
		this.password = password;
		this.resource = resource;
		if( resource != null ) stream.jid.resource = resource; //??
		active = true;
		var iq = new xmpp.IQ();
		iq.ext = new xmpp.Auth( username );
		stream.sendIQ( iq, handleResponse );
		return true;
	}
	
	
	function handleResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				var hasDigest = ( !usePlainText && iq.ext.toXml().elementsNamed( "digest" ).next() != null );
				var r = new xmpp.IQ( xmpp.IQType.set );
				r.ext = if( hasDigest ) new xmpp.Auth( username, null, crypt.SHA1.encode( stream.id+password ), resource );
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
