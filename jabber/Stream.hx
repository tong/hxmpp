package jabber;

import jabber.Stream;
import jabber.stream.Connection;
import jabber.stream.TPacketCollector;
import jabber.stream.TPacketInterceptor;
import jabber.stream.PacketCollector;
import jabber.stream.PacketTimeout;
import xmpp.filter.PacketIDFilter;
import util.XmlUtil;


typedef Server = {
	//var domain : String;
	//var allowsRegister : Bool;
	//var sasl : Bool;
	//
	var features : Hash<Xml>;
}


class StreamFeatures {
	var list : List<String>; // TODO var features : Hash<StreamFeature>;
	public function new() {
		list = new List();
	}
	public function iterator() {
		return list.iterator();
	}
	public function add( f : String ) : Bool {
		if( Lambda.has( list, f ) ) return false;
		list.add( f );
		return true;
	}
}


/**
	Abstract base for XMPP streams.
*/
class Stream {
	
	public dynamic function onOpen() {}
	public dynamic function onClose() {}
	public dynamic function onError( ?e : Dynamic ) {}
	
	/** */
	public var status : StreamStatus;
	/** */
	public var cnx(default,setConnection) : Connection;
	/** */
	public var id(default,null) : String;
	/** */
	public var lang(default,null) : String;
	/** */
	public var jid(default,null) : jabber.JID;
	/** */
	public var server(default,null) : Server;
	/** */
	public var features(default,null) : StreamFeatures;
	/** */
	public var version : Bool;
	
	var collectors : List<TPacketCollector>;
	var interceptors : List<TPacketInterceptor>;
	var numPacketsSent : Int;
	var cache : StringBuf;
	
	
	function new( c : Connection, jid : jabber.JID ) {
		
		if( c == null )
			throw "Missing XMPP connection argument";
		
		this.jid = jid;
		
		collectors = new List();
		interceptors = new List();
		server = { features : new Hash() };
		features = new StreamFeatures();
		version = true;
		numPacketsSent = 0;
		status = StreamStatus.closed;
		setConnection( c );
	}
	
	
	function setConnection( c : Connection ) : Connection {
		switch( status ) {
		case open, pending :
			close( true );
			setConnection( c );
			open();
		case closed :
			if( cnx != null && cnx.connected )
				cnx.disconnect();
			cnx = c;
			cnx.onConnect = connectHandler;
			cnx.onDisconnect = disconnectHandler;
			cnx.onData = processData;
			cnx.onError = errorHandler;
		}
		return cnx;
	}
	
	
	/**
		Returns the next unique (base64 encoded) id for this stream.
	*/
	public function nextID() : String {
		//TODO
		return util.StringUtil.random64( 5 )+numPacketsSent;
	}
	
	/**
		Opens the outgoing XMPP stream.
	*/
	public function open() : Bool {
//		if( status == StreamStatus.open ) return false;
		if( !cnx.connected ) cnx.connect() else connectHandler();
		return true;
	}
	
	/**
		Close the outgoing xml stream.
	*/
	public function close( disconnect = false ) : Bool {
		if( status == StreamStatus.open ) {
			sendData( xmpp.Stream.CLOSE );
			status = StreamStatus.closed;
			if( disconnect ) cnx.disconnect();
			handleClose();
			return true;
		}
		//if( status == StreamStatus.pending && disconnect && cnx.connected ) { 
		return false;
	}
	
	/**
		Intercept, send and return the given XMPP packet.
	*/
	public function sendPacket<T>( p : xmpp.Packet, intercept : Bool = true ) : T {
		if( !cnx.connected /*|| status != StreamStatus.open*/ ) return null;
		if( intercept ) for( i in interceptors ) i.interceptPacket( p );
		return ( sendData( p.toString() ) ) ? cast p : null;
	}
	
	/**
		Send raw data.
	*/
	public function sendData( t : String ) : Bool {
		if( !cnx.connected || cnx.send( t ) == null ) return false;
		numPacketsSent++;
		#if XMPP_DEBUG trace( t, "xmpp-o" ); #end
		return true;
	}
	
	/**
		Sends an IQ packet and forwards the collected response to the given handler function.
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
	
	/**
		Sends message packets.
	*/
	public function sendMessage( to : String, body : String, ?subject : String, ?type : xmpp.MessageType, ?thread : String, ?from : String ) : xmpp.Message {
		return sendPacket( new xmpp.Message( to, body, subject, type, thread, from ) );
	}
	
	/**
		Sends presence packet.
	*/
	public function sendPresence( ?type : xmpp.PresenceType, ?show : String, ?status : String, ?priority : Int ) : xmpp.Presence {
		return sendPacket( new xmpp.Presence( type, show, status, priority ) );
	}
	
	public function addCollector( c : TPacketCollector ) : Bool {
		if( Lambda.has( collectors, c ) ) return false;
		collectors.add( c );
		return true;
	}

	public function removeCollector( c : TPacketCollector ) : Bool {
		return collectors.remove( c );
	}

	public function addInterceptor(i : TPacketInterceptor ) : Bool {
		if( Lambda.has( interceptors, i ) ) return false;
		interceptors.add( i );
		return true;
	}

	public function removeInterceptor( i : TPacketInterceptor ) : Bool {
		return interceptors.remove( i );
	}
	
	/**
	*/
	public function processData( t : String ) {
		// ignore keepalive
		if( cache == null && t == " " )
			return;
		#if XMPP_DEBUG
		try {
			var x = Xml.parse( t );
			for( e in x.elements() )
				trace( "<<< "+e, "xmpp-i" );
		} catch( e : Dynamic ) {
			trace( "<<< "+t, "xmpp-i" );
		}
		#end
		
		if( xmpp.Stream.eregStreamClose.match( t ) ) {
			close( true );
			return;
		}
		if( xmpp.Stream.eregStreamError.match( t ) ) {
			var err : xmpp.StreamError = null;
			try {
				err = xmpp.StreamError.parse( Xml.parse( t ) );
			} catch( e : Dynamic ) {
				onError( "Invalid stream:error" );
				close();
				return;
			}
			onError( err );
			close( true );
			return;
		}
		
		switch( status ) {
		case closed :
			return;
		case pending :
			//#if XMPP_DEBUG trace( t, "xmpp-i" ); #end
			processStreamInit( XmlUtil.removeXmlHeader( t ) );
		case open :
			var x : Xml = null;
			try {
				x = Xml.parse( t );
				if( Std.string( x.firstChild().nodeType ) == "pcdata" )
					throw new error.Exception( "Invalid xmpp" );
			} catch( e : Dynamic ) {
				if( cache == null ) {
					cache = new StringBuf();
					cache.add( t );
					return;
				} else {
					cache.add( t );
					try {
						x = Xml.parse( cache.toString() );
						if( Std.string( x.firstChild().nodeType ) == "pcdata" )
							throw new error.Exception( "Invalid XMPP data" );
					} catch( e : Dynamic ) {
						return; /* wait for more data */
					}
				}
			}
			collectXml( x );
		}
	}
	
	/**
	*/
	public function collectXml( x : Xml ) : Array<xmpp.Packet> {
		var packets = new Array<xmpp.Packet>();
		for( xml in x.elements() ) {
			var p = xmpp.Packet.parse( xml );
			handlePacket( p );
			packets.push( p );
		}
		return packets;
	}
	
	/**
		Handles ncoming XMPP packets.
	*/
	public function handlePacket( p : xmpp.Packet ) : Bool {
		var collected = false;
		for( c in collectors ) {
			//if( c == null ) collectors.remove( c );
			if( c.accept( p ) ) {
				collected = true;
				//if( c.deliver == null ) collectors.remove( c );
				c.deliver( p );
				if( !c.permanent ) {
					collectors.remove( c );
					//c = null;
				}					
				if( c.block ) break;
			}
		}
		if( !collected ) {
			#if JABBER_DEBUG
			trace( "XMPP packet not processed", "warn" );
			#end
			if( p._type == xmpp.PacketType.iq ) {
				var q : xmpp.IQ = cast p;
				if( q.type != xmpp.IQType.error ) {
					var r = new xmpp.IQ( xmpp.IQType.error, p.id, p.from, p.to );
					r.errors.push( new xmpp.Error( xmpp.ErrorType.cancel, 501, xmpp.ErrorCondition.FEATURE_NOT_IMPLEMENTED ) );
					sendPacket( r );
				}
			}
			return false;
		}
		return true;
	}
	
	
	/*
	function parseStreamFeatures( x : Xml ) {
		for( e in x.elements() ) {
			server.features.set( e.nodeName, e );
		}
	}
	*/
	
	//function handleOpen() {
	//}
	
	function handleClose() {
		id = null;
		numPacketsSent = 0;
		onClose();
	}
	
	function processStreamInit( t : String ) {
	}
	
	function connectHandler() {
	}
	
	function disconnectHandler() {
		handleClose();
	}
	
	//function dataHandler( t : String ) {
	//}
	
	function errorHandler( m : Dynamic ) {
		onError( m );
	}
	
}
