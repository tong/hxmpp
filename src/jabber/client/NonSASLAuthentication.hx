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
		iq.extension = new xmpp.IQAuthentication( username );
		stream.sendIQ( iq, handleResponse );
	}
	
	
	function handleResponse( response : xmpp.IQ ) {
		if( response.type == IQType.result ) {
			var hasDigest = false;
			for( c in response.extension.toXml().elementsNamed( "digest" ) ) { hasDigest = true; break; }
			var iq = new IQ( IQType.set );
	//		#if !php
			iq.extension = if( !usePlainText && hasDigest ) new xmpp.IQAuthentication( username, null, crypt.SHA1.encode( stream.id + password ), resource );
			else new xmpp.IQAuthentication( username, password, null, resource );
			stream.sendIQ( iq, handleResult );
	//		#end
		} else {
			authenticating = false;
			onFailed.dispatchEvent( stream );
		}
	}
	
	function handleResult( iq : xmpp.IQ ) {
		authenticating = false;
		switch( iq.type ) {
			case IQType.result :
				#if JABBER_DEBUG trace( "Jabber authentication of "+username+" success.\n" ); #end
				onSuccess.dispatchEvent( stream );
			default :
				#if JABBER_DEBUG trace( "Jabber authentication "+username+" failed.\n" ); #end
				onFailed.dispatchEvent( stream );
		}
	}
	
}
