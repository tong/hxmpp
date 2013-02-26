/*
 * Copyright (c) 2012, disktree.net
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
	RFC-3921 - Instant Messaging and Presence: http://xmpp.org/rfcs/rfc3921.html
	Exchanging Presence Information: http://www.xmpp.org/rfcs/rfc3921.html#presence
*/
class Presence extends xmpp.Packet {
	
	public static inline var MAX_STATUS_SIZE = 1023;
	
	public var type : PresenceType;
   	public var show : PresenceShow;
    public var status(default,set_status) : String;
    public var priority : Null<Int>;
    
	public function new( ?show : PresenceShow, ?status : String, ?priority : Int, ?type : PresenceType ) {
		super();
		_type = xmpp.PacketType.presence;
		this.show = show;
		this.status = status;
		this.priority = priority;
		this.type = type;
	}
	
	function set_status( s : String ) : String {
		return status = ( ( s == null || s == "" ) ?
			null :
			( s.length > MAX_STATUS_SIZE ) ? s.substr( 0, MAX_STATUS_SIZE ) : s );
	}
	
	public override function toXml() : Xml {
		var x = super.addAttributes( Xml.createElement( "presence" ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( show != null ) x.addChild( XMLUtil.createElement( "show", Type.enumConstructor( show ) ) );
		if( status != null ) x.addChild( XMLUtil.createElement( "status", status ) );
		if( priority != null ) x.addChild( XMLUtil.createElement( "priority", Std.string( priority ) ) );
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
			case "show" :
				if( fc != null ) p.show = Type.createEnum( PresenceShow, fc.nodeValue );
			case "status" :
				if( fc != null ) p.status =  fc.nodeValue;
			case "priority" :
				if( fc != null ) p.priority = Std.parseInt( fc.nodeValue );
			case "error" :
				p.errors.push( xmpp.Error.parse( c ) );
			default :
				p.properties.push( c );
			}
		}
		return p;
	}
	
	//public static function showOfString() : PresenceShow {
	
}
