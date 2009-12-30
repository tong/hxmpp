/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package xmpp;

class StreamError {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-streams";
	
	public var condition : String;
	/** Describes the error in more detail */
	public var text : String;
	/** Language of the text content XML character data  */
	public var lang : String;
	/** Application-specific error condition */
	public var app : { condition : String, ns : String };
	
	public function new( ?condition : String ) {
		this.condition = condition;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "stream:error" );
		var c = Xml.createElement( condition );
		c.set( "xmlns", XMLNS );
		x.addChild( c );
		if( text != null ) {
			var t = util.XmlUtil.createElement( "text", text );
			t.set( "xmlns", XMLNS );
			if( lang != null ) t.set( "lang", lang );
			x.addChild( t );
		}
		if( app != null && app.condition != null && app.ns != null ) {
			var a = Xml.createElement( app.condition );
			a.set( "xmlns", app.ns );
			x.addChild( a );	
		}
		return x;
	}
	
	public static function parse( x : Xml ) : StreamError {
		var p = new StreamError();
		for( e in x.elements() ) {
			var ns = e.get( "xmlns" );
			if( ns == null ) continue;
			switch( e.nodeName ) {
			case "text" :
				if( ns == XMLNS ) p.text = e.firstChild().nodeValue;
			default :
				if( ns == XMLNS ) p.condition = e.nodeName;
				else p.app = { condition : e.nodeName, ns : ns };
			}
		}
		if( p.condition == null )
			return null;
		return p;
	}

}
