
import js.Node.console;
import js.Node.process;
import js.node.Buffer;
import js.node.Readline;
import js.node.net.Socket;
import js.node.tls.TLSSocket;
import xmpp.JID;
import xmpp.IQ;
import xmpp.Message;
import xmpp.Presence;
import xmpp.Stream;
import xmpp.client.Stream;
import xmpp.XML;
import xmpp.sasl.*;

using Lambda;
using StringTools;
using xmpp.client.Authentication;
using xmpp.client.StartTLS;

class App {

    static var tls : TLSSocket;
    static var stream : Stream;

	static function handleSocketDisconnect() {
        trace( 'Socket disconnected' );
    }
	
	static function handleSocketError(e) {
		trace( 'Socket error', e );
    }

	static function handleSocketData(buf) {
		var str : String = buf.toString();
		print( xmpp.extra.Printer.print( str, true ), 33 );
		stream.recv( str );
	}
	
	static function print( str : String, ?color : Int ) {
		if( color != null ) str = '\x1B['+color+'m'+str+'\x1B[0m';
		Sys.println(str);
	}

	static function main() {

		var args = Sys.args();
		if( args.length < 2 ) {
			Sys.println( 'Invalid arguments' );
			Sys.println( 'Usage: node app.js <jid> <password> <?ip>' );
			Sys.exit(1);
		}

		var jid : JID = args[0];
		if( jid.resource == null ) jid.resource = 'hxmpp';
		var password = args[1];
		var ip = (args[2] == null) ? jid.domain : args[2];
		var port = (args[3] == null) ? xmpp.client.Stream.PORT : Std.parseInt( args[3] );

		var socket = new Socket();
		socket.on( Data, handleSocketData );
		socket.on( End, handleSocketDisconnect );
		socket.on( Error, handleSocketError );
		socket.connect( port, ip, function() {

			stream = new Stream( jid.domain );

			stream.output = function(str){
				print( xmpp.extra.Printer.print(str,true), 32 );
				if( tls != null ) tls.write( str ) else socket.write( str );
			}

			stream.onPresence = p -> trace( 'Presence from: '+p.from );
			stream.onMessage = m -> trace( 'Message from: '+m.from );
			stream.onIQ = iq -> {
				trace( 'Unhandled iq: '+iq );
			}

			stream.start( function(features){
				stream.startTLS( function(success){
					if( success ) {
						tls = new TLSSocket( socket, { requestCert: true, rejectUnauthorized: true } );
						tls.on( End, handleSocketDisconnect );
						tls.on( Data, handleSocketData );
						tls.on( Error, handleSocketError );
						stream.start( function(features){
							var mech = new PlainMechanism();
							//var mech = new SCRAMSHA1Mechanism();
							stream.authenticate( jid.node, jid.resource, password, mech, function(?e){
								stream.query( new IQ('jabber:iq:roster'), r -> {
									stream.send( new Presence() );
								});
							});
						});
					} else {
						trace( "StartTLS failed" );
						socket.end();
					}
				});
			});
		});
	}
}
