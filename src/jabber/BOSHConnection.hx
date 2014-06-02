/*
 * Copyright (c) disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

#if js
	#if nodejs
	import js.Node;
	#else
	import js.html.XMLHttpRequest;
	#end
#elseif flash
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
#elseif php
	#error
#elseif sys
	import jabber.net.BOSHRequest;
#end
import haxe.io.Path;
//import jabber.util.Timer;
import haxe.Timer;

using StringTools;

/**
	Emulates the semantics of a long-lived, bidirectional TCP connection by efficiently using multiple synchronous HTTP request/response pairs without requiring the use of frequent polling or chunked responses.
	
	Bidirectional-streams Over Synchronous HTTP (BOSH): http://xmpp.org/extensions/xep-0124.html
	XMPP Over BOSH: http://xmpp.org/extensions/xep-0206.html
*/
class BOSHConnection extends jabber.StreamConnection {

	public static inline var BOSH_VERSION = "1.6";
	public static inline var XMLNS = "http://jabber.org/protocol/httpbind";
	public static inline var XBOSH = "urn:xmpp:xbosh";

	static inline var INTERVAL = 0;
	static inline var MAX_CHILD_ELEMENTS = 10;
	
	/** Server HTTP path */
	public var path(default,null) : String;
	
	/** Maximum number of requests the connection manager is allowed to keep waiting at any one time during the session. */
	public var hold(default,null) : Int;
	
	/** Longest time (in seconds) that the connection manager is allowed to wait before responding to any request during the session. */
	public var wait(default,null) : Int;
	
	/** Session id */
	public var sid(default,null) : String;
	
	/** Request id */
	public var rid(default,null) : Int;

	#if (sys||nodejs)
	public var ip : String;
	public var port : Int = 80;
	#end
	
	/** */
	public var maxConcurrentRequests(default,null) : Int;
	
	var initialized : Bool;
	var requestCount : Int;
	var requestQueue : Array<String>;
	var responseTimer : Timer;
	var responseQueue : Array<Xml>;
	var pollingEnabled : Bool;
	var pauseEnabled : Bool;
	var pauseTimer : Timer;
	var inactivity : Int;
	var maxPause : Int;
	var timeoutTimer : Timer;
	var timeoutOffset : Int;
	var attached : Bool;
	//var requests : Array<Http>;

	/**
		A new connection to a HTTP/BOSH gateway of a jabber server.
		The default wait time for responses is 30 seconds.
	*/
	public function new( host : String, path : String,
						 hold : Null<Int> = 1, wait : Null<Int> = 30, secure : Bool = false,
						 maxConcurrentRequests : Null<Int> = 2, timeoutOffset : Null<Int> = 25 ) {
		
		if( path.startsWith( 'https://' ) )
			path = path.substr(8);
		else if( path.startsWith( 'http://' ) )
			path = path.substr(7);
			
		super( host, secure, true );
		this.path = path;
		this.hold = hold;
		this.wait = wait;
		this.secure = secure;
		this.maxConcurrentRequests = maxConcurrentRequests;
		this.timeoutOffset = timeoutOffset;
		
		initialized = pauseEnabled = attached = false;
		pollingEnabled = true;
	}
	
	public override function connect() {
		if( initialized && connected ) {
			restart();
		} else {
			initialized = true;
			rid = Std.int( Math.random()*10000000 );
			requestCount = 0;
			requestQueue = new Array();
			responseQueue = new Array();
			responseTimer = new Timer( INTERVAL );
			var b = Xml.createElement( "body" );
			#if flash // TODO flash 2.06 fukup hack
			b.set( '_xmlns_', XMLNS );
			b.set( 'xml_lang', 'en' );
			b.set( 'xmlns_xmpp', XBOSH );
			b.set( 'xmpp_version', '1.0' );
			#else
			b.set( 'xmlns', XMLNS );
			b.set( 'xml:lang', 'en' );
			b.set( 'xmlns:xmpp', XBOSH );
			b.set( 'xmpp:version', '1.0' );
			#end
			b.set( 'ver', BOSH_VERSION );
			b.set( 'hold', Std.string( hold ) );
			b.set( 'rid', Std.string( rid ) );
			b.set( 'wait', Std.string( wait ) );
			b.set( 'to', host );
			b.set( 'secure', Std.string( secure ) );
			#if xmpp_debug
			XMPPDebug.o( b.toString() );
			#end
			sendRequests( b );
		}
	}
	
	public override function disconnect() {
		if( connected ) {
			var r = createRequest();
			r.set( "type", "terminate" );
			r.addChild( new xmpp.Presence(null,null,null,unavailable).toXml() );
			//sendQueuedRequests( r.toString() );
			sendRequests( r );
			cleanup();
			//onDisconnect(null);
			//TODO abot pending http requests
		}
	}
	
	public override function write( s : String ) : Bool {
		return sendQueuedRequests( s );
	}

	/**
		Set the value of the 'secs' attribute to null to force the connection manager to return all the requests it is holding.
	*/
	public function pause( secs : Null<Int> ) : Bool {
		#if jabber_debug
		trace( 'pausing bosh session for $secs seconds' );
		#end
		if( secs == null )
			secs = inactivity;
		if( !pauseEnabled || secs > maxPause )
			return false;
//		pollingEnabled = false;
		var r = createRequest();
		r.set( "pause", Std.string( secs ) );
		sendRequests( r );
		pauseTimer = new Timer( secs*1000 );
		pauseTimer.run = handlePauseTimeout;
		return true;
	}
	
	/**
		Attach to an already created BOSH session.
		Experrimental!
	*/
	public function attach( sid : String, rid : Int, wait : Int, hold : Int ) {
		this.sid = sid;
		this.rid = rid;
		this.wait = wait;
		this.hold = hold;
		initialized = true;
		requestCount = 0;
		requestQueue = new Array();
		responseQueue = new Array();
	//	responseTimer = new Timer( INTERVAL );
		connected = true;
		//onConnect();
		//attached = true;
		//restart();
	}
	
	function restart() {
		//if( attached )
		//	return;
		var r = createRequest();
		#if flash // haXe 2.06 fuckup
		r.set( '_xmlns_', XMLNS );
		r.set( "xmpp_restart", "true" );
		r.set( "xmlns_xmpp", XBOSH );
		r.set( "xml_lang", "en" );
		#else
		r.set( 'xmlns', XMLNS );
		r.set( "xmpp:restart", "true" );
		r.set( "xmlns:xmpp", XBOSH );
		r.set( "xml:lang", "en" );
		#end
		r.set( "to", host );
		#if xmpp_debug XMPPDebug.o( r.toString() ); #end
		sendRequests( r );
	}
	
	function sendQueuedRequests( ?t : String ) : Bool {
		if( t != null )
			requestQueue.push( t );
		else if( requestQueue.length == 0 )
			return false;
		return sendRequests( null );
	}
	
	function sendRequests( ?t : Xml, poll : Bool = false ) : Bool {
		
		if( requestCount >= maxConcurrentRequests ) {
			#if jabber_debug trace( 'max concurrent http request limit ($requestCount,$maxConcurrentRequests)' ); #end
			return false;
		}

		requestCount++;

		if( t == null ) {
			if( poll ) {
				t = createRequest();
			} else {
				var i = 0;
				var e = new Array<String>();
				while( i++ < MAX_CHILD_ELEMENTS && requestQueue.length > 0 )
					e.push( requestQueue.shift() );
				t = createRequest( e );
			}
		}
		
		createHTTPRequest( t.toString() );

		if( timeoutTimer != null ) timeoutTimer.stop();
		timeoutTimer = new Timer( (wait*1000)+(timeoutOffset*1000) );
		timeoutTimer.run = handleTimeout;
		
		return true;
	}
	
	function createHTTPRequest( data : String ) {
		
		#if js
			#if nodejs
			var _path = path.substr( path.lastIndexOf( '/' ) );
			_path = Path.addTrailingSlash( _path );
			var opts : Dynamic = { //TODO NodeHttpsReqOpt
				host : ip,
				port : port,
				path : _path,
				method : 'POST',
				//requestCert: false,
				rejectUnauthorized:  false,
				headers: { 'Content-Type' : 'text/xml', 'Content-Length' : data.length }
			};
			var h = function(res:NodeHttpClientResp) {
				switch res.statusCode {
				case 200:
					res.setEncoding( NodeC.UTF8 );
					res.on( NodeC.EVENT_STREAM_DATA, handleHTTPData );
				default:
					trace("TODO....");
					handleHTTPError( "ERROR" );
				}
			}
			var r : NodeHttpClientReq = secure ? Node.https.request( opts, h ): Node.http.request( opts, h );
			r.on( NodeC.EVENT_STREAM_ERROR, handleHTTPError );
			r.write( data );
			r.end();
			
			#elseif google_apps_script //TODO
			var options = {
				"method": "post",
				"headers": { "GData-Version": "2" },
				"payload": data
			};
			var result = google.script.UrlFetchApp.fetch( getHTTPPath(), options );
			handleHTTPData( result );

			#else
			var r = new XMLHttpRequest();
			//TODO if( crossOrigin ) r.withCredentials = true;
			r.open( "POST", getHTTPPath(), true );
			r.onreadystatechange = function(e){
				//trace(e+":"+r.readyState);
				if( r.readyState != 4 )
					return;
				var s = r.status;
				if( s != null && s >= 200 && s < 400 )
					handleHTTPData( r.responseText );
				else
					handleHTTPError( "Http Error #"+r.status );
			}
			r.send( data );

			#end
		
		#elseif flash
		var r = new flash.net.URLRequest( getHTTPPath() );
		r.method = flash.net.URLRequestMethod.POST;
		r.contentType = "text/xml";
		r.requestHeaders.push( new flash.net.URLRequestHeader( "Accept", "text/xml" ) );
		// TODO haXe 2.06 HACK
		var s = data;
		s = s.replace( '_xmlns_', 'xmlns' );
		s = s.replace( 'xml_lang', 'xml:lang' );
		s = s.replace( 'xmlns_xmpp', 'xmlns:xmpp' );
		s = s.replace( 'xmpp_version', 'xmpp:version' );
		s = s.replace( 'xmpp_restart', 'xmpp:restart' );
		r.data = s;
		var l = new flash.net.URLLoader();
		l.addEventListener( Event.COMPLETE, function(e) handleHTTPData(e.target.data) );
		l.addEventListener( IOErrorEvent.IO_ERROR, function(e){ handleHTTPError(e.type); } );
		l.addEventListener( SecurityErrorEvent.SECURITY_ERROR, function(e){ handleHTTPError(e.type); } );
		//l.addEventListener( HTTPStatusEvent.HTTP_STATUS, function(e) handleHTTPStatus( e.status ) );
		l.load( r );
		
		#elseif (cpp||neko)
		var _path = path.substr( path.lastIndexOf('/') );
		_path = Path.addTrailingSlash( _path );
		var r = new BOSHRequest();
		r.request( ip, port, _path, data, handleHTTPData, handleHTTPError );

		#else
		
		#end
	}
	
	function handleTimeout() {
		timeoutTimer.stop();
		cleanup();
		onDisconnect( "bosh timeout" );
	}
	
	/*
	function handleHTTPStatus( s : Int ) {
		//trace( "handleHTTPStatus "+s );
	}
	*/
	
	function handleHTTPError( e : String ) {
		//#if jabber_debug trace(e); #end
		cleanup();
		onDisconnect( e );
	}
	
	function handleHTTPData( t : String ) {
		if( t == null ) {
			#if jabber_debug trace( "Received empty bosh response" ); #end
			return;
		}
		var x : Xml = null;
		try x = Xml.parse( t ).firstElement() catch( e : Dynamic ) {
			#if jabber_debug trace( 'Invalid XML : '+t ); #end
			return;
		}
		if( x == null ) {
			#if jabber_debug trace( 'Received empty bosh response' ); #end
			//requestCount--; //?????????????????
			//poll();
			return;
		}
		if( x.get( 'xmlns' ) != XMLNS ) {
			#if jabber_debug trace( 'Invalid BOSH body ($x)' ); #end
			cleanup();
			onDisconnect( 'Invalid bosh body ($x)' );
			return;
		}
		requestCount--;
		if( timeoutTimer != null )
			timeoutTimer.stop();
		if( connected ) {
			switch( x.get( "type" ) ) {
			case "terminate" :
				cleanup();
				#if jabber_debug trace( 'BOSH stream terminated by server' ); #end
				onDisconnect( x.get( 'condition' ) );
				return;
			case "error" :
				trace("TODO");
				return;
			}
			var c = x.firstElement();
			if( c == null ) {
				if( requestCount == 0 )
					poll();
				else
					sendQueuedRequests();
				return;
			}
			for( e in x.elements() )
				responseQueue.push( e );
			resetResponseProcessor();
			if( requestCount == 0 && !sendQueuedRequests() )
				if( responseQueue.length > 0 ) Timer.delay( poll, 0 ) else poll();
			
		} else {
			if( !initialized )
				return;
			sid = x.get( "sid" );
			if( sid == null ) {
				cleanup();
				onDisconnect( "invalid sid" );
				return;
			}
			wait = Std.parseInt( x.get( "wait" ) );
			/*
			var t = x.get( "ver" );
			if( t != null &&  t != BOSH_VERSION ) {
				cleanup();
				onError( 'Invalid BOSH version ($t)' );
				return;
			}
			*/
			var t = null;
			t = x.get( "maxpause" );
			if( t != null ) {
				maxPause = Std.parseInt(t)*1000;
				pauseEnabled = true;
			}
			t = null;
			t = x.get( "requests" );
			if( t != null ) maxConcurrentRequests = Std.parseInt( t );
			t = null;
			t = x.get( "inactivity" );
			if( t != null ) inactivity = Std.parseInt( t );
			//#if xmpp_debug XMPPDebug.i( t ); #end
			onConnect();
			connected = true;
			onData( x.toString() );
		}
	}
	
	function handlePauseTimeout() {
		pauseTimer.stop();
		pollingEnabled = true;
		poll();
	}
	
	function processResponse() {
		responseTimer.stop();
		onData( responseQueue.shift().toString() );
		resetResponseProcessor();
	}
	
	function resetResponseProcessor() {
		if( responseQueue != null && responseQueue.length > 0 ) {
			if( responseTimer != null ) responseTimer.stop();
			responseTimer = new Timer( INTERVAL );
			responseTimer.run = processResponse;
		}
	}
	
	public function poll() {
		if( !connected || !pollingEnabled || requestCount > 0 || sendQueuedRequests() )
			return;
		sendRequests( null, true );
	}

	/* hhmmmmmmm ???? use ?
	function createRequestString( ?children : Array<String> ) : String {
		rid++;
		var s = '<body xmlns="$XMLNS" xml:lang="en" rid="$rid" sid="$sid">';
		if( children != null ) s += children.join('');
		return s+'</body>';
	}
	*/
	
	function createRequest( ?children : Array<String> ) : Xml {
		var x = Xml.createElement( "body" );
		#if flash //TODO haXe 2.06 fukup
		x.set( "_xmlns_", XMLNS );
		x.set( "xml_lang", "en" );
		#else
		x.set( "xmlns", XMLNS );
		x.set( "xml:lang", "en" );
		#end
		x.set( "rid", Std.string( ++rid ) );
		x.set( "sid", sid );
		if( children != null ) {
			for( e in children ) {
				//TODO it's a disaster we have to reparse the xml here!
				#if flash
				x.addChild( Xml.createPCData(e) );
				#else
				x.addChild( Xml.parse(e) );
				#end
			}
		}
		return x;
	}
	
	function getHTTPPath() : String {
		var b = new StringBuf();
		b.add( "http" );
		if( secure ) b.add( "s" );
		b.add( "://" );
		b.add( path );
		return b.toString();
	}
	
	function cleanup() {
		if( timeoutTimer != null ) timeoutTimer.stop();
		if( responseTimer != null ) responseTimer.stop();
		connected = initialized = false;
		sid = null;
		requestQueue = null;
		responseQueue = null;
		requestCount = 0;
	}

}
