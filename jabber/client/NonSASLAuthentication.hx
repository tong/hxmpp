package jabber.client;

import jabber.event.IQResult;
import xmpp.IQ;


/**
*/
class NonSASLAuthentication {
	
	public dynamic function onSuccess( s : Stream ) {}
	public dynamic function onFailed( s : jabber.event.XMPPErrorEvent<Stream> ) {}
	
	public var stream(default,null) : Stream;
	public var active(default,null) : Bool;
	public var usePlainText : Bool;
	public var username(default,null) : String;
	public var password(default,null) : String;
	public var resource(default,null) : String;


	public function new( stream : Stream, ?usePlainText : Bool ) {
	
		this.stream = stream;
		this.usePlainText = ( usePlainText != null ) ? usePlainText : false;
		username = stream.jid.node;
		resource = stream.jid.resource;
		
		active = false;
	}


	public function authenticate( password : String, ?resource : String ) {
		if( active ) throw new error.Exception( "Authentication already in progress" );
		this.password = password;
		this.resource = resource;
		active = true;
		var iq = new IQ();
		iq.ext = new xmpp.Auth( username );
		stream.sendIQ( iq, handleResponse );
	}
	
	
	function handleResponse( r : IQ ) {
		switch( r.type ) {
			case result :
				var hasDigest = ( !usePlainText && r.ext.toXml().elementsNamed( "digest" ).next() != null );
				var iq = new IQ( xmpp.IQType.set );
				iq.ext = if( hasDigest ) new xmpp.Auth( username, null, crypt.SHA1.encode( stream.id+password ), resource );
				else new xmpp.Auth( username, password, null, resource );
				stream.sendIQ( iq, handleResult );
			case error :
				onFailed( new jabber.event.XMPPErrorEvent<Stream>( stream, r ) );
			default : //#
		}
	}
	
	function handleResult( iq : IQ ) {
		active = false;
		switch( iq.type ) {
			case result : onSuccess( stream );
			case error : onFailed( new jabber.event.XMPPErrorEvent<Stream>( stream, iq ) );
			default : //#
		}
	}
	
}
