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
	Static stuff for creation/manipulation of XMPP stream opening/closing tags.
*/
class Stream {
	
	public static var STREAM = "http://etherx.jabber.org/streams";
	public static var CLIENT = "jabber:client";
	public static var SERVER = "jabber:client";
	#if JABBER_COMPONENT
	public static var COMPONENT = "jabber:component:accept";
	#end
	
	/**
		Creates the opening XML tag of a XMPP stream.
	*/
	public static function createOpenXml( ns : String, to : String,
										  ?version : Bool, ?lang : String, ?header : Bool = true ) : String {
		var b = new StringBuf();
		b.add( '<stream:stream xmlns="' );
		b.add( ns );
		b.add( '" xmlns:stream="'+STREAM );
		if( to != null ) {
			b.add( '" to="' );
			b.add( to );
		}
		b.add( '" xmlns:xml="http://www.w3.org/XML/1998/namespace"' );
		if( version )
			b.add( ' version="1.0"' );
		if( lang != null ) {
			b.add( ' xml:lang="' );
			b.add( lang );
			b.add( '"' );
		}
		b.add( '>' );
		return ( header ) ? '<?xml version="1.0" encoding="UTF-8"?>'+b.toString() : b.toString();
	}
	
}
