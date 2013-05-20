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
	XMPP message packet.
*/
class Message extends xmpp.Packet {
	
	/***/
	public var type : MessageType;
	/***/
	public var body : String;
	/***/
	public var subject : String;
	/***/
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
    	var m = new Message( null, null, null, x.exists( "type" ) ? Type.createEnum( xmpp.MessageType, x.get( "type" ) ) : null );
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
