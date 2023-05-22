
import xmpp.IQ;
import xmpp.Jid;
import xmpp.Message;
import xmpp.Presence;
import xmpp.Stanza; 
import xmpp.client.Stream;
import js.node.net.Socket;

using xmpp.DelayedDelivery;
using xmpp.StartTLS;
using xmpp.client.Authentication;
using xmpp.client.Roster;

class App {

	static function print( str : String, ?color : Int ) {
		if( color != null ) str = '\x1B['+color+'m'+str+'\x1B[0m';
		Sys.println(str);
	}

	public var stream(default,null) : Stream;
	public var secure(default,null) = false;

	public function new() {}

	public function connect(jid: Jid, password: String, ?host : String, callback : Void->Void) {

		if(host == null) host = jid.domain;

		var socket = new Socket();

		function sendData(str:String) {
			print( xmpp.xml.Printer.print(str,true), 32 );
			socket.write( str );
		};

		function recvData(buf) {
			var str : String = #if nodejs buf.toString() #else buf #end;
			print( xmpp.xml.Printer.print( str, true ), 33 );
			stream.recv( str );
		}

		socket.on(Data, recvData);
		socket.on(End, () -> trace('Socket disconnected'));
		socket.on(Error, e -> trace('Socket error',e));

		stream = new Stream(jid.domain);
		stream.onPresence = p -> trace('Presence from: '+p.from);
		stream.onMessage = m -> {
            var delay = m.getDelay();
            var str = '[${m.from}]';
            if(delay != null) str += '[delay=${delay.stamp}]';
            str += ' ${m.body}';
            Sys.println(str);
        }
		stream.onIQ = iq -> {
			trace('Unhandled iq: '+iq);
            //return Error({type: cancel, condition: feature_not_implemented});
            return null;
		}

		stream.output = sendData;

        function handleStreamOpen(features) {
            if(secure) {
                var mech = new sasl.PlainMechanism(false);
                //var mech = new sasl.SCRAMSHA1Mechanism();
                stream.authenticate(jid.node, jid.resource, password, mech, (?error)->{
                    trace("logged in");
                    stream.send(new Presence());
                });
            } else {
				stream.startTLS(success -> {
					if(success) {
					    socket = socket.upgrade();
						socket.on(Data, recvData);
						// tls.on(End, () -> trace('TLSSocket disconnected'));
						// tls.on(Error, e -> trace('TLSSocket error',e));
                        socket.on('keylog', e -> trace(e));
                        socket.on('secure', () -> {
                            secure = true;
                        });
						stream.start(handleStreamOpen);
                    }
                });
            }
        }

		socket.connect(xmpp.client.Stream.PORT, host, ()->{
			stream.start(handleStreamOpen);
		});
	}

	static function main() {
		var args = Sys.args();
		if(args.length < 2) {
			Sys.println('Invalid arguments');
			Sys.println('\tUsage: node app.js <jid> <password> <?ip>');
			Sys.exit(1);
		}
		var jid : Jid = args[0];
        jid.resource = jid.resource ?? "hxmpp";
		var password = args[1];
		var host = (args[2] == null) ? jid.domain : args[2];
		var client = new App();
		client.connect(jid, password, host, () -> {
			trace("Client connected");
		});
	}
}
