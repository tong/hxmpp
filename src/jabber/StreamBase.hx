package jabber;

import event.Dispatcher;
import util.IDFactory;



/**
	Abstract base for jabber streams between any entities.<br>
*/
class StreamBase {
	
	public static var VERSION = "1.0";

	
	public var version(default,setVersion) 	: String;
	public var lang(default,setLang) 		: String;
	public var id(default,null) 			: String;
	public var connection(default,setConnection) : IStreamConnection;
	public var status(default,null) 		: StreamStatus;
	//public var features(default,null)		: List<String>; //TODO activate
	
	public var collectors 					: List<IPacketCollector>;
	public var interceptors 				: List<IPacketInterceptor>;
	
	public var onOpen(default,null)  		: Dispatcher<StreamBase>;
	public var onClose(default,null) 		: Dispatcher<StreamBase>;
	//public var onData(default,null) 		: Dispatcher<>; //
	//public var onError(default,null) 		: Dispatcher<StreamError>;

	var idFactory 	: IDFactory;
	var cache 		: String;


	function new( connection : IStreamConnection, ?version : String ) {
		
		status = StreamStatus.closed;
		this.setConnection( connection ); // add connection listeners
		this.version = version;
		
		idFactory = new IDFactory();
		collectors = new List();
		interceptors = new List();
		
		onOpen = new Dispatcher();
		onClose = new Dispatcher();
	}
	
	
	function setVersion( v : String ) : String {
		if( status == StreamStatus.closed ) version = v;
		return version;
	}
	
	function setLang( l : String ) : String {
		if( status != StreamStatus.open ) lang = l;
		return lang;
	}
	
	function setConnection( c : IStreamConnection ) : IStreamConnection {
		//if( status == StreamStatus.pending ) throw "";
		if( status == StreamStatus.open || status == StreamStatus.pending ) close();
		if( connection != null && connection.connected ) connection.disconnect(); 
		connection = c;
		connection.onConnect = onConnect;
		connection.onDisconnect = onDisconnect;
		connection.onData = processData;
		return connection;
	}
	
	
	//////// internal connection handlers
	function onConnect() { throw "Abstract error"; }
	function onDisconnect() { throw "Abstract error"; }
	function onData( data : String ) { throw "Abstract error"; }
	//////// ---
	
	
	/**
		Returns a unique id for xmpp packets. 
	*/
	public function nextID() : String {
		return idFactory.next();
	}
	
	/**
		Request to open the stream by sending an openn stream packet if the connection is up,
		tries to connect the connection first otherwise.
		Returns false for already opened or pending streams. 
	*/
	public function open() : Bool {
		if( status == StreamStatus.open || status == StreamStatus.pending ) return false;
		//status = StreamStatus.pending;
		if( !connection.connected ) connection.connect();
		else onConnect();
		return true;
	}
	
	/**
		Sends a closing stream tag. Keeps connection up.
	*/
	//public function close( ?error ) : Bool {
	public function close() : Bool {
		if( status == StreamStatus.open ) {
			sendData( "</stream:stream>" ); // TODO other namespaces
			status = StreamStatus.closed;
			cache = "";
			return true;
		}
		return false;
	}
	
	/**
		Intercepts and sends a xmpp packet.
		Returns the intercepted packet.
	*/
	//TODO
	//public function sendPacket( packet : xmpp.Packet, ?intercept : Bool ) : mpp.Packet {
	public function sendPacket( packet : xmpp.Packet ) : xmpp.Packet {
		if( !connection.connected || status != StreamStatus.open ) return null;
		for( interceptor in interceptors ) interceptor.intercept( packet );
		sendData( packet.toString() );
		return packet;
	}
	
	/**
		Sends raw string.
	*/
	public function sendData( data : String ) : Bool {
		if( !connection.connected ) return false;
		connection.send( data );
		return true;
	}
	
	/**
		Removes a packet collector from the stream.
		This method could be used as timeout handler for packet collectors for automatic remove on timeout.
	*/
	public function removeCollector( c : IPacketCollector ) {
		if( c.timeout != null ) c.timeout.stop();
		collectors.remove( c );
	}
	
	
	function processData( d : String ) {
		
		// TODO !! DOSNT WORK FOR <stream:error>
		//<stream:error xmlns:stream="http://etherx.jabber.org/streams"><conflict xmlns="urn:ietf:params:xml:ns:xmpp-streams"/></stream:error></stream:stream>
		
		#if neko
		if( status != StreamStatus.open ) {
			onData( d );
		} else { // cache data
			try {
				var x = Xml.parse( d );
				onData( d );
				cache = "";
			} catch( e : Dynamic ) {
				if( cache != null && cache.length == 0 ) {
					cache += d;
				} else {
					cache += d;
					try {
						var x = Xml.parse( cache );
						onData( cache );
						cache = "";
					} catch( e : Dynamic ) {  /*# wait for more data #*/  }
				}
			}
		}
		#else true
		onData( d );
		#end
	}
	
	function collectPackets( data : Xml ) {
		
		/*TODO
		split id packet filters from rest
		collect collectors with id filters first
		*/
//		trace("Collecting......." + data );
		for( xml in data.elements() ) {
			var packet : Dynamic;
			try {
				packet = xmpp.Packet.parse( xml );
			} catch( e : Dynamic ) {
				trace( "ERROR, parsing packet:" + e ); // TODO
			} 
			var collected = false;
			for( c in collectors ) {
//				trace("......." + c.filters);
				if( c.accept( packet ) ) {
//					trace("COLLECTED"+packet.toString());
					collected = true;
					c.deliver( packet );
					if( !c.permanent ) {
						collectors.remove( c );
						c = null; // garbage
					}
			//		if( c.block ) {
			//			//TODO
			//			trace("COLLECTING BLOCKED");
			//		}
				}
			}
			if( !collected ) {
				trace("## PACKET NOT COLLECTED! ##");
			}
		}
	}
	
	function parseStreamFeatures( src : Xml ) {
		//TODO
		/*
		for( e in src.elements() ) {
			switch( e.nodeName ) {
				case "starttls" :
				case "mechanisms" :
				case "compression" :
				case "auth" :
				case "register" :
			}
		}
		*/
	}
}
