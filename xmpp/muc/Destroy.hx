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
package xmpp.muc;

import xmpp.XMLUtil;
using xmpp.XMLUtil;

class Destroy {
	
	public var jid : String;
	public var reason : String;
	
	public function new( ?jid : String, ?reason : String ) {
		this.jid = jid;
		this.reason = reason;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "destroy" );
		if( jid != null ) x.set( "jid", jid );
		x.addField( this, "reason" );
		return x;
	}
	
	public static function parse( x : Xml ) : Destroy {
		var r = if( x.firstElement() == null ) null;
		else x.firstElement().firstChild().nodeValue;
		return new Destroy( x.get('jid'), r );
	}
	
}
