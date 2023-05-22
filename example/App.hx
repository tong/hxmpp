
import haxe.io.Bytes;
import sys.net.Socket;
import xmpp.Jid;
import xmpp.IQ;
import xmpp.Presence;
import xmpp.Response;
import xmpp.XML;
import xmpp.client.Stream;

using xmpp.EntityTime;
using xmpp.LastActivity;
using xmpp.PrivateStorage;
using xmpp.ServiceDiscovery;
using xmpp.StartTLS;
using xmpp.client.Authentication;

class App {

    static var socket : Socket;
    static var stream : Stream;

	static function main() {
		var args = Sys.args();
		if(args.length < 2) {
            Sys.stderr().writeString('Invalid arguments\nUsage: hl app.hl <jid> <password> <?ip>\n');
			Sys.exit(1);
		}
		var jid : Jid = args[0];
        jid.resource = jid.resource ?? "hxmpp";
		var password = args[1];
        var host = jid.domain;
        var port = Stream.PORT;

        connect(jid, password, host, port, () -> {
            stream.onPresence = p -> {
                info('${p.from} type=${p.type}');
                if(p.type == null) {
                }
            }
            stream.onMessage = m -> {
                trace('Message from: ${m.from}: ${m.body}');
            }
            stream.onIQ = iq -> {
                switch iq.payload.xmlns {
                case _:
                    trace('Unhandled iq: '+iq.payload.xmlns);
                }
                return null;
            }
            stream.discoItems(res -> switch res {
                case Result(r):
                    info('Server items:');
                    trace(r);
                case Error(e):
                    warn('ERROR ${e.type}, ${e.condition}');
                    trace(e);
            });
            stream.discoInfo((res:Response<Payload>) -> {
                switch res {
                case Result(payload):
                    info('Server info');
                    info(' └─ Identities');
                    for(f in payload.elements.named('identity'))
                        info('   └─ '+f['category']+':'+f['name']);
                    info(' └─ Features');
                    var features = payload.elements.named('feature');
                    for(f in features) info('   └─ '+f["var"]);
                    for(f in features) {
                        switch f['var'] {
                        /*
                        case EntityTime.XMLNS: stream.getEntityTime(res -> switch res {
                            case Result(r): info('Server time: ${r.elements["utc"][0].text} [tzo=${r.elements["tzo"][0].text}]');
                            case Error(e): warn('ERROR ${e.type}, ${e.condition}');
                        });
                        */
                        case EntityTime.XMLNS:
                            stream.getEntityTime(res -> trace(res));
                        case PrivateStorage.XMLNS:
                            var storageElement = XML.create("hxmpp").set("xmlns", "hxmpp:login-count");
                            stream.getPrivateStorage(storageElement, res -> {
                                switch res {
                                case Result(r):
                                    final numLogins = (r.content.text == null) ? 1 : Std.parseInt(r.content.text)+1;
                                    info('Login count: $numLogins');
                                    storageElement.text = Std.string(numLogins);
                                    stream.setPrivateStorage(storageElement, res -> {
                                        if(!res.ok())
                                            warn('Failed to store data on server: '+res.error);
                                    });
                                case Error(e): trace(e);
                                }
                            });
                        }
                    }
                case Error(e): warn(e.toXML());
                }
                stream.send(new Presence());
            });
        });
	}

    static function connect(jid: Jid, password: String, host: String, ?port: Int, onConnect: Void->Void) {
		stream = new Stream(jid.domain);
        var secure = false;
        var host = new sys.net.Host(host);
		socket = new sys.net.Socket();
		function sendData(str:String) {
			println( xmpp.xml.Printer.print(str,true), 32 );
			socket.write(str);
		}
		function recvData(buf) {
			var str : String = buf;
			println( xmpp.xml.Printer.print( str, true ), 33 );
			stream.recv( str );
		}
		stream.output = sendData;
		Sys.println('Connecting $jid');
		socket.connect(host, port);
        function handleStreamOpen(features) {
            info('Stream open');
            if(secure) {
                var mech = new sasl.PlainMechanism(false);
                stream.authenticate(jid.node, jid.resource, password, mech, (?error) -> {
                    if(error != null) {
                        trace(error);
                    } else {
                        info('Stream authenticated');
                        onConnect();
                        //onConnect(stream);
                    }
                });
            } else {
                stream.startTLS(success -> {
                    if(success) {
                        var tls = socket.upgrade(host);
                        //tls.verifyCert = false;
                        tls.handshake();
                        socket = tls;
                        secure = true;
                        stream.start(handleStreamOpen);
                    } else stream.end();
                });
            }
        }
        stream.start(handleStreamOpen);

		final bufSize = 512;
		final maxBufSize = 1024 * 1024;
		var buf = Bytes.alloc(bufSize);
		var pos = 0;
		var bytes : Null<Int> = null;
		while( true ) {
			var available = buf.length - pos;
            try {
			    bytes = socket.input.readBytes( buf, pos, available );
            } catch(e:haxe.io.Eof) {
                trace(e);
                break;
            } catch(e) {
				trace( e );
			}
			pos += bytes;
			//if( pos == bufSize ) {
			if(bytes == bufSize) {
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

	static function print(str: String, ?color: Int, ?background: Int) {
        if(color == null && background == null) Sys.print(str) else {
            final out = new StringBuf();
            final codes = [];
            if(color != null) codes.push(color);
            if(background != null) codes.push(background);
            out.add('\x1B[');
            out.add(codes.join(";")+"m");
            out.add(str+'\x1B[0m');
            Sys.print(out.toString());
        }
	}

	static inline function println(str: String, ?color: Int, ?background: Int)
        print('$str\n', color, background);

    static inline function info(str: String) println(str, 94, 40);
    static inline function warn(str: String) println(str, 95, 40);
    static inline function error(str: String) println(str, 91, 40);
}

