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
		#if (neko||cpp||php||nodejs)
		return Sys.systemName();
		#elseif flash
		return flash.system.Capabilities.os;
		#elseif js
		var os = js.Lib.window.navigator.appVersion;
		return switch( os ) {
		case "X11","Linux" : "Linux";
		default : os;
		}
		#end
	}
	
}
