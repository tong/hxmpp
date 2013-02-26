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

using xmpp.XMLUtil;

typedef ApplicationErrorCondition = {
	var condition : String;
	var xmlns : String;
}

/**
	Abstract base class for xmpp.Error and xmpp.StreamError
*/
class ErrorPacket {
	
	/** */
	public var condition : String;
	/** Describes the error in more detail */
	public var text : String;
	/** Language of the text content XML character data  */
	public var lang : String;
	/** Application-specific error condition */
	public var app : ApplicationErrorCondition;
	
	function new( condition : String,
				  ?text : String, ?lang : String, ?app : ApplicationErrorCondition) {
		this.condition = condition;
		this.text = text;
		this.lang = lang;
		this.app = app;
	}
	
	function _toXml( p : String, ns: String ) : Xml {
		var x = Xml.createElement( p );
		var c = Xml.createElement( condition );
		c.ns( ns );
		x.addChild( c );
		if( text != null ) {
			var t = XMLUtil.createElement( "text", text );
			XMLUtil.setNamespace( t, ns );
			if( lang != null ) t.set( "lang", lang );
			x.addChild( t );
		}
		if( app != null && app.condition != null && app.xmlns != null ) {
			var a = Xml.createElement( app.condition );
			a.ns( app.xmlns );
			x.addChild( a );
		}
		return x;
	}
	
	static function parseInto( p : ErrorPacket, x : Xml, xmlns : String ) : Bool {
		for( e in x.elements() ) {
			var ns = e.get( "xmlns" );
			if( ns == null )
				return false;
			switch( e.nodeName ) {
			case "text" :
				if( ns == xmlns ) {
					var c = e.firstChild();
					if( c != null ) p.text = c.nodeValue;
					p.lang = e.get( "xml:lang" );
				}
			default :
				if( ns == xmlns )
					p.condition = e.nodeName;
				else
					p.app = { condition : e.nodeName, xmlns : ns };
			}
		}
		return true;
	}
	
}
