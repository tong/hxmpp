/*
 * Copyright (c), disktree.net
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
	Four elements, which provide insights into a human users availbility for and interest in communication.
*/
@:enum abstract PresenceShow(String) {
	
	/** Especially socialable */
	var chat = "chat";

	/** Away from device */
	var away = "away";
	
	/** Extended Away */
	var xa = "xa";

	/** Busy */
	var dnd = "dnd";
}

@:enum abstract PresenceType(String) {
	var error = "error";
	var probe = "probe";
	var subscribe = "subscribe";
	var subscribed = "subscribed";
	var unavailable = "unavailable";
	var unsubscribe = "unsubscribe";
	var unsubscribed = "unsubscribed";
}

/**
	RFC-3921 - Instant Messaging and Presence: http://xmpp.org/rfcs/rfc3921.html
	Exchanging Presence Information: http://www.xmpp.org/rfcs/rfc3921.html#presence
*/
class Presence extends xmpp.Packet {

	public var type : PresenceType;
	public var show : PresenceShow;
	public var status : String;
	public var priority : Null<Int>;

	public function new( ?show : PresenceShow, ?status : String, ?priority : Int, ?type : PresenceType ) {
		
		super();

		_type = presence;

		this.show = show;
		this.status = status;
		this.priority = priority;
		this.type = type;
	}

	public override function toXml() : Xml {
		var x = super.addAttributes( Xml.createElement( "presence" ) );
		if( type != null ) x.set( "type", Std.string( type ) );
		if( show != null ) x.addChild( XMLUtil.createElement( "show", Std.string( show ) ) );
		if( status != null && status != "" ) x.addChild( XMLUtil.createElement( "status", status ) );
		if( priority != null ) x.addChild( XMLUtil.createElement( "priority", Std.string( priority ) ) );
		return x;
	}

	public static function parse( x : Xml ) : Presence {
		var p = new Presence( x.get( "type" ) );
		Packet.parseAttributes( p, x );
		//if( x.exists( "type" ) ) p.type = Type.createEnum( PresenceType, x.get( "type" ) );
		if( x.exists( "type" ) ) p.type = cast x.get( "type" );
		for( c in x.elements() ) {
			var fc = c.firstChild();
			switch c.nodeName {
			case "show" : p.show = cast fc.nodeValue;
			case "status" : p.status =  fc.nodeValue;
			case "priority" : if( fc != null ) p.priority = Std.parseInt( fc.nodeValue );
			case "error" : p.errors.push( xmpp.Error.parse( c ) );
			default : p.properties.push( c );
			}
		}
		return p;
	}

}
