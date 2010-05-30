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

class Terminate {
	
	public var vm_id : String;
	
	public function new( vm_id : String ) {
		this.vm_id = vm_id;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "terminate_vm" );
		x.set( "xmlns", xmpp.LOP.XMLNS );
		if( vm_id != null ) x.set( "vm_id", vm_id );
		return x;
	}
	
	public static inline function parse( x : Xml ) : xmpp.lop.Terminate {
		return new Terminate( x.get( "vm_id" ) );
	}
	
}
