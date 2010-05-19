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

/**
	<a href="http://xmpp.org/rfcs/rfc3920.html#stanzas-error">XMPP stanza errors</a>
	
	* MUST contain a child element corresponding to one of the defined stanza error conditions specified below; this element MUST be qualified by the 'urn:ietf:params:xml:ns:xmpp-stanzas' namespace.
    * MAY contain a <text/> child containing XML character data that describes the error in more detail; this element MUST be qualified by the 'urn:ietf:params:xml:ns:xmpp-stanzas' namespace and SHOULD possess an 'xml:lang' attribute.
    * MAY contain a child element for an application-specific error condition; this element MUST be qualified by an application-defined namespace, and its structure is defined by that namespace.
	
*/
class Error {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";
	
	public var type : ErrorType;
	public var code : Null<Int>;
	public var text : String;
	public var conditions : Array<Xml>;
	
	public function new( ?type : xmpp.ErrorType,
						 ?code : Null<Int>,
						 ?text : String,
						 ?conditions : Array<Xml> ) {
		this.type = type;
		this.code = code;
		this.text = text;
		this.conditions = ( conditions == null ) ? new Array() : conditions;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "error" );
		if( code != null ) x.set( "code", Std.string( code ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( text != null ) {
			var e = XMLUtil.createElement( "text", text );
			e.set( "xmlns", XMLNS );
			x.addChild( e );
		}
		for( c in conditions ) x.addChild( c );
		return x;
	}
	
	public function toString() : String {
		return "XMPPError("+type+","+code+")";
	}
	
	public static function parse( x : Xml ) : xmpp.Error {
		var e = new Error();
		var v = x.get( "code" );
		if( v != null ) e.code = Std.parseInt( v ); 
		v = x.get( "type" );
		if( v != null ) e.type = Type.createEnum( ErrorType, v );
		for( el in x.elements() ) {
			switch( el.nodeName ) {
			case "text" :
				//try e.text = el.firstChild().nodeValue catch(e:Dynamic){}
				//if( el.get( "xmlns" ) != XMLNS )
				e.text = el.firstChild().nodeValue;
			default :
				e.conditions.push( el );
			}
		}
		return e;
	}
	
	/*
-		Parses the error from a given packet.
-	public static function fromPacket( p : xmpp.Packet ) : xmpp.Error {
-		for( e in p.toXml().elementsNamed( "error" ) )
-			return Error.parse( e );
-		return null;
-	}
-	*/

}
