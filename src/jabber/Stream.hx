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

import haxe.ds.StringMap;
import haxe.io.Bytes;
import jabber.util.Base64;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.Message;
import xmpp.MessageType;
import xmpp.Packet;
import xmpp.PacketType;
import xmpp.Presence;
import xmpp.PresenceType;
import xmpp.PresenceShow;
import xmpp.filter.PacketIdFilter;

using Lambda;

#if jabber_component
import jabber.component.Stream.ComponentJID in JID;
#end

/**
	Base for xmpp/xml stream implementations.
	Container for the exchange of XML elements with another entity.

	http://xmpp.org/rfcs/rfc6120.html#streams
*/
class Stream {
	
	public static var defaultPacketIdLength = 5;
	public static var defaultMaxBufSize = 1048576; // 524288; //TODO move to connection
	
	/**
		Callback when the stream is ready to exchange data
	*/
	public dynamic function onOpen() {}
	
	/**
		Called when the stream closes, optionally reporting errors if occured 
	*/
	public dynamic function onClose( ?e : String ) {}
	
	/** Current status */
	public var status(default,null) : StreamStatus;
	
	/** The connection used to transport xmpp data */
	public var cnx(default,set) : StreamConnection;
	
	/** Client stream features */
	public var features(default,null) : StreamFeatures;
	
	/** Holds servers stream features */
	public var server(default,null) : Server;
	
	/** Stream id */
	public var id(default,null) : String;
	
	/** */
	public var lang(default,null) : String;
	
	/** Jabber-id of this entity */
	public var jid(default,set) : JID;

	/** */
	//public var dataFilters(default,null) : Array<StreamDataFilter>;

	/** */
	//public var dataInterceptors(default,null) : Array<StreamDataInterceptor>;

	/** Incoming data buffer size */
	public var bufSize(default,null) : Int;

	/** Max incoming data buffer size */
	public var maxBufSize : Int;
	
	var buf : StringBuf;
	var packetCollectorsId : haxe.ds.StringMap<PacketCollector>;
	var packetCollectors : Array<PacketCollector>;
	var packetInterceptors : Array<PacketInterceptor>;

	#if jabber_debug
	var numPacketsSent : Int;
	#end

	function new( cnx : StreamConnection, ?maxBufSize : Int ) {
		this.maxBufSize = (maxBufSize == null || maxBufSize < 1) ? defaultMaxBufSize : maxBufSize;
		reset();
		if( cnx != null ) set_cnx( cnx );
	}
	
	function set_jid( j : JID ) : JID {
		if( status != StreamStatus.closed )
			throw "cannot change jid on open xmpp stream";
		return jid = j;
	}
	
	function set_cnx( c : StreamConnection ) : StreamConnection {
		switch( status ) {
		case open, pending #if !jabber_component, starttls #end :
			// TODO no! cannot share connection with other streams!
			close( true );
			set_cnx( c );
			 // re-open XMPP stream
			#if jabber_component
			// ?????
			#else
			open( null );
			#end
		case closed :
			if( cnx != null && cnx.connected )
				cnx.disconnect();
			resetBuffer();
			cnx = c;
			cnx.onConnect = handleConnect;
			cnx.onDisconnect = handleDisconnect;
			cnx.onString = handleString;
			cnx.onData = handleData;
		}
		return cnx;
	}
	
	/**
		Open the xml stream.
	*/
	#if jabber_component
	public function open( host : String, subdomain : String, secret : String,
						  ?identities : Array<xmpp.disco.Identity> ) {
		#if jabber_debug throw 'abstract method "open", use "connect" for components'; #end
	}
	#else
	public function open( jid : String ) {
		if( jid != null )
			this.jid = new JID( jid );
		else if( this.jid == null )
			this.jid = new JID( null );
		if( cnx == null )
			throw 'no stream connection set';
		//status = Status.pending;
		cnx.connected ? handleConnect() : cnx.connect();
	}
	#end
	
	/**
		Closes the stream; Set disconnect=true to close the used connection as well
	*/
	public function close( ?disconnect = false ) {
		if( status == closed ) {
			#if jabber_debug
			trace( "cannot close stream (status=closed)" ); #end
			return;
		}
		if( !cnx.http )
			send( "</stream:stream>" );
		if( disconnect || cnx.http )
			cnx.disconnect();
		handleDisconnect( null );
	}

	/**
		Send raw bytes
	*/
	public function sendData( data : Bytes ) : Bytes {
		//TODO
		//trace("sendBytes / "+dataInterceptors.length );
		/*
		for( i in dataInterceptors )
			bytes = i.interceptData( bytes );
		*/
		if( !cnx.writeData( data ) )
			return null;
		#if jabber_debug numPacketsSent++; #end
		#if xmpp_debug XMPPDebug.o( data ); #end
		return data;
	}

	/**
		Send string
	*/
	public function send( s : String ) : String {
		if( !cnx.connected )
			return null;
		#if flash // TODO haXe 2.06 fukup		
		s = StringTools.replace( s, "_xmlns_=", "xmlns=" );
		#end
		/*
		if( dataInterceptors.length > 0 ) {
			if( sendBytes( Bytes.ofString( s+"\n" ) ) == null )
				return null;
		} else {
			if( !cnx.write( s ) )
				return null;
		}
		*/
		var sent = sendData( Bytes.ofString(s) );
		if( sent == null )
			return null;
		return s;
	}

	/**
		Intercept/Send/Return packet
	*/
	//public function sendPacket<T:Packet>( p : T, intercept : Bool = true ) : T {
	public function sendPacket<T:Packet>( p : T ) : T {
		if( !cnx.connected )
			return null;
		var s = p.toString();
		if( !cnx.write( s ) )
			return null;
		return p;
		/*
		if( intercept )
			interceptPacket( #if (java||cs) cast #end p ); //TODO still throws error on java
		//if( cnx.http ) {
			//return if( cnx.writeXml( p.toXml() ) != null ) p else null;
		return ( sendData( untyped p.toString() ) != null ) ? p : null;
		*/
	}

	/**
		Send a presence packet.
	*/
	public function sendPresence( ?show : PresenceShow, ?status : String, ?priority : Int, ?type : PresenceType ) : Presence {
		return cast sendPacket( new Presence( show, status, priority, type ) );
	}

	/**
		Send a message packet (default type is 'chat')
	*/
	public function sendMessage( to : String, body : String,
								 ?subject : String, ?type : Null<MessageType>,
								 ?thread : String, ?from : String ) : Message {
		return sendPacket( new Message( to, body, subject, type, thread, from ) );
	}

	/**
		Send a iq requestt and pass the response to the given handler.
	*/
	public function sendIQ( iq : IQ, ?h : IQ->Void ) : IQ {
		if( iq.id == null )
			iq.id = nextId();
		var c : PacketCollector = null;
		if( h != null )
			c = addIdCollector( iq.id, h );
		var s : IQ = sendPacket( iq );
		if( s == null && h != null ) { // TODO wtf, is this needed ?
			packetCollectors.remove( c );
			c = null;
			return null;
		}
		return iq;
	}

	/**
		Create and send the result for given request
	*/
	public inline function sendIQResult( iq : IQ ) {
		sendPacket( IQ.createResult( iq ) );
	}
	
	/**
		Creates, adds and returns a packet collector.
	*/
	public function collectPacket( filters : Iterable<xmpp.PacketFilter>, h : Dynamic->Void,
								   permanent : Bool = false ) : PacketCollector {
		var c = new PacketCollector( filters, h, permanent );
		//return addCollector(c) ? c : null;
		addCollector(c);
		return c;
	}

	/**
		Runs this stream XMPP packet interceptors on the given packet.
	*/
	/*
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		for( i in packetInterceptors ) i.interceptPacket( p );
		return p;
	}
	*/
	
	/**
		Adds an packet collector which filters XMPP packets by ids.
		These collectors get processed before any other.
	*/
	public function addIdCollector( id : String, h : Dynamic->Void ) : PacketCollector {
		var c = new PacketCollector( [new PacketIdFilter(id)], h );
		//collectors_id.push( c );
		packetCollectorsId.set( id, c );
		return c;
	}
	
	/**
		Add a packet collector.
	*/
	public function addCollector( c : PacketCollector ) : Bool {
		if( packetCollectors.has( c ) )
			return false;
		packetCollectors.push( c );
		return true;
	}
	
	/**
	*/
	public function removeCollector( c : PacketCollector ) : Bool {
		if( packetCollectors.remove( c ) )
			return true;
		//if( packetCollectorsId.remove( c ) ) return true;
		//if( Std.is( c, PcketIdCollector) )
		return false;
		/*
		if( !collectors.remove( c ) )
			if( !idPacketCollectors.remove( c ) )
				return false;
		return true;
		*/
	}

	/**
	*/
	public function removeIdCollector( id : String ) : Bool {
		/*
		for( c in packetCollectorsId ) {
			if( c.id == id ) {
				packetCollectorsId.remove( c );
				return true;
			}
		}
		return false;
		*/
		/*
		if( !packetCollectorsId.exists( id ) )
			return false;
		packetCollectorsId.remove( id );
		return true;
		*/
		if( !packetCollectorsId.remove( id ) )
			return false;
		return true;
	}
	
	/**
	*/
	public function addInterceptor( i : PacketInterceptor ) : Bool {
		if( Lambda.has( packetInterceptors, i ) )
			return false;
		packetInterceptors.push( i );
		return true;
	}
	
	/**
	*/
	public function removeInterceptor( i : PacketInterceptor ) : Bool {
		return packetInterceptors.remove( i );
	}
	
	/**
		Process incoming xmpp packets.
		Returns true if the packet got handled.
	*/
	public function handlePacket( p : xmpp.Packet ) : Bool {
		#if xmpp_debug XMPPDebug.i( p.toString() ); #end
		/*
		var i = -1;
		while( ++i < idPacketCollectors.length ) {
			var c = idPacketCollectors[i];
			if( c.accept( p ) ) {
				idPacketCollectors.splice( i, 1 );
				c.deliver( p );
				c = null;
				return true;
			}
		}
		*/
		if( p.id != null && packetCollectorsId.exists( p.id ) ) {
			var c = packetCollectorsId.get( p.id );
			packetCollectorsId.remove( p.id );
			c.deliver( p );
			c = null;
			return true;
		}

		var collected = false;
		var i = -1;
		while( ++i < packetCollectors.length ) {
			var c = packetCollectors[i];
			//remove unused collectors
			/*
			if( c.handlers.length == 0 ) {
				packetCollectors.splice( i, 1 );
				continue;
			}
			*/
			if( c.accept( p ) ) {
				collected = true;
				/*
				c.deliver( p );
				if( !c.permanent ) {
					packetCollectors.splice( i, 1 );
					c = null;
				}
				*/
				if( !c.permanent ) {
					packetCollectors.splice( i, 1 );
				}
				c.deliver( p );
				if( c.block )
					break;
			}
		}
		if( !collected ) {
			#if jabber_debug
			trace( 'xmpp stanza not handled ( ${p.from} -> ${p.to} )( ${p.id} )' );
			#end
			if( p._type == PacketType.iq ) { // 'feature not implemented' response
				#if as3
				var q : Dynamic = p;
				#else
				var q : IQ = cast p;
				#end
				if( q.type != IQType.error ) {
					var r = new IQ(IQType.error, p.id, p.from, p.to );
					r.errors.push( new xmpp.Error( xmpp.ErrorType.cancel, 'feature-not-implemented' ) );
					send( r.toString() );
				}
			}
		}
		return collected;
	}

	/**
		Process incoming xml data.
		Returns array of handled packets.
	*/
	public function handleXml( x : Xml ) : Array<xmpp.Packet> {
		var a = new Array<xmpp.Packet>();
		for( e in x.elements() ) {
			var p = xmpp.Packet.parse( e );
			if( p != null && handlePacket( p ) ) 
				a.push( p );
		}
		return a;
	}
	
	/**
		Process incomig stream data.
		Returns false if unable to process (more data needed).
	*/
	public function handleString( s : String ) : Bool {
		
		if( status == closed )
			throw "stream closed";

		if( StringTools.fastCodeAt( s, s.length-1 ) != 62 ) { // ">"
			buffer( s );
			return false;
		}

		/*
		if( bufSize == 0 && StringTools.fastCodeAt( t, 0 ) != 60 ) {
			trace("Invalid XMPP data recieved","error");
		}
		*/
		
		if( StringTools.startsWith( s, '</stream:stream' ) ) {
			#if xmpp_debug XMPPDebug.i( s ); #end
			close( cnx.connected );
			return true;
		} else if( StringTools.startsWith( s, '</stream:error' ) ) {
			// TODO report error info (?)
			#if xmpp_debug XMPPDebug.i( s ); #end
			close( cnx.connected );
			return true;
		}
		
		buffer( s );
		if( bufSize > maxBufSize ) {
			#if jabber_debug
			trace( 'max buffer size ($maxBufSize)' );
			#end
			close( false );
		}
		
		switch status {
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
			try x = Xml.parse( s ).firstElement() catch( e : Dynamic ) {
				#if xmpp_debug XMPPDebug.i( s ); #end
				#if jabber_debug trace( "start-tls failed" ); #end
				cnx.disconnect();
				return true;
			}
			#if xmpp_debug XMPPDebug.i( s ); #end
			if( x.nodeName != "proceed" || x.get( "xmlns" ) != "urn:ietf:params:xml:ns:xmpp-tls" ) {
				cnx.disconnect();
				return true;
			}
			cnx.onSecured = function(err:String) {
				if( err != null ) {
					handleStreamClose( 'tls failed : $err' );
				}
				open( null );
			}
			cnx.setSecure();
			return true;
		#end //!jabber_component
		case open :
			var x : Xml = null;
			try x = Xml.parse( buf.toString() ) catch( e : Dynamic ) {
				#if jabber_debug trace( "Packet incomplete, waiting for more data .." ); #end
				return false;
			}
			resetBuffer();
			handleXml( x );
			return true;
		}
		return true;
	}

	/**
	*/
	public function handleData( data : Bytes ) : Bool {
		/*
		if( status == closed )
			return false;
		for( f in dataFilters ) {
			bytes = f.filterData( bytes );
		}
		*/
		return handleString( data.toString() );
	}

	/**
		Create/Returns unique ids
	*/
	public function nextId() : String {
		return Base64.random( defaultPacketIdLength ) #if jabber_debug + '_$numPacketsSent' #end;
	}

	function handleConnect() {
		#if jabber_debug trace( 'connected' ); #end
	}

	function handleDisconnect( ?e : String ) {
		//if( status != closed )
		handleStreamClose( e );
	}
	
	function buffer( s : String ) {
		buf.add( s );
		bufSize += s.length;
	}
	
	function processStreamInit( s : String ) : Bool {
		return #if jabber_debug throw 'abstract method' #else false #end;
	}
	
	function handleStreamOpen() {
		onOpen();
	}
	
	function handleStreamClose( ?e : String ) {
		resetBuffer();
		reset();
		onClose( e );
	}
	
	function resetBuffer() {
		buf = new StringBuf();
		bufSize = 0;
	}
	
	function reset() {
		status = closed;
		server = { features : new Map() };
		features = new StreamFeatures();
		packetCollectors = new Array();
		packetCollectorsId = new haxe.ds.StringMap();
		packetInterceptors = new Array();
		//dataFilters = new Array();
		//dataInterceptors = new Array();
		#if jabber_debug numPacketsSent = 0; #end
	}
}

private typedef Server = {
	var features : StringMap<Xml>;
}

private class StreamFeatures {

	var l : #if neko List<String> #else Array<String> #end;
	
	public inline function new() {
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
