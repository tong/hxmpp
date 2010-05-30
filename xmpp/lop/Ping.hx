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

class Ping {
	
	public var vm_id : String;
	public var job_id : String;
	public var status : String; // type (specs failure)
	
	public function new( vm_id : String, ?job_id : String, ?status : String ) {
		this.vm_id = vm_id;
		this.job_id = job_id;
		this.status = status;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "spawn_vm" );
		x.set( "xmlns", xmpp.LOP.XMLNS );
		if( vm_id != null ) x.set( "vm_id", vm_id );
		if( job_id != null ) x.set( "job_id", job_id );
		if( status != null ) x.set( "status", status );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.lop.Ping {
		return new Ping( x.get( "vm_id" ), x.get( "job_id" ), x.get( "status" ) );
	}
	
}
