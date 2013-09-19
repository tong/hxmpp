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
package xmpp.jingle;

class Content {
	
	public var creator : Creator;
	public var name : String;
	public var disposition : String;
	public var senders : Senders;
	public var other : Array<Xml>;
	
	public function new( creator : Creator, name : String,
						 ?disposition : String, ?senders : Senders ) {
		this.creator = creator;
		this.name = name;
		this.disposition = disposition;
		this.senders = senders;
		other = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "content" );
		x.set( "creator", Type.enumConstructor( creator ) );
		x.set( "name", name );
		if( disposition != null ) x.set( "disposition", disposition );
		if( senders != null ) x.set( "senders", Type.enumConstructor( senders ) );
		for( e in other ) x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : Content {
		var c = new Content( Type.createEnum( Creator, x.get( "creator" ) ),
							 x.get( "name" ),
							 x.get( "disposition" ),
							 x.exists( "senders" ) ? Type.createEnum( Senders, x.get( "senders" ) ) : null );
		c.other = Lambda.array( x );
		return c;
	}
	
}
