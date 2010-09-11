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

class SI {
	
	public static var XMLNS = "http://jabber.org/protocol/si";
	public static var PROFILE = XMLNS+"/profile/file-transfer";
	
	public var id : String;
	public var mime : String;
	public var profile : String;
	public var any : Array<Xml>;
	
	public function new( ?id : String, ?mime : String, ?profile : String ) {
		this.id = id;
		this.mime = mime;
		this.profile = profile;
		any = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "si" );
		x.set( "xmlns", XMLNS );
		if( id != null ) x.set( "id", id );
		if( mime != null ) x.set( "mime", mime );
		if( profile != null ) x.set( "profile", profile );
		for( e in any ) x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : SI {
		var si = new SI( x.get( "id" ), x.get( "mime-type" ), x.get( "profile" ) );
		for( e in x.elements() )
			si.any.push( e );
		return si;
	}
	
}
