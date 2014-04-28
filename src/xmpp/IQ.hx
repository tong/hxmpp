/*
 * Copyright (c) disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package xmpp;

/**
	InfoQuery XMPP packet

	Info/Query, or IQ, is a "request-response" mechanism, similar in some ways to the Hypertext Transfer Protocol [HTTP].
	The semantics of IQ enable an entity to make a request of, and receive a response from, another entity.
	The data content of the request and response is defined by the schema or other structural definition associated with
	the XML namespace that qualifies the direct child element of the IQ element, and the interaction is tracked by the
	requesting entity through use of the 'id' attribute.
	Thus, IQ interactions follow a common pattern of structured data exchange such as get/result or set/result (although
	an error can be returned in reply to a request if appropriate)

	Requesting                  Responding
	  Entity                      Entity
	----------                  ----------
	    |                            |
	    | <iq id='1' type='get'>     |
	    |   [ ... payload ... ]      |
	    | </iq>                      |
	    | -------------------------> |
	    |                            |
	    | <iq id='1' type='result'>  |
	    |   [ ... payload ... ]      |
	    | </iq>                      |
	    | <------------------------- |
	    |                            |
	    | <iq id='2' type='set'>     |
	    |   [ ... payload ... ]      |
	    | </iq>                      |
	    | -------------------------> |
	    |                            |
	    | <iq id='2' type='error'>   |
	    |   [ ... condition ... ]    |
	    | </iq>                      |
	    | <------------------------- |
	    |                            |

*/
class IQ extends Packet {
	
	/** Either: get/set/result/error */
	public var type : IQType;
	
	/** The exclusive child (mostly '<query xmlns="ext-namspace"/>') */
	public var x : PacketElement;
	
	public function new( ?type : IQType, ?id : String, ?to : String, ?from : String ) {
		super( to, from, id );
		this.type = ( type != null ) ? type : xmpp.IQType.get;
		_type = xmpp.PacketType.iq;
	}
	
	public override function toXml(): Xml {
		var p = super.addAttributes( Xml.createElement( "iq" ) );
		p.set( "type", Std.string( (type == null) ? IQType.get : type ) );
		if( id != null ) p.set( "id", id );
		if( x != null ) p.addChild( x.toXml() );
		return p;
	}
	
	public static function parse( x : Xml ) : IQ {
		var iq = new IQ();
		iq.type = haxe.EnumTools.createByName( IQType, x.get( "type" ) );
		Packet.parseAttributes( iq, x );
		for( c in x.elements() ) {
			switch c.nodeName {
			case "error" :
				var e = xmpp.Error.parse( c );
				if( e != null ) iq.errors.push( e );
			default :
				iq.properties.push( c );
			}
		}
		if( iq.properties.length > 0 )
			iq.x = new PlainPacket( iq.properties.shift() );
		return iq;
	}
	
	/**
		Creates a '<query xmlns="namespace"/>' XML tag
	*/
    public static inline function createQueryXml( ns : String, name : String = "query" ) : Xml {
		return XMLUtil.setNamespace( Xml.createElement( name ), ns );
	}

	/**
		Create a IQ request packet
	*/
	public static inline function createRequest( jid : String, x : PacketElement ) : IQ {
		var iq = new IQ( null, null, jid );
		iq.x = x;
		return iq;
	}
	
	/**
		Creates IQ result response packet of given iq-request
	*/
	//public static inline function createResult( r : IQ, ?from : String ) : IQ {
		//return new IQ( result, r.id, r.from, from );
	public static inline function createResult( r : IQ, ?x : PacketElement, ?from : String ) : IQ {
		var r = new IQ( result, r.id, r.from, from );
		r.x = x;
		return r;
	}

	/**
		Creates a error type IQ packet from given request
	*/
	public static function createError( iq : IQ, ?errors : Array<xmpp.Error>, ?from : String ) : IQ {
		var r = new IQ( IQType.error, iq.id, iq.from, from );
		if( errors != null ) r.errors = errors;
		return r;
	}
	
}
