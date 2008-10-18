package jabber.client;

import xmpp.IQ;


/**
*/
class NonSASLAuthentication {
	
	public var stream(default,null) : Stream;
	public var usePlainText : Bool;
	public var authenticating(default,null) : Bool;
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
		
		authenticating = false;
	}


	public dynamic function onSuccess( s : Stream ) {
		// i am yours.
	}
	public dynamic function onFailed( s : Stream ) {
		// i am yours.
	}

	public function authenticate( password : String, ?resource : String ) {
		if( authenticating ) throw "Authentication already in progress";
		this.password = password;
		this.resource = resource;
		authenticating = true;
		var iq = new xmpp.IQ();
		iq.ext = new xmpp.Auth( username );
		stream.sendIQ( iq, handleResponse );
	}
	
	
	function handleResponse( r : IQ ) {
		switch( r.type ) {
			case xmpp.IQType.result :
				
				//var q = xmpp.Auth.parse( r.ext.toXml() );
				//trace(q);
				
				trace("#####################");
				//trace( ( !usePlainText && r.ext.toXml().elementsNamed( "digest" ).next() != null ) );
				var hasDigest = ( !usePlainText && r.ext.toXml().elementsNamed( "digest" ).next() != null );
				trace(hasDigest);
				trace(resource);
				
				var iq = new xmpp.IQ( xmpp.IQType.set );
				iq.ext = if( hasDigest ) new xmpp.Auth( username, null, crypt.SHA1.encode( stream.id+password ), resource );
				else new xmpp.Auth( username, password, null, resource );
				stream.sendIQ( iq, handleResult );
			/*
				var hasDigest = false;
				if( !usePlainText ) {
					for( c in response.ext.toXml().elementsNamed( "digest" ) ) { hasDigest = true; break; }
				}
				var iq = new xmpp.IQ( xmpp.IQType.set );
				iq.ext = if( hasDigest ) new xmpp.Auth( username, null, crypt.SHA1.encode( stream.id + password ), resource );
				else new xmpp.Auth( username, password, null, resource );
				stream.sendIQ( iq, handleResult );
				*/
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
