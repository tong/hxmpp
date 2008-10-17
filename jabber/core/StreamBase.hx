package jabber.core;

import jabber.StreamStatus;
import xmpp.filter.PacketIDFilter;


/**
	Abstract base for client and component jabber streams.<br>
*/
class StreamBase /* implements IStream */ {
	
	public var status : StreamStatus; //public var status(default,setStatus) : StreamStatus;
	public var connection(default,setConnection) : StreamConnection;
	public var id(default,null) : String;
//	public var features(default,setFeatures) : Array<String>; //TODO
	//public var serverFeatures : Hash<>;
	public var lang(default,setLang) : String;
	public var collectors : List<IPacketCollector>;
	public var interceptors : List<IPacketInterceptor>;
	
	var packetsSent : Int;
	var cache : StringBuf;
	
	#if JABBER_DEBUG
	public var onXMPP(default,null) : event.Dispatcher<jabber.event.XMPPEvent>;
	#end
	
	
	function new( connection : StreamConnection ) {
		
		status = StreamStatus.closed;

		this.setConnection( connection );
		
//		features = new Array();
		collectors = new List();
		interceptors = new List();
		packetsSent = 0;
		
		#if JABBER_DEBUG
		onXMPP = new event.Dispatcher();
		#end
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
		if( status != StreamStatus.closed ) throw "Cannot change language";
		return lang = l;
	}
	
	
	/**
		Returns a unique id.
	*/
	public function nextID() : String {
		return haxe.BaseCode.encode( util.StringUtil.random64( 5 )+packetsSent, util.StringUtil.BASE64 );
	}
	
	/**
	*/
	public function open() : Bool {
		if( !connection.connected ) connection.connect();
		else connectHandler();
		return true;
		/*
		switch( status ) {
			case closed :
				if( !connection.connected ) connection.connect();
				else connectHandler();
				return true;
			default : return false;
		}
		*/
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
	public function sendPacket<T>( p : xmpp.Packet, ?intercept : Bool = false ) : T {
	
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
		if( iq.id == null ) iq.id = nextID();
		var c : IPacketCollector = new PacketCollector( [cast new PacketIDFilter( iq.id )], handler, permanent, timeout, block );
		collectors.add( c );
		return { iq : sendPacket( iq ), collector : c };
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
				var r = new EReg( "/stream:stream", "" );
				if( r.match( d ) ) {
					trace( "STREAM CLOSE: "+d );
					return;
				}
				var r = new EReg( "stream:error", "" );
				if( r.match( d ) ) {
					trace( "STREAM CLOSE: "+d );
					return;
				}
				
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
			var p : Dynamic = null;
			try {
				p = xmpp.Packet.parse( xml );
			} catch( e : Dynamic ) {
				throw "Error parsing XMPP packet: "+xml;
			} 
			packets.push( p );
			var collected = false;
			for( c in collectors ) {
				if( c.accept( p ) ) {
					collected = true;
					#if JABBER_DEBUG
					onXMPP.dispatchEvent( new jabber.event.XMPPEvent( this, p.toString(), true ) );
					#end
					c.deliver( p );
					if( c.block ) break;
					if( !c.permanent ) {
						collectors.remove( c );
						c = null; // gc
					}					
				}
			}
			#if JABBER_DEBUG
			if( !collected ) trace( "WARNING, xmpp packet not processed: "+p );
			#end
		}
		return packets;
	}
	
	function parseStreamFeatures( x : Xml ) {
		//TODO
		trace("#################################### parseStreamFeatures");
		/*
		//var xx = Xml.parse( '<starttls xmlns="urn:ietf:params:xml:ns:xmpp-sasl"></starttls>' ).firstElement();
		var xx = Xml.parse('<presence from="jdev@conference.jabber.org/etix" xml:lang="en" to="tong@jabber.spektral.at/laboratory" ></presence>').firstElement();
		try {
			trace( haxe.xml.Check.checkNode( xx, xmpp.Rule.presence ) );
		} catch( e : Dynamic ) {
			trace( e );
		}
		*/
	//	var f = new haxe.xml.Fast( x );
	//	trace( f.node.starttls );
		
		/*
		if( f.hasNode.resolve( "starttls" ) ) {
			trace("NNNNN");
		}
		if( f.hasNode.resolve( "mechanisms" ) ) {
			trace( f.node.mechanisms.att.xmlns );
		}
		*/
		/*
		<stream:features>
			<starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls"></starttls>
			<mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl">
				<mechanism>DIGEST-MD5</mechanism>
				<mechanism>PLAIN</mechanism>
				<mechanism>ANONYMOUS</mechanism>
				<mechanism>CRAM-MD5</mechanism>
			</mechanisms>
			<compression xmlns="http://jabber.org/features/compress">
				<method>zlib</method>
			</compression>
			<auth xmlns="http://jabber.org/features/iq-auth"/>
			<register xmlns="http://jabber.org/features/iq-register"/>
		</stream:features>
		*/
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
