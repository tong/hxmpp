package jabber.client;

import event.Dispatcher;
import xmpp.IQ;


/**
	Client@Server authentication.
*/
class NonSASLAuthentication {
	
	public var onSuccess(default,null) : Dispatcher<Stream>;
	public var onFailed(default,null)  : Dispatcher<Stream>;
	
	public var usePlainText : Bool;
	public var authenticating(default,null) : Bool;
	
	var stream 		: Stream;
	var username 	: String;
	var password 	: String;
	var resource 	: String;
	

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
		if( authenticating ) throw "Authentication already in progress";
		this.password = password;
		this.resource = resource;
		authenticating = true;
		var iq = new IQ();
		iq.extension = new xmpp.iq.Authentication( username );
		stream.sendIQ( iq, handleResponse );
	}
	
	
	function handleResponse( response : xmpp.IQ ) {
		if( response.type == IQType.result ) {
			var hasDigest = false;
			for( c in response.extension.toXml().elementsNamed( "digest" ) ) { hasDigest = true; break; }
			var iq = new IQ( IQType.set );
	//		#if !php
			iq.extension = if( !usePlainText && hasDigest ) new xmpp.iq.Authentication( username, null, crypt.SHA1.encode( stream.id + password ), resource );
			else new xmpp.iq.Authentication( username, password, null, resource );
			stream.sendIQ( iq, handleResult );
	//		#end
		} else {
			authenticating = false;
			onFailed.dispatchEvent( stream );
		}
	}
	
	function handleResult( iq : xmpp.IQ ) {
		if( iq.type == IQType.result ) {
			authenticating = false;
			#if JABBER_DEBUG trace( "Authentication success.\n" ); #end
			onSuccess.dispatchEvent( stream );
		} else {
			authenticating = false;
			#if JABBER_DEBUG trace( "Authentication error.\n" ); #end
			onFailed.dispatchEvent( stream );
		}
	}
	
}
