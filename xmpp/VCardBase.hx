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
	VCard base class
*/
class VCardBase {
	
	public var xmlns(default,null) : String;
	
	/** Required */
	//public var fn : String;
	
	/** Required */
	//public var n : xmpp.vcard.Name;
	
	/*
//	public var nickname : String;
//	public var photo : Photo;
	public var birthday : String;
//	public var addresses : Array<Address>;
//	public var tels	: Array<Tel>;
//	public var email : EMail;
	public var jid : String;
	public var tz : String;
	//public var geo : Geo<Float>; //temp only, in vc4 it is a uri
	public var title : String;
	public var role : String;
//	public var org : Org;
	public var url 	: String;
	//public var desc : String; //temp only
	*/
	
	function new( xmlns : String ) {
		this.xmlns = xmlns;
	}
	
	public function toXml() : Xml {
		
		var x = Xml.createElement( "vcard" );
		x.ns( xmlns );
		
		//addXmlField( x, "fn" );
		//addXmlField( x, "n" );
		//addXmlField( x, "nickname" );
		
		//for( a in addresses ) reflectValues( x, "adr", a );
		
		return x;
	}
	
	function addXmlField( x : Xml, id : String, ?name : String ) {
		var v = Reflect.field( this, id );
		//trace("##################### "+v);
		
		//if( v != null )
		//	x.addChild( XMLUtil.createElement( (name==null) ? n : name, v ) );
	}
	
	function addXmlFields( id : String, x : Xml ) {
		var field = Reflect.field( this, id );
		if( field != null ) {
			for( f in Reflect.fields( field ) ) {
				var v = Reflect.field( field, f );
				if( v != null ) {
					
				}
				/*
				var v = Reflect.field( f, f) );
				if( f != null ) {
					
				}
				*/
			}
		}
	}
	
	/*
	function reflectValues<T>( x : Xml, e : String, obj : T ) {
		//var e = Xml.createElement( e );
		for( f in Reflect.fields( obj ) ) {
			var v = Reflect.field( f );
			if( v != null ) {
				x.addChild( XMLUtil.createElement( f.toUpperCase(), v ) );
			}
		}
	}
	*/
	
	static function reflectElementValues<T>( x : Xml, t : T ) {
		for( e in x.elements() ) {
			var c : Xml = e.firstChild();
			if( c == null || c.nodeValue == "" )
				continue;
			Reflect.setField(t, e.nodeName, c.nodeValue );		
		}
	}
	
	static inline function parseTextValue( x : Xml ) : String {
		return x.firstElement().firstChild().nodeValue;
	}
	
}
