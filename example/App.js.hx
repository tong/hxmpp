import js.Node.process;
import js.node.Net;
import js.node.net.Socket;
import xmpp.Jid;
import xmpp.Presence;
import xmpp.Response;
import xmpp.XML;
import xmpp.client.Authentication;
import xmpp.client.Roster;
import xmpp.client.Stream;

using xmpp.DelayedDelivery;
using xmpp.StartTLS;
using xmpp.client.Authentication;
using xmpp.client.Roster;

/**
	Basic XMPP client for nodejs.

	Connects to the server, secures the connection, logs in, prints the roster and incoming messages.

		node app.js <jid> <password> [host]
**/
class App {
	static var socket:Socket;
	static var stream:Stream;

	static function main() {
		final args = Sys.args();
		if (args.length < 2) {
			Sys.println('Usage: node app.js <jid> <password> [host]');
			Sys.exit(1);
		}
		final jid:Jid = args[0];
		final password = args[1];
		final host = args[2] ?? jid.domain;

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

		Sys.println('Connecting to $host');
		socket = Net.connect(Stream.PORT, host, () -> stream.start(features -> {
			// Upgrade the connection to TLS before sending any credentials
			stream.startTLS(success -> {
				if (!success)
					exit('Server does not support TLS');
				socket = socket.upgrade(jid.domain);
				listen();
				socket.on('secureConnect', () -> stream.start(features -> login(jid, password, features)));
			});
		}));
		listen();

		process.on('SIGINT', () -> {
			stream.send(new Presence(null, null, null, unavailable));
			stream.end();
			socket.end();
		});
	}

	static function login(jid:Jid, password:String, features:XML) {
		final mechanism = Authentication.selectMechanism(features);
		if (mechanism == null)
			exit('No supported authentication mechanism offered: ${Authentication.getMechanisms(features)}');
		stream.authenticate(jid.node, jid.resource ?? 'hxmpp', password, mechanism, (?error) -> {
			if (error != null)
				exit('Login failed: ${error.condition} ${error.text ?? ""}');
			Sys.println('Logged in as ${stream.jid}');
			Roster.handleRequests(stream, (item, ver) -> Sys.println('Contact changed: ${item.jid} [${item.subscription}]'));
			stream.loadRoster(res -> {
				switch res {
					case Result(payload):
						Sys.println('Contacts:');
						for (item in Roster.parseRoster(payload).items)
							Sys.println('  ${item.jid} ${item.name ?? ""} [${item.subscription}]');
					case Error(e):
						Sys.println('Failed to load roster: ${e.condition}');
				}
				stream.send(new Presence());
			});
		});
	}

	static function listen() {
		socket.setEncoding('utf8');
		socket.on('data', (str:String) -> {
			log(str, 33);
			stream.recv(str);
		});
		socket.on('error', e -> exit(e.message));
		socket.on('end', () -> exit('Disconnected'));
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
