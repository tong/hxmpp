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
package xmpp.roster;

import xmpp.XMLUtil;

class Item {
	
	public var jid(default,null) : String;
	public var subscription : Subscription;
	public var name : String;
	public var askType : AskType;
	public var groups : List<String>;
	
	public function new( jid : String,
						 ?subscription : Subscription, ?name : String, ?askType : AskType, ?groups : Iterable<String> ) {
		this.jid = jid;
		this.subscription = subscription;
		this.name = name;
		this.askType = askType;
		this.groups = (groups != null) ? Lambda.list( groups ) : new List();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		x.set( "jid", jid );
		if( name != null ) x.set( "name", name );
		if( subscription != null ) x.set( "subscription", Std.string( subscription ) ); //TODO default 'none' ?
		if( askType != null ) x.set( "ask", Std.string( askType ) );
		for( g in groups ) x.addChild( XMLUtil.createElement( "group", g ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.roster.Item {
		var i = new Item( x.get( "jid" ) );
		i.name = x.get( "name" );
		i.subscription = cast x.get( "subscription" );
		i.askType = cast x.get( "ask" );
		for( g in x.elementsNamed( "group" ) ) i.groups.add( g.firstChild().nodeValue );
		return i;
	}
	
}
