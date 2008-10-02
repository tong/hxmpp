
import jabber.StreamSocketConnection;
import jabber.client.NonSASLAuthentication;



class JabberClientDemo {
	
	static var stream : jabber.client.Stream;
	
	
	static function main() {
		
		jabber.util.XMPPDebug.redirectTraces();
		
		trace("JÄBA");
		
		#if JABBER_SOCKETBRIDGE
		trace( "Using JABBER_SOCKETBRIDGE" );
		jabber.SocketBridgeConnection.init( "f9bridge", init );
		#else
		init();
		#end
	}
	
	
	static function init() {
		var cnx = new jabber.StreamSocketConnection( "jabber.spektral.at", 5222 );
		stream = new jabber.client.Stream( new jabber.JID("tong@jabber.spektral.at"), cnx, "1.0" );
		stream.onOpen = function(s) {
			trace("JABBER STREAM opened...");
			var auth = new NonSASLAuthentication(s);
			auth.onSuccess = loginSuccess;
			auth.onFailed = function(s) { trace( "LOGIN FAILED" ); };
			auth.authenticate( "sp3ak", "norc" );
		};
		stream.onClose = function(s) { trace( "Stream to: "+s.jid.domain+" closed." ); } ;
		stream.onXMPP.addHandler( xmppTransferHandler );
		stream.open();
	}
	
	static function loginSuccess( s ) {
		var vcard = new jabber.client.VCardTemp( stream );
		vcard.onLoad = function(vc) {
			//trace(vc.data);
		}
		vcard.load();
		
		/*
		#if neko
		var zlib = new jabber.util.ZLibCompression();
		var compression = new jabber.StreamCompression( s );
		compression.request( zlib );
		#end
		*/
		
		var roster = new jabber.client.Roster( stream );
		roster.onAvailable = function(r) {
			trace( "ROSTER AVAILABLE " );
			for( e in r.entries ) {
				trace("ENTRY: "+ e.jid );
			}
		};
		roster.load();
		
		/*
		var service = new jabber.client.ServiceDiscovery(stream);
		service.onInfo = function( e ) {
		}
		service.discoverInfo("account@disktree");
		*/
	}
		
	static function xmppTransferHandler( e : jabber.event.XMPPEvent ) {
		trace( "\t" + ( if( e.incoming ) "<<< "+e.data else ">>> "+e.data )+"\n" );
	}
	
}
