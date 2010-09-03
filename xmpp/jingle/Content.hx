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

//TODO

class Content {
	
	public var creator : String;
	public var name : String;
	public var disposition : String;
	public var senders : String; //xmpp.jingle.Senders 
	
	// out of spec ..
	public var transport : Transport;
	public var description : Description;
	public var any : Array<Xml>;
	
	public function new( ?creator : String = "initiator", name : String ) {
		this.creator = creator;
		this.name = name;
		any = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "content" );
		x.set( "creator", creator );
		x.set( "name", name );
		//TODO
		//if( disposition != null )
		if( description != null ) x.addChild( description.toXml() );
		
		//if( senders != null )
		if( transport != null ) x.addChild( transport.toXml() );
		for( e in any ) x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : Content {
		var c = new Content( x.get( "creator" ), x.get( "name" ) );
		//TODO
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "transport" :
				c.transport = Transport.parse( e );
//			case "description" :
//				c.description = Description.parse( e ); //fuuuuuuuuuuuuuuuuuuk jingle type have different descriptions
			default :
				c.any.push( e );
			}
		}
		//TODO
		///c.any = Lambda.array( x );
		return c;
	}
	
}
