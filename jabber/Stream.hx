package jabber;

import jabber.Stream;
import jabber.stream.Connection;
//import jabber.stream.TPacketCollector;
import jabber.stream.TPacketInterceptor;
import jabber.stream.PacketCollector;
import jabber.stream.PacketTimeout;
import xmpp.filter.PacketIDFilter;
import util.XmlUtil;

typedef TDataFilter = {
	function filterData( t : haxe.io.Bytes ) : haxe.io.Bytes;
}

typedef TDataInterceptor = {
	function interceptData( t : haxe.io.Bytes ) : haxe.io.Bytes;
}

private typedef Server = {
	////var domain : String;
	//var allowsRegister : Bool;
	////var tls : { has : Bool, required : Bool };
	var features : Hash<Xml>;
}

private class StreamFeatures {
	var l : List<String>; // TODO var features : Hash<StreamFeature>;
	public function new() {
		l = new List();
	}
	public function iterator() {
		return l.iterator();
	}
	public function add( f : String ) : Bool {
		if( Lambda.has( l, f ) )
			return false;
		l.add( f );
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
	//public var jid(default,null) : jabber.JID;
	/** */
	public var jidstr(getJIDStr,null) : String;
	/** */
	public var server(default,null) : Server;
	/** List of features this stream offers */
	public var features(default,null) : StreamFeatures;
	/** Indicates if the version number of the XMPP stream ("1.0") should get added to the stream opening XML element */
	public var version : Bool;
	
	//TODO
	public var dataFilters : List<TDataFilter>;
	public var dataInterceptors : List<TDataInterceptor>;
	
	var numPacketsSent : Int;
	var collectors : List<PacketCollector>; // TODO public var collectors : Array<TPacketCollector>; 
	var interceptors : List<TPacketInterceptor>; // TODO public var interceptors : Array<TPacketCollector>; 
	
	
	function new( c : Connection, jid : jabber.JID ) {
		if( c == null )
			throw "No connection";
		//this.jid = jid;
		collectors = new List();
		interceptors = new List();
		server = { features : new Hash() };
		features = new StreamFeatures();
		version = true;
		numPacketsSent = 0;
		status = StreamStatus.closed;
		setConnection( c );
		
		dataFilters = new List();
		dataInterceptors = new List();
	}
	
	
	function getJIDStr() : String {
		return throw "Abstract getter";
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
		//return sendBytes( haxe.io.Bytes.ofString( t ) ).toString();
		//TODO ??? intercept data here ?
		if( !cnx.connected ) return null;
		#if XMPP_DEBUG XMPPDebug.outgoing( t ); #end
//		var b = haxe.io.Bytes.ofString( t );
		for( i in dataInterceptors )
			t = i.interceptData( haxe.io.Bytes.ofString(t) ).toString();
//		if( b == null ) return null;
		cnx.write( t );
		numPacketsSent++;
		return t;
	}
	
	/*
	public function send( t : haxe.io.Bytes ) : haxe.io.Bytes  {
		
	}
	*/
	
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
		#if XMPPDebug.outgoing( t ); #end
		return s;
	}
	*/
	
	/**
		Send an IQ packet and forward the collected response to the given handler function.
	*/
	public function sendIQ( iq : xmpp.IQ, ?handler : xmpp.IQ->Void,
							?permanent : Bool, ?timeout : PacketTimeout, ?block : Bool )
	: { iq : xmpp.IQ, collector : PacketCollector }
	{
		if( iq.id == null ) iq.id = nextID();
		var c : PacketCollector = null;
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
	public function sendPresence( ?show : xmpp.PresenceShow, ?status : String, ?priority : Int, ?type : xmpp.PresenceType ) : xmpp.Presence {
		return sendPacket( new xmpp.Presence( show, status, priority, type ) );
	}
	
	/**
	*/
	public function addCollector( c : PacketCollector ) : Bool {
		if( Lambda.has( collectors, c ) ) return false;
		collectors.add( c );
		return true;
	}
	
	/**
	*/
	public function removeCollector( c : PacketCollector ) : Bool {
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
		
		if( status == StreamStatus.closed )
			return -1;
		
		//TODO .. data filters
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
		case closed : return buflen; //hm?
		case pending : return processStreamInit( XmlUtil.removeXmlHeader( t ), buflen );
		case open :
			// filter data here ?
			var x : Xml = null;
			try x = Xml.parse( t ) catch( e : Dynamic ) {
				return 0; // wait for more data
			}
			handleXml( x );
			return buflen;
		}
		return 0;
	}
	
	/**
		Handle incoming XML data.
	*/
	public function handleXml( x : Xml ) : Array<xmpp.Packet> {
		var ps = new Array<xmpp.Packet>();
		for( x in x.elements() ) {
			var p = xmpp.Packet.parse( x );
			handlePacket( p );
			ps.push( p );
		}
		return ps;
	}
	
	/**
		Handle incoming XMPP packets.
		Returns true if the packet got handled.
	*/
	public function handlePacket( p : xmpp.Packet ) : Bool {
		#if XMPP_DEBUG
		if( p.errors.length > 0 ) XMPPDebug.error( p.toString() );
		else XMPPDebug.incoming( p.toString() );
		#end
		var collected = false;
		for( c in collectors ) {
			//if( c == null ) collectors.remove( c );
			if( c.accept( p ) ) {
				collected = true;
				//if( c.deliver == null )
				//	collectors.remove( c );
				//if( !c.deliver( p ) ) {
				//}
				c.deliver( p );
				if( !c.permanent )
					collectors.remove( c );
				if( c.block )
					break;
			}
		}
		if( !collected ) {
			#if JABBER_DEBUG
			trace( Type.enumConstructor( p._type )+" packet not handled", "warn" );
			#end
			if( p._type == xmpp.PacketType.iq ) { // send a 'feature not implemented' response
				var q : xmpp.IQ = cast p;
				if( q.type != xmpp.IQType.error ) {
					var r = new xmpp.IQ( xmpp.IQType.error, p.id, p.from, p.to );
					r.errors.push( new xmpp.Error( xmpp.ErrorType.cancel, 501, xmpp.ErrorCondition.FEATURE_NOT_IMPLEMENTED ) );
					sendData( r.toString() );
				}
			}
		}
		return collected;
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
