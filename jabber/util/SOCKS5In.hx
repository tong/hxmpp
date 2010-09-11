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
package jabber.util;

#if (neko||cpp)
import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;

/**
	<a href="http://www.faqs.org/rfcs/rfc1928.html">RFC 1928</a>
	This is not a complete implementation of the SOCKS5 protocol,<br/>
	just a subset fulfilling requirements in context of XMPP (datatransfers).
*/
class SOCKS5In {
	
	/**
		SOCKS5 negotiation for incoming socket connections.
		Returns true on negotiation success.
	*/
	public static function process( i : Input, o : Output, digest : String, ip : String, port : Int ) : Bool {

		trace( i.readByte() ); // 5 version
		var n = i.readByte(); // num auth methods
		trace( n );
		for( _ in 0...n ) trace( i.readByte() );
		
		o.writeByte( 5 );
		o.writeByte( 0 );
		
		trace( i.readByte() );
		trace( i.readByte() );
		trace( i.readByte() );
		trace( i.readByte() );
		var len = i.readByte();
		trace( len );
		var _digest = i.readString( len );
		trace( _digest );
		if( _digest != digest ) {
			trace( "Digest dos not match" );
			return false;
		}
		trace( i.readInt16() );
		
		o.writeByte( 5 );
		o.writeByte( 0 );
		o.writeByte( 0 );
		o.writeByte( 3 );
		
		o.writeByte( ip.length );
		o.writeString( ip );
		o.writeInt16( port );
		
		return true;
	}
}

#end
