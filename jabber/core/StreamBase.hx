package jabber.core;

import jabber.StreamConnection;
import jabber.StreamStatus;
import xmpp.filter.PacketIDFilter;
import util.XmlUtil;


/*
private class FeatureList {

	var features : List<String>;
	
	public function new() {
		features = new List();
	}
	public function has( name : String ) {
		for( f in features ) if( f == name ) return f;
		return null;
	}
	
	public function add( name : String  ) {
	}
	
	public function remove( name : String  ) {
	}
	
	public function clear() {
		features = new List();
	}
}
*/


/**
	Abstract base for client and component jabber streams.<br>
*/
class StreamBase implements jabber.Stream {
	
	public dynamic function onOpen<T>( s : T ) {}
	public dynamic function onClose<T>( s : T ) {}
	public dynamic function onError<T>( s : T, m : Dynamic ) {}
	
	public var status : StreamStatus;
	//public var authenticated : Bool;
	public var connection(default,setConnection) : StreamConnection;
	public var id(default,null) : String;
	public var features(default,null) : Array<String>; //TODO
//	public var serverFeatures : Hash<>;
	public var lang(default,setLang) : String;
	public var collectors : List<IPacketCollector>;
	public var interceptors : List<IPacketInterceptor>;
	
	//var myJID : String; // must not be a JID for components
	var packetsSent : Int; // num xmpp packets sent
	var cache : StringBuf;
	
	
	function new( connection : StreamConnection ) {
		
		status = StreamStatus.closed;
		this.setConnection( connection );
		
		collectors = new List();
		interceptors = new List();
		packetsSent = 0;
		features = new Array();
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
	
	function setLang( l : String ) : String {
		if( status != StreamStatus.closed ) throw new error.Exception( "Cannot change language on active stream" );
		return lang = l;
	}
	
	
	/**
		Returns a unique (base64 encoded) id for this stream.
	*/
	public function nextID() : String {
		return util.StringUtil.random64( 5 );
		//return haxe.BaseCode.encode( util.StringUtil.random64( 5 )+packetsSent, util.StringUtil.BASE64 );
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
	public function close( ?disconnect = false ) : Bool {
		trace( "Closing jabber stream:" + status );
		if( status == StreamStatus.open ) {
			sendData( xmpp.XMPPStream.CLOSE );
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
	public function sendPacket<T>( p : xmpp.Packet, ?intercept : Bool = true ) : T {
		// TODO cache packets sent while fe: initializing stream compression.
		if( !connection.connected || status != StreamStatus.open ) return null;
		if( intercept ) for( i in interceptors ) i.interceptPacket( p );
		if( sendData( p.toString() ) ) return cast p;
		return null;
	}
	
	/**
		Sends raw data.
	*/
	public function sendData( data : String ) : Bool {
		if( !connection.connected ) return false;
		if( !connection.send( data ) ) return false;
		packetsSent++;
		#if JABBER_DEBUG trace( data, true ); #end
		return true;
	}
	
	/**
		Sends an IQ xmpp packet and forwards the collected response to the given handler function.
	*/
	public function sendIQ( iq : xmpp.IQ, ?handler : xmpp.IQ->Void,
							?permanent : Bool, ?timeout : PacketTimeout, ?block : Bool )
	: { iq : xmpp.IQ, collector : IPacketCollector }
	{
		if( iq.id == null ) iq.id = nextID();
		var c : IPacketCollector = null;
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
	
	
	function processData( d : String ) {
		
		if( d == " " && cache == null ) return; // ignore keepalive
		
		#if JABBER_DEBUG
		try {
			var x = Xml.parse( d );
			for( e in x.elements() ) trace( e, false );
		} catch( e : Dynamic ) {
			trace( d, false );
		}
		#end
		
		if( xmpp.XMPPStream.eregStreamClose.match( d ) ) {
			//TODO
			close( true );
			return;
		}
		if( xmpp.XMPPStream.eregStreamError.match( d ) ) {
			//TODO
			close( true );
			return;
		}
		
		switch( status ) {
			
			case closed : return;
			
			case pending : processStreamInit( XmlUtil.removeXmlHeader( d ) );
				
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
			/*
			var p : xmpp.Packet = null;
			try {
				p = xmpp.Packet.parse( x );
			} catch( e : Dynamic ) {
				trace( "##### ERROR ##### ");
				trace( e );
				trace( x );
				trace( "#################" );
				return null;
			}
			*/ 
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
				trace( "WARNING, xmpp packet not processed: "+p );
				#end
				//TODO create response
			}
		}
		return packets;
	}
	
	
	function parseStreamFeatures( x : Xml ) {
		return null;
	}
	
	function connectHandler() {}
	function disconnectHandler() {}
	function dataHandler( data : String ) {}
	function errorHandler( m : Dynamic ) {
		onError( this, m  );
	}
	
}
