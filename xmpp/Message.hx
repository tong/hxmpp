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
	XMPP message packet.<br/>
*/
class Message extends xmpp.Packet {
	
	public var type : MessageType;
	public var body : String;
	public var subject : String;
    public var thread : String;
	
    public function new( ?to : String, ?body : String, ?subject : String,
    					 ?type : MessageType, ?thread : String, ?from : String ) {
		_type = xmpp.PacketType.message;
		super( to, from );
		this.type = if ( type != null ) type else xmpp.MessageType.chat;
		this.body = body;
		this.subject = subject;
		this.thread = thread;
	}
    
    public override function toXml() : Xml {
    	var x = super.addAttributes( Xml.createElement( "message" ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( subject != null ) x.addChild( XMLUtil.createElement( "subject", subject ) );
		if( body != null ) x.addChild( XMLUtil.createElement( "body", body ) );
		if( thread != null ) x.addChild( XMLUtil.createElement( "thread", thread ) );
		for( p in properties ) x.addChild( p );
		return x;
    }
    
    public static function parse( x : Xml ) : xmpp.Message {
    	var m = new Message( null, null, null, if( x.exists( "type" ) ) Type.createEnum( xmpp.MessageType, x.get( "type" ) ) );
   		xmpp.Packet.parseAttributes( m, x );
   		for( c in x.elements() ) {
			switch( c.nodeName ) {
			case "subject" : m.subject = c.firstChild().nodeValue;
			case "body" : m.body = c.firstChild().nodeValue;
			case "thread" : m.thread = c.firstChild().nodeValue;
			default : m.properties.push( c );
			}
		}
   		return m;
	}
    
}
