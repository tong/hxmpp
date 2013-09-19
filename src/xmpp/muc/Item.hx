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
package xmpp.muc;

import xmpp.XMLUtil;

/**
*/
class Item {
	
	public var affiliation : Affiliation;
	public var role : Role;
	public var nick : String;
	public var jid : String;
	public var actor : String;
	public var reason : String;
	public var continue_ : String;
	
	public function new( ?affiliation : Affiliation, ?role : Role, ?nick : String, ?jid : String ) {
		this.affiliation = affiliation;
		this.role = role;
		this.nick = nick;
		this.jid = jid;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		if( jid != null ) x.set( "jid", jid );
		if( nick != null ) x.set( "nick", nick );
		if( role != null ) x.set( "role", Type.enumConstructor( role ) );
		if( affiliation != null ) x.set( "affiliation", Type.enumConstructor( affiliation ) );
		if( actor != null ) {
			var e = Xml.createElement( "actor" );
			e.set( "jid", actor );
			x.addChild( e );
		}
		if( reason != null ) {
			x.addChild( XMLUtil.createElement( "reason", reason ) );
		}
		if( continue_ != null ) {
			var e = Xml.createElement( "continue" );
			e.set( "thread", continue_ );
			x.addChild( e );
		}
		return x;
	}
	
	public static function parse( x : Xml ) : Item {
		var p = new Item();
		if( x.exists( "affiliation" ) ) p.affiliation = Type.createEnum( Affiliation, x.get( "affiliation" ) );
		if( x.exists( "role" ) ) p.role = Type.createEnum( Role, x.get( "role" ) );
		if( x.exists( "nick" ) ) p.nick = x.get( "nick" );
		if( x.exists( "jid" ) ) p.jid = x.get( "jid" );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "actor" : p.actor = e.get( "jid" );
				case "reason" : p.reason = e.firstChild().nodeValue;
				case "continue" : p.continue_ = e.get( "continue" );
			}
		}
		return p;
	}
	
}
