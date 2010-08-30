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
	<a href="http://xmpp.org/extensions/xep-0085.html">XEP-0085: Chat State Notifications</a><br/>
*/
class ChatStateNotification {
	
	public static var XMLNS = xmpp.Packet.PROTOCOL+"/chatstates";
	
	/**
		Adds (or changes if already has) the chat state property of the givent message packet.
	*/
	public static function set( m : xmpp.Message, state : ChatState ) : xmpp.Message {
		clearChatStateProperty( m );
		m.properties.push( createXML( state ) );
		return m;
	}
	
	/**
		Remove the chat state property from the given message packet.
	*/
	public static function clearChatStateProperty( m : xmpp.Message ) : xmpp.Message  {
		for( p in m.properties ) {
			switch( p.nodeName ) {
			case "active","composing","paused","inactive","gone" :
				m.properties.remove( p );
			}
		}
		return m;
	}
	
	/**
		Creates chat state extension XML.
	*/
	public static function createXML( s : ChatState ) : Xml {
		var x = Xml.createElement( Type.enumConstructor( s ) );
		x.set( "xmlns", XMLNS );
		return x;
	}
	
	/**
		Extracts the chat state of the given message.
	*/
	public static function get( m : xmpp.Message ) : xmpp.ChatState {
		var s = getString( m );
		return ( s == null ) ? null : Type.createEnum( xmpp.ChatState, s );
	}
	
	/**
		Extracts the chat state of the given message as string.
	*/
	public static function getString( m : xmpp.Message ) : String {
		for( e in m.properties ) {
			var s = e.nodeName;
			switch( s ) {
			case "active","composing","paused","inactive","gone" :
				return s;
			}
		}
		return null;
	}
	
}
