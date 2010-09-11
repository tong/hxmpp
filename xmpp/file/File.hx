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
package xmpp.file;

class File {
	
	public var name : String;
	public var size : Int;
	public var date : String;
	public var hash : String;
	
	public function new( name : String, size : Int, ?date : String, ?hash : String ) {
		this.name = name;
		this.size = size;
		this.date = date;
		this.hash = hash;
	}

	public function toXml() : Xml {
		var x = Xml.createElement( "file" );
		x.set( "xmlns", SI.PROFILE );
		x.set( "name", name );
		x.set( "size", Std.string( size ) );
		if( date != null ) x.set( "date", date );
		if( hash != null ) x.set( "hash", hash );
		return x;
	}
	
	public static function parse( x : Xml ) : File {
		return new File( x.get( "name" ), Std.parseInt( x.get( "size" ) ), x.get( "date" ), x.get( "hash" ) );
	}
	
}
