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

#if neko
import neko.Sys;
#elseif cpp
import cpp.Sys;
#elseif php
import php.Sys;
#elseif (nodejs||rhino)
import js.Sys;
#end

class SystemUtil {
	
	/**
		Returns the name of the OS used.
	*/
	public static #if !js inline #end function systemName() : String {
		
		#if (neko||cpp||php||nodejs||rhino)
		return Sys.systemName();
		
		#elseif flash
		return flash.system.Capabilities.os;
		
		#elseif js
		var t  = js.Lib.window.navigator.appVersion;
		t = t.substr( t.indexOf("(")+1, t.indexOf(")")-3 );
		return if( t.indexOf( "Linux" ) != -1 ) "Linux";
		else if( t.indexOf( "Macintosh" ) != -1 ) "Macintosh";
		else if( t.indexOf( "Windows" ) != -1 ) "Windows";
		else null;
		
		#end
	}
	
}
