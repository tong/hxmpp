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
		xmpp.XMLUtil.setNamespace( x, XMLNS );
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
		if( Type.enumEq( _type, xmpp.file.IBType.data ) ) {
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
		xmpp.XMLUtil.ns( x, XMLNS );
		x.set( "sid", sid );
		x.set( "seq", Std.string( seq ) );
		return x;
	}
	
}
