/*
 * Copyright (c) 2012, disktree.net
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
package xmpp;

/**
	Abstract base for XMPP packets.
*/
class Packet {
	
	public static var PROTOCOL(default,null) : String = "http://jabber.org/protocol";
	
	/** The top level type of the XMPP packet */
	public var _type(default,null) : PacketType;
	public var to : String;
	public var from : String;
	public var id : String;	
	public var lang : String;
	public var properties : Array<Xml>;
	public var errors : Array<xmpp.Error>;
	
	function new( ?to : String, ?from : String, ?id : String, ?lang : String ) {
		this.to = to;
		this.from = from;
		this.id = id ;
		this.lang = lang;
		errors = new Array();
		properties = new Array();
	}

	/**
		Creates/Returns the XML representation of this XMPP packet.
	*/
	public function toXml() : Xml {
		return null; //#if jabber_debug throw 'abstract method' #else null #end;
	}
	
	/**
		Creates/Returns the string representation of this XMPP packet.
	*/
	public function toString() : String {
		return toXml().toString();
	}

	/**
		Adds the basic packet attributes to the given XML.
	*/
	function addAttributes( x : Xml ) : Xml {
		if( to != null ) x.set( "to", to );
		if( from != null ) x.set( "from", from );
		if( id != null ) x.set( "id", id );
		if( lang != null ) x.set( "xml:lang", lang );
		for( p in properties ) x.addChild( p );
		for( e in errors ) {
			if( e == null ) continue; //HACK
			x.addChild( e.toXml() );
		}
        return x;
	}
	
	/**
		Parses given XML into a XMPP packet object.
	*/
	public static function parse( x : Xml ) : xmpp.Packet {
		switch( x.nodeName ) {
		case "iq" 		: return cast IQ.parse( x );
		case "message"  : return cast Message.parse( x );
		case "presence" : return cast Presence.parse( x );
		default : return cast new PlainPacket( x );
		}
	}
	
	/**
		Parses/adds basic attributes to the XMPP packet.
	*/
	static function parseAttributes( p : xmpp.Packet, x : Xml ) : xmpp.Packet {
		p.to = x.get( "to" );
		p.from = x.get( "from" );
		p.id = x.get( "id" );
//		p.lang = x.get( "xml:lang" );
		return p;
	}
	
	/*
	static function parsePacketBase( p : xmpp.Packet, x : Xml ) {
		xmpp.Packet.parseAttributes( p, x );
		xmpp.Packet.parseChilds( p, x );
	}
	*/
}
