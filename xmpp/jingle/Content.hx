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
package xmpp.jingle;

class Content {
	
	public var creator : Creator;
	public var name : String;
	public var disposition : String;
	public var senders : Senders;
	public var other : Array<Xml>;
	
	public function new( creator : Creator, name : String,
						 ?disposition : String, ?senders : Senders ) {
		this.creator = creator;
		this.name = name;
		this.disposition = disposition;
		this.senders = senders;
		other = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "content" );
		x.set( "creator", Type.enumConstructor( creator ) );
		x.set( "name", name );
		if( disposition != null ) x.set( "disposition", disposition );
		if( senders != null ) x.set( "senders", Type.enumConstructor( senders ) );
		for( e in other ) x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : Content {
		var c = new Content( Type.createEnum( Creator, x.get( "creator" ) ),
							 x.get( "name" ),
							 x.get( "disposition" ),
							 x.exists( "senders" ) ? Type.createEnum( Senders, x.get( "senders" ) ) : null );
		//TODO
		/*
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "transport" :
				//TODO
			default : c.other.push( e );
			}
		}
		*/
		c.other = Lambda.array( x );
		return c;
	}
	
}
