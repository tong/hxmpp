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
package xmpp.privacylist;

class Item {
	
	public var type : ItemType;
	public var action : Action;
	public var value : String;
	public var order : Int;
	
	public function new( action : Action, ?type : ItemType, ?value : String, ?order : Int = -1 ) {
		this.type = type;
		this.action = action;
		this.value = value;
		this.order = order;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		x.set( "action", Type.enumConstructor( action ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( value != null ) x.set( "value", value );
		if( order != -1 ) x.set( "order", Std.string( order ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.privacylist.Item {
		var _order = x.get( "order" );
		var order = ( _order == null ) ? -1 : Std.parseInt( _order );
		var _type =  x.get( "type" );
		return new Item( Type.createEnum( Action, x.get( "action" ) ),
						 if( _type != null ) Type.createEnum( ItemType, _type ) else null,
						 x.get( "value" ),
						 order );
	}
	
}
