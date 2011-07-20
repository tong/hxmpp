/*
 *	This file is part of HXMPP.
 *	Copyright (c)2010 http://www.disktree.net
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

import haxe.io.Bytes;
import jabber.stream.Connection;
import jabber.stream.TPacketInterceptor;
import jabber.stream.PacketCollector;
import jabber.stream.TDataInterceptor;
import jabber.stream.TDataFilter;
import jabber.stream.Status;
import jabber.util.Base64;
import xmpp.filter.PacketIDFilter;
#if JABBER_COMPONENT
import jabber.component.Stream;
private typedef JID = ComponentJID;
#end

private typedef Server = {
	var features : Hash<Xml>;
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
	#if JABBER_DEBUG
	public inline function toString() : String { return l.toString(); }
	#end
}

/**
	Abstract base for XMPP streams to and from another entity.
*/
class Stream {
	
	public static var defaultPacketIdLength = 5;
	
	public dynamic function onOpen() {}
	public dynamic function onClose( ?error : String ) {}
	
	public var jid(default,setJID) : JID;
	public var status : Status;
	public var cnx(default,setConnection) : Connection;
	public var features(default,null) : StreamFeatures;
	public var server(default,null) : Server;
	public var id(default,null) : String;
	public var lang(default,null) : String;
	public var dataFilters(default,null) : Array<TDataFilter>;
	public var dataInterceptors(default,null) : Array<TDataInterceptor>;
	
	var collectors_id : Array<PacketCollector>;
	var collectors : Array<PacketCollector>;
	var interceptors : Array<TPacketInterceptor>;
	var numPacketsSent : Int;
	
	function new( cnx : Connection ) {
		status = Status.closed;
		server = { features : new Hash() };
		features = new StreamFeatures();
		collectors_id = new Array();
		collectors = new Array();
		interceptors = new Array();
		numPacketsSent = 0;
		dataFilters = new Array();
		dataInterceptors = new Array();
		if( cnx != null ) setConnection( cnx );
	}
	
	function setJID( j : JID ) : JID {
		if( status != Status.closed )
			throw "cannot change jid on active stream";
		return jid = j;
	}
	
	function setConnection( c : Connection ) : Connection {
		switch( status ) {
		case Status.open, Status.pending #if !JABBER_COMPONENT, Status.starttls #end :
			close( true );
			setConnection( c );
			 // re-open XMPP stream
			#if JABBER_COMPONENT
			//trace("TODO");
			#else
			open( jid );
			#end
		case Status.closed :
			if( cnx != null && cnx.connected )
				cnx.disconnect();
			cnx = c;
			cnx.__onConnect = handleConnect;
			cnx.__onDisconnect = handleDisconnect;
			cnx.__onString = handleString;
			cnx.__onData = handleData;
		}
		return cnx;
	}
	
	/**
		Get the next unique id for a XMPP packet.
	*/
	public function nextID() : String {
		return Base64.random( defaultPacketIdLength )#if JABBER_DEBUG+"_"+numPacketsSent#end;
	}
	
	/**
		Open the XMPP stream.
	*/
	#if JABBER_COMPONENT
	public function open( host : String, subdomain : String, secret : String, ?identities : Array<xmpp.disco.Identity> ) {
		#if JABBER_DEBUG throw 'abstract method'; #end
	}
	#else
	public function open( jid : JID ) {
		if( jid != null ) this.jid = jid
		else if( this.jid == null ) this.jid = new JID( null );
		if( cnx == null )
			throw 'no stream connection set';
		cnx.connected ? handleConnect() : cnx.connect();
	}
	#end
	
	/**
		Close the XMPP stream.<br/>
		Passed argument indicates if the connection to the server should also get closed.
	*/
	public function close( ?disconnect = false ) {
		if( status == Status.closed )
			return;
		if( !cnx.http ) sendData( "</stream:stream>" );
		status = Status.closed;
		if( disconnect || cnx.http ) cnx.disconnect();
		handleDisconnect(null);
	}
	
	/**
		Intercept/Send/Return XMPP packet.
	*/
	public function sendPacket<T>( p : T, intercept : Bool = true ) : T {
		if( !cnx.connected )
			return null;
		if( intercept ) interceptPacket( untyped p );
		//TODO return the given packet?
		return ( sendData( untyped p.toString() ) != null ) ? p : null;
	}
	
	/**
		Send raw string.
	*/
	//TODO public function sendString( t : String ) : String {
	public function sendData( t : String ) : String {
		if( !cnx.connected )
			return null;
		#if flash // TODO haXe 2.06 fukup		
		t = StringTools.replace( t, "_xmlns_=", "xmlns=" );
		#end
		if( dataInterceptors.length > 0 ) {
			if( sendRawData( haxe.io.Bytes.ofString(t) ) == null )
				return null;
		} else {
			if( !cnx.write( t ) )
				return null;
		}
		numPacketsSent++;
		#if XMPP_DEBUG XMPPDebug.out( t ); #end
		return t;
	}
	
	//TODO public function sendData( bytes : Bytes ) : Bytes {
	public function sendRawData( bytes : Bytes ) : Bytes {
		//trace("RAW "+bytes.length);
		for( i in dataInterceptors )
			bytes = i.interceptData( bytes );
		//trace("RAW "+bytes.length);
		if( !cnx.writeBytes( bytes ) )
			return null;
		return bytes;
	}
	
	/**
		Send an IQ packet and forwards the response to the given handler function.
	*/
	public function sendIQ( iq : xmpp.IQ, ?handler : xmpp.IQ->Void ) : xmpp.IQ {
		if( iq.id == null ) iq.id = nextID();
		var c : PacketCollector = null;
		if( handler != null ) c = addIDCollector( iq.id, handler );
		var s : xmpp.IQ = sendPacket( iq );
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
	
	/*
	public function sendPresenceTo( jid : String ) : xmpp.Presence {
		var p = new xmpp.Presence();
		p.to = jid;
		var s : xmpp.Presence = sendPacket(p);
		return s;
	}
	*/
	
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
		var c = new PacketCollector( [cast new PacketIDFilter(id)], handler );
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
	public function addInterceptor( i : TPacketInterceptor ) : Bool {
		if( Lambda.has( interceptors, i ) )
			return false;
		interceptors.push( i );
		return true;
	}
	
	/**
	*/
	public function removeInterceptor( i : TPacketInterceptor ) : Bool {
		return interceptors.remove( i );
	}
	
	/**
	*/
	public function handleData( buf : haxe.io.Bytes, bufpos : Int, buflen : Int ) : Int {
		if( status == Status.closed )
			return -1;
		//TODO .. data filters
//		for( f in dataFilters ) {
//			buf = f.filterData( buf );
//		}
		return handleString( buf.readString( bufpos, buflen ) );
	}
	
	/**
	*/
	public function handleString( t : String ) : Int {
		
		if( status == Status.closed )
			return -1;

		if( StringTools.startsWith( t, '</stream:stream' ) ) {
			#if XMPP_DEBUG XMPPDebug.inc( t ); #end
			close( cnx.connected );
			return 0;
		} else if( StringTools.startsWith( t, '</stream:error' ) ) {
			#if XMPP_DEBUG XMPPDebug.inc( t ); #end
			close( cnx.connected );
			return 0;
		}
		
		switch( status ) {
		
		case Status.closed :
			// TODO cleanup
			return -1;//buflen?
		
		case Status.pending :
			return processStreamInit( t, t.length );
		
		#if !JABBER_COMPONENT
		case Status.starttls :
			var x : Xml = null;
			try x = Xml.parse( t ).firstElement() catch( e : Dynamic ) {
				#if XMPP_DEBUG XMPPDebug.inc( t ); #end
				#if JABBER_DEBUG trace( "StartTLS failed" ); #end
				cnx.disconnect();
				return 0;
			}
			#if XMPP_DEBUG XMPPDebug.inc( t ); #end
			if( x.nodeName != "proceed" || x.get( "xmlns" ) != "urn:ietf:params:xml:ns:xmpp-tls" ) {
				cnx.disconnect();
				return 0;
			}
			var me = this;
			cnx.__onSecured = function(err:String) {
				if( err != null ) {
					me.handleStreamClose( "TLS failed ["+err+"]" );
				}
				me.open( null );
			}
			cnx.setSecure();
			return t.length;
		#end //!JABBER_COMPONENT
			
		case Status.open :
			var x : Xml = null;
			try x = Xml.parse( t ) catch( e : Dynamic ) {
				//#if JABBER_DEBUG trace( "Packet incomplete, waiting for more data ..", "info" ); #end
				return 0; // wait for more data
			}
			handleXml( x );
			return t.length;
		}
		return 0;
	}
	
	/**
		Inject incoming XML data.<br/>
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
		Handles incoming XMPP packets.<br/>
		Returns true if the packet got handled.
	*/
	public function handlePacket( p : xmpp.Packet ) : Bool {
		#if XMPP_DEBUG XMPPDebug.inc( p.toString() ); #end
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
			//TODO remove unused collectors
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
			#if JABBER_DEBUG
			trace( "Incoming '"+Type.enumConstructor( p._type )+"' packet not handled ( "+p.from+" -> "+p.to+" )( "+p.id+" )", "warn" );
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
	
	//TODO is this needed ?
	/*
	public function replaceConnection( n : Connection ) {
		if( !n.connected )
			throw 'not connected';
		#if JABBER_DEBUG
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
	
	function processStreamInit( t : String, buflen : Int ) : Int {
		return #if JABBER_DEBUG throw 'abstract method' #else -1 #end;
	}
	
	function handleConnect() {
		//#if JABBER_DEBUG trace( 'connected', 'info' ); #end
	}

	function handleDisconnect( e : String ) {
		handleStreamClose( e );
	}
	
	function handleStreamOpen() {
		onOpen();
	}
	
	function handleStreamClose( ?e : String ) {
		onClose( e );
	}
	
	/*
	function cleanup() {
		id = null;
		numPacketsSent = 0;
		collectors = new List();
		interceptors = new List();
		sever = { features : new Hash() };
		features = new StreamFeatures();
	}
	*/
	
}
