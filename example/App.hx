import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import sys.net.Host;
import sys.net.Socket;
import xmpp.Jid;
import xmpp.Presence;
import xmpp.Response;
import xmpp.XML;
import xmpp.client.Authentication;
import xmpp.client.Stream;

using xmpp.DelayedDelivery;
using xmpp.StartTLS;
using xmpp.client.Authentication;
using xmpp.client.Roster;

/**
	Basic XMPP client for sys targets (hl, cpp, neko, lua, python).

	Connects to the server, secures the connection, logs in, prints the roster and incoming messages.

		hl app.hl <jid> <password> [host]
**/
class App {
	static var socket:Socket;
	static var stream:Stream;

	static function main() {
		final args = Sys.args();
		if (args.length < 2) {
			Sys.println('Usage: hl app.hl <jid> <password> [host]');
			Sys.exit(1);
		}
		final jid:Jid = args[0];
		final password = args[1];
		final host = new Host(args[2] ?? jid.domain);

		stream = new Stream(jid.domain);
		stream.output = str -> {
			log(str, 32);
			socket.write(str);
		}
		stream.onMessage = m -> {
			if (m.body == null)
				return;
			final delay = m.delay();
			Sys.println('${m.from}: ${m.body}' + (delay != null ? ' (sent ${delay.stamp})' : ''));
		}
		stream.onPresence = p -> Sys.println('${p.from} is ${p.type ?? "available"}');

		Sys.println('Connecting to ${host.host}');
		socket = new Socket();
		socket.connect(host, Stream.PORT);
		stream.start(features -> {
			// Upgrade the connection to TLS before sending any credentials
			stream.startTLS(success -> {
				if (!success)
					exit('Server does not support TLS');
				final tls = socket.upgrade(host);
				try
					tls.handshake()
				catch (e)
					exit('TLS handshake failed (invalid certificate?): $e');
				socket = tls;
				stream.start(features -> login(jid, password, features));
			});
		});
		read();
	}

	static function login(jid:Jid, password:String, features:XML) {
		final mechanism = Authentication.selectMechanism(features);
		if (mechanism == null)
			exit('No supported authentication mechanism offered: ${Authentication.getMechanisms(features)}');
		stream.authenticate(jid.node, jid.resource ?? 'hxmpp', password, mechanism, (?error) -> {
			if (error != null)
				exit('Login failed: ${error.condition} ${error.text ?? ""}');
			Sys.println('Logged in as ${stream.jid}');
			stream.send(new Presence());
			stream.loadRoster(res -> switch res {
				case Result(roster):
					Sys.println('Contacts:');
					for (item in roster.elements)
						Sys.println('  ${item["jid"]} ${item["name"] ?? ""} [${item["subscription"]}]');
				case Error(e):
					Sys.println('Failed to load roster: ${e.condition}');
			});
		});
	}

	/**
		Reads from the socket until disconnected.
		Data is passed to the stream once no more is available, so multi-byte characters are not split.
	**/
	static function read() {
		final buf = Bytes.alloc(4096);
		var data = new BytesBuffer();
		while (true) {
			final len = try socket.input.readBytes(buf, 0, buf.length) catch (e:haxe.io.Eof) exit('Disconnected');
			data.addBytes(buf, 0, len);
			if (len < buf.length) {
				final str = data.getBytes().toString();
				data = new BytesBuffer();
				log(str, 33);
				stream.recv(str);
			}
		}
	}

	static function log(str:String, color:Int) {
		#if xmpp_debug
		Sys.println('\x1B[${color}m' + xmpp.xml.Printer.print(str, true) + '\x1B[0m');
		#end
	}

	static function exit<T>(message:String):T {
		Sys.println(message);
		Sys.exit(1);
		return null;
	}
}
