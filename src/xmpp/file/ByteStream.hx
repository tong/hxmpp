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
package xmpp.file;

using xmpp.XMLUtil;

class ByteStream {
	
	public static var XMLNS = xmpp.Packet.PROTOCOL+"/bytestreams";
	
	public var sid : String;
	public var mode : ByteStreamMode;
	public var streamhosts : Array<ByteStreamHost>;
	public var streamhost_used : String;
	public var activate : String;
	
	public function new( sid : String,
						 ?streamhosts : Array<ByteStreamHost>, ?mode : ByteStreamMode ) {
		this.sid = sid;
		this.streamhosts = (streamhosts != null) ? streamhosts : new Array();
		this.mode = mode;
	}
	
	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		x.set( "sid", sid );
		for( h in streamhosts ) x.addChild( h.toXml() );
		if( streamhost_used != null ) {
			var e = Xml.createElement( "streamhost-used" );
			e.set( "jid", streamhost_used );
			x.addChild( e );
		}
		if( mode != null ) x.set( "mode", Std.string( mode ) );
		x.addField( this, 'activate' );
		return x;
	}
	
	public static function parse( x : Xml ) : ByteStream {
		var b = new ByteStream( x.get( "sid" ) );
		b.mode = cast x.get( "mode" );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "streamhost-used" :
				b.streamhost_used = e.get( "jid" );
				break;
			case "activate" :
				b.activate = e.firstChild().nodeValue;
				break;
			case "streamhost" :
				b.streamhosts.push( ByteStreamHost.parse( e ) );
			}
		}
		return b;
	}
	
}
