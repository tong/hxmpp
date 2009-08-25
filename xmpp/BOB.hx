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
	<a href="http://xmpp.org/extensions/xep-0231.html">XEP-0231: Bits of Binary</a>
*/
class BOB {
	
	public static var XMLNS = "urn:xmpp:bob";
	
	/** Content ID */
	public var cid : String;
	/** Content type. fe: image/png */
	public var type : String;
	/** Suggested period for caching time of data, 0 for 'no cache' */
	public var max_age : Int;
	/** File type */
	public var data : String;
	
	public function new( cid : String, ?type : String, ?max_age : Int = -1, ?data : String ) {
		this.cid = cid;
		this.type = type;
		this.max_age = max_age;
		this.data = data;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "data" );
		x.set( "xmlns", XMLNS );
		x.set( "cid", cid );
		x.set( "type", type );
		if( max_age >= 0 ) x.set( "max-age", Std.string( max_age ) );
		if( data != null ) x.addChild(  Xml.createPCData( data ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.BOB {
		var b = new xmpp.BOB( x.get( "cid" ), x.get( "type" ), Std.parseInt( x.get( "max-age" ) ) );
		if( x.firstChild() != null )
			b.data = x.firstChild().toString();
		return b;
	}
	
	/**
		Parses cids ('algo+hash@bob.xmpp.org') from the given string.
		//TODO return : Array<{algo:String,hash:String}>
	*/
	public static function parseCID( t : String ) : {algo:String,hash:String} {
		var algo : String = null;
		var hash : String = null;
		~/cid:(.*?)\+(.*?)@bob.xmpp.org/.customReplace( t, function(r) {
			algo = r.matched( 1 );
			hash = r.matched( 2 );
			return null;
		} );
		return { algo : algo, hash : hash };
	}
	
	/**
	*/
	public static function getCIDParts( cid : String ) : Array<String> {
		var i1 = cid.indexOf( "+" );
		var i2 = cid.lastIndexOf( "@bob.xmpp.org" );
		return if( i1 == -1 || i2 == -1 ) null;
		else [ cid.substr( 0, i1 ), cid.substr( i1+1, i2-i1-1 ) ];
	}
	
	/**
	*/
	public static function createCID( algo : String, hash : String ) : String {
		return algo+"+"+hash+"@bob.xmpp.org";
	}
	
	/*
		Create BOB data elements to use for direct messages.
	
	public function createElement( bytes : haxe.io.Bytes, type : String, maxage : Int, data : String ) {
		var hash : String = crypt.SHA1.encode( bytes.toString() );
		return new xmpp.BOB( xmpp.BOB.createCID( "sha1", hash ), type, maxage, data );
	}
	*/
	
}
