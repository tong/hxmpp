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
package xmpp.file;

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
		this.streamhosts = ( streamhosts != null ) ? streamhosts : new Array();
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
		if( mode != null ) x.set( "mode", Type.enumConstructor( mode ) );
		if( activate != null ) x.addChild( xmpp.XMLUtil.createElement( "activate", activate ) );
		return x;
	}
	
	public static function parse( x : Xml ) : ByteStream {
		var b = new ByteStream( x.get( "sid" ) );
		if( x.exists( "mode" ) ) b.mode = Type.createEnum( ByteStreamMode, x.get( "mode" ) );
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
