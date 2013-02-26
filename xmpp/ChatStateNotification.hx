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

using xmpp.XMLUtil;

/**
	XEP-0085: Chat State Notifications: http://xmpp.org/extensions/xep-0085.html
*/
class ChatStateNotification {
	
	public static var XMLNS(default,null) : String = xmpp.Packet.PROTOCOL+"/chatstates";
	
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
		x.ns( XMLNS );
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
