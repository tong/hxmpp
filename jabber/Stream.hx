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

import haxe.io.Bytes;
import jabber.util.Base64;
import xmpp.IQ;
import xmpp.filter.PacketIDFilter;

#if jabber_component
import jabber.component.Stream;
private typedef JID = ComponentJID;
#end

private typedef Server = {
	var features :Map<String,Xml>;
}

private class StreamFeatures {

	var l : #if neko List<String> #else Array<String> #end;
	
	public function new() {
		l = #if neko new List() #else new Array<String>() #end;
	}
	
	public inline function iterator() : Iterator<String> {
		return l.iterator();
	}
	
	public function add( f : String ) : Bool {
		if( Lambda.has( l, f ) ) return false;
		#if neko l.add(f) #else l.push(f) #end;
		return true;
	}
	
	public inline function has( f : String ) : Bool {
		return Lambda.has( l, f );
	}
	
	public inline function remove( f : String ) : Bool {
		return l.remove( f );
	}
	
	public inline function clear( f : String ) {
		l = #if neko new List() #else new Array<String>() #end;
	}
	
	#if jabber_debug
	public inline function toString() : String { return l.toString(); }
	#end
}

/**
	Abstract base class for handling a XMPP data stream with another entity.
	
	Implementations using this class are:
		* jabber.client.Stream
		* jabber.component.Stream
*/
class Stream {
	
	public static var defaultPacketIdLength = 5;
	public static var defaultMaxBufSize = 1048576; // 524288; //TODO hmmmmmm
	
	/**
		Called when the XMPP stream is opened and ready to exchange XMPP data
	*/
	public dynamic function onOpen() {}
	
	/**
		Called when the XMPP stream closes, optionally reporting stream errors
	*/
	public dynamic function onClose( ?e : String ) {}
	
	/** Current status of the XMPP stream */
	public var status : StreamStatus;
	
	/** The connection used to transport xmpp data */
	public var cnx(default,set) : StreamConnection;
	
	/** Clients stream features */
	public var features(default,null) : StreamFeatures;
	
	/** */
	public var server(default,null) : Server;
	
	/** Stream id */
	public var id(default,null) : String;
	
	/** */
	public var lang(default,null) : String;
	
	/** Jabber-id */
	public var jid(default,set) : JID;

	public var dataFilters(default,null) : Array<StreamDataFilter>;
	public var dataInterceptors(default,null) : Array<StreamDataInterceptor>;

	/***/
	public var bufSize(default,null) : Int;

	/***/
	public var maxBufSize : Int;
	
	var buf : StringBuf;
	var collectors_id : Array<PacketCollector>;
	var collectors : Array<PacketCollector>;
	var interceptors : Array<PacketInterceptor>;
	var numPacketsSent : Int;
	
	function new( cnx : StreamConnection, ?maxBufSize : Int ) {
		this.maxBufSize = ( maxBufSize == null || maxBufSize < 1 ) ? defaultMaxBufSize : maxBufSize;
		cleanup();
		if( cnx != null )
			set_cnx( cnx );
	}
	
	function set_jid( j : JID ) : JID {
		if( status != StreamStatus.closed )
			throw "cannot change jid on open xmpp stream";
		return jid = j;
	}
	
	function set_cnx( c : StreamConnection ) : StreamConnection {
		switch( status ) {
		case open, pending #if !jabber_component, starttls #end :
			close( true );
			set_cnx( c );
			 // re-open XMPP stream
			#if jabber_component
			// ?????
			#else
			open( jid );
			#end
		case closed :
			if( cnx != null && cnx.connected )
				cnx.disconnect();
			resetBuffer();
			cnx = c;
			cnx.__onConnect = handleConnect;
			cnx.__onDisconnect = handleDisconnect;
			cnx.__onString = handleString;
			cnx.__onData = handleData;
		}
		return cnx;
	}
	
	/**
		Create/Returns the next unique id for this XMPP stream
	*/
	public function nextID() : String {
		return Base64.random( defaultPacketIdLength ) #if jabber_debug+"_"+numPacketsSent #end;
	}
	
	/**
		Open the XMPP stream.
	*/
	#if jabber_component
	public function open( host : String, subdomain : String, secret : String, ?identities : Array<xmpp.disco.Identity> ) {
		#if jabber_debug throw 'abstract method "open", use "connect" for components'; #end
	}
	#else
	public function open( jid : JID ) {
		if( jid != null )
			this.jid = jid
		else if( this.jid == null )
			this.jid = new JID( null );
		if( cnx == null )
			throw 'no stream connection set';
		//status = Status.pending;
		cnx.connected ? handleConnect() : cnx.connect();
	}
	#end
	
	/**
		Closes the XMPP stream.<br/>
		Passed argument indicates if the data connection to the server should also get disconnected.
	*/
	public function close( ?disconnect = false ) {
		if( status == closed ) {
			#if jabber_debug trace( "cannot close xmpp stream, status is 'closed'" ); #end
			return;
		}
		if( !cnx.http )
			sendData( "</stream:stream>" );
		if( disconnect || cnx.http )
			cnx.disconnect();
		handleDisconnect( null );
	}
	
	/**
		Intercept/Send/Return XMPP packet.
	*/
	public function sendPacket<T:xmpp.Packet>( p : T, intercept : Bool = true ) : T {
		if( !cnx.connected )
			return null;
		if( intercept )
			interceptPacket( #if (java||cs) cast #end p ); //TODO still throws error on java
		return ( sendData( untyped p.toString() ) != null ) ? p : null;
	}
	
	/**
		Send raw string.
	*/
	public function sendData( t : String ) : String {
		if( !cnx.connected )
			return null;
		#if flash // TODO haXe 2.06 fukup		
		t = StringTools.replace( t, "_xmlns_=", "xmlns=" );
		#end
		if( dataInterceptors.length > 0 ) {
			if( sendBytes( haxe.io.Bytes.ofString(t+"\n") ) == null )
				return null;
		} else {
			if( !cnx.write( t ) )
				return null;
		}
		numPacketsSent++;
		#if xmpp_debug
		XMPPDebug.o( t );
		#end
		return t;
	}
	
	//TODO public function sendBytes( bytes : Bytes ) : Bytes {
	public function sendBytes( bytes : Bytes ) : Bytes {
		for( i in dataInterceptors )
			bytes = i.interceptData( bytes );
		if( !cnx.writeBytes( bytes ) )
			return null;
		return bytes;
	}
	
	/**
		Send an IQ packet and forwards the response to the given handler function.
	*/
	public function sendIQ( iq : IQ, ?handler : IQ->Void ) : IQ {
		if( iq.id == null ) iq.id = nextID();
		var c : PacketCollector = null;
		if( handler != null ) c = addIDCollector( iq.id, handler );
		var s : IQ = sendPacket( iq );
		// TODO wtf, is this needed ?
		if( s == null && handler != null ) {
			collectors.remove( c );
			c = null;
			return null;
		}
		//return { iq : s, collector : c };
		return iq;
	}

	/**
		Create and send the resulting iq for given request
	*/
	public inline function sendIQResult( iq : IQ ) {
		sendPacket( IQ.createResult( iq ) );
	}

	/**
		Send a message packet (default type is 'chat').
	*/
	public function sendMessage( to : String, body : String, ?subject : String, ?type : xmpp.MessageType, ?thread : String, ?from : String ) : xmpp.Message {
		return cast sendPacket( new xmpp.Message( to, body, subject, type, thread, from ) );
	}
	
	/**
		Send a presence packet.
	*/
	public function sendPresence( ?show : xmpp.PresenceShow, ?status : String, ?priority : Int, ?type : xmpp.PresenceType ) : xmpp.Presence {
		return cast sendPacket( new xmpp.Presence( show, status, priority, type ) );
	}
	
	/**
		Send directed presence
	*/
	public inline function sendPresenceTo( jid : String, ?show : xmpp.PresenceShow, ?status : String, ?priority : Int, ?type : xmpp.PresenceType ) : xmpp.Presence {
		var p = new xmpp.Presence();
		p.to = jid;
		return  sendPacket(p);
	}
	
	/**
		Runs the XMPP packet interceptor on the given packet.
	*/
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		for( i in interceptors ) i.interceptPacket( p );
		return p;
	}
	
	/**
		Creates, adds and returns a XMPP packet collector.
	*/
	public function collect( filters : Iterable<xmpp.PacketFilter>, handler : Dynamic->Void, permanent : Bool = false ) : PacketCollector {
		var c = new PacketCollector( filters, handler, permanent );
		return addCollector( c ) ? c : null;
	}
	
	/**
		Adds an packet collector which filters XMPP packets by ids.
		These collectors get processed before any other.
	*/
	public function addIDCollector( id : String, handler : Dynamic->Void ) : PacketCollector {
		var c = new PacketCollector( [new PacketIDFilter(id)], handler );
		collectors_id.push( c );
		return c;
	}
	
	/**
		Adds a XMPP packet collector to this stream and starts the timeout if not null.
	*/
	public function addCollector( c : PacketCollector ) : Bool {
		if( Lambda.has( collectors, c ) )
			return false;
		collectors.push( c );
		return true;
	}
	
	/**
	*/
	public function removeCollector( c : PacketCollector ) : Bool {
		if( !collectors.remove( c ) )
			if( !collectors_id.remove( c ) )
				return false;
		return true;
	}
	
	/**
	*/
	public function addInterceptor( i : PacketInterceptor ) : Bool {
		if( Lambda.has( interceptors, i ) )
			return false;
		interceptors.push( i );
		return true;
	}
	
	/**
	*/
	public function removeInterceptor( i : PacketInterceptor ) : Bool {
		return interceptors.remove( i );
	}
	
	/**
	*/
	public function handleData( bytes : Bytes ) : Bool {
		if( status == closed )
			return false;
		for( f in dataFilters ) {
			bytes = f.filterData( bytes );
		}
		return handleString( bytes.toString() );
	}
	
	/**
	*/
	public function handleString( t : String ) : Bool {
		
		if( status == closed ) {
			#if jabber_debug trace( "cannot process incoming data, xmpp stream not connected", "debug" ); #end
			throw "stream is closed";
		}

		if( StringTools.fastCodeAt( t, t.length-1 ) != 62 ) { // ">"
			buffer( t );
			return false;
		}
		/*
		if( bufSize == 0 && StringTools.fastCodeAt( t, 0 ) != 60 ) {
			trace("Invalid XMPP data recieved","error");
		}
		*/
		
		if( StringTools.startsWith( t, '</stream:stream' ) ) {
			#if xmpp_debug XMPPDebug.i( t ); #end
			close( cnx.connected );
			return true;
		} else if( StringTools.startsWith( t, '</stream:error' ) ) {
			// TODO report error info (?)
			#if xmpp_debug XMPPDebug.i( t ); #end
			close( cnx.connected );
			return true;
		}
		
		buffer( t );
		if( bufSize > maxBufSize ) {
			#if jabber_debug
			trace( 'max buffer size reached ($bufSize:$maxBufSize)', 'error' );
			trace( t );
			#end
			close( false );
		}
		
		switch( status ) {
		case closed :
			return false;
		case pending :
			if( processStreamInit( buf.toString() ) ) {
				resetBuffer();
				return true;
			} else {
				return false;
			}
		#if !jabber_component
		case starttls :
			var x : Xml = null;
			try x = Xml.parse( t ).firstElement() catch( e : Dynamic ) {
				#if xmpp_debug XMPPDebug.i( t ); #end
				#if jabber_debug trace( "startTLS failed", "warn" ); #end
				cnx.disconnect();
				return true;
			}
			#if xmpp_debug XMPPDebug.i( t ); #end
			if( x.nodeName != "proceed" || x.get( "xmlns" ) != "urn:ietf:params:xml:ns:xmpp-tls" ) {
				cnx.disconnect();
				return true;
			}
			var me = this;
			cnx.__onSecured = function(err:String) {
				if( err != null ) {
					me.handleStreamClose( 'tls failed [$err]' );
				}
				me.open( null );
			}
			cnx.setSecure();
			return true;
		#end //!jabber_component
		case open :
			var x : Xml = null;
			try x = Xml.parse( buf.toString() ) catch( e : Dynamic ) {
				//#if jabber_debug trace( "Packet incomplete, waiting for more data ..", "info" ); #end
				return false; // wait for more data
			}
			resetBuffer();
			handleXml( x );
			return true;
		}
		return true;
	}
	
	/**
		Inject incoming XML data.
		Returns array of handled XMPP packets.
	*/
	public function handleXml( x : Xml ) : Array<xmpp.Packet> {
		var ps = new Array<xmpp.Packet>();
		for( e in x.elements() ) {
			var p = xmpp.Packet.parse( e );
			if( p != null && handlePacket( p ) ) 
				ps.push( p );
		}
		return ps;
	}
	
	/**
		Handles incoming XMPP packets.
		Returns true if the packet got handled.
	*/
	public function handlePacket( p : xmpp.Packet ) : Bool {
		#if xmpp_debug
		XMPPDebug.i( p.toString() );
		#end
		var i = -1;
		while( ++i < collectors_id.length ) {
			var c = collectors_id[i];
			if( c.accept( p ) ) {
				collectors_id.splice( i, 1 );
				c.deliver( p );
				c = null;
				return true;
			}
		}
		var collected = false;
		i = -1;
		while( ++i < collectors.length ) {
			var c = collectors[i];
			//remove unused collectors
			/*
			if( c.handlers.length == 0 ) {
				collectors.splice( i, 1 );
				continue;
			}
			*/
			if( c.accept( p ) ) {
				collected = true;
				/*
				c.deliver( p );
				if( !c.permanent ) {
					collectors.splice( i, 1 );
					c = null;
				}
				*/
				if( !c.permanent ) {
					collectors.splice( i, 1 );
				}
				c.deliver( p );
				
				if( c.block )
					break;
			}
		}
		if( !collected ) {
			#if jabber_debug
			trace( 'incoming "${Type.enumConstructor(p._type)}" packet not handled ( ${p.from} -> ${p.to} )( ${p.id} )', 'warn' );
			//trace(p);
			#end
			if( p._type == xmpp.PacketType.iq ) { // 'feature not implemented' response
				#if as3
				var q : Dynamic = p;
				#else
				var q : xmpp.IQ = cast p;
				#end
				if( q.type != xmpp.IQType.error ) {
					var r = new xmpp.IQ( xmpp.IQType.error, p.id, p.from, p.to );
					r.errors.push( new xmpp.Error( xmpp.ErrorType.cancel, 'feature-not-implemented' ) );
					sendData( r.toString() );
				}
			}
		}
		return collected;
	}
	
	function buffer( t : String ) {
		buf.add( t );
		bufSize += t.length;
	}
	
	function resetBuffer() {
		buf = new StringBuf();
		bufSize = 0;
	}
	
	//TODO is this needed ? seamless connection changin
	/*
	public function replaceConnection( n : Connection ) {
		if( !n.connected )
			throw 'not connected';
		#if jabber_debug
		if( n.http )
			throw 'cannot replace with http connection';
		trace( 'replacing stream connection', 'debug' );
		#end
		n.__onConnect = handleConnect;
		n.__onDisconnect = handleDisconnect;
		n.__onString = handleString;
		n.__onData = handleData;
		cnx = n;
	}
	*/
	
	function processStreamInit( t : String ) : Bool {
		return #if jabber_debug throw 'abstract method' #else false #end;
	}
	
	function handleConnect() {
		trace( 'connected', 'info' );
		#if jabber_debug
		#end
	}

	function handleDisconnect( ?e : String ) {
		//if( status != closed )
		handleStreamClose( e );
	}
	
	function handleStreamOpen() {
		onOpen();
	}
	
	function handleStreamClose( ?e : String ) {
		resetBuffer();
		cleanup();
		onClose( e );
	}
	
	function cleanup() {
		
		status = closed;
		server = { features : new Map() };
		features = new StreamFeatures();
		
		collectors = new Array();
		collectors_id = new Array();
		interceptors = new Array();

		dataFilters = new Array();
		dataInterceptors = new Array();
		
		numPacketsSent = 0;
	}
	
}
