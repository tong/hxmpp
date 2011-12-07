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
	
	/** Either: get/set/result/error */
	public var type : IQType;
	
	/** The exclusiv child of the IQ packet. */
	public var x : PacketElement;
	
	public function new( ?type : IQType, ?id : String, ?to : String, ?from ) {
		super( to, from, id );
		_type = xmpp.PacketType.iq;
		this.type = ( type != null ) ? type : xmpp.IQType.get;
	}
	
	public override function toXml(): Xml {
		var p = super.addAttributes( Xml.createElement( "iq" ) );
		p.set( "type", Type.enumConstructor( (type==null)?IQType.get:type ) );
		if( id != null ) p.set( "id", id );
		if( x != null ) p.addChild( x.toXml() );
		return p;
	}
	
	public static function parse( x : Xml ) : IQ {
		var iq = new IQ();
		iq.type = Type.createEnum( IQType, x.get( "type" ) );
		Packet.parseAttributes( iq, x );
		for( c in x.elements() ) {
			switch( c.nodeName ) {
			case "error" :
				var e = xmpp.Error.parse( c );
				if( e != null )
					iq.errors.push( e );
			default :
				iq.properties.push( c );
			}
		}
		if( iq.properties.length > 0 ) {
			iq.x = new PlainPacket( iq.properties.shift() );
		}
		return iq;
	}
	
	/**
		Creates a '<query xmlns="namspace"/>' XML tag.
	*/
    public static function createQueryXml( ns : String, name : String = "query" ) : Xml {
		var x = Xml.createElement( name );
		XMUtil.setNamespace( x, ns );
		return x;
	}
	
	/**
		Creates a result type IQ from the given request.
	*/
	public static inline function createResult( iq : IQ ) : IQ {
		return new IQ( IQType.result, iq.id, iq.from, iq.to );
	}
	
	/**
		Creates a error type IQ from the given request.
	*/
	public static function createError( iq : IQ, ?errors : Array<xmpp.Error> ) : IQ {
		var r = new IQ( IQType.error, iq.id, iq.from );
		if( errors != null ) r.errors = errors;
		return r;
	}
	
}
