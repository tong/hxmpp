/*
 *	This file is part of HXMPP.
 *	Copyright (c)2010 http://www.disktree.net
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
package xmpp.lop;

class Submit {
	
	public var id : String; // vm id
	public var code : String;
	
	public function new( id : String, ?code : String ) {
		this.id = id;
		this.code = code;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "submit_job" );
		x.set( "xmlns", xmpp.LOP.XMLNS );
		x.set( "vm_id", id );
		if( code != null ) x.addChild( Xml.createPCData( code ) );
		return x;
	}
	
	public static function parse( x : Xml ) : Submit {
		return new Submit( x.get( "vm_id" ),
						   ( x.firstChild() != null ) ? x.firstChild().nodeValue : null );
	}
	
}
