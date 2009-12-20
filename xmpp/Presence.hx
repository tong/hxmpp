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
package xmpp;

import util.XmlUtil;

/**
	<a href="http://xmpp.org/rfcs/rfc3921.html">RFC-3921 - Instant Messaging and Presence</a></br>
	<a href="http://www.xmpp.org/rfcs/rfc3921.html#presence">Exchanging Presence Information</a>
*/
class Presence extends Packet {
	
	public var type : PresenceType;
   	public var show : PresenceShow;
    public var status(default,setStatus) : String;
    public var priority : Null<Int>;
    
	public function new( ?show : PresenceShow, ?status : String, ?priority : Int, ?type : PresenceType ) {
		super();
		_type = xmpp.PacketType.presence;
		this.show = show;
		this.status = status;
		this.priority = priority;
		this.type = type;
	}
	
	function setStatus( s : String ) : String {
		if( s == null )
			return status = s;
		if( s.length == 0 || s.length > 1023 )
			throw "Invalid presence status size "+s.length;
		return status = s;
	}
	
	public override function toXml() : Xml {
		var x = super.addAttributes( Xml.createElement( "presence" ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( show != null ) x.addChild( XmlUtil.createElement( "show", Type.enumConstructor( show ) ) );
		if( status != null && status != "" ) x.addChild( XmlUtil.createElement( "status", status ) );
		if( priority != null ) x.addChild( XmlUtil.createElement( "priority", Std.string( priority ) ) );
		return x;
	}
	
	public static function parse( x : Xml ) : Presence {
		var p = new Presence( x.get( "type" ) );
		Packet.parseAttributes( p, x );
		if( x.exists( "type" ) )
			p.type = Type.createEnum( PresenceType, x.get( "type" ) );
		for( c in x.elements() ) {
			var fc = c.firstChild();
			switch( c.nodeName ) {
			case "show" : if( fc != null ) p.show = Type.createEnum( PresenceShow, fc.nodeValue );
			case "status" : if( fc != null ) p.status =  fc.nodeValue;
			case "priority" : if( fc != null ) p.priority = Std.parseInt( fc.nodeValue );
			default : p.properties.push( c );
			}
		}
		return p;
	}
	
}
