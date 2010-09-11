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
package xmpp.file;

class IB {
	
	public static var XMLNS = xmpp.Packet.PROTOCOL+"/ibb";
	
	public var type : IBType;
	public var sid : String;
	public var blockSize : Null<Int>;
	public var seq : Int;
	public var data : String;
	
	public function new( type : IBType, sid : String, ?blockSize : Null<Int> ) {
		this.type = type;
		this.sid = sid;
		this.blockSize = blockSize;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( Type.enumConstructor( type ) );
		x.set( "xmlns", XMLNS );
		x.set( "sid", sid );
		switch( type ) {
		case open : x.set( "block-size", Std.string( blockSize ) );
		case data : x.set( "seq", Std.string( seq ) );
		default : //
		}
		return x;
	}
	
	public static function parse( x : Xml ) : IB {
		var _type = Type.createEnum( IBType, x.nodeName );
		var ib = new IB( _type, x.get( "sid" ), Std.parseInt( x.get( "block-size" ) ) );
		if( _type == IBType.data ) {
			ib.data = x.firstChild().nodeValue;
			ib.sid = x.get( "sid" );
			ib.seq = Std.parseInt( x.get( "seq" ) );
			/*
			for( e in x.elements() ) {
				trace(">>>>>");
				if( e.nodeName == "data" ) {
					ib.data = e.firstChild().nodeValue;
					break;
				}
			}
			*/
		}
		return ib;
	}
	
	public static function parseData( p : xmpp.Packet ) : { sid : String , seq : Int, data : String } {
		for( x in p.properties ) {
			if( x.nodeName == "data" ) {
				return { sid : x.get( "sid" ),
						 seq : Std.parseInt( x.get( "seq" ) ),
						 data : x.firstChild().nodeValue
					   };
			}
		}
		return null;
	}
	
	public static function createDataElement( sid : String, seq : Int, d : String ) : Xml {
		var x = xmpp.XMLUtil.createElement( "data", d );
		x.set( "xmlns", XMLNS );
		x.set( "sid", sid );
		x.set( "seq", Std.string( seq ) );
		return x;
	}
	
}
