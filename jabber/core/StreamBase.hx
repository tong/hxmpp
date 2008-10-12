package jabber.core;

import jabber.StreamStatus;
import xmpp.filter.PacketIDFilter;

/**
	Abstract base for client and component jabber streams.<br>
*/
class StreamBase {
	
	public var status : StreamStatus; //public var status(default,setStatus) : StreamStatus;
	public var connection(default,setConnection) : StreamConnection;
	public var id(default,null) : String;
//	public var features(default,setFeatures) : Array<String>; //TODO
	public var lang(default,setLang) : String;
	public var collectors : List<IPacketCollector>;
	public var interceptors : List<IPacketInterceptor>;
	#if JABBER_DEBUG
	public var onXMPP(default,null) : event.Dispatcher<jabber.event.XMPPEvent>;
	#end
	
	var version : String;
	var idFactory : util.IDFactory;
	var cache : StringBuf;
	
	
	function new( connection : StreamConnection, ?version : String ) {
		
		status = StreamStatus.closed;

		this.setConnection( connection );
		this.version = version;
		
//		features = new Array();
		collectors = new List();
		interceptors = new List();
		idFactory = new util.IDFactory();
		
		#if JABBER_DEBUG
		onXMPP = new event.Dispatcher();
		#end
	}
	
	
	function setConnection( c : StreamConnection ) : StreamConnection {
		if( status == StreamStatus.open || status == StreamStatus.pending ) close( true );
		if( connection != null && connection.connected ) connection.disconnect(); 
		connection = c;
		connection.onConnect = connectHandler;
		connection.onDisconnect = disconnectHandler;
		connection.onData = processData;
		connection.onError = errorHandler;
		return connection;
	}
	
	function setLang( l : String ) : String {
		if( status != StreamStatus.closed ) throw "Cannot change language";
		return lang = l;
	}
	
	
	/**
	*/
	public function nextID() : String {
		return idFactory.next();
	}
	
	/**
	*/
	public function open() : Bool {
		switch( status ) {
			case open, pending : return false;
			case closed :
				if( !connection.connected ) connection.connect();
				else connectHandler();
				return true;
		}
	}
	
	/**
	*/
	public function close( ?disconnect = false ) : Bool {
		if( status == StreamStatus.open ) {
			sendData( "</stream:stream>" );
			status = StreamStatus.closed;
			if( disconnect ) connection.disconnect();
			onClose( this );
			return true;
		}
		return false;
	}
	
	/**
		Intercepts, sends and returns a xmpp packet.
	*/
	public function sendPacket( p : xmpp.Packet, ?intercept : Bool = false ) : xmpp.Packet {
		if( !connection.connected || status != StreamStatus.open ) return null;
		if( intercept ) for( i in interceptors ) i.interceptPacket( p );
		if( sendData( p.toString() ) ) return p;
		return null;
	}
	
	/**
		Sends raw data.
	*/
	public function sendData( data : String ) {
		if( !connection.connected ) return false;
		if( !connection.send( data ) ) return false;
		#if JABBER_DEBUG
		onXMPP.dispatchEvent( new jabber.event.XMPPEvent( this, data, false ) );
		#end
		return true;
	}
	
	/**
		Sends an IQ xmpp packet and forwards the collected response to the given handler function.
	*/
	public function sendIQ( iq : xmpp.IQ, handler : xmpp.IQ->Void,
							?permanent : Bool, ?timeout : PacketTimeout, ?block : Bool )
	: { iq : xmpp.IQ, collector : IPacketCollector } {
		iq.id = nextID();
		var c : IPacketCollector = new PacketCollector( [cast new PacketIDFilter( iq.id )], handler, permanent, timeout, block );
		collectors.add( c );
		return { iq : untyped sendPacket( iq ), collector : c };
	}
	
	/**
	public function handlePacket( p : xmpp.Packet ) {
		// override me
	}
	*/
	
	/** */
	public dynamic function onOpen<T>( stream : T ) { /* override me */ }
	/** */
	public dynamic function onClose<T>( stream : T ) { /* override me */ }
	/** */
	public dynamic function onError<T>( stream : T, m : Dynamic ) { /* override me */ }
	
	
	function processData( d : String ) {
		//if( status != StreamStatus.closed ) return;
		if( d == " " && cache == null ) return;
		switch( status ) {
			
			case closed : return;
			
			case pending :
				#if JABBER_DEBUG
				onXMPP.dispatchEvent( new jabber.event.XMPPEvent( this, d, true ) );
				#end
				d = util.XmlUtil.removeXmlHeader( d );
				processStreamInit( d );
				
			case open :
				//TODO
				//var s = "</stream:stream>";
				var r = new EReg( "stream:stream", "" );
				if( r.match( d ) ) {
					trace( d );
					return;
				}
				//TODO
				var r = new EReg( "stream:error", "" );
				if( r.match( d ) ) {
					trace( d );
					return;
				}
				//TODO
				
				var x : Xml = null;
				try {
					x = Xml.parse( d );
					if( Std.string( x.firstChild().nodeType ) == "pcdata" ) throw "";
				} catch( e : Dynamic ) {
					if( cache == null ) {
						cache = new StringBuf();
						cache.add( d );
						return;
					} else {
						cache.add( d );
						try {
							x = Xml.parse( cache.toString() );
							if( Std.string( x.firstChild().nodeType ) == "pcdata" ) throw "";
						} catch( e : Dynamic ) {
							return; // wait for more data.
						}
					}
				}
				collectPackets( x );
		}
	}
	
	function processStreamInit( d : String ) {
		// override me.
	}
	
	function collectPackets( data : Xml ) : Array<xmpp.Packet> {
		var packets = new Array<xmpp.Packet>();
		for( xml in data.elements() ) {
			var packet : Dynamic = null;
			try {
				packet = xmpp.Packet.parse( xml );
			} catch( e : Dynamic ) {
				throw "Error parsing XMPP packet: "+xml;
			} 
			packets.push( packet );
			var collected = false;
			for( c in collectors ) {
				if( c.accept( packet ) ) {
					collected = true;
					#if JABBER_DEBUG
					onXMPP.dispatchEvent( new jabber.event.XMPPEvent( this, packet.toString(), true ) );
					#end
					c.deliver( packet );
					if( !c.permanent ) {
						collectors.remove( c );
						c = null; // gc
					}
					/*
					if( c.block ) {
						//TODO
						trace("COLLECTING BLOCKED");
						return packets;
					}
					*/
				}
			}
			#if JABBER_DEBUG
			if( !collected ) trace( "WARNING, xmpp packet not processed: "+packet );
			#end
		}
		return packets;
	}
	
	function parseStreamFeatures( src : Xml ) {
		//TODO
		//trace("parseStreamFeatures");
	}
	
	
	function connectHandler() {}
	
	function disconnectHandler() {}
	
	function dataHandler( data : String ) {
		#if JABBER_DEBUG
		onXMPP.dispatchEvent( new jabber.event.XMPPEvent( this, data, true ) );
		#end
	}
	
	function errorHandler( m : Dynamic ) {
		onError( this, m  );
	}
	
}
