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
	
	public static inline var XMLNS = xmpp.Namespace.PROTOCOL+"/bytestreams";
	
	public var sid : String;
	public var mode : String; //ByteStreamMode;
	public var streamhosts : Array<ByteStreamHost>;
	public var streamhost_used : String;
	public var activate : String;
	
	public function new( ?sid : String, ?mode : String = "tcp", ?streamhosts : Array<ByteStreamHost> ) {
		this.sid = sid;
		this.mode = mode;
		this.streamhosts = ( streamhosts != null ) ? streamhosts : new Array();
	}
	
	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( sid != null ) x.set( "sid", sid );
		if( mode != null ) x.set( "mode", mode );
		for( sh in streamhosts )
			x.addChild( sh.toXml() );
		if( streamhost_used != null ) {
			var e = Xml.createElement( "streamhost-used" );
			e.set( "jid", streamhost_used );
			x.addChild( e );
		}
		if( activate != null ) {
			var e = Xml.createElement( "activate" );
			e.set( "jid", activate );
			x.addChild( e );
		}
//		x.addChild( Xml.parse('<fast xmlns="http://affinix.com/jabber/stream"/>') );
		return x;
	}
	
	public static function parse( x : Xml ) : ByteStream {
		var b = new ByteStream();
		b.sid = x.get( "sid" );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "streamhost" :
				b.streamhosts.push( ByteStreamHost.parse( e ) );
			case "streamhost-used" :
				b.streamhost_used = e.get( "jid" );
				break;
			}
		}
		// TODO.....
		//..........
		return b;
	}
	
}
