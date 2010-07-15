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
class StreamError extends ErrorPacket {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-streams";
	
	public function new( condition : String,
				  		 ?text : String, ?lang : String, ?app : ApplicationErrorCondition) {
		super( condition, text, lang, app );
	}
	
	public function toXml() : Xml {
		return _toXml( "stream:error", XMLNS );
	}
	
	public static function parse( x : Xml ) : StreamError {
		var p = new StreamError( null );
		ErrorPacket.parseInto( p, x, XMLNS );
		if( p.condition == null )
			return null;
		return p;
	}
	
}
