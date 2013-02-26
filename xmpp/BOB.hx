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

using xmpp.XMLUtil;

/**
	XEP-0231: Bits of Binary: http://xmpp.org/extensions/xep-0231.html
*/
class BOB {
	
	public static inline var XMLNS = 'urn:xmpp:bob';
	
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
		x.ns( XMLNS );
		x.set( "cid", cid );
		x.set( "type", type );
		if( max_age >= 0 ) x.set( "max-age", Std.string( max_age ) );
		if( data != null ) x.addChild( Xml.createPCData( data ) );
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
	*/
	public static function parseCID( t : String ) : { algo : String, hash : String } {
		//TODO return : Array<{algo:String,hash:String}>
		var algo : String = null;
		var hash : String = null;
		~/cid:(.*?)\+(.*?)@bob\.xmpp\.org/.map( t, function(r) {
			algo = r.matched( 1 );
			hash = r.matched( 2 );
			return null;
		} );
		return { algo : algo, hash : hash };
	}
	
	/**
		Finds all CIDs in given string
	*/
	/*
	public static function findCIDs( t : String ) : Array<{cid:String,pos:Int}> {
		// cid:sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org
		var a = new Array<{cid:String,pos:Int}>();
		var reg = ~/cid:([a-z0-9]+)\+([a-z0-9]+)@bob\.xmpp\.org/g; //gm
		reg.map( t, function(r){
			a.push( { cid : createCID( r.matched(1), r.matched(2) ), pos : r.matchedPos().pos } );
			//a.push( { cid : l.substr( pos.pos, pos.len ), pos : pos.pos } );
			//trace( r.matched( 1 ) +" : "+ r.matched( 2 ) );
			//trace( r.matchedPos() );
			return null;
		});
		return a;
	}
	*/
	
	/**
		Splits a CID into its parts
	*/
	public static function getCIDParts( cid : String ) : Array<String> {
		var a = cid.indexOf( "+" );
		var b = cid.lastIndexOf( "@bob.xmpp.org" );
		return if( a == -1 || b == -1 ) null else [ cid.substr(0,a), cid.substr(a+1,b-a-1) ];
	}
	
	/**
	*/
	public static function createCID( algo : String, hash : String ) : String {
		#if sys
		var b = new StringBuf();
		b.add( algo );
		b.add( "+" );
		b.add( hash );
		b.add( "@bob.xmpp.org" );
		return b.toString();
		#else
		return algo+"+"+hash+"@bob.xmpp.org";
		#end
	}
	
}
