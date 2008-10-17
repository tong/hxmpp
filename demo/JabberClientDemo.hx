
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
		//var cnx = new jabber.BOSHConnection( "127.0.0.1", 5222 );
		var cnx = new jabber.StreamSocketConnection( "127.0.0.1", 5222 );
		stream = new jabber.client.Stream( new jabber.JID( "tong@disktree" ), cnx, "1.0" );
		stream.onOpen = function(s) {
			trace("JABBER STREAM opened...");
			if( stream.sasl.negotiated ) {
				loginSuccess( stream );
				return;
			}
			var auth = new jabber.client.SASLAuthentication(stream);
			//auth.handshake.registerMechanism( net.sasl.AnonymousMechanism.ID, net.sasl.AnonymousMechanism );
			auth.handshake.mechanisms.push( new net.sasl.AnonymousMechanism() );
			auth.handshake.mechanisms.push( new net.sasl.PlainMechanism() );
			auth.handshake.mechanisms.push( new net.sasl.MD5Mechanism() );
		
			auth.onSuccess = loginSuccess;
			auth.onFailed = function(s) { trace( "LOGIN FAILED" ); };
			//auth.authenticate( "test", "norc" );
			auth.authenticate( "test" );
			
		};
		stream.onClose = function(s) { trace( "Stream to: "+s.jid.domain+" closed." ); } ;
		stream.onXMPP.addHandler( xmppTransferHandler );
		stream.open();
	}
	
	static function loginSuccess( s ) {
		var vcard = new jabber.client.VCardTemp( stream );
		vcard.onLoad = function(vc) {
			trace("VCARD LOADED");
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
		//roster.change = rosterChangeHandler;
		roster.load();
		
		/*
		var service = new jabber.client.ServiceDiscovery(stream);
		service.onInfo = function( e ) {
		}
		service.discoverInfo("account@disktree");
		*/
	}
	
	static function rosterChangeHandler( e ) {
		trace(e.type);
	}
	
	static function xmppTransferHandler( e : jabber.event.XMPPEvent ) {
		trace( "\t" + ( if( e.incoming ) "<<< "+e.data else ">>> "+e.data )+"\n" );
	}
	
}
