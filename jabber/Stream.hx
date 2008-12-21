package jabber;

/*

TODO

typedef Stream = {
	
	var onOpen : s<T>
	var onClose
	var
	
	
	
}

*/


import jabber.core.TPacketCollector;
import jabber.core.TPacketInterceptor;
import jabber.core.PacketCollector;
import xmpp.filter.PacketIDFilter;
import jabber.core.PacketTimeout;
import util.XmlUtil;


private typedef Server = {
	var features(default,null) : Hash<Xml>;
}

//TODO make typedef, or if not possible a stream base class without implementation (?)

/**
	
*/
class Stream {
	
	public dynamic function onOpen<T>( s : T ) {}
	public dynamic function onClose<T>( s : T ) {}
	public dynamic function onError<T>( s : T, m : Dynamic ) {}
	
	public var status : StreamStatus;
	public var connection(default,setConnection) : StreamConnection;
	public var id(default,null) : String;
	public var lang(default,null) : String;
	public var server(default,null) : Server;
	public var features(default,null) : Array<String>;
	public var version : Bool;
	public var jid(default,null) : jabber.JID;
	
	var collectors : List<TPacketCollector>;
	var interceptors : List<TPacketInterceptor>;
	var numPacketsSent : Int;
	var cache : StringBuf;
	
	
	function new( cnx : StreamConnection, jid : jabber.JID ) {
		
		if( cnx == null ) throw "Missing connection argument";
		
		collectors = new List();
		interceptors = new List();
		server = { features : new Hash() };
		features = new Array();
		version = true;
		numPacketsSent = 0;
		
		this.status = StreamStatus.closed;
		this.jid = jid;
		this.setConnection( cnx );
	}
	
	
	function setConnection( c : StreamConnection ) : StreamConnection {
		switch( status ) {
			case open, pending :
				close( true );
			case closed :
				if( connection != null && connection.connected ) connection.disconnect(); 
				connection = c;
				connection.onConnect = connectHandler;
				connection.onDisconnect = disconnectHandler;
				connection.onData = processData;
				connection.onError = errorHandler;
		}
		return connection;
	}
	
	
	/**
		Returns a unique (base64 encoded) id for this stream.
	*/
	public function nextID() : String {
		//TODO return haxe.BaseCode.encode( util.StringUtil.random64( 5 )+numPacketsSent, util.StringUtil.BASE64 );
		return util.StringUtil.random64( 5 )+numPacketsSent;
	}
	
	/**
		Opens the outgoing xml stream.
	*/
	public function open() : Bool {
//		if( status == StreamStatus.open ) return false;
		if( !connection.connected ) connection.connect() else connectHandler();
		return true;
	}
	
	/**
		Closes the outgoing xml stream.
	*/
	public function close( disconnect = false ) : Bool {
		if( status == StreamStatus.open ) {
			sendData( xmpp.Stream.CLOSE );
			status = StreamStatus.closed;
			if( disconnect ) connection.disconnect();
			numPacketsSent = 0;
			onClose( this );
			return true;
		}
		//if( status == StreamStatus.pending && disconnect && cnx.connected ) { 
		return false;
	}
	
	/**
		Intercepts, sends and returns the given xmpp packet.
	*/
	public function sendPacket<T>( p : xmpp.Packet, ?intercept : Bool = true ) : T {
		if( !connection.connected /*|| status != StreamStatus.open*/ ) return null;
		if( intercept ) for( i in interceptors ) i.interceptPacket( p );
		if( sendData( p.toString() ) ) return cast p;
		return null;
	}
	
	/**
		Sends raw data.
	*/
	public function sendData( d : String ) : Bool {
		if( !connection.connected ) return false;
		if( !connection.send( d ) ) return false;
		numPacketsSent++;
		#if JABBER_DEBUG trace( d, "xmpp-o" ); #end
		return true;
	}
	
	/**
		Sends an IQ xmpp packet and forwards the collected response to the given handler function.
	*/
	public function sendIQ( iq : xmpp.IQ, ?handler : xmpp.IQ->Void,
							?permanent : Bool, ?timeout : PacketTimeout, ?block : Bool )
	: { iq : xmpp.IQ, collector : TPacketCollector }
	{
		if( iq.id == null ) iq.id = nextID();
		var c : TPacketCollector = null;
		if( handler != null ) {
			c = new PacketCollector( [cast new PacketIDFilter( iq.id )], handler, permanent, timeout, block );
			collectors.add( c );
		}
		var sent = sendPacket( iq );
		if( sent == null && handler != null ) {
			collectors.remove( c );
			c = null;
			return null;
		}
		return { iq : sent, collector : c };
	}
	
	public function addCollector( c : TPacketCollector ) : Bool {
		if( Lambda.has( collectors, c ) ) return false;
		collectors.add( c );
		return true;
	}
	
	public function addCollectors( iter : Iterable<TPacketCollector> ) : Bool {
		for( i in iter ) {
			if( Lambda.has( collectors, i ) ) return false;
		}
		for( i in iter ) collectors.add( i );
		return true;
	}
	
	public function removeCollector( c : TPacketCollector ) : Bool {
		return collectors.remove( c );
	}
	
	public function clearCollectors() {
		collectors = new List();
	}
	
	public function addInterceptor(i : TPacketInterceptor ) : Bool {
		if( Lambda.has( interceptors, i ) ) return false;
		interceptors.add( i );
		return true;
	}
	
	public function addInterceptors( iter : Iterable<TPacketInterceptor> ) : Bool {
		for( i in iter ) {
			if( Lambda.has( interceptors, i ) ) return false;
		}
		for( i in iter ) interceptors.add( i );
		return true;
	}
	
	public function removeInterceptor( i : TPacketInterceptor ) : Bool {
		return interceptors.remove( i );
	}
	
	public function clearInterceptors() {
		interceptors = new List();
	}


	function processData( d : String ) {
		
		if( cache == null && d == " " ) return; // ignore keepalive
		
		#if JABBER_DEBUG
		try {
			var x = Xml.parse( d );
			for( e in x.elements() ) trace( "<<< "+e, "xmpp-i" );
		} catch( e : Dynamic ) {
			trace( "<<< "+d, "xmpp-i" );
		}
		#end
		
		if( xmpp.Stream.eregStreamClose.match( d ) ) {
			//TODO
			close( true );
			return;
		}
		if( xmpp.Stream.eregStreamError.match( d ) ) {
			//TODO
			close( true );
			return;
		}
		
		switch( status ) {
			
			case closed :
				return;
			
			case pending :
				//#if JABBER_DEBUG trace( d, "xmpp-i" ); #end
				processStreamInit( XmlUtil.removeXmlHeader( d ) );
				
			case open :
				var x : Xml = null;
				try {
					x = Xml.parse( d );
					if( Std.string( x.firstChild().nodeType ) == "pcdata" ) throw new error.Exception( "Invalid xmpp" );
				} catch( e : Dynamic ) {
					if( cache == null ) {
						cache = new StringBuf();
						cache.add( d );
						return;
					} else {
						cache.add( d );
						try {
							x = Xml.parse( cache.toString() );
							if( Std.string( x.firstChild().nodeType ) == "pcdata" ) throw new error.Exception( "Invalid xmpp" );
						} catch( e : Dynamic ) { return; /* wait for more data */ }
					}
				}
				collectPackets( x );
		}
	}
	
	function processStreamInit( d : String ) {
		// override me //
	}
	
	function collectPackets( d : Xml ) : Array<xmpp.Packet> {
		var packets = new Array<xmpp.Packet>();
		for( x in d.elements() ) {
			var p = xmpp.Packet.parse( x );
			packets.push( p );
			var collected = false;
			for( c in collectors ) {
		//		if( c == null ) collectors.remove( c );
				if( c.accept( p ) ) {
					collected = true;
					c.deliver( p );
					if( c.block ) break;
					if( !c.permanent ) {
						collectors.remove( c );
						c = null;
					}					
				}
			}
			if( !collected ) {
				#if JABBER_DEBUG
				trace( "XMPP packet not processed: "+p, "warn" );
				#end
				//TODO create response
			}
		}
		return packets;
	}
	
	function parseStreamFeatures( x : Xml ) {
		for( e in x.elements() ) {
			server.features.set( e.nodeName, e );
		}
	}
	
	function connectHandler() {
	}
	
	function disconnectHandler() {
	}
	
	function dataHandler( d : String ) {
	}
	
	function errorHandler( m : Dynamic ) {
		onError( this, m  );
	}
	
}
