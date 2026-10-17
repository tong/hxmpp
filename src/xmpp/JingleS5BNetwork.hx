package xmpp;

import haxe.io.Bytes;
import xmpp.JingleS5B;

/**
	Network access for SOCKS5 bytestreams.
**/
interface JingleS5BNetwork {
	/** Opens a TCP connection, `callback` is called with an error or the connection **/
	function connect(host:String, port:Int, callback:(error:Null<String>, connection:Null<JingleS5BConnection>) -> Void):Void;

	/**
		Listens for TCP connections on all interfaces on a free port, `callback` is called with an error or the port.
		Returns a function to stop listening.
	**/
	function listen(onConnection:JingleS5BConnection->Void, callback:(error:Null<String>, port:Int) -> Void):() -> Void;
		/** Returns the addresses of the local interfaces (offered for direct connections) **/
		function addresses():Array<String>;
}

/**
	A TCP connection.

	Data is delivered only after the connection was passed to the `connect` callback or `onConnection`: set `onData`
	and `onClose` there (synchronously), nothing received before is lost.
**/
interface JingleS5BConnection {
	/** Called with received data **/
	var onData:Bytes->Void;

	/** Called once the connection is closed **/
	var onClose:() -> Void;

	function write(data:Bytes):Void;

	/** Calls `callback` once the data written so far is sent (e.g. to write a large file in parts) **/
	function written(callback:() -> Void):Void;

	function close():Void;
}

#if nodejs
/**
	Network access for SOCKS5 bytestreams on nodejs.
**/
class JingleS5BNodeNetwork implements JingleS5BNetwork {
	/** Connection timeout in milliseconds **/
	public var timeout:Int;

	public function new(timeout = 5000)
		this.timeout = timeout;

	public function connect(host:String, port:Int, callback:(error:Null<String>, connection:Null<JingleS5BConnection>) -> Void) {
		var done = false;
		final socket = js.node.Net.connect({host: host, port: port});
		socket.setTimeout(timeout);
		socket.once('connect', () -> {
			if (done)
				return;
			done = true;
			socket.setTimeout(0);
			callback(null, new NodeConnection(socket));
		});
		socket.once('timeout', () -> {
			if (done)
				return;
			done = true;
			socket.destroy();
			callback('timeout', null);
		});
		socket.once('error', (e:js.lib.Error) -> {
			if (done)
				return;
			done = true;
			callback(e.message, null);
		});
	}

	public function listen(onConnection:JingleS5BConnection->Void, callback:(error:Null<String>, port:Int) -> Void):() -> Void {
		final server = js.node.Net.createServer(socket -> onConnection(new NodeConnection(socket)));
		server.once('error', (e:js.lib.Error) -> callback(e.message, 0));
		server.listen({port: 0}, () -> callback(null, (server.address() : Dynamic).port));
		return () -> server.close();
	}

	public function addresses():Array<String> {
		final list = [];
		final interfaces = js.node.Os.networkInterfaces();
		for (name in interfaces.keys())
			for (i in interfaces.get(name)) {
				final info:Dynamic = i;
				if (!info.internal && (info.family == 'IPv4' || info.family == 4))
					list.push(info.address);
			}
		return list;
	}
}

private class NodeConnection implements JingleS5BConnection {
	public var onData:Bytes->Void = data -> {};
	public var onClose:() -> Void = () -> {};

	final socket:js.node.net.Socket;

	public function new(socket:js.node.net.Socket) {
		this.socket = socket;
		socket.on('data', (data:js.node.Buffer) -> onData(data.hxToBytes()));
		socket.on('close', () -> onClose());
		socket.on('error', (e:js.lib.Error) -> {});
	}

	public function write(data:Bytes)
		socket.write(js.node.Buffer.hxFromBytes(data));

	public function written(callback:() -> Void)
		socket.write(js.node.Buffer.alloc(0), () -> callback());

	public function close()
		socket.end();
}
#end

#if (sys && target.threaded)
/**
	Network access for SOCKS5 bytestreams on sys targets (e.g. hl, cpp), with threads for blocking socket operations.

	Callbacks must run on the thread using the stream: `post` is called with each callback and has to run it there,
	e.g. by adding it to the event queue of the application.

		final s5b:JingleS5BConfig = {network: new JingleS5BSysNetwork(f -> events.add(f))};

	Only the address of the interface of the default route is offered for direct connections (`addresses`).
**/
class JingleS5BSysNetwork implements JingleS5BNetwork {
	/** Connection timeout in seconds **/
	public var timeout:Float;

	final post:(() -> Void)->Void;

	public function new(post:(() -> Void)->Void, timeout = 5.0) {
		this.post = post;
		this.timeout = timeout;
	}

	public function connect(host:String, port:Int, callback:(error:Null<String>, connection:Null<JingleS5BConnection>) -> Void) {
		sys.thread.Thread.create(() -> {
			final socket = new sys.net.Socket();
			try {
				socket.setTimeout(timeout);
				socket.connect(new sys.net.Host(host), port);
				// a connect timing out may return as if it succeeded (HashLink: EINPROGRESS of the send timeout)
				if ((try socket.peer() catch (_) null) == null)
					throw "connection timed out";
				socket.setTimeout(0);
			} catch (e) {
				socket.close();
				post(() -> callback(Std.string(e), null));
				return;
			}
			final connection = new SysConnection(socket, post);
			// reading starts once the callback has set the handlers: received data would get lost before
			post(() -> {
				callback(null, connection);
				connection.start();
			});
		});
	}

	public function listen(onConnection:JingleS5BConnection->Void, callback:(error:Null<String>, port:Int) -> Void):() -> Void {
		final server = new sys.net.Socket();
		var port = 0;
		var stopped = false;
		sys.thread.Thread.create(() -> {
			try {
				server.bind(new sys.net.Host("0.0.0.0"), 0);
				server.listen(5);
				port = server.host().port;
			} catch (e) {
				server.close();
				post(() -> callback(Std.string(e), 0));
				return;
			}
			final p = port;
			post(() -> callback(null, p));
			while (true) {
				final socket = try server.accept() catch (e) break;
				if (stopped) {
					socket.close();
					break;
				}
				final connection = new SysConnection(socket, post);
				post(() -> {
					onConnection(connection);
					connection.start();
				});
			}
			server.close();
		});
		return () -> {
			if (stopped)
				return;
			stopped = true;
			// closing the socket doesn't interrupt a blocking accept on every system: connect to it
			sys.thread.Thread.create(() -> try {
				final s = new sys.net.Socket();
				s.setTimeout(timeout);
				s.connect(new sys.net.Host("127.0.0.1"), port);
				s.close();
			} catch (_) {});
		}
	}

	public function addresses():Array<String> {
		// connecting a UDP socket sends nothing, but selects the interface of the route
		return try {
			final s = new sys.net.UdpSocket();
			s.connect(new sys.net.Host("192.0.2.1"), 9);
			final address = s.host().host.toString();
			s.close();
			(address == "0.0.0.0" || StringTools.startsWith(address, "127.")) ? [] : [address];
		} catch (_)
			[];
	}
}

/**
	A TCP connection with a thread reading and a thread writing (writes don't block the caller).
**/
private class SysConnection implements JingleS5BConnection {
	public var onData:Bytes->Void = data -> {};
	public var onClose:() -> Void = () -> {};

	final socket:sys.net.Socket;
	final post:(() -> Void)->Void;
	final writes = new sys.thread.Deque<Write>();
	final writerDone = new sys.thread.Lock();
	var closing = false;
	var closed = false;

	var started = false;

	public function new(socket:sys.net.Socket, post:(() -> Void)->Void) {
		this.socket = socket;
		this.post = post;
	}

	/** Starts reading and writing, once the handlers are set (on the thread of `post`) **/
	public function start() {
		if (started)
			return;
		started = true;
		sys.thread.Thread.create(readLoop);
		sys.thread.Thread.create(writeLoop);
	}

	public function write(data:Bytes)
		if (!closing)
			writes.add(Data(data));

	public function written(callback:() -> Void)
		if (!closing)
			writes.add(Written(callback));

	/** Closes the connection once the queued data is written **/
	public function close() {
		if (closing)
			return;
		closing = true;
		writes.add(Close);
	}

	function readLoop() {
		final buf = Bytes.alloc(65536);
		while (true) {
			final len = try socket.input.readBytes(buf, 0, buf.length) catch (e) 0;
			if (len <= 0)
				break;
			final data = buf.sub(0, len);
			post(() -> onData(data));
		}
		// stop the writer if the peer closed the connection, close the socket once it is done
		writes.add(Close);
		writerDone.wait();
		socket.close();
		post(() -> {
			if (closed)
				return;
			closed = true;
			onClose();
		});
	}

	function writeLoop() {
		while (true) {
			switch writes.pop(true) {
				case Data(data):
					try
						socket.output.writeFullBytes(data, 0, data.length)
					catch (e)
						break;
				case Written(callback):
					post(callback);
				case Close:
					break;
			}
		}
		// wakes the reader, which reports the closed connection
		try
			socket.shutdown(true, true)
		catch (_) {}
		writerDone.release();
	}
}

/** What the writer thread of a `SysConnection` does next **/
private enum Write {
	Data(data:Bytes);

	/** The data before is written **/
	Written(callback:() -> Void);

	Close;
}
#end
