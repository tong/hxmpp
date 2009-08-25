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

/**
	InfoQuery XMPP packet.
*/
class IQ extends Packet {
	
	/** */
	public var type : IQType;
	/** The exclusiv child of the IQ packet. */
	public var x : PacketElement;
	
	public function new( ?type : IQType, ?id : String, ?to : String, ?from ) {
		super( to, from, id );
		_type = xmpp.PacketType.iq;
		this.type = if( type != null ) type else xmpp.IQType.get;
	}
	
	public override function toXml(): Xml {
		if( type == null ) type = IQType.get;
		var _x = super.addAttributes( Xml.createElement( "iq" ) );
		_x.set( "type", Type.enumConstructor( type ) );
		_x.set( "id", id );
		if( x != null ) _x.addChild( x.toXml() );
		return _x;
	}
	
	public static function parse( x : Xml ) : IQ {
		var iq = new IQ();
		iq.type = Type.createEnum( IQType, x.get( "type" ) );
		Packet.parseAttributes( iq, x );
		for( c in x.elements() ) {
			switch( c.nodeName ) {
			case "error" :  iq.errors.push( xmpp.Error.parse( c ) );
			default : iq.properties.push( c );
			}
		}
		if( iq.properties.length > 0 )
			iq.x = new PlainPacket( iq.properties[0] );
		return iq;
	}
	
	/**
		Creates a '<query xmlns="namspace"/>' xml tag.
	*/
    public static function createQueryXml( ns : String ) : Xml {
		var q = Xml.createElement( "query" );
		q.set( "xmlns", ns );
		return q;
	}
	
	/**
	*/
	public static inline function createResult( iq : IQ ) : IQ {
		return new IQ( IQType.result, iq.id, iq.from );
	}
	
}
