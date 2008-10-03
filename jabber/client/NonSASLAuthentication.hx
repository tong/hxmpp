package jabber.client;

import xmpp.IQ;


/**
*/
class NonSASLAuthentication {
	
	public var stream(default,null) : Stream;
	public var usePlainText : Bool;
	public var authenticating(default,null) : Bool;
	
	var username : String;
	var password : String;
	var resource : String;


	public function new( stream : Stream, ?usePlainText : Bool,
										  ?onSuccess : Stream->Void, ?onFailed : Stream->Void ) {
	
		this.stream = stream;
		this.usePlainText = ( usePlainText != null ) ? usePlainText : false;
		username = stream.jid.node;
		resource = stream.jid.resource;
		if( onSuccess != null ) this.onSuccess = onSuccess;
		if( onFailed != null ) this.onFailed = onFailed;
		
		authenticating = false;
	}


	public dynamic function onSuccess( stream : Stream ) { /* i am yours */ }
	public dynamic function onFailed( stream : Stream ) { /* i am yours */ }

	public function authenticate( password : String, ?resource : String ) {
		if( authenticating ) throw "Authentication already in progress";
		this.password = password;
		this.resource = resource;
		authenticating = true;
		var iq = new xmpp.IQ();
		iq.ext = new xmpp.iq.Auth( username );
		stream.sendIQ( iq, handleResponse );
	}
	
	
	function handleResponse( response : xmpp.IQ ) {
		switch( response.type ) {
			case xmpp.IQType.result :
				var hasDigest = false;
				for( c in response.ext.toXml().elementsNamed( "digest" ) ) { hasDigest = true; break; }
				var iq = new xmpp.IQ( xmpp.IQType.set );
				iq.ext = if( !usePlainText && hasDigest ) new xmpp.iq.Auth( username, null, crypt.SHA1.encode( stream.id + password ), resource );
				else new xmpp.iq.Auth( username, password, null, resource );
				stream.sendIQ( iq, handleResult );
			default : 
				authenticating = false;
				onFailed( stream );
		}
	}
	
	function handleResult( r : xmpp.IQ ) {
		authenticating = false;
		switch( r.type ) {
			case result : onSuccess( stream );
			default : onFailed( stream );
		}
	}
	
}
