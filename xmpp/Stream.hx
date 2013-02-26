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
	Static stuff for creation/manipulation of XMPP stream opening/closing tags.
*/
class Stream {
	
	public static var STREAM(default,null) : String = "http://etherx.jabber.org/streams";
	public static var CLIENT(default,null) : String = "jabber:client";
	public static var SERVER(default,null) : String = "jabber:client";
	#if jabber_component
	public static var COMPONENT(default,null) : String = "jabber:component:accept";
	#end
	
	/**
		Creates the opening XML tag of a XMPP stream.
	*/
	public static function createOpenXml( ns : String, to : String,
										  ?version : Bool, ?lang : String, ?header : Bool = true ) : String {
		var b = new StringBuf();
		b.add( '<stream:stream xmlns="' );
		b.add( ns );
		b.add( '" xmlns:stream="'+STREAM );
		if( to != null ) {
			b.add( '" to="' );
			b.add( to );
		}
		b.add( '" xmlns:xml="http://www.w3.org/XML/1998/namespace"' );
		if( version )
			b.add( ' version="1.0"' );
		if( lang != null ) {
			b.add( ' xml:lang="' );
			b.add( lang );
			b.add( '"' );
		}
		b.add( '>' );
		return ( header ) ? '<?xml version="1.0" encoding="UTF-8"?>'+b.toString() : b.toString();
	}
	
}
