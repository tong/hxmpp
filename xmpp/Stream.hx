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

import util.XmlUtil;

class Stream {
	
	public static inline var XMLNS_STREAM 	  = "http://etherx.jabber.org/streams";
	public static inline var XMLNS_CLIENT 	  = "jabber:client";
	public static inline var XMLNS_SERVER 	  = "jabber:client";
	public static inline var XMLNS_COMPONENT = "jabber:component:accept";
	public static inline var CLOSE = "</stream:stream>";
	public static inline var ERROR = "</stream:error>";
	public static inline var REGEXP_CLOSE = new EReg( CLOSE, "" );
	public static inline var REGEXP_ERROR = new EReg( ERROR, "" );
	
	/**
	*/
	public static function createOpenStream( xmlns : String, to : String,
											 ?version : Bool, ?lang : String, ?xmlHeader : Bool = true ) : String {
		var b = new StringBuf();
		b.add( '<stream:stream xmlns="' );
		b.add( xmlns );
		b.add( '" xmlns:stream="'+XMLNS_STREAM+'" to="' );
		b.add( to );
		b.add( '" xmlns:xml="http://www.w3.org/XML/1998/namespace" ' );
		if( version )
			b.add( 'version="1.0" ' );
		if( lang != null ) {
			b.add( 'xml:lang="' );
			b.add( lang );
			b.add( '"' );
		}
		b.add( '>' );
		return ( xmlHeader ) ? XmlUtil.XML_HEADER+b.toString() : b.toString();
	}
	
	/*
	public static function parseStreamFeatures( x : Xml ) {
	}
	*/
	
}
