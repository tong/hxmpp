package xmpp.net;

import haxe.Timer;

using haxe.io.Path;

/**
	Emulates the semantics of a long-lived, bidirectional TCP connection by efficiently using multiple synchronous HTTP request/response pairs without requiring the use of frequent polling or chunked responses.

	Bidirectional-streams Over Synchronous HTTP (BOSH): http://xmpp.org/extensions/xep-0124.html
	XMPP Over BOSH: http://xmpp.org/extensions/xep-0206.html
*/
class BOSH {

	public static inline var BOSH_VERSION = "1.6";
	public static inline var XMLNS = "http://jabber.org/protocol/httpbind";
	public static inline var XBOSH = "urn:xmpp:xbosh";

	static inline var INTERVAL = 0;
	static inline var MAX_CHILD_ELEMENTS = 10;

	public dynamic function onConnect( features : XML ) {}
	public dynamic function onDisconnect( ?error : String ) {}
	public dynamic function onData( data : String ) {}
	//public dynamic function onStanza( s ) {}

	/***/
	public var host(default,null) : String;

	/***/
	public var port(default,null) : Null<Int>;

	/** Server HTTP path */
	public var path(default,null) : String;

	/** Maximum number of requests the connection manager is allowed to keep waiting at any one time during the session. */
	public var hold(default,null) : Int;

	/** Longest time (in seconds) that the connection manager is allowed to wait before responding to any request during the session. */
	public var wait(default,null) : Int;

	/** Session id */
	public var sid(default,null) : String;

	/** Request ID */
	public var rid(default,null) : Int;

	/** */
	public var secure(default,null) : Bool;

	/** */
	public var maxConcurrentRequests(default,null) : Int;

	/** */
	//public var timeoutOffset(default,null) : Int;

	var initialized = false;
	var ready = false;
	var attached = false;
	var pollingEnabled = true;

	var requestCount : Int;
	var requestQueue : Array<String>;
	var responseQueue : Array<XML>;
	var responseTimer : Timer;

	var pauseTimer : Timer;
	var maxPause : Int;
	var pauseEnabled = false;

	//var inactivity : Int;

	var timeoutTimer : Timer;
	var timeoutOffset : Int;

	var stream : xmpp.client.Stream;
	var startCallback : XML->Void;

	public function new( host : String, ?port : Int, path : String, hold = 1, wait = 30, secure = false, maxConcurrentRequests = 2, timeoutOffset = 25 ) {
		this.host = host;
		this.port = port;
		this.path = path;
		this.hold = hold;
		this.wait = wait;
		this.secure = secure;
		this.maxConcurrentRequests = maxConcurrentRequests;
		this.timeoutOffset = timeoutOffset;
	}

	public function start( stream : xmpp.client.Stream, callback : (features:XML)->Void ) {

		this.stream = stream;
		this.startCallback = callback;

		rid = Std.int( Math.random() * 10000000 );
		requestCount = 0;
		requestQueue = [];
		responseQueue = [];
		responseTimer = new Timer( INTERVAL );

		initialized = true;

		sendRequests( XML.create( "body" )
			.set( 'xmlns', XMLNS )
			.set( 'xml:lang', 'en' )
			.set( 'xmlns:xmpp', XBOSH )
			.set( 'xmpp:version', '1.0' )
			.set( 'ver', BOSH_VERSION )
			.set( 'hold', Std.string( hold ) )
			.set( 'rid', Std.string( rid ) )
			.set( 'wait', Std.string( wait ) )
			.set( 'to', host )
			.set( 'secure', Std.string( secure ) )
		);
	}

	public function send( str : String ) : Bool {
		return sendQueuedRequests( str );
	}

	public function poll() {
		if( !ready || !pollingEnabled || requestCount > 0 || sendQueuedRequests() )
			return;
		sendRequests( null, true );
	}

	public function restart( callback : XML->Void ) {
		//var _processor = @:privateAccess stream.processor;
		@:privateAccess stream.input = function(e){
			// Simulate stream restart
			//stream.processor = _processor;
			stream.input = stream.handleString;
			stream.reset();
			stream.ready = true;
			callback( e );
		}
		sendRequests( createRequest()
			.set( 'xmlns', XMLNS )
			.set( "xmpp:restart", "true" )
			.set( "xmlns:xmpp", XBOSH )
			//.set( "xml:lang", "en" )
			.set( "to", host )
		);
	}

	function sendQueuedRequests( ?str : String ) : Bool {
		if( str != null )
			requestQueue.push( str );
		else if( requestQueue.length == 0 )
			return false;
		return sendRequests( null );
	}

	function sendRequests( ?xml : XML, poll = false ) : Bool {
		
		if( requestCount >= maxConcurrentRequests ) {
			trace( 'max concurrent http request limit ($requestCount,$maxConcurrentRequests)' );
			return false;
		}

		requestCount++;

		if( xml == null ) {
			if( poll ) xml = createRequest() else {
				var i = 0;
				var e = [while( i++ < MAX_CHILD_ELEMENTS && requestQueue.length > 0 ) requestQueue.shift() ];
				xml = createRequest( e );
			}
		}

		createHTTPRequest( xml );

		if( timeoutTimer != null ) timeoutTimer.stop();
		timeoutTimer = new Timer( wait * 1000 + timeoutOffset * 1000 );
		timeoutTimer.run = handleTimeout;

		return true;
	}

	function createRequest( ?children : Array<String> ) : XML {
		var xml = XML.create( "body" )
			.set( "xmlns", XMLNS )
			.set( "rid", Std.string( ++rid ) )
			.set( "sid", sid );
		if( children != null ) for( e in children ) xml.append( e );
		return xml;
	}

	function createHTTPRequest( body : String ) {
		
		var httpPath = 'http';
		if( secure ) httpPath += 's';
		httpPath += '://$host';
		if( port != null ) httpPath += ':$port';
		httpPath += '/$path';

		#if nodejs

		var options : HttpRequestOptions = {
			host : host,
			port : port,
			path : httpPath,
			method : js.node.http.Method.Post,
			//requestCert: false,
			//rejectUnauthorized:  false,
			//'Content-Type' : 'text/xml'
			headers: {
				'Content-Type' : 'text/xml',
				'Content-Length' : Std.string( body.length )
			}
		};
		var req = js.node.Http.request( options, res -> {
			res.setEncoding( 'utf8' );
			res.on( 'data', buf -> handleData( buf.toString() ) );
			res.on( 'end', () -> {
				trace('No more data in response.');
			});
		});
		req.on( 'error', e -> {
			trace(e);
		});
		//req.write( body );
		req.end( body );

		#elseif js

		var xhr = new js.html.XMLHttpRequest();
		xhr.open( "POST", httpPath, true );
		xhr.onreadystatechange = function(e){
			if( xhr.readyState != 4 )
				return;
			var s = xhr.status;
			if( s != null && s >= 200 && s < 400 )
				handleData( xhr.responseText );
			else
				handleError( "Http Error #"+xhr.status );
		}
		xhr.send( body );

		#elseif sys

		//TODO
		/* var req = new xmpp.net.BOSHRequest();
		req.send( host, port, path, body,
			function(res) {
				handleData(res);
			},
			function(e) {
				trace(e);
				handleError(e);
			}
		);
 */
		#end
	}

	function handleData( str : String ) {
		var xml : XML = str;
		if( xml.get( 'xmlns' ) != XMLNS ) {
            trace( 'Invalid BOSH body ($xml)' );
			return;
		}
		requestCount--;
        if( timeoutTimer != null ) timeoutTimer.stop();
		if( ready ) {
			/*
			switch xml.get( "type" ) {
			case 'terminate':
			case 'error':
			case 'terminate':
			}
			*/
			var child = xml.firstElement;
			if( child == null ) {
				if( requestCount == 0 ) poll() else sendQueuedRequests();
				return;
			}
			
			for( e in xml.elements ) {
				responseQueue.push( e );
			}
			resetResponseProcessor();
			if( requestCount == 0 && !sendQueuedRequests() ) {
				if( responseQueue.length > 0 ) Timer.delay( poll, 0 ) else poll();
			}
		} else {
			if( !initialized )
				return;
			sid = xml["sid"];
			if( sid == null ) {
				//TODO
				//cleanup();
				//onDisconnect( "invalid sid" );
				trace( "invalid sid" );
				return;
			}
			wait = Std.parseInt( xml["wait"] );
			if( xml.has( 'maxpause' ) ) {
				maxPause = Std.parseInt( xml.get( 'maxpause' ) ) * 1000;
				pauseEnabled = true;
			}
			if( xml.has( 'requests' ) )
				maxConcurrentRequests = Std.parseInt( xml.get( 'requests' ) );
			if( xml.has( 'inactivity' ) )
				maxConcurrentRequests = Std.parseInt( xml.get( 'inactivity' ) );
			ready = true;
			startCallback( xml.firstElement );
		}
	}

	function resetResponseProcessor() {
		if( responseQueue != null && responseQueue.length > 0 ) {
			if( responseTimer != null ) responseTimer.stop();
			responseTimer = new Timer( INTERVAL );
			responseTimer.run = processResponse;
		}
	}

	function processResponse() {
		responseTimer.stop();
		onData( responseQueue.shift().toString() );
		resetResponseProcessor();
	}

	function handleError( e ) {
		trace(e);
	}

	function handleTimeout() {
		trace("handleTimeout");
		//cleanup();
		//onDisconnect( "timeout" );
	}

	 function cleanup() {
        if( timeoutTimer != null ) timeoutTimer.stop();
        if( responseTimer != null ) responseTimer.stop();
        ready = initialized = false;
        sid = null;
        requestQueue = null;
        responseQueue = null;
        requestCount = 0;
    }

}
