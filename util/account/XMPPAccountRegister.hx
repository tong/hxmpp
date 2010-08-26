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
import jabber.JIDUtil;

/**
	Tool for registering a new XMPP client account.
	Intended to get called programmatically from another process.
*/
class XMPPAccountRegister {
	
	static function main() {
		var args = neko.Sys.args();
		if( args.length < 3 || args.length > 6 ) {
			Lib.println( "Invalid length of arguments ("+args.length+")" );
			neko.Sys.exit( 1 );
		}
		if( !JIDUtil.isValid( args[0] ) ) {
			Lib.println( "Invalid JID ("+args[0]+")" );
			neko.Sys.exit( 1 );	
		}
		var jid = new jabber.JID( args[0] );
		var pass = args[1];
		if( pass.length < 4 ) {
			Lib.println( "Password too weak .. use 4 tokens at least!" );
			neko.Sys.exit( 1 );	
		}
		var email = args[2];
		if( email != null ) {
			if( !~/[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?/i.match( email ) ) {
				Lib.println( "Invalid email" );
				neko.Sys.exit( 1 );	
			}
		}
		var name = args[3];
		var ip = args[4];
		XMPPAccountRegisterUtil.run( function(err:String){
			if( err != null ) {
				Lib.println( "Failed to register account: "+err );
				neko.Sys.exit( 1 );	
			}
			Lib.println( "Account successfully registered ["+jid.toString()+"]" );
			neko.Sys.exit( 0 );
		}, jid.domain, jid.node, pass, email, name, ip );
	}
	
}
