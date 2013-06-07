
import jabber.client.Stream;
import jabber.client.Authentication;

class App {

	static function main() {
		var creds = XMPPClient.getAccountFromFile( 'a' );
		trace(creds);
		var jid = new jabber.JID( creds.user+'@'+creds.host );
		var cnx = new jabber.BOSHConnection( creds.host, creds.http );
		var stream = new Stream( cnx );
		stream.onOpen = function() {
			var auth = new Authentication( stream, [
				new jabber.sasl.MD5Mechanism()
			] );
			auth.onFail = function(e) {
				trace( "Authentication failed ("+stream.jid+")", "warn" );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( "Authenticated as "+stream.jid );
				stream.sendPresence();
			}
			auth.start( creds.password, 'hxmpp-bosh' );
		}
		stream.onClose = function(?e) {
			if( e == null )
				trace( 'XMPP stream closed', 'warn' );
			else
				trace( 'XMPP stream error : $e', 'error' );
			cnx.disconnect();
		}
		stream.open( jid );

		/*
		var jid = new jabber.JID( USER+'@'+HOST );
		if( IP == null )
			IP = jid.domain;
		var cnx = new jabber.BOSHConnection( HOST, HTTP );
		stream = new Stream( cnx );
		stream.onOpen = function() {
			var auth = new Authentication( stream, [
				new jabber.sasl.MD5Mechanism()
			] );
			auth.onFail = function(e) {
				trace( "Authentication failed ("+stream.jid+")", "warn" );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( "Authenticated as "+stream.jid );
				stream.sendPresence();
			}
			auth.start( PASSWORD, RESOURCE );
		}
		stream.onClose = function(?e) {
			if( e == null )
				trace( 'XMPP stream closed', 'warn' );
			else
				trace( 'XMPP stream error : $e', 'error' );
			cnx.disconnect();
		}
		stream.open( jid );
		*/
	}

}
