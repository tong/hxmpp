package jabber;

/**
	Emulates the semantics of a long-lived, bidirectional TCP connection
	by efficiently using multiple synchronous HTTP request/response pairs
	without requiring the use of frequent polling or chunked responses.
*/
class BOSHConnection extends jabber.stream.Connection {
	
	public static inline var BOSH_VERSION = "1.6";
	
	public var path(default,null) : String;
	public var secure(default,null) : Bool;
	public var sid(default,null) : String;
	public var hold(default,null) : Int;
	public var wait(default,null) : Int;
	public var maxConcurrentRequests(default,null) : Int;
	
	var rid : Int;
	var requestCount : Int;
	var requestQueue : Array<Xml>;
	var maxPause : Int;
	
	var active : Bool;
	
	public function new( host : String, path : String,
						 ?secure : Bool = false, ?hold : Int = 1, ?wait : Int = 20 ) {
		super( host );
		this.path = path;
		this.secure = secure;
		this.hold = hold;
		this.wait = wait;
		maxConcurrentRequests = 2;
		rid = Std.int( Math.random()*10000000 );
		requestCount = 0;
		requestQueue = new Array();
		
		active = false;
	}
	
	public override function connect() {
		if( connected ) restart();
		else {
			var b = Xml.createElement( "body" );
			b.set( 'ver', BOSH_VERSION );
			b.set( 'hold', Std.string( hold ) );
			b.set( 'rid', Std.string( rid ) );
			b.set( 'wait', Std.string( wait ) );
			b.set( 'to', host );
			//b.set( 'content', 'text/xml; charset=utf-8' );
			b.set( 'secure', Std.string( secure ) );
			//b.set( 'window', '5' );
			b.set( 'xml:lang', 'en' );
			//b.set( 'xmpp:version', '1.0' );
			b.set( 'xmlns', xmpp.BOSH.XMLNS );
			b.set( 'xmlns:xmpp', 'urn:xmpp:xbosh' );
			sendRequests( b );
			#if XMPP_DEBUG
			jabber.XMPPDebug.outgoing( b.toString() );
			#end
			active = true;
		}
	}
	
	public override function write( t : String ) {
		sendQueuedRequests( Xml.parse(t) ); //TODO, remove Xmlparse
		return null;
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		trace("REad");
		return true;
	}
	
	public override function disconnect() {
		if( connected ) {
			trace("TODO");
			var r = createRequest();
			r.set( "type", "terminate" );
			//r.addChild( new xmpp.Presence(null,null,null,xmpp.PresenceType.unavailable).toXml() );
			sendRequests( r );
			connected = active = false;
			onDisconnect();
		}
	}
	
	public function pause( secs : Int ) : Bool {
		//TODO
		return false;
	}
	
	function restart() {
		var r = createRequest();
		r.set( "xmpp:restart", "true" );
		r.set( "xmlns:xmpp", "urn:xmpp:xbosh" );
		r.set( "xml:lang", "en" );
		r.set( "to", host );
		sendRequests( r );
	}
	
	function handleHTTPStatus( s : Int ) {
		//trace( s );
	}
	
	function handleHTTPError( e : String ) {
		onError( e );
	}
	
	function handleHTTPData( t : String ) {
		requestCount--;
		var x = Xml.parse( t ).firstElement();
		if( connected ) {
			/*
			if( terminated ) {
				//terminated = false;
				connected = false;
				onDisconnect();
				return;
			}
			*/
			if( x.get( "type" ) == "terminate" ) {
				onError( "BOSH error "+x.get("condition") );
				connected = false;
				return;
			}
			var c = x.firstElement();
			if( c == null ) {
				if( requestCount == 0 ) poll() else sendQueuedRequests();
				return;
			}
			var b = haxe.io.Bytes.ofString( c.toString() );
			onData( b, 0, b.length );
			if( requestCount == 0 && !sendQueuedRequests() )
				poll();
		} else {
			if( active ) {
				#if XMPP_DEBUG
				jabber.XMPPDebug.incoming( t );
				#end
				/*
				var c = x.firstElement();
				if( c == null ) {
					poll();
					return;
				}
				*/
				sid = x.get( "sid" );
				wait = Std.parseInt( x.get( "wait" ) );
				// TODO
				// <body xmlns="http://jabber.org/protocol/httpbind" xmlns:stream="http://etherx.jabber.org/streams" authid="764f197f" sid="764f197f" secure="true" requests="2" inactivity="30" polling="5" wait="20" hold="1" ack="5079633" maxpause="300" ver="1.6"><stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><mechanism>DIGEST-MD5</mechanism><mechanism>PLAIN</mechanism><mechanism>ANONYMOUS</mechanism><mechanism>CRAM-MD5</mechanism></mechanisms><compression xmlns="http://jabber.org/features/compress"><method>zlib</method></compression><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/><session xmlns="urn:ietf:params:xml:ns:xmpp-session"/></stream:features></body>
				var t = x.get( "requests" );
				if( t != null ) maxConcurrentRequests = Std.parseInt( t );
				t = x.get( "maxpause" );
				if( t != null ) maxPause = Std.parseInt( t ) * 1000;
				
				onConnect();
				connected = true;
				var buf = haxe.io.Bytes.ofString( x.toString() );
				onData( buf, 0, buf.length );
			} else {
				//trace(x);
			}
		}
	}
	
	function sendQueuedRequests( ?t : Xml ) : Bool {
		if( t != null ) requestQueue.push( t );
		else if( requestQueue.length == 0 )
			return false;
		return sendRequests( null );
	}
	
	function sendRequests( t : Xml, ?poll : Bool = false ) : Bool {
		if( requestCount >= maxConcurrentRequests )
			return false;
		requestCount++;
		if( t == null ) {
			if( poll ) t = createRequest();
			else {
				var i = 0;
				var tmp = new Array<Xml>();
				while( i++ < 10 && requestQueue.length > 0 )
					tmp.push( requestQueue.shift() );
				t = createRequest( tmp );
			}
		}
		#if flash
		var r = new flash.net.URLRequest( path );
		r.method = flash.net.URLRequestMethod.POST;
		r.data = t;
		//r.contentType = "text/xml";
		//r.requestHeaders.push( new flash.net.URLRequestHeader( "Content-type", "text/xml" ) );
		//r.requestHeaders.push( new flash.net.URLRequestHeader( "Accept", "text/xml" ) );
		var me = this;
		var l = new flash.net.URLLoader();
		l.dataFormat = flash.net.URLLoaderDataFormat.TEXT;
		l.addEventListener( flash.events.Event.COMPLETE, function(e) me.handleHTTPData( e.target.data ) );
		l.addEventListener( flash.events.IOErrorEvent.IO_ERROR, function(e) me.handleHTTPError( e ) );
		l.addEventListener( flash.events.HTTPStatusEvent.HTTP_STATUS, function(e) me.handleHTTPStatus(e) );
		l.load( r );
		#else
		var r = new haxe.Http( path );
		r.onStatus = handleHTTPStatus;
		r.onError = handleHTTPError;
		r.onData = handleHTTPData;
		r.setPostData( t.toString() );
		//r.setHeader( "Content-type", "text/xml" );
		//r.setHeader( "Accept", "text/xml" );
		r.request( true );
		#end
		return true;
	}
	
	function createRequest( ?t : Array<Xml> ) : Xml {
		var x = Xml.createElement( "body" );
		x.set( 'xmlns', xmpp.BOSH.XMLNS );
		x.set( "xml:lang", "en" );
		x.set( "rid", Std.string( ++rid ) );
		x.set( "sid", sid );
		if( t != null ) {
			for( e in t )
				x.addChild( e );
		}
		return x;
	}
	
	inline function poll() {
		sendRequests( null, true );
	}
	
}
