package jabber.client;

import event.Dispatcher;
import xmpp.IQ;


/**
	Client@Server authentication.
*/
class NonSASLAuth {
	
	public var onSuccess(default,null) : Dispatcher<Stream>;
	public var onFailed(default,null) : Dispatcher<Stream>;
	
	public var usePlainText : Bool;
	
	var stream 		: Stream;
	var username 	: String;
	var password 	: String;
	var resource 	: String;
	var authenticating : Bool;
	

	public function new( stream : Stream, ?usePlainText : Bool ) {
	
		this.stream = stream;
		this.usePlainText = ( usePlainText != null ) ? usePlainText : false;
		username = stream.jid.node;
		resource = stream.jid.resource;
		
		onSuccess = new Dispatcher();
		onFailed = new Dispatcher();
		authenticating = false;
	}


	public function authenticate( password : String, ?resource : String ) {
		if( authenticating ) {
			throw "Unable to authenticate, already in progress";
		} else {
			authenticating = true;
			this.password = password;
			this.resource = resource;
			var iq = new IQ();
			iq.extension = new xmpp.iq.Authentication( username );
			//iq.child = new xmpp.iq.Authentication( username ).toXml();
			stream.sendIQ( iq, handleResponse );
		}
	}
	
	
	function handleResponse( response : xmpp.IQ ) {
		if( response.type == IQType.result ) {
			var hasDigest = false;
			for( c in response.extension.toXml().elementsNamed( "digest" ) ) { hasDigest = true; break; }
			var iq = new IQ( IQType.set );
			iq.extension = if( !usePlainText && hasDigest ) new xmpp.iq.Authentication( username, null, crypt.SHA1.encode( stream.id + password ), resource );
			else new xmpp.iq.Authentication( username, password, null, resource );
			stream.sendIQ( iq, handleResult );
		} else {
			onFailed.dispatchEvent( stream );
		}
	}
	
	function handleResult( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case IQType.result : 
				authenticating = false;
				onSuccess.dispatchEvent( stream );
			case IQType.error : 
				authenticating = false;
				onFailed.dispatchEvent( stream );
			default : //#
		}
	}
}
