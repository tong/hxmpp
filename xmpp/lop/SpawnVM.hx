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

using xmpp.XMLUtil;

class SpawnVM {
	
	public var species : String;
	public var id : String;
	public var password : String;
	
	public function new( species : String, ?id : String, ?password : String ) {
		this.species = species;
		this.id = id;
		this.password = password;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "spawn_vm" );
		x.ns( xmpp.LOP.XMLNS );
		if( species != null ) x.set( "vm_species", species );
		if( id != null ) x.set( "vm_id", id );
		if( password != null ) x.set( "farm_password", password );
		return x;
	}
	
	public static function parse( x : Xml ) : SpawnVM {
		return new SpawnVM( x.get( "vm_species" ), x.get( "vm_id" ), x.get( "farm_password" ) );
	}
	
}
