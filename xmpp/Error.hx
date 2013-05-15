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

import xmpp.ErrorPacket;

/**
*/
class Error extends xmpp.ErrorPacket {
	
	public static var XMLNS(default,null) : String = "urn:ietf:params:xml:ns:xmpp-stanzas";
	
	public var type : ErrorType;
	public var code : Null<Int>;
	
	public function new( type : ErrorType, condition : String,
				  		 ?code : Null<Int>, ?text : String, ?lang : String, ?app : ApplicationErrorCondition ) {
		super( condition, text, lang, app );
		this.type = type;
		this.code = code;
	}
	
	public function toXml() : Xml {
		var x = _toXml( "error", XMLNS );
		x.set( "type", Type.enumConstructor( type ) );
		if( code != null ) x.set( "code", Std.string( code ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.Error {
		var p = new Error( null, null );
		if( !ErrorPacket.parseInto( p, x, XMLNS ) )
			return null;
		//TODO remove try/catch here
	//	try {
			p.type = Type.createEnum( ErrorType, x.get( "type" ).toLowerCase() );
			var v = x.get( "code" );
			if( v != null )
				p.code = Std.parseInt( v );
	//	} catch(e:Dynamic) {
	//		#if jabber_debug trace(e,"error"); #end
	//		return null;
	//	}
		return p;
	}
	
}
