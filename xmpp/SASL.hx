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

/**
	Static methods for creation/manipulation of SASL XMPP packets.
*/
class SASL {
	
	public static var XMLNS(default,null) : String = "urn:ietf:params:xml:ns:xmpp-sasl";
	public static var EREG_FAILURE = ~/(^failure$)|(^not-authorized$)|(^aborted$)|(^incorrect-encoding$)|(^invalid-authzid$)|(^invalid-mechanism$)|(^mechanism-too-weak$)|(^temporary-auth-failure$)/;
	
	/**
	*/
	public static function createAuth( mech : String, ?text : String ) : Xml {
		if( mech == null )
			return null;
		var x = ( text != null ) ? XMLUtil.createElement( "auth", text ) : Xml.createElement( "auth" );
		x.setNamespace( XMLNS );
		x.set( "mechanism", mech );
		return x;
	}
	
	/**
	*/
	public static function createResponse( t : String ) : Xml {
		if( t == null )
			return null;
		var x = XMLUtil.createElement( "response", t );
		x.setNamespace( XMLNS );
		return x;
	}
	
	/**
		Parses list of SASL mechanisms.
	*/
	public static function parseMechanisms( x : Xml ) : Array<String> {
		var m = new Array<String>();
		for( e in x.elements() ) {
			if( e.nodeName != "mechanism" )
				continue;
			m.push( e.firstChild().nodeValue );
		}
	//	for( e in x.elementsNamed( "mechanism" ) )
	//		m.push( e.firstChild().nodeValue );
		return m;
	}
	
}
