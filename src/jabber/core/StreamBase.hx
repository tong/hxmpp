package jabber.core;

import event.Dispatcher;
import util.IDFactory;
import xmpp.XMPPStreamError;


/**
	Abstract base for xmpp stream comunication between jabber entities.<br>
*/
class StreamBase {
	
	public static inline var VERSION = "1.0";

	
	public var connection(default,setConnection) : IStreamConnection;
	public var status(default,null) : StreamStatus;
	
	public var version(default,setVersion) : String;
	public var lang(default,setLang) : String;
	public var id(default,null) : String;
	
	public var collectors : List<IPacketCollector>;
	public var interceptors : List<IPacketInterceptor>;
	
	public var onOpen(default,null)  : Dispatcher<StreamBase>;
	public var onClose(default,null) : Dispatcher<StreamBase>;
	public var onError(default,null) : Dispatcher<{stream:StreamBase,error:XMPPStreamError}>;
	public var onXMPP(default,null) : Dispatcher<jabber.event.XMPPEvent>;
	
	
	#if XMPP_DEBUG
	//public var onXMPP(default,null) 	: Dispatcher<String>; //
	#end
	//public var onError(default,null) 	: Dispatcher<StreamError>;
	
	var idFactory : IDFactory;
	var cache : String; // TODO StringBuf
	
	//public var extensions: Array<StreamExtension>;


	function new( connection : IStreamConnection, ?version : String ) {
		
		status = StreamStatus.closed;
		this.setConnection( connection ); // add connection listeners
		this.version = version;
		
		idFactory = new IDFactory();
		collectors = new List();
		interceptors = new List();
		
		onOpen = new Dispatcher();
		onClose = new Dispatcher();
		onError = new Dispatcher();
		onXMPP = new Dispatcher();
	}
	
	
	function setVersion( v : String ) : String {
		if( status != StreamStatus.closed ) throw "Cannot change version on active xmpp stream";
		return version = v;
	}
	
	function setLang( l : String ) : String {
		if( status != StreamStatus.closed ) throw "Cannot change language on active xmpp stream";
		return lang = l;
	}
	
	function setConnection( c : IStreamConnection ) : IStreamConnection {
		if( status == StreamStatus.pending ) throw "Stream is already pending";
		if( status == StreamStatus.open || status == StreamStatus.pending ) close();
		if( connection != null && connection.connected ) connection.disconnect(); 
		connection = c;
		connection.onConnect = connectHandler;
		connection.onDisconnect = disconnectHandler;
		connection.onData = dataHandler;
		return connection;
	}
	
	
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
		else connectHandler();
		return true;
	}
	
	/**
		Sends a closing stream tag. Keeps socket connection up.
	*/
	// TODO public function close( ?error ) : Bool {
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
		Intercepts, sends and returns a xmpp packet.
	*/
	public function sendPacket( packet : xmpp.Packet, ?intercept : Bool ) : xmpp.Packet {
		if( !connection.connected || status != StreamStatus.open ) throw "Cannot send packet, stream not connected";
		if( intercept || intercept == null ) { 
			for( interceptor in interceptors )
				interceptor.intercept( packet );
		}
		if( sendData( packet.toString() ) ) {
			onXMPP.dispatchEvent( new jabber.event.XMPPEvent( this, packet, false ) );
			return packet;
		}
		return null;
	}
	
	/**
		Sends raw string.
	*/
	public function sendData( data : String ) : Bool {
		if( !connection.connected ) return false;
		return connection.send( data );
	}
	
	/**
		Removes a packet collector from the stream.
		This method could be used as timeout handler for packet collectors for automatic remove on timeout.
	*/
	public function removeCollector( c : IPacketCollector ) {
		if( c.timeout != null ) c.timeout.stop();
		collectors.remove( c );
	}
	
	/*
	function handlePacketData( data : String ) {
		if( data.substr( 0, 13 ) == "<stream:error" ) {
			var error = XMPPStreamError.parse( Xml.parse( data.substr( 0, data.indexOf( "</stream:error>" )+15 ) ).firstElement() );
			onError.dispatchEvent( { stream : cast( this, jabber.core.StreamBase ),  error : error } );
		}
		var i = data.indexOf( "</stream:stream>" );
		if( i != -1 ) {
			connection.disconnect();
			onClose.dispatchEvent( this );
			return;
		}
			
		var xml : Xml = null;
		try {
			xml = Xml.parse( data );
		} catch( e : Dynamic ) {
			throw "Invalid xmpp " + data;
		}
		
		if( xml != null ) {
			var packets = collectPackets( xml );
			for( packet in packets ) {
				onXMPP.dispatchEvent( new jabber.event.XMPPEvent( this, packet ) );
			}
		}
		
	}	
	*/
	
	
	function collectPackets( data : Xml ) : Array<xmpp.Packet> {
		
		var packets = new Array<xmpp.Packet>();
		
		for( xml in data.elements() ) {
			var packet : Dynamic = null;
			try {
				packet = xmpp.Packet.parse( xml );
			} catch( e : Dynamic ) {
				throw "Error parsing xmpp packet: " + xml;
			} 
			packets.push( packet );
			var collected = false;
			for( c in collectors ) {
				if( c.accept( packet ) ) {
					collected = true;
					onXMPP.dispatchEvent( new jabber.event.XMPPEvent( this, packet ) );
					c.deliver( packet );
					if( !c.permanent ) {
						collectors.remove( c );
						c = null; // gc
					}
			//		if( c.block ) {
			//			//TODO
			//			trace("COLLECTING BLOCKED");
			//		}
				}
			}
			if( !collected ) {
				trace( "WARNING, last xmpp packet not collected.\n" );
			}
		}
		return packets;
	}
	
	
	//////// internal connection handlers
	
	function connectHandler() { throw "Abstract error onConnect"; }
	function disconnectHandler() { throw "Abstract error onDisconnect"; }
	function dataHandler( data : String ) { throw "Abstract error onData"; }
	
	//////// ---
	
}
