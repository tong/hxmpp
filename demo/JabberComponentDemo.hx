


class JabberComponentDemo {
	
	static var stream : jabber.component.Stream;
	
	static function main() {
		
		var cnx = new jabber.SocketConnection( "127.0.0.1", 5275 );
		stream = new jabber.component.Stream( "norc", "1234", cnx );
		stream.onOpen = function(s) {
			trace("JABBER STREAM opened...");
		};
		stream.onClose = function(s) { trace( "Stream to: "+s.jid.domain+"closed." ); } ;
		stream.onXMPP.addHandler( xmppTransferHandler );
		stream.open();
	}
	
	static function loginSuccess() {
	}
		
	static function xmppTransferHandler( e : jabber.event.XMPPEvent ) {
		trace( "\t" + if( e.incoming ) "<<< "+e.data else ">>> "+e.data );
	}
	
}
