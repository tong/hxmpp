
import haxe.io.Bytes;
import xmpp.JID;
import xmpp.IQ;
import xmpp.Message;
import xmpp.Presence;
import xmpp.Stream;
import xmpp.client.Stream;
import xmpp.XML;
import sasl.*;

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
            Sys.stderr().writeString('Invalid arguments\nUsage: node app.js <jid> <password> <?ip>\n');
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
        
		var socket = new sys.net.Socket();
		
		function sendData(str:String) {
			print( xmpp.xml.Printer.print(str,true), 32 );
			socket.write(str);
		}
		
		function recvData(buf) {
			var str : String = buf;
			print( xmpp.xml.Printer.print( str, true ), 33 );
			stream.recv( str );
		}

		stream.output = sendData;

		Sys.println( 'Connecting $jid' );
        
		socket.connect( new sys.net.Host( ip ), port );
        stream.start( features -> {
            trace(features);
            var mech = new SCRAMSHA1Mechanism();
            stream.authenticate( jid.node, jid.resource, password, mech, (?error) -> {
                trace(error);
                stream.send(new Presence());
            });
            /*
            stream.startTLS( function(success){
                trace(success);
                trace('tls socket upcast not implemented');
                /*
                var ssl = new sys.ssl.Socket();
                ssl.verifyCert = false;
                ssl.connect( new sys.net.Host( ip ), port );
            });
            */
        });

		var bufSize = 512;
		var maxBufSize = 1024 * 1024;
		var buf = Bytes.alloc( bufSize );
		var pos = 0;
		var bytes : Null<Int> = null;
		while( true ) {
			var available = buf.length - pos;
            try {
			    bytes = socket.input.readBytes( buf, pos, available );
            } catch(e:Dynamic) {
				trace( e );
			}
			pos += bytes;
			if( pos == bufSize ) {
				var nsize = buf.length + bufSize;
				if( nsize >= maxBufSize ) {
					trace( 'max buffer size ($maxBufSize)' );
					//return false;
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
	}
}
