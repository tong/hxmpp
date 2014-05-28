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
import xmpp.Packet;
import xmpp.IQ;
import xmpp.Message;
import xmpp.Presence;
import jabber.util.Base64;

#if jabber_component
import jabber.component.Stream.ComponentJID in JID;
#end

using Lambda;

/**
	Describes the status of a xmpp stream.
*/
enum StreamStatus {
	
	/**
		XMPP stream is inactive.
	*/
	closed;
	
	/**
		Request to open xmpp stream sent but no response so far.
	*/
	//pending;
	connecting;
	//pending( ?info : String );
	
	#if !jabber_component
	/**
		SSL/TLS negotiation in progress.
	*/
	starttls;
	#end
	
	/**
		XMPP stream is open and ready to exchange data.
	*/
	open;
	//open( ?info : String );
}

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
	public var serverFeatures(default,null) :  StringMap<Xml>;
	
	/** Stream id */
	public var id(default,null) : String;
	
	/** */
	public var lang(default,null) : String;
	
	/** Jabber-id of this entity */
	public var jid(default,set) : JID;

	//public var dataFilters(default,null) : Array<StreamDataFilter>;
	//public var dataInterceptors(default,null) : Array<StreamDataInterceptor>;

	/** Incoming data buffer size */
	public var bufSize(default,null) : Int;

	/** Max incoming data buffer size */
	public var maxBufSize : Int;

	var idCollectors : StringMap<Packet->Void>; //? StringMap<PacketIdCollector>;
	var collectors : Array<PacketCollector>;
	var interceptors : Array<PacketInterceptor>;
	var buffer : StringBuf;

	#if jabber_debug
	var numPacketsSent = 0;
	#end

	function new( cnx : StreamConnection, ?maxBufSize : Int ) {
		
		this.maxBufSize = (maxBufSize == null || maxBufSize < 1) ? defaultMaxBufSize : maxBufSize;
		
		status = closed;
		features = new StreamFeatures();
		serverFeatures = new StringMap();
		collectors = new Array();
		idCollectors = new StringMap();
		interceptors = new Array();
		//dataFilters = new Array();
		//dataInterceptors = new Array();
		buffer = new StringBuf();
		//reset();

		if( cnx != null ) set_cnx( cnx );
	}
	
	function set_jid( j : JID ) : JID {
		if( status != StreamStatus.closed )
			throw "cannot change jid";
		return jid = j;
	}
	
	function set_cnx( c : StreamConnection ) : StreamConnection {
		if( status != closed ) {
			return throw 'stream active';
		}
		cnx = c;
		cnx.onConnect = handleConnect;
		cnx.onDisconnect = handleDisconnect;
		cnx.onData = handleData;
		return c;
		/*
		switch status {
		case open, connecting #if !jabber_component, starttls #end :
			close( true );
			set_cnx( c );
			 // Re-open XMPP stream
			#if jabber_component
			// ?????
			#else
			open( null );
			#end
		case closed :
			if( cnx != null && cnx.connected )
				cnx.disconnect();
			buffer = new StringBuf();
			cnx = c;
			cnx.onConnect = handleConnect;
			cnx.onDisconnect = handleDisconnect;
			cnx.onString = handleString;
			cnx.onData = handleData;
		}
		return cnx;
		*/
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
			throw 'no stream connection';
		cnx.connected ? handleConnect() : cnx.connect();
	}
	#end
	
	/**
		Closes the stream; Set disconnect=true to close the used connection as well
	*/
	public function close( ?disconnect = false ) {
		if( status == closed ) {
			#if jabber_debug
			trace( "cannot close stream (closed)" ); #end
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
	/*
	public function sendData( data : Bytes ) : Bytes {
		//TODO
		//trace("sendBytes / "+dataInterceptors.length );
		/*
		for( i in dataInterceptors )
			bytes = i.interceptData( bytes );
		* /
		if( !cnx.connected )
			return null;
		if( !cnx.writeData( data ) )
			return null;
		#if jabber_debug numPacketsSent++; #end
		#if xmpp_debug XMPPDebug.o( data ); #end
		return data;
	}
	*/

	/**
		Send string
	*/
	//public function send( s : String ) : String {
	public function send( s : String ) : Bool {
		
		#if flash // TODO haXe 2.06 fukup		
		s = StringTools.replace( s, "_xmlns_=", "xmlns=" );
		#end

		if( cnx.write(s) ) {
			#if jabber_debug numPacketsSent++; #end
			#if xmpp_debug XMPPDebug.o( s ); #end
			return true;
		} else {
			return false;
		}

		/*
		if( dataInterceptors.length > 0 ) {
			if( sendBytes( Bytes.ofString( s+"\n" ) ) == null )
				return null;
		} else {
			if( !cnx.write( s ) )
				return null;
		}
		*/
		//var sent = sendData( Bytes.ofString(s) );
		//return cnx.write(s);
		//var sent = cnx.write(s);
		//if( sent == null )
		//	return null;
		//return sent;
	}

	/**
		Intercept/Send/Return packet
	*/
	public function sendPacket<T:Packet>( p : T ) : T {
		if( !cnx.connected )
			return null;
		var s = p.toString();

		//if( !cnx.write( s ) )
		if( !send( s ) )
			return null;
		return p;
	}

	/**
		Send a presence packet.
	*/
	public function sendPresence( ?show : PresenceShow, ?status : String, ?priority : Int, ?type : PresenceType ) : Presence {
		return sendPacket( new Presence( show, status, priority, type ) );
	}

	/**
		Send a message packet (default type is 'chat')
	*/
	public function sendMessage( to : String, body : String,
								 ?subject : String, ?type : Null<MessageType>, ?thread : String, ?from : String ) : Message {
		return sendPacket( new Message( to, body, subject, type, thread, from ) );
	}

	/**
		Send a iq requestt and pass the response to the given handler.
	*/
	public function sendIQ( iq : IQ, ?h : IQ->Void ) : IQ {
		if( iq.id == null )
			iq.id = nextId();
		if( h != null )
			idCollectors.set( iq.id, cast h );
		var sent : IQ = sendPacket( iq );
		return sent;
		/*
		if( iq.id == null )
			iq.id = nextId();
		var c : PacketCollector = null;
		if( h != null )
			c = addIdCollector( iq.id, cast h );
		var s : IQ = sendPacket( iq );
		if( s == null && h != null ) { // TODO wtf, is this needed ?
			collectors.remove( c );
			c = null;
			return null;
		}
		return iq;
		*/
	}
	
	/**
		Creates, adds and returns a packet collector.
	*/
	public function collectPacket( filters : Iterable<xmpp.PacketFilter>, h : Dynamic->Void,
								   permanent : Bool = false ) : PacketCollector {
		var c = new PacketCollector( filters, h, permanent );
		return addCollector(c) ? c : null;
	}
	
	/**
		Add a packet collector.
	*/
	public function addCollector( c : PacketCollector ) : Bool {
		if( collectors.has( c ) )
			return false;
		collectors.push( c );
		return true;
	}
	
	/**
	*/
	public function removeCollector( c : PacketCollector ) : Bool {
		return collectors.remove(c);
	}

	/**
	*/
	public function removeIdCollector( id : String ) : Bool {
		return idCollectors.remove( id );
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
		Process incoming xmpp packets.
		Returns true if collected/handled by stream.
	*/
	public function handlePacket( p : xmpp.Packet ) : Bool {
		
		#if xmpp_debug
		XMPPDebug.i( p.toString() );
		#end
		/*
		var i = -1;
		while( ++i < idcollectors.length ) {
			var c = idcollectors[i];
			if( c.accept( p ) ) {
				idcollectors.splice( i, 1 );
				c.deliver( p );
				c = null;
				return true;
			}
		}
		*/

		if( p.id != null && idCollectors.exists( p.id ) ) {
			var h = idCollectors.get( p.id );
			idCollectors.remove( p.id );
			h(p);
			return true;
		}

		var collected = false;
		var i = -1;
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
					r.errors.push( new xmpp.Error( cancel, 'feature-not-implemented' ) );
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
		Process incomig data.
		Returns false if unable to process (more data needed).
	*/
	public function handleData( s : String ) : Bool {
		
		if( status == closed )
			throw "stream not ready";

		if( StringTools.fastCodeAt( s, s.length-1 ) != 62 ) { // ">"
			//trace("BUFFER "+s );
			buffer.add( s );
			return false;
		}
		if( StringTools.startsWith( s, '</stream:stream' ) ) {
			#if xmpp_debug XMPPDebug.i( s ); #end
			close( cnx.connected );
			return true;
		}
		if( StringTools.startsWith( s, '</stream:error' ) ) {
			// TODO report error info (?)
			#if xmpp_debug XMPPDebug.i( s ); #end
			close( cnx.connected );
			return true;
		}

		buffer.add(s);

		//TODO
		/*
		if( buffer.length > maxBufSize ) {
			#if jabber_debug
			trace( 'max buffer size ($maxBufSize)' );
			#end
			close( false );
			return false;
		}
		*/

		switch status {
		
		case closed :
			return false;

		case connecting:
			if( processStreamInit( buffer.toString() ) ) {
				buffer = new StringBuf();
				return true;
			}
			return false;

#if !jabber_component	
		case starttls :
			var x : Xml = null;
			try x = Xml.parse(s).firstElement() catch( e : Dynamic ) {
				#if xmpp_debug XMPPDebug.i( s ); #end
				onClose(e);
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
#end
		case open:
			var x : Xml = null;
			try x = Xml.parse( buffer.toString() ) catch( e : Dynamic ) {
				#if jabber_debug trace( "Packet incomplete, waiting for more data .." ); #end
				return false;
			}
			buffer = new StringBuf();
			handleXml( x );
			return true;

		}

		return true;

		/*
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
		* /
		
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
		*/
	}

	/**
	public function handleData( data : Bytes ) : Bool {
		/*
		if( status == closed )
			return false;
		for( f in dataFilters ) {
			bytes = f.filterData( bytes );
		}
		* /
		return handleString( data.toString() );
	}
	*/

	/**
		Create/Returns unique ids
	*/
	public function nextId() : String {
		return Base64.random( defaultPacketIdLength ) #if jabber_debug + '_$numPacketsSent' #end;
	}

	function handleConnect() {
	}

	function handleDisconnect( ?e : String ) {
		//if( status != closed )
		handleStreamClose( e );
	}

	function processStreamInit( s : String ) : Bool {
		return #if jabber_debug throw 'abstract method' #else false #end;
	}
	
	function handleStreamOpen() {
		onOpen();
	}
	
	function handleStreamClose( ?e : String ) {
		reset();
		status = closed;
		onClose( e );
	}
	
	function reset() {
		//status = closed;
		features = new StreamFeatures();
		serverFeatures = new StringMap();
		collectors = new Array();
		idCollectors = new haxe.ds.StringMap();
		interceptors = new Array();
		//dataFilters = new Array();
		//dataInterceptors = new Array();
		buffer = new StringBuf();
		#if jabber_debug numPacketsSent = 0; #end
	}
}

private class StreamFeatures {

	var l : Array<String>;
	
	public inline function new() {
		l = new Array<String>();
	}
	
	public inline function iterator() : Iterator<String> {
		return l.iterator();
	}
	
	public inline function add( f : String ) : Bool {
		if( Lambda.has( l, f ) )
			return false;
		l.push(f);
		return true;
	}
	
	public inline function has( f : String ) : Bool {
		return Lambda.has( l, f );
	}
	
	public inline function remove( f : String ) : Bool {
		return l.remove( f );
	}
	
	public inline function clear( f : String ) {
		l = new Array<String>();
	}
	
	#if jabber_debug
	public inline function toString() : String { return l.toString(); }
	#end

}
