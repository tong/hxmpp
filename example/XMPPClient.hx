
import xmpp.JID;
import xmpp.IQ;
import xmpp.Message;
import xmpp.Presence;
import xmpp.Stream;
import xmpp.client.Stream;
import xmpp.XML;
import xmpp.sasl.*;
import js.node.net.Socket;
import js.node.tls.TLSSocket;
import Sys.print;
import Sys.println;

using xmpp.client.Authentication;
using xmpp.client.StartTLS;
using xmpp.client.Roster;
using xmpp.ServiceDiscovery;

class XMPPClient {

	static function print( str : String, ?color : Int ) {
		if( color != null ) str = '\x1B['+color+'m'+str+'\x1B[0m';
		Sys.println(str);
	}

	public var jid(default,null) : JID;
	public var stream(default,null) : Stream;

	var password : String;
	var socket : Socket;
	var tls : TLSSocket;

	public function new( jid : JID, password : String ) {
		this.jid = jid;
		this.password = password;
	}

	public function login( ?ip : String, onReady : Void->Void ) {

		if( ip == null ) ip = jid.domain;

		function sendData(str:String) {
			print( xmpp.xml.Printer.print(str,true), 32 );
			socket.write( str );
		};

		function recvData(buf) {
			var str : String = #if nodejs buf.toString() #else buf #end;
			print( xmpp.xml.Printer.print( str, true ), 33 );
			stream.recv( str );
		}

		socket = new Socket();
		socket.on( Data, recvData );
		socket.on( End, () -> trace('Socket disconnected') );
		socket.on( Error, e -> trace('Socket error',e) );

		stream = new Stream( jid.domain );
		stream.onPresence = p -> trace( 'Presence from: '+p.from );
		stream.onMessage = m -> trace( 'Message from: '+m.from );
		stream.onIQ = iq -> {
			trace( 'Unhandled iq: '+iq );
		}

		stream.output = sendData;

		socket.connect( xmpp.client.Stream.PORT, ip, function() {
			stream.start( function(features){
				trace(features);
				stream.startTLS( function(success){
					if( success ) {
						var tls = new js.node.tls.TLSSocket( socket, { requestCert: true, rejectUnauthorized: true } );
						tls.on( End, () -> trace('TLSSocket disconnected') );
						tls.on( Error, e -> trace('TLSSocket error',e) );
						tls.on( Data, recvData );
						socket = tls;
						stream.start( function(features){
							for( f in features.elements ) trace(f);
							var mech = new PlainMechanism();
							//var mech = new SCRAMSHA1Mechanism();
							stream.authenticate( jid.node, jid.resource, password, mech, function(?error){
								if( error != null ) {
									trace( error.condition, error.text );
									stream.end();
									socket.end();
								} else {

									/* stream.extensions.set( ServiceDiscovery.XMLNS_INFO, iq -> {
										trace(iq);
									} ); */

									stream.getRoster( r -> {
										switch r {
										case Result(roster):
											for( i in roster.items ) println( i);
										case Error(e):
											trace(e);
										}

										stream.send( new Presence() );

										/* stream.getDiscoInfo( stream.domain, r -> {
											switch r {
											case Result(p):
												for( i in p.identity ) trace(i);
												for( f in p.feature ) trace(f);
											case Error(e):
											}
										});

										stream.getDiscoItems( stream.domain, r -> {
											switch r {
											case Result(p):
												for( i in p.items ) trace(i);
											case Error(e):
											}
										}); */
									});

									/*
									stream.query( new IQ('jabber:iq:roster'), r -> {
										stream.send( new Presence() );
										onReady();
									});
									*/
								}
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

	static function main() {

		var args = Sys.args();
		if( args.length < 2 ) {
			Sys.println( 'Invalid arguments' );
			Sys.println( '\tUsage: node app.js <jid> <password> <?ip>' );
			Sys.exit(1);
		}

		var jid : JID = args[0];
		if( jid.resource == null ) jid.resource = 'hxmpp';
		var password = args[1];
		var ip = (args[2] == null) ? jid.domain : args[2];

		var client = new XMPPClient( jid, password );
		client.login( ip, () -> {
			trace("Client connected");
		});
	}
}
