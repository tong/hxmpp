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
package xmpp.pubsub;

class Item {
	
	public var id : String;
	public var payload : Xml;
	/* The node attribute is allowed (required!) in pubsub-event namespace only!? */
	//public var node : String;
	
	public function new( ?id : String, ?payload : Xml/*, ?node : String*/ ) {
		this.id = id;
		this.payload = payload;
		//this.node = node;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		if( id != null ) x.set( "id", id );
		//if( node != null ) x.set( "node", node );
		if( payload != null ) x.addChild( payload );
		return x;
	}
	
	public static function parse( x : Xml ) : Item {
		var e = x.firstElement();
		if( e == null ) e = x.firstChild();
		return new Item( x.get( "id" ), e/*, x.get( "node" )*/ );
	}
	
}
