/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber;

import util.Timer;
#if flash
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
#end
	
	//TODO
	
	// timeout timer (?), added but needed?
	
	// polling 
	/// multiple streams over one connection
	// secure!
	// secure keys
	// pause -> test
	
/**
	<p>
	Emulates the semantics of a long-lived, bidirectional TCP connection
	by efficiently using multiple synchronous HTTP request/response pairs
	without requiring the use of frequent polling or chunked responses.
	</p>
	<a href="http://xmpp.org/extensions/xep-0124.html">Bidirectional-streams Over Synchronous HTTP (BOSH)</a><br/>
	<a href="http://xmpp.org/extensions/xep-0206.html">XMPP Over BOSH</a><br/>
*/
class BOSHConnection extends jabber.stream.Connection {
	
	static function __init__() {
		XMLNS = "http://jabber.org/protocol/httpbind";
		XMLNS_XMPP = "urn:xmpp:xbosh";
	}
	
	public static inline var BOSH_VERSION = "1.6";
	public static var XMLNS(default,null) : String;
	public static var XMLNS_XMPP(default,null) : String;
	
	/** BOSH path */
	public var path(default,null) : String;
	/** Maximum number of requests the connection manager is allowed to keep waiting at any one time during the session. */
	public var hold(default,null) : Int;
	/** Longest time (in seconds) that the connection manager is allowed to wait before responding to any request during the session. */
	public var wait(default,null) : Int;
	/** BOSH session id */
	public var sid(default,null) : String;
	/** */
	public var maxConcurrentRequests(default,null) : Int;
	/** */
	public var secure(default,null) : Bool;
	
	var initialized : Bool;
	var rid : Int;
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
	
	public function new( host : String, path : String,
						 hold : Int = 1,
						 wait : Int = 30,
						 secure : Bool = false,
						 maxConcurrentRequests : Int = 2 ) {
		super( host );
		this.path = path;
		this.hold = hold;
		this.wait = wait;
		this.secure = secure;
		this.maxConcurrentRequests = maxConcurrentRequests;
		initialized = false;
		pauseEnabled = false;
		pollingEnabled = true;
		timeoutOffset = 25;//TODO
	}
	
	/**
	*/
	public override function connect() {
		if( initialized && connected ) {
			restart();
		} else {
			initialized = true;
			rid = Std.int( Math.random()*10000000 );
			requestCount = 0;
			requestQueue = new Array();
			responseQueue = new Array();
			responseTimer = new Timer( 1 );
			var b = Xml.createElement( "body" );
			b.set( 'xml:lang', 'en' );
			b.set( 'xmlns', XMLNS );
			b.set( 'xmlns:xmpp', XMLNS_XMPP );
			b.set( 'xmpp:version', '1.0' );
			b.set( 'ver', BOSH_VERSION );
			b.set( 'hold', Std.string( hold ) );
			b.set( 'rid', Std.string( rid ) );
			b.set( 'wait', Std.string( wait ) );
			b.set( 'to', host );
			b.set( 'secure', Std.string( secure ) );
			#if XMPP_DEBUG
			XMPPDebug.out( b.toString() );
			#end
			sendRequests( b );
		}
	}
	
	/**
	*/
	public override function disconnect() {
		if( connected ) {
			var r = createRequest();
			r.set( "type", "terminate" );
			r.addChild( new xmpp.Presence(null,null,null,xmpp.PresenceType.unavailable).toXml() );
			//sendQueuedRequests( r.toString() );
			sendRequests( r );
			cleanup();
			//onDisconnect();
		}
	}
	
	/**
	*/
	public override function write( t : String ) : Bool {
		sendQueuedRequests( t );
		return true;
	}
	
	/**
		Set the value of the 'secs' attribute to null to force the connection manager
		to return all the requests it is holding.
	*/
	public function pause( secs : Null<Int> ) : Bool {
		#if JABBER_DEBUG
		trace( "Pausing BOSH session for "+secs+" seconds" );
		#end
		if( secs == null )
			secs = inactivity;
		if( !pauseEnabled || secs > maxPause )
			return false;
//		pollingEnabled = false;
		var r = createRequest();
		r.set( "pause", Std.string( secs ) );
		sendRequests( r );
		pauseTimer = new util.Timer( secs*1000 );
		pauseTimer.run = handlePauseTimeout;
		return true;
	}
	
	function restart() {
		var r = createRequest();
		r.set( "xmpp:restart", "true" );
		r.set( "xmlns:xmpp", XMLNS_XMPP );
		r.set( 'xmlns', XMLNS );
		r.set( "xml:lang", "en" );
		r.set( "to", host );
		#if XMPP_DEBUG
		XMPPDebug.out( r.toString() );
		#end
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
			#if JABBER_DEBUG trace( "max concurrent request limit reached ("+requestCount+","+maxConcurrentRequests+")", "info" ); #end
			//requestQueue.push(t);
			return false;
		}
		requestCount++;
		if( t == null ) {
			if( poll ) {
				t = createRequest();
			} else {
				var i = 0;
				var tmp = new Array<String>();
				while( i++ < 10 && requestQueue.length > 0 )
					tmp.push( requestQueue.shift() );
				 t = createRequest( tmp );
			}
		}
		#if js
		var r = new haxe.Http( getHTTPPath() );
		//r.onStatus = handleHTTPStatus;
		r.onError = handleHTTPError;
		r.onData = handleHTTPData;
		r.setPostData( t.toString() );
		r.request( true );
		#elseif flash
		var r = new flash.net.URLRequest( getHTTPPath() );
		r.method = flash.net.URLRequestMethod.POST;
		r.contentType = "text/xml";
		r.data = t.toString();
		r.requestHeaders.push( new flash.net.URLRequestHeader( "Accept", "text/xml" ) );
		var me = this;
		var l = new flash.net.URLLoader();
		l.addEventListener( Event.COMPLETE, function(e) me.handleHTTPData( e.target.data ) );
		l.addEventListener( IOErrorEvent.IO_ERROR, handleHTTPError );
		//l.addEventListener( HTTPStatusEvent.HTTP_STATUS, function(e) me.handleHTTPStatus( e.status ) );
		l.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleHTTPError );
		l.load( r );
		#end
		if( timeoutTimer != null )
			timeoutTimer.stop();
		timeoutTimer = new Timer( (wait*1000)+(timeoutOffset*1000) );
		timeoutTimer.run = handleTimeout;
		return true;
	}
	
	function handleTimeout() {
		//trace("TIMEOUT TIMEOUT TIMEOUT TIMEOUT ");
		timeoutTimer.stop();
		cleanup();
		__onError( "BOSH timeout" );
	}
	
	/*
	function handleHTTPStatus( s : Int ) {
		trace( "handleHTTPStatus "+s );
	}
	*/
	
	function handleHTTPError( e : String ) {
		trace("handleHTTPError "+e);
		cleanup();
		__onError( e );
	}
	
	function handleHTTPData( t : String ) {
		var x : Xml = null;
		try {
			x = Xml.parse( t ).firstElement();
		} catch( e : Dynamic ) {
			#if JABBER_DEBUG trace( "Invalid XML" ); #end
			return;
		}
		if( x.get( "xmlns" ) != XMLNS ) {
			#if JABBER_DEBUG trace( "Invalid BOSH body" ); #end
			return;
		}
		requestCount--;
		if( timeoutTimer != null ) {
			timeoutTimer.stop();
		}
		if( connected ) {
			switch( x.get( "type" ) ) {
			case "terminate" :
				cleanup();
				#if JABBER_DEBUG
				trace( "BOSH stream terminated by server", "warn" );
				#end
				__onDisconnect();
				return;
			case "error" :
				//TODO
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
		//	var b = haxe.io.Bytes.ofString( c.toString() );
		//	__onData( b, 0, b.length );
			for( e in x.elements() ) {
				responseQueue.push( e );
			}
			resetResponseProcessor();
			if( requestCount == 0 &&
				!sendQueuedRequests() ) {
				( responseQueue.length > 0 ) ? Timer.delay( poll, 0 ) : poll();
			}
			
		} else {
			if( !initialized )
				return;
			sid = x.get( "sid" );
			if( sid == null ) {
				cleanup();
				__onError( "Invalid SID" );
				return;
			}
			wait = Std.parseInt( x.get( "wait" ) );
			/*
			var t = x.get( "ver" );
			if( t != null &&  t != BOSH_VERSION ) {
				cleanup();
				__onError( "Invalid BOSH version ("+t+")" );
				return;
			}
			*/
			var t = null;
			t = x.get( "maxpause" );
			if( t != null ) {
				maxPause = Std.parseInt( t )*1000;
				pauseEnabled = true;
			}
			t = null;
			t = x.get( "requests" );
			if( t != null ) maxConcurrentRequests = Std.parseInt( t );
			t = null;
			t = x.get( "inactivity" );
			if( t != null ) inactivity = Std.parseInt( t );
		//	#if XMPP_DEBUG
		//	trace("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
		//	XMPPDebug.inc( t );
		//	#end
			__onConnect();
			connected = true;
			var b = haxe.io.Bytes.ofString( x.toString() );
			__onData( b, 0, b.length );
		}
	}
	
	function handlePauseTimeout() {
		pauseTimer.stop();
		pollingEnabled = true;
		poll();
	}
	
	function processResponse() {
		responseTimer.stop();
		var x = responseQueue.shift();
		var b = haxe.io.Bytes.ofString( x.toString() );
		__onData( b, 0, b.length );
		resetResponseProcessor();
	}
	
	function resetResponseProcessor() {
		if( responseQueue != null && responseQueue.length > 0 ) {
			responseTimer.stop();
			responseTimer = new Timer( 0 );
			responseTimer.run = processResponse;
		}
	}
	
	function poll() {
		if( !connected || !pollingEnabled || requestCount > 0 || sendQueuedRequests() )
			return;
		sendRequests( null, true );
	}
	
	function createRequest( ?t : Iterable<String> ) : Xml {
		var x = Xml.createElement( "body" );
		x.set( "xmlns", XMLNS );
		x.set( "xml:lang", "en" );
		x.set( "rid", Std.string( ++rid ) );
		x.set( "sid", sid );
		if( t != null ) {
			for( e in t ) { x.addChild( Xml.createPCData(e) ); }
		}
		return x;
	}
	
	function getHTTPPath() : String {
		var b = new StringBuf();
		b.add( "http" );
		//if( secure ) b.add( "s" );
		b.add( "://" );
		b.add( path );
		return b.toString();
	}
	
	function cleanup() {
		timeoutTimer.stop();
		responseTimer.stop();
		connected = initialized = false;
		sid = null;
		requestCount = 0;
		requestQueue = null;
		responseQueue = null;
	}
	
}
