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
	
	public static var XMLNS = SI.XMLNS+"/profile/file-transfer";
	
	public var name : String;
	public var size : Null<Int>;
	public var date : String;
	public var hash : String;
	public var desc : String;
	public var range : Range;
	
	public function new( name : String, size : Null<Int>,
						 ?date : String, ?hash : String, ?desc : String, ?range : Range ) {
		this.name = name;
		this.size = size;
		this.date = date;
		this.hash = hash;
		this.desc = desc;
		this.range = range;
	}

	public function toXml() : Xml {
		var x = Xml.createElement( "file" );
		XMLUtil.ns( x, XMLNS );
		if( name != null ) x.set( "name", name );
		if( size != null ) x.set( "size", Std.string( size ) );
		if( date != null ) x.set( "date", date );
		if( hash != null ) x.set( "hash", hash );
		if( desc != null ) x.addChild( xmpp.XMLUtil.createElement( "desc", desc ) );
		if( range != null ) {
			var r = Xml.createElement( "range" );
			if( range.offset != null ) r.set( "offset", Std.string( range.offset ) );
			if( range.length != null ) r.set( "length", Std.string( range.length ) );
			x.addChild( r );
		}
		return x;
	}
	
	public static function parse( x : Xml ) : File {
		var desc : String = null;
		var range : Range = null;
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "desc" : desc = e.firstChild().nodeValue;
			case "range" :
				range = { offset : null, length : null };
				if( e.exists( "offset" ) ) range.offset = Std.parseInt( e.get( "offset" ) );
				if( e.exists( "length" ) ) range.length = Std.parseInt( e.get( "length" ) );
			}
		}
		return new File( x.get( "name" ), Std.parseInt( x.get( "size" ) ), x.get( "date" ), x.get( "hash" ), desc, range );
	}
	
}
