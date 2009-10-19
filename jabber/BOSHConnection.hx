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

#if flash
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
#end
//import util.Timer;
	
	//TODO reconnect fuk
	//TODO timeout timer (?)
	//TODO polling 
	///TODO multiple streams over one connection)
	//TODO secure!
	//TODO secure keys
	//TODO pause
	
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
	
	public static inline var BOSH_VERSION = "1.6";
	public static var XMLNS = "http://jabber.org/protocol/httpbind";
	public static var XMLNS_XMPP = "urn:xmpp:xbosh";
	
	public var path(default,null) : String;
	/** Maximum number of requests the connection manager is allowed to keep waiting at any one time during the session. */
	public var hold(default,null) : Int;
	/** Longest time (in seconds) that the connection manager is allowed to wait before responding to any request during the session. */
	public var wait(default,null) : Int;
	public var sid(default,null) : String;
	public var maxConcurrentRequests(default,null) : Int;
	public var secure(default,null) : Bool;
	
	var initialized : Bool;
	//var restarted : Bool; //TODO replace connected ?
	var rid : Int;
	var maxPause : Int;
	var requestCount : Int;
	var requestQueue : Array<Xml>;
	//var responseQueue : Array<Xml>;
	//var responseTimer : Timer;
	
	public function new( host : String, path : String,
						 hold : Int = 1, wait : Int = 30,
						 secure : Bool = false ) {
		super( host );
		this.path = path;
		this.hold = hold;
		this.wait = wait;
		this.secure = secure;
		maxConcurrentRequests = 2; //TODO
		initialized = false;
		rid = Std.int( Math.random()*10000000 );
		requestCount = 0;
		requestQueue = new Array();
	}

	public override function connect() {
		if( connected )
			restart();
		else {
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
			initialized = true;
			sendRequests( b );
		}
	}
	
	public override function disconnect() {
		if( connected ) {
			var r = createRequest();
			r.set( "type", "terminate" );
			r.addChild( new xmpp.Presence(null,null,null,xmpp.PresenceType.unavailable).toXml() );
			sendRequests( r );
			/*
			connected = initialized = false;
			requestCount = 0;
			requestQueue = new Array();
			sid = null;
			*/
			cleanup();
			//onDisconnect();
		}
	}
	
	public override function write( t : String ) : String {
		try {
			var x = Xml.parse( t );
			sendQueuedRequests( x ); //TODO, remove Xmlparse
		} catch( e : Dynamic ) {
			return null;
		}
		return t;
	}
	
	function restart() {
		//trace("BOSH RESTART");
		var r = createRequest();
		r.set( "xmpp:restart", "true" );
		r.set( "xmlns:xmpp", XMLNS_XMPP );
		r.set( 'xmlns', XMLNS );
		r.set( "xml:lang", "en" );
		r.set( "to", host );
		sendRequests( r );
	}
	
	function sendQueuedRequests( ?t : Xml ) : Bool {
		if( t != null )
			requestQueue.push( t );
		else if( requestQueue.length == 0 )
			return false;
		return sendRequests( null );
	}
	
	function sendRequests( t : Xml, ?poll : Bool = false ) : Bool {
		if( requestCount >= maxConcurrentRequests ) {
			trace("maxConcurrentRequests limit");
			return false;
		}
		requestCount++;
		if( t == null ) {
			if( poll ) {
				//TODO create timeout timer
				t = createRequest();
			} else {
				var i = 0;
				var tmp = new Array<Xml>();
				while( i++ < 10 && requestQueue.length > 0 )
					tmp.push( requestQueue.shift() );
				t = createRequest( tmp );
			}
		}
		#if flash
		var r = new flash.net.URLRequest( getHTTPPath() );
		r.method = flash.net.URLRequestMethod.POST;
		r.contentType = "text/xml";
		r.data = t.toString();
		r.requestHeaders.push( new flash.net.URLRequestHeader( "Accept", "text/xml" ) );
		var me = this;
		var l = new flash.net.URLLoader();
		l.addEventListener( Event.COMPLETE, function(e) me.handleHTTPData( e.target.data ) );
		l.addEventListener( IOErrorEvent.IO_ERROR, handleHTTPError );
		l.addEventListener( HTTPStatusEvent.HTTP_STATUS, function(e) me.handleHTTPStatus( e.status ) );
		l.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleHTTPError );
		l.load( r );
		#elseif js
		var r = new haxe.Http( getHTTPPath() );
		r.onStatus = handleHTTPStatus;
		r.onError = handleHTTPError;
		r.onData = handleHTTPData;
	//	#if neko
	//	r.setHeader( "Host", "127.0.0.1" );
	//	r.setHeader( "User-Agent", "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.3) Gecko/20090910 Ubuntu/9.04 (jaunty) Shiretoko/3.5.3" );
	//	r.setHeader( "Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" );
	//	r.setHeader( "Accept-Encoding", "gzip,deflate" );
	//	r.setHeader( "Accept-Charset", "ISO-8859-1,utf-8;q=0.7,*;q=0.7" );
	//	r.setHeader( "Keep-Alive", "300" );
		//r.setHeader( "Referer", "http://127.0.0.1/xiki_3/www/" );
	//	r.setHeader( "Content-Length", Std.string( t.toString().length ) );
	//	r.setHeader( "Content-Type", "text/plain; charset=UTF-8" );
	//	r.noShutdown = true;
	//	#end
		r.setPostData( t.toString() );
		r.request( true );
		#end
	//	if( poll ) {
	//	}
		return true;
	}
	
	//function sendQueuedRequestsAsString
	
	function handleHTTPStatus( s : Int ) {
		//if( s != 200 ) 
		//trace( "handleHTTPStatus "+s );
	}
	
	function handleHTTPError( e : String ) {
		//trace("handleHTTPError "+e);
		onError( e );
	}
	
	function handleHTTPData( t : String ) {
		trace("handleHTTPData "+connected);
		requestCount--;
		var x = Xml.parse( t ).firstElement();
//		trace("handleHTTPData " );
		if( connected ) {
			if( x.get( "type" ) == "terminate" ) {
				//TODO
				trace("BOSH TERMINATED");
				cleanup();
				onDisconnect();
			}
			var c = x.firstElement();
			if( c == null ) {
				//TODO check if rmpty terminate response
				if( requestCount == 0 )
					poll();
				else
					sendQueuedRequests();
				return;
			} 
			var b = haxe.io.Bytes.ofString( c.toString() );
			try {
				onData( b, 0, b.length );
			} catch( e : Dynamic ) {
				trace(e);
			}
			if( requestCount == 0 && !sendQueuedRequests() ) {
				//trace("pollit");
				poll();
			}
			
		} else {
			if( initialized ) {
				sid = x.get( "sid" );
				/*
				if( sid == null ) {
					throw "No SID!";
					connected = initialized = false;
				}
				*/
				wait = Std.parseInt( x.get( "wait" ) );
				var t = x.get( "ver" );
				if( t != null &&  t != BOSH_VERSION ) {
					onError( "Invalid BOSH version ("+t+")" );
					return;
				}
				var t = x.get( "maxpause" );
				if( t != null ) maxPause = Std.parseInt( t ) * 1000;
				var t = x.get( "requests" );
				if( t != null ) maxConcurrentRequests = Std.parseInt( t );
				
				onConnect();
				connected = true;
				var b = haxe.io.Bytes.ofString( x.toString() );
				onData( b, 0, b.length );
				
			} else {
				//trace("????????? "+ x );
			}
		}
	}
	
	function createRequest( ?t : Array<Xml> ) : Xml {
		var x = Xml.createElement( "body" );
		x.set( "xmlns", XMLNS );
		x.set( "xml:lang", "en" );
		x.set( "rid", Std.string( ++rid ) );
		x.set( "sid", sid );
		if( t != null ) {
			for( e in t )
				x.addChild( e );
		}
		return x;
	}
	
	function createRequestString( t : String ) : String {
		var x = Xml.createElement( "body" );
		x.set( "xmlns", XMLNS );
		x.set( "xml:lang", "en" );
		x.set( "rid", Std.string( ++rid ) );
		x.set( "sid", sid );
		var s = x.toString();
		trace(s.length);
		s = s.substr( 0, s.length-2 )+">";
		s += t+"</body>";
		trace(s);
		return s;
	}
	
	function getHTTPPath() : String {
		var b = new StringBuf();
		b.add( "http" );
	//	if( secure ) b.add( "s" );
		b.add( "://" );
		b.add( path );
		return b.toString();
	}
	
	//TODO
	function cleanup() {
		connected = initialized = false;
		sid = null;
		rid = Std.int( Math.random()*10000000 );
		requestCount = 0;
		requestQueue = new Array();
	}
	
	inline function poll() {
		sendRequests( null, true );
	}
	
}
