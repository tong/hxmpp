/*
 *	This file is part of HXMPP.
 *	Copyright (c)2010 http://www.disktree.net
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
package;

import neko.Lib;

class XMPPAccountRegisterUtil {
	
	public static function run( cb : String->Void,
								server : String, node : String, pass : String,
								?email : String, ?name : String,
								?ip : String ) {
		var _ip = ( ip != null ) ? ip : server;
		var cnx = new jabber.SocketConnection( _ip );
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			var acc = new jabber.client.Account( stream );
			acc.onRegister = function( node : String ) {
				stream.close( true );
				neko.Sys.exit( 0 );
			}
			acc.onError = function( e ) {
				Lib.println( e );
				stream.close( true );
				neko.Sys.exit( 0 );
			}
			acc.register( new xmpp.Register( node, pass, email, name ) );
		}
		stream.onClose = function(?e) {
			if( e != null ) {
				cb( "XMPP stream error: "+e );
			}
		}
		stream.open( null );
	}
}
