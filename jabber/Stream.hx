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
	//var secure : { has : Bool, required : Bool };
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
		if( Lambda.has( list, f ) )
			return false;
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
			open(); // re-open stream
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
		Get the next unique (base64 encoded) id for this stream.
	*/
	public function nextID() : String {
		//TODO
		return util.StringUtil.random64( 5 )+numPacketsSent;
	}
	
	/**
		Open the XMPP stream.
	*/
	public function open() : Bool {
//		if( status == StreamStatus.open ) return false;
		if( !cnx.connected ) cnx.connect() else connectHandler();
		return true;
	}
	
	/**
		Close the XMPP stream.
	*/
	public function close( disconnect = false ) {
		if( status == StreamStatus.open ) {
			sendData( xmpp.Stream.CLOSE );
			status = StreamStatus.closed;
			if( disconnect )
				cnx.disconnect();
			handleClose();
			//return true;
		}
		//if( status == StreamStatus.pending && disconnect && cnx.connected ) { 
		//return false;
	}
	
	/**
		Intercept, send and return the given XMPP packet.
	*/
	public function sendPacket<T>( p : xmpp.Packet, intercept : Bool = true ) : T {
		if( !cnx.connected /*|| status != StreamStatus.open*/ ) return null;
		if( intercept )
			for( i in interceptors )
				i.interceptPacket( p );
		return ( sendData( p.toString() ) != null ) ? cast p : null;
		//return ( sendBytes( haxe.io.Bytes.ofString( p.toString() ) ) != null ) ? cast p : null;
	}
	
	/**
		Send raw string.
	*/
	public function sendData( t : String ) : String {
		if( !cnx.connected ) return null;
		var s = cnx.write( t );
		if( s == null ) return null;
		numPacketsSent++;
		#if XMPP_DEBUG XMPPDebug.outgoing( t ); #end
		return s;
	}
	
	/*
		TODO Send raw bytes data.
	*/
	/*
	public function sendBytes( t : haxe.io.Bytes ) : haxe.io.Bytes {
		//TODO
		if( !cnx.connected ) return null;
		var s = cnx.writeBytes( t );
		if( s == null ) return null;
		numPacketsSent++;
		#if XMPP_DEBUG trace( t, "xmpp-o" ); #end
		return s;
	}
	*/
	
	/**
		Send an IQ packet and forward the collected response to the given handler function.
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
		var s = sendPacket( iq );
		if( s == null && handler != null ) {
			collectors.remove( c );
			c = null;
			return null;
		}
		return { iq : s, collector : c };
	}
	
	/**
		Send a message packet.
	*/
	public function sendMessage( to : String, body : String, ?subject : String, ?type : xmpp.MessageType, ?thread : String, ?from : String ) : xmpp.Message {
		return sendPacket( new xmpp.Message( to, body, subject, type, thread, from ) );
	}
	
	/**
		Send a presence packet.
	*/
	public function sendPresence( ?type : xmpp.PresenceType, ?show : String, ?status : String, ?priority : Int ) : xmpp.Presence {
		return sendPacket( new xmpp.Presence( type, show, status, priority ) );
	}
	
	/**
	*/
	public function addCollector( c : TPacketCollector ) : Bool {
		if( Lambda.has( collectors, c ) ) return false;
		collectors.add( c );
		return true;
	}
	
	/**
	*/
	public function removeCollector( c : TPacketCollector ) : Bool {
		return collectors.remove( c );
	}
	
	/**
	*/
	public function addInterceptor(i : TPacketInterceptor ) : Bool {
		if( Lambda.has( interceptors, i ) ) return false;
		interceptors.add( i );
		return true;
	}
	
	/**
	*/
	public function removeInterceptor( i : TPacketInterceptor ) : Bool {
		return interceptors.remove( i );
	}
	
	/**
	*/
	public function processData( buf : haxe.io.Bytes, bufpos : Int, buflen : Int ) : Int {
		
		if( status == StreamStatus.closed ) {
			return -1;
		}
		
		var t = buf.readString( bufpos, buflen );
		
		//TODO 
		if( xmpp.Stream.eregStreamClose.match( t ) ) {
			close( true );
			return -1;
		}
		// TODO
		if( ~/stream:error/.match( t ) ) {
			trace(t);
			var err : xmpp.StreamError = null;
			try {
				err = xmpp.StreamError.parse( Xml.parse( t ) );
			} catch( e : Dynamic ) {
				onError( "Invalid stream:error" );
				close();
				return -1;
			}
			onError( err );
			close( true );
			return -1;
		}
		
		switch( status ) {
		case closed :
			return buflen; //hm?
		case pending :
			return processStreamInit( XmlUtil.removeXmlHeader( t ), buflen );
		case open :
			var x : Xml = null;
			try {
				x = Xml.parse( t );
			} catch( e : Dynamic ) {
				return 0;
			}
			collectXml( x );
			return buflen;
		}
		return 0;
	}
	
	/**
	*/
	public function collectXml( x : Xml ) : Array<xmpp.Packet> {
		var packets = new Array<xmpp.Packet>();
		for( x in x.elements() ) {
			#if XMPP_DEBUG XMPPDebug.incoming( x.toString() ); #end
			var p = xmpp.Packet.parse( x );
			handlePacket( p );
			packets.push( p );
		}
		return packets;
	}
	
	/**
		Handle incoming XMPP packets.
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
				}					
				if( c.block )
					break;
			}
		}
		if( !collected ) {
			#if JABBER_DEBUG
			trace( p._type+" packet not handled", "warn" );
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
	
	function processStreamInit( t : String, buflen : Int ) : Int {
		return throw new error.AbstractError();
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
