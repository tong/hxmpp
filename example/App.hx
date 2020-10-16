
import haxe.io.Bytes;
import xmpp.JID;
import xmpp.IQ;
import xmpp.Message;
import xmpp.Presence;
import xmpp.Stream;
import xmpp.client.Stream;
import xmpp.XML;
import xmpp.sasl.*;
#if sys
import sys.net.Socket;
#elseif nodejs
import js.node.net.Socket;
import js.node.tls.TLSSocket;
#end

using xmpp.client.Authentication;
using xmpp.client.StartTLS;

class App {

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
		
		var stream = new Stream( jid.domain );
		stream.onPresence = p -> trace( 'Presence from: '+p.from );
		stream.onMessage = m -> trace( 'Message from: '+m.from );
		stream.onIQ = iq -> {
			trace( 'Unhandled iq: '+iq );
		}

		var socket = new Socket();
		
		function sendData(str:String) {
			print( xmpp.extra.Printer.print(str,true), 32 );
			socket.write( str );
		}
		
		function recvData(buf) {
			var str : String = #if nodejs buf.toString() #else buf #end;
			print( xmpp.extra.Printer.print( str, true ), 33 );
			stream.recv( str );
		}

		stream.output = sendData;

		Sys.println( 'Connecting $jid' );

		#if sys

		socket.connect( new sys.net.Host( ip ), port );
		stream.start( function(features){
			stream.startTLS( function(success){
				trace(success);
				trace('tls socket upcast not implemented');
				/*
				var ssl = new sys.ssl.Socket();
				ssl.verifyCert = false;
				ssl.connect( new sys.net.Host( ip ), port );
				*/
			});
		});

		var bufSize = 512;
		var maxBufSize = 1024 * 1024;
		var buf = Bytes.alloc( bufSize );
		var pos = 0;
		var bytes : Int;
		while( true ) {
			var available = buf.length - pos;
			try bytes = try socket.input.readBytes( buf, pos, available ) catch(e:Dynamic) {
				trace( e );
				return false;
			}
			pos += bytes;
			if( pos == bufSize ) {
				var nsize = buf.length + bufSize;
				if( nsize >= maxBufSize ) {
					trace( 'max buffer size ($maxBufSize)' );
					return false;
				}
				var nbuf = Bytes.alloc( nsize );
				nbuf.blit( 0, buf, 0, buf.length );
				buf = nbuf;
			} else {
				var str = buf.sub( 0, pos ).toString();
				recvData( str );
				buf = Bytes.alloc( bufSize );
				pos = 0;
			}
		}

		#elseif nodejs

		var tls : TLSSocket = null;

	/* 	function handleSocketData(buf) {
			var str : String = buf.toString();
			print( xmpp.extra.Printer.print( str, true ), 33 );
			stream.recv( str );
		}
 */
		//var socket = new js.node.net.Socket();
		socket.on( Data, recvData );
		socket.on( End, () -> trace('Socket disconnected') );
		socket.on( Error, e -> trace('Socket error',e) );
		socket.connect( port, ip, function() {
			stream.start( function(features){
				stream.startTLS( function(success){
					if( success ) {
						var tls = new js.node.tls.TLSSocket( socket, { requestCert: true, rejectUnauthorized: true } );
						tls.on( End, () -> trace('TLSSocket disconnected') );
						tls.on( Error, e -> trace('TLSSocket error',e) );
						tls.on( Data, recvData );
						socket = tls;
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

		#end
	}
}
