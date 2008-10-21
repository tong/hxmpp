package jabber.client;

import xmpp.IQ;


/**
*/
class NonSASLAuthentication {
	
	public dynamic function onFailed( stream : Stream ) {}
	public dynamic function onSuccess( stream : Stream ) {}
	
	public var stream(default,null) : Stream;
	public var active(default,null) : Bool;
	public var usePlainText : Bool;
	public var username(default,null) : String;
	public var password(default,null) : String;
	public var resource(default,null) : String;


	public function new( stream : Stream, ?usePlainText : Bool,
						 ?onSuccess : Stream->Void, ?onFailed : Stream->Void ) {
	
		this.stream = stream;
		this.usePlainText = ( usePlainText != null ) ? usePlainText : false;
		username = stream.jid.node;
		resource = stream.jid.resource;
		if( onSuccess != null ) this.onSuccess = onSuccess;
		if( onFailed != null ) this.onFailed = onFailed;
		
		active = false;
	}


	public function authenticate( password : String, ?resource : String ) {
		if( active ) throw "Authentication already in progress";
		this.password = password;
		this.resource = resource;
		active = true;
		var iq = new IQ();
		iq.ext = new xmpp.Auth( username );
		stream.sendIQ( iq, handleResponse );
	}
	
	
	function handleResponse( r : IQ ) {
		switch( r.type ) {
			case xmpp.IQType.result :
				var hasDigest = ( !usePlainText && r.ext.toXml().elementsNamed( "digest" ).next() != null );
				var iq = new IQ( xmpp.IQType.set );
				iq.ext = if( hasDigest ) new xmpp.Auth( username, null, crypt.SHA1.encode( stream.id+password ), resource );
				else new xmpp.Auth( username, password, null, resource );
				stream.sendIQ( iq, handleResult );
			default : 
				active = false;
				onFailed( stream );
		}
	}
	
	function handleResult( r : IQ ) {
		active = false;
		switch( r.type ) {
			case result : onSuccess( stream );
			default : onFailed( stream );
		}
	}
	
}
