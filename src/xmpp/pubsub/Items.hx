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

class Items extends List<Item> {
	
	public var node : String;
	public var subid : String;
	public var maxItems : Null<Int>;
	
	public function new( ?node : String, ?subid :String, ?maxItems : Null<Int> ) {
		super();
		this.node = node;
		this.subid = subid;
		this.maxItems = maxItems;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "items" );
		if( node != null ) x.set( "node", node );
		if( subid != null ) x.set( "subid", subid );
		if( maxItems != null ) x.set( "max_items", Std.string( maxItems ) );
		for( i in iterator() ) x.addChild( i.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Items {
		var max = x.get( "maxItems" );
		var i = new Items( x.get( "node" ),
						   x.get( "subid" ),
						   ( max != null ) ? Std.parseInt( max ) : null );
		for( e in x.elementsNamed( "item" ) )
			i.add( Item.parse( e ) );
		return i;
	}
	
}
