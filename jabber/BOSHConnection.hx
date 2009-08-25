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
#end
#if (flash||js)
import haxe.Timer;
#elseif neko
import util.Timer;
#elseif cpp
import util.Timer;
#end

/**
	Emulates the semantics of a long-lived, bidirectional TCP connection
	by efficiently using multiple synchronous HTTP request/response pairs
	without requiring the use of frequent polling or chunked responses.
	
	TODO timeout timer
	TODO polling
	//TODO multiple streams over one connections
	// sec keys
*/
class BOSHConnection extends jabber.stream.Connection {
	
	public static inline var BOSH_VERSION = "1.6";
	public static var XMLNS = "http://jabber.org/protocol/httpbind";
	public static var XMLNS_XMPP = "urn:xmpp:xbosh";
	
	public var path(default,null) : String;
	public var secure(default,null) : Bool;
	public var sid(default,null) : String;
	public var hold(default,null) : Int;
	public var wait(default,null) : Int;
	public var maxConcurrentRequests(default,null) : Int;
	
	var rid : Int;
	var requestCount : Int;
	var requestQueue : Array<Xml>;
	var active : Bool;
	var timer : Timer;
	var maxPause : Int;
	//var inactivity : Int;
	//var request : #if flash flash.net.URLReques #else
	//var key : String;
	
	public function new( host : String, path : String,
						 ?secure : Bool = false, ?hold : Int = 1, ?wait : Int = 15,
						 ?key : String ) {
		
		super( host );
		this.path = path;
		this.secure = secure;
		this.hold = hold;
		this.wait = wait;
		
	//	this.key = key;
		
		maxConcurrentRequests = 2; // TODO -1;
		rid = Std.int( Math.random()*10000000 );
		requestCount = 0;
		requestQueue = new Array();
		active = false;
		//timer = new haxe.Timer( 10000 );
	}
	
	public override function connect() {
		if( connected )
			restart();
		else {
			var b = Xml.createElement( "body" );
			b.set( 'xml:lang', 'en' );
			b.set( 'xmlns', XMLNS );
			b.set( 'xmlns:xmpp', 'urn:xmpp:xbosh' );
			b.set( 'xmpp:version', '1.0' );
			b.set( 'ver', BOSH_VERSION );
			b.set( 'hold', Std.string( hold ) );
			b.set( 'rid', Std.string( rid ) );
			b.set( 'wait', Std.string( wait ) );
			b.set( 'to', host );
			b.set( 'secure', Std.string( secure ) );
			//b.set( 'content', 'text/xml; charset=utf-8' );
			//b.set( 'window', '5' );
			//route='xmpp:jabber.org:9999'
			//b.set( 'newkey', 'bfb06a6f113cd6fd3838ab9d300fdb4fe3da2f7d');
			/*
			if( key != null ) {
				newkey='ca393b51b682f61f98e7877d61146407f3d0a770'
			}
			*/
			sendRequests( b );
			active = true;
			#if XMPP_DEBUG
			jabber.XMPPDebug.outgoing( b.toString() );
			#end
		}
	}
	
	public override function write( t : String ) {
		//if( !connected ) return null;
		try {
			sendQueuedRequests( Xml.parse( t ) ); //TODO, remove Xmlparse
		} catch( e : Dynamic) {
			return null;
		}
		return t;
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
		trace(e);
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
			try {
				onData( b, 0, b.length );
			} catch( e : Dynamic ) {
				trace(e);
			}
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
				//lastKey = sid = x.get( "key" );
				
				sid = x.get( "sid" );
				wait = Std.parseInt( x.get( "wait" ) );
				// TODO
				// <body xmlns="http://jabber.org/protocol/httpbind" xmlns:stream="http://etherx.jabber.org/streams" authid="764f197f" sid="764f197f" secure="true" requests="2" inactivity="30" polling="5" wait="20" hold="1" ack="5079633" maxpause="300" ver="1.6"><stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><mechanism>DIGEST-MD5</mechanism><mechanism>PLAIN</mechanism><mechanism>ANONYMOUS</mechanism><mechanism>CRAM-MD5</mechanism></mechanisms><compression xmlns="http://jabber.org/features/compress"><method>zlib</method></compression><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/><session xmlns="urn:ietf:params:xml:ns:xmpp-session"/></stream:features></body>
			
				var t = x.get( "ver" );
				if( t != null &&  t != BOSH_VERSION ) {
					onError( "Invalid BOSH version ("+t+")" );
					return;
				}
			//	var t = x.get( "polling" );
			//	if( t != null ) polling = Std.parseInt( t );
				//t = x.get( "inactivity" );
				//if( t != null ) inactivity = Std.parseInt( t );
				var t = x.get( "maxpause" );
				if( t != null ) maxPause = Std.parseInt( t ) * 1000;
				var t = x.get( "requests" );
				if( t != null ) maxConcurrentRequests = Std.parseInt( t );
				//..
				
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
		if( t != null )
			requestQueue.push( t );
		else if( requestQueue.length == 0 )
			return false;
		return sendRequests( null );
	}
	
	function sendRequests( t : Xml, ?poll : Bool = false ) : Bool {
		if( requestCount >= maxConcurrentRequests )
			return false;
		requestCount++;
		if( t == null ) {
			t = if( poll ) {
				//TODO create timeout timer
				createRequest();
			} else {
				var i = 0;
				var tmp = new Array<Xml>();
				while( i++ < 10 && requestQueue.length > 0 )
					tmp.push( requestQueue.shift() );
				createRequest( tmp );
			}
		}
		#if flash
		var r = new flash.net.URLRequest( path );
		r.method = flash.net.URLRequestMethod.POST;
		r.contentType = "text/xml";
		r.data = t.toString();
		//r.requestHeaders.push( new flash.net.URLRequestHeader( "Content-type", "text/xml" ) );
		//r.requestHeaders.push( new flash.net.URLRequestHeader( "Accept", "text/xml" ) );
		var me = this;
		var l = new flash.net.URLLoader();
		l.dataFormat = flash.net.URLLoaderDataFormat.TEXT;
		l.addEventListener( flash.events.Event.COMPLETE, function(e) me.handleHTTPData( e.target.data ) );
		l.addEventListener( flash.events.IOErrorEvent.IO_ERROR, function(e) me.handleHTTPError( e ) );
		l.addEventListener( HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent) me.handleHTTPStatus( e.status ) );
		l.addEventListener( flash.events.ProgressEvent.PROGRESS, function(e) {
	//		trace( e );
		} );
		l.addEventListener( flash.events.ProgressEvent.SOCKET_DATA, function(e) {
	//		trace( e );
		} );
	//	l.addEventListener( flash.events.Event.OPEN, function(e) trace( e ) );
		l.addEventListener( flash.events.SecurityErrorEvent.SECURITY_ERROR, function(e) trace( e ) );
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
		if( poll ) {
			/*
			//trace("PPOLL");
			if( timer != null )
				timer.stop();
			timer = new Timer( inactivity*1000 );//timer = new Timer( (wait-5)*1000 );
			timer.run = handleTimeout;
			*/
		}
		return true;
	}
	
	function handleTimeout() {
		trace("#################TODO timeout");
		timer.stop();
		//TODO handle timeout
		//..
		onDisconnect();
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
	
	/*
	function createStringRequest( t : String ) : String {
		var x = createRequest();
		var s = x.toString();
		s = s.substr( 0, s.length-2 ) + t + "</body>";
		return s;
	}
	*/
	
	inline function poll() {
		sendRequests( null, true );
	}
	
}
