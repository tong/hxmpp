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

/**
	Terminal tool to manually register a new XMPP client account.
*/
class NewXMPPAccount {
	
	static function getUserInput( ?message : String ) : String {
		if( message != null ) Lib.print( message+"> " );
		return neko.io.File.stdin().readLine();
	}
	
	static function getServername() : String {
		var name = getUserInput( "server" );
		if( !~/[A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?/i.match( name ) ) {
			Lib.println( "Invalid server name" );
			getServername();
		}
		return name;
	}
	
	static function getUsername() : String {
		var node = getUserInput( "username" );
		if( node.length < 3 ) {
			Lib.println( "Too short" );
			getUsername();
		}
		return node;
	}
	
	static function getPassword() : String {
		var pass = getUserInput( "password" );
		if( pass.length < 4 ) {
			Lib.println( "Too short .. length of 4 at least" );
			getPassword();
		} else if( pass.length < 5 ) {
			Lib.println( "Warning, weak password!" );
		}
		return pass;
	}
	
	static function getName() : String {
		var name = getUserInput( "name [blank to use the node name]" );
		if( name.length == 0 ) {
			return null;
		} 
		return name;
	}
	
	static function getEmail() : String {
		var email = getUserInput( "email" );
		if( !~/[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?/i.match( email ) ) {
			Lib.println( "Invalid email" );
			getEmail();
		}
		return email;
	}
	
	static function main() {
		
		Lib.println( "Enter your credentials:" );
		
		var server = getServername();
		var node = getUsername();
		var pass = getPassword();
		var name = getName();
		if( name == null ) name = node;
		var email = getEmail();
		
		Lib.println( "********************************************************************" );
		Lib.println( "       JID: "+node+"@"+server );
		Lib.println( "  Password: "+pass );
		Lib.println( "      Name: "+name );
		Lib.println( "     Email: "+email );
		Lib.println( "********************************************************************" );
		
		var r = getUserInput( "Register this account? [y/n]" );
		switch( r ) {
		case "y","Y" :
			Lib.println( "Registering ..." );
			var cnx = new jabber.SocketConnection( server );
			var stream = new jabber.client.Stream( cnx );
			stream.onOpen = function() {
				var acc = new jabber.client.Account( stream );
				acc.onRegister = function( node : String ) {
					Lib.println( "Account registration success ["+node+"@"+server+"]" );
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
				if( e != null )
					Lib.println( "XMPP stream error: "+e );
			}
			stream.open( null );
		default :
			Lib.println( "Aborted." );
		}
	}
	
}
