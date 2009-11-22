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
class ChatStateExtension {
	
	public static inline var XMLNS = xmpp.NS.PROTOCOL+"/chatstates";
	
	/**
		Adds (or changes if already has) the chat state property of the givent message packet.
	*/
	public static function set( m : xmpp.Message, state : ChatState ) : xmpp.Message {
		for( p in m.properties ) {
			switch( p.nodeName ) {
			case "active","composing","paused","inactive","gone" :
				m.properties.remove( p );
			}
		}
		m.properties.push( createXml( state ) );
		return m;
	}
	
	/**
		Creates a chat state extension xml.
	*/
	public static inline function createXml( state : ChatState ) : Xml {
		var x = Xml.createElement( Type.enumConstructor( state ) );
		x.set( "xmlns", XMLNS );
		return x;
	}
	
	/**
		Extracts the chat state of the given message.
		Returns null if no state was found.
	*/
	public static function get( m : xmpp.Message ) : xmpp.ChatState {
		for( e in m.properties ) {
			var s = e.nodeName;
			switch( s ) {
			case "active","composing","paused","inactive","gone" :
				return Type.createEnum( xmpp.ChatState, s );
			}
		}
		return null;
	}
	
	/**
	*/
	public static function getString( m : xmpp.Message ) : String {
		for( e in m.properties ) {
			var s = e.nodeName;
			switch( s ) {
			case "active","composing","paused","inactive","gone" : return s;
			}
		}
		return null;
	}
	
}
