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

class Retract extends List<Item> {
		
	public var node : String;
	public var notify : Bool;
	
	public function new( node : String, ?itemIDs : Iterable<String>, ?notify : Bool = false ) {
		super();
		this.node = node;
		if( itemIDs != null )
			for( id in itemIDs ) add( new Item( id ) );
		this.notify = notify;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "retract" );
		x.set( "node", node );
		if( notify ) x.set( "notify", "true" );
		for( i in iterator() )
			x.addChild( i.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Retract {
		var _n = x.get( "notify" );
		var r = new Retract( x.get( "node" ), if( _n != null && ( _n == "true" || _n == "1" ) ) true else false );
		for( e in x.elementsNamed( "item" ) )
			r.add( Item.parse( e ) );
		return r;
	}
	
}
