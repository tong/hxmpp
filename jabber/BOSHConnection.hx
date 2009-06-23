package jabber;

/**
	Emulates the semantics of a long-lived, bidirectional TCP connection
	by efficiently using multiple synchronous HTTP request/response pairs
	without requiring the use of frequent polling or chunked responses
*/
class BOSHConnection extends jabber.stream.Connection {
	
	public static inline var BOSH_VERSION = "1.6";
	
	var path : String;
	var secure : Bool;
	var sid : String;
	var rid : Int;
	var hold : Int;
	var wait : Int;
	var maxConcurrentRequests : Int;
	var requestCount : Int;
	var requestQueue : Array<Xml>;
	
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
	}
	
	public override function connect() {
		var b = Xml.createElement( "body" );
		b.set( 'xml:lang', 'en' );
		b.set( 'xmlns', xmpp.BOSH.XMLNS );
		b.set( 'ver', BOSH_VERSION );
		b.set( 'hold', Std.string( hold ) );
		b.set( 'rid', Std.string( rid ) );
		b.set( 'wait', Std.string( wait ) );
		b.set( 'to', host );
		//b.set( 'content', 'text/xml; charset=utf-8' );
		b.set( 'secure', Std.string( secure ) );
		//b.set( 'window', '5' );
		sendRequests( b );
		#if XMPP_DEBUG
		jabber.XMPPDebug.outgoing( b.toString() );
		#end
	}
	
	public override function write( t : String ) {
		sendQueuedRequests( Xml.parse(t) ); //TODO, remove Xmlparse
		return null;
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		return true;
	}
	
	public override function disconnect() {
		trace("TODO");
	}
	
	public function restart() {
	}
	
	public function pause( secs : Int ) : Bool {
		return false;
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
			if( x.get( "type" ) == "terminate" ) {
				onError( "BOSH error "+x.get("condition") );
				connected = false;
				return;
			}
			var c = x.firstElement();
			if( c == null ) {
				if( requestCount == 0 ) {
					poll();
					return;
				}
				sendQueuedRequests();
				return;
			}
			var buf = haxe.io.Bytes.ofString( c.toString() );
			onData( buf, 0, buf.length );
			if( requestCount == 0 && !sendQueuedRequests() )
				poll();
		} else {
			#if XMPP_DEBUG
			jabber.XMPPDebug.incoming( t );
			#end
			sid = x.get( "sid" );
			wait = Std.parseInt( x.get( "wait" ) );
			onConnect();
			connected = true;
			var buf = haxe.io.Bytes.ofString( x.toString() );
			onData( buf, 0, buf.length );
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
		//r.contentType = "text/xml";
		r.data = t;
		r.method = flash.net.URLRequestMethod.POST;
		//r.requestHeaders.push( new flash.net.URLRequestHeader( "Content-type", "text/xml" ) );
		//r.requestHeaders.push( new flash.net.URLRequestHeader( "Accept", "text/xml" ) );
		var me = this;
		var l = new flash.net.URLLoader();
		l.dataFormat = flash.net.URLLoaderDataFormat.TEXT;
		l.addEventListener( flash.events.Event.COMPLETE, function(e) me.handleHTTPData( e.target.data ) );
		//l.addEventListener( flash.events.Event.CLOSE, function(e) { trace(e);} );
		//l.addEventListener( flash.events.Event.OPEN, function(e) { trace(e);} );
		l.addEventListener( flash.events.IOErrorEvent.IO_ERROR, function(e) me.handleHTTPError( e ) );
		//l.addEventListener( flash.events.HTTPStatusEvent.HTTP_STATUS, function(e) { trace(e);} );
		l.load( r );
		#else
		var r = new haxe.Http( path );
		r.onStatus = handleHTTPStatus;
		r.onError = handleHTTPError;
		r.onData = handleHTTPData;
		r.setPostData( t.toString() );
		r.setHeader( "Content-type", "text/xml" );
		r.setHeader( "Accept", "text/xml" );
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
