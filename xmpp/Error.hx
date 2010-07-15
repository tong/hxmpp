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

import xmpp.ErrorPacket;

/**
*/
class Error extends xmpp.ErrorPacket {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";
	
	public var type : ErrorType;
	public var code : Null<Int>;
	
	public function new( type : ErrorType, condition : String,
				  		 ?code : Null<Int>, ?text : String, ?lang : String, ?app : ApplicationErrorCondition) {
		super( condition, text, lang, app );
		this.type = type;
		this.code = code;
	}
	
	public function toXml() : Xml {
		var x = _toXml( "error", XMLNS );
		x.set( "type", Type.enumConstructor( type ) );
		if( code != null ) x.set( "code", Std.string( code ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.Error {
		var p = new Error( null, null );
		ErrorPacket.parseInto( p, x, XMLNS );
		if( p.condition == null )
			return null;
		p.type = Type.createEnum( ErrorType, x.get( "type" ) );
		var v = x.get( "code" );
		if( v != null ) p.code = Std.parseInt( v );
		return p;
	}
	
}
