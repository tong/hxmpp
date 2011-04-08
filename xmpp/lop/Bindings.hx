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

class Bindings extends List<Binding> {

	public var vm_id : String;

	public function new( vm_id : String ) {
		super();
		this.vm_id = vm_id;
	}

	public function toXml() : Xml {
		var x = Xml.createElement( "manage_bindings" );
		x.ns( xmpp.LOP.XMLNS );
		x.set( "vm_id", vm_id );
		for( b in iterator() ) {
			var e = Xml.createElement( "binding" );
			e.set( "name", b.name );
			if( b.value != null )  e.set( "value", b.value );
			if( b.datatype != null )  e.set( "datatype", b.datatype );
			x.addChild( e );
		}
		return x;
	}

	public static function parse( x : Xml ) : xmpp.lop.Bindings {
		var b = new Bindings( x.get( "vm_id" ) );
		for( e in x.elementsNamed( "binding" ) )
			b.add( { name : e.get( "name" ),
					 value : e.get( "value" ),
					 datatype : e.get( "datatype" ) } );
		return b;
	}

}
