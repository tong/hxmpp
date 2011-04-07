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
	Static methods for creation/manipulation of SASL XMPP packets.
*/
class SASL {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-sasl";
	public static var EREG_FAILURE = ~/(^failure$)|(^not-authorized$)|(^aborted$)|(^incorrect-encoding$)|(^invalid-authzid$)|(^invalid-mechanism$)|(^mechanism-too-weak$)|(^temporary-auth-failure$)/;
	
	/**
	*/
	public static function createAuth( mech : String, ?text : String ) : Xml {
		if( mech == null )
			return null;
		var x = ( text != null ) ? XMLUtil.createElement( "auth", text ) : Xml.createElement( "auth" );
		#if flash // TODO haXe 2.06 fukup
		x.set( "_xmlns_", XMLNS );
		#else
		x.set( "xmlns", XMLNS );
		#end
		x.set( "mechanism", mech );
		return x;
	}
	
	/**
	*/
	public static function createResponse( t : String ) : Xml {
		if( t == null )
			return null;
		// TODO flash 2.06 (+) namespace hack
		var x = XMLUtil.createElement( "response", t );
	#if flash // TODO haXe 2.06 fukup
		x.set( "_xmlns_", XMLNS );
	#else
		x.set( "xmlns", XMLNS );
	#end
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
