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
