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
package xmpp;

/**
	Abstract base for XMPP packets.
*/
class Packet {
	
	//public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";
	public static var PROTOCOL = "http://jabber.org/protocol";
	
	public var _type(default,null) : PacketType;
	public var to : String;
	public var from : String;
	public var id : String;	
	public var lang : String;
	public var properties : Array<Xml>; // <PacketElement> hmm? 
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
		return throw "Abstract method";
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
		for( e in errors ) x.addChild( e.toXml() );
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
		p.lang = x.get( "xml:lang" );
		return p;
	}
	
	// TODO remove
	/**
		Reflects the elements of the XML into the packet.
	*/
	public static function reflectPacketNodes<T>( x : Xml, p : T ) : T {
		for( e in x.elements() ) {
			var v : String = null;
			try {
				v = e.firstChild().nodeValue;
			} catch( e : Dynamic ) {
				continue;
			};
			if( v != null ) {
				try {
					Reflect.setField( p, e.nodeName, v );
				} catch( e : Dynamic ) {
					#if JABBER_DEBUG
					trace( "Unrecognized packet node "+e.nodeName );
					#end
				}
			}
		}
		return p;
	}
	
	/*TODO replace util.XMLUtil
	public static function createXmlElement( n : String, ?d : String ) : Xml {
		var x = Xml.createElement( n );
		if( d != null ) x.addChild( Xml.createPCData( d ) );
		return x;
	}
	*/
	
	/*
	public static function createPacketElementXml<T>( o : T, name : String ) : Xml {
		trace( Reflect.field( o, name ) );
		var v = Reflect.field( o, name );
		if( v == null ) return null;
		return XMLUtil.createElement( name, v );
	}
*/
	/*
	public static function reflectPacketAttributes<T>( x : Xml, p : T ) : T {
		for( a in x.attributes ) {
		}
	}
	public static function reflectPacketAttribute<T>( x : Xml, p : T, id : String ) : T {
		for( a in x.attributes ) {
		}
	}
	*/
	/*
	static inline function parsePacketBase( p : xmpp.Packet, x : Xml ) {
		xmpp.Packet.parseAttributes( p, x );
		xmpp.Packet.parseChilds( p, x );
	}
	*/
}
